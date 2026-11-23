#!/usr/bin/env python3
"""slice-check: read a sliced Bambu .gcode.3mf (or a plain .gcode) and fail loudly
on mistakes that ruin a print no matter how good the model is.

Built after the bunk storage trays (2026-11-19): the small tray was placed 10 mm
above the bed beside a taller one, printed into thin air, and spaghettied.

Checks (FAIL stops the print, WARN needs a look, INFO is for the record):
  floating  every new island of extrusion must sit on the bed or on what was
            printed the layer before; an island with nothing under it FAILs
  bed       the plate type is the expected one (Textured PEI by default) and
            its bed temperature suits the filament (PLA 45-65 C)
  bounds    all printed moves stay on the printable area and under the height
            limit, and the first layer stays out of the front-left keep-out
  stale     (with --sources) no source file is newer than the slice
  objects   (with --expect-objects N) the slice holds N parts
  summary   filaments, colors, grams, time, swaps, supports (INFO)

  python3 slice_check.py plate.gcode.3mf [more ...] [--bed "Textured PEI Plate"]
      [--sources a.stl b.scad] [--expect-objects N] [--json report.json]

Exit code 1 if anything FAILs.
"""
import argparse, json, math, os, re, sys, zipfile
import numpy as np
from scipy import ndimage

CELL = 1.0          # mm per grid cell
REACH = 2           # cells an island may step past the layer below (overhangs, bridges' ends)
MIN_ISLAND = 4      # cells; smaller specks (a stray dab) are ignored
GAP_MM = 0.4        # an island may sit on print up to this far below it: a 0.2 mm layer plus the one-layer support gap
PLA_BED = (45, 65)


class Report:
    def __init__(self, name):
        self.name, self.rows = name, []

    def add(self, level, check, msg):
        self.rows.append({"level": level, "check": check, "msg": msg})

    @property
    def failed(self):
        return any(r["level"] == "FAIL" for r in self.rows)


def read_gcode(path):
    if path.endswith(".3mf"):
        with zipfile.ZipFile(path) as z:
            names = [n for n in z.namelist() if re.match(r"Metadata/plate_\d+\.gcode$", n)]
            if not names:
                raise SystemExit(f"{path}: no plate gcode inside (was it sliced?)")
            g = {n: z.read(n).decode("utf-8", "replace") for n in names}
            info = z.read("Metadata/slice_info.config").decode() if "Metadata/slice_info.config" in z.namelist() else ""
            objs = []
            if "Metadata/model_settings.config" in z.namelist():
                ms = z.read("Metadata/model_settings.config").decode()
                # count printable parts: the plate tool packs a plate into one assembled object
                objs = re.findall(r'<part id="\d+" subtype="normal_part"[^>]*>\s*<metadata key="name" value="([^"]*)"', ms)
            return g, info, objs
    return {"plate": open(path, encoding="utf-8", errors="replace").read()}, "", []


def settings(text):
    s = {}
    for m in re.finditer(r"^; (\w+) = (.*)$", text, re.M):
        s.setdefault(m.group(1), m.group(2).strip())
    return s


def walk(text):
    """Yield (z, x0, y0, x1, y1, feature) for every extruding move in the print body,
    skipping the start/end gcode and filament-change (flush) blocks."""
    body = text
    a = text.find("; MACHINE_START_GCODE_END"); b = text.find("; MACHINE_END_GCODE_START")
    if a >= 0: body = text[a: b if b > a else None]
    x = y = z = 0.0; rel = True; feat = None; in_change = False; e_abs = 0.0
    for line in body.splitlines():
        if line.startswith(";"):
            if line.startswith("; Z_HEIGHT:"): z = float(line.split(":")[1])
            elif line.startswith("; FEATURE:"): feat = line.split(":", 1)[1].strip()
            continue
        c = line.split(";", 1)[0].strip()
        if not c: continue
        if c.startswith("M83"): rel = True; continue
        if c.startswith("M82"): rel = False; continue
        if c.startswith("M620 S") and not c.startswith("M620 S255"): in_change = True; continue
        if c.startswith("M621 S"): in_change = False; continue
        if c.startswith("G92"):
            m = re.search(r"E([-\d.]+)", c)
            if m: e_abs = float(m.group(1))
            continue
        if not c.startswith(("G0", "G1", "G2", "G3")): continue
        nx, ny = x, y
        m = re.search(r"X([-\d.]+)", c); nx = float(m.group(1)) if m else x
        m = re.search(r"Y([-\d.]+)", c); ny = float(m.group(1)) if m else y
        m = re.search(r"E([-\d.]+)", c)
        de = 0.0
        if m:
            v = float(m.group(1)); de = v if rel else v - e_abs; e_abs = v if not rel else e_abs
        if de > 0 and not in_change and feat and (nx != x or ny != y):
            yield z, x, y, nx, ny, feat
        x, y = nx, ny


def raster(segs, shape):
    g = np.zeros(shape, bool)
    for x0, y0, x1, y1 in segs:
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / (CELL / 2)))
        t = np.linspace(0, 1, n + 1)
        xi = np.clip(((x0 + (x1 - x0) * t) / CELL).astype(int), 0, shape[0] - 1)
        yi = np.clip(((y0 + (y1 - y0) * t) / CELL).astype(int), 0, shape[1] - 1)
        g[xi, yi] = True
    return g


def check_plate(name, text, info, objs, args, rep):
    s = settings(text)
    # ---- bed ----
    bed = s.get("curr_bed_type", "?")
    if args.bed and bed != args.bed:
        rep.add("FAIL", "bed", f"plate type is '{bed}', expected '{args.bed}'")
    else:
        rep.add("PASS", "bed", f"plate type '{bed}'")
    key = {"Textured PEI Plate": "textured_plate_temp", "Cool Plate": "cool_plate_temp",
           "Engineering Plate": "eng_plate_temp", "High Temp Plate": "hot_plate_temp"}.get(bed)
    ftypes = s.get("filament_type", "").split(";")
    if key and key in s:
        temps = [float(v) for v in s[key].split(",") if v]
        for ft, t in zip(ftypes, temps):
            if ft.strip().upper().startswith("PLA") and not (PLA_BED[0] <= t <= PLA_BED[1]):
                rep.add("FAIL", "bed", f"{ft} on {bed} at {t:.0f} C; PLA wants {PLA_BED[0]}-{PLA_BED[1]} C")
            else:
                rep.add("PASS", "bed", f"{ft} bed {t:.0f} C")
    # ---- walk the moves ----
    area = [tuple(map(float, p.split("x"))) for p in s.get("printable_area", "0x0,256x0,256x256,0x256").split(",")]
    ax0, ay0 = min(p[0] for p in area), min(p[1] for p in area)
    ax1, ay1 = max(p[0] for p in area), max(p[1] for p in area)
    hmax = float(s.get("printable_height", "250"))
    excl = [tuple(map(float, p.split("x"))) for p in s.get("bed_exclude_area", "").split(",") if "x" in p]
    ex = (min(p[0] for p in excl), min(p[1] for p in excl), max(p[0] for p in excl), max(p[1] for p in excl)) if excl else None
    shape = (int(ax1 / CELL) + 2, int(ay1 / CELL) + 2)
    layers = {}; out = []; in_excl = []; ztop = 0.0
    for z, x0, y0, x1, y1, feat in walk(text):
        layers.setdefault(round(z, 3), []).append((x0, y0, x1, y1))
        ztop = max(ztop, z)
        for px, py in ((x0, y0), (x1, y1)):
            if not (ax0 - 0.5 <= px <= ax1 + 0.5 and ay0 - 0.5 <= py <= ay1 + 0.5):
                out.append((round(px, 1), round(py, 1), z))
    if not layers:
        rep.add("FAIL", "floating", "no extrusion found in the print body"); return
    zs = sorted(layers)
    first = zs[0]
    for x0, y0, x1, y1 in layers[first]:
        if ex and any(ex[0] <= px <= ex[2] and ex[1] <= py <= ex[3] for px, py in ((x0, y0), (x1, y1))):
            in_excl.append((round(x0, 1), round(y0, 1)))
    if out: rep.add("FAIL", "bounds", f"{len(out)} moves off the printable area, e.g. {out[0]}")
    if ztop > hmax: rep.add("FAIL", "bounds", f"prints to {ztop:.1f} mm, over the {hmax:.0f} mm limit")
    if in_excl: rep.add("FAIL", "bounds", f"first layer enters the front-left keep-out at {in_excl[0]}")
    if not (out or ztop > hmax or in_excl):
        rep.add("PASS", "bounds", f"on the plate, {ztop:.1f} mm tall, keep-out clear")
    # ---- floating islands ----
    floats = []; below = []   # (z, occupancy) of recent printed layers
    st = np.ones((3, 3), bool)
    for z in zs:
        cur = raster(layers[z], shape)
        if below:
            lab, n = ndimage.label(ndimage.binary_dilation(cur, st), structure=st)
            # what's printed up to GAP_MM below: slicers leave a one-layer air gap between a part's top surface and the support
            # built on it, so the support snaps off (support bottom z distance). Anything higher up than that is in mid-air.
            near = [occ for zb, occ in below if z - zb <= GAP_MM + 1e-6]
            under = ndimage.binary_dilation(np.logical_or.reduce(near), st, iterations=REACH) if near else np.zeros_like(cur)
            for k in range(1, n + 1):
                isl = (lab == k) & cur
                cells = int(isl.sum())
                if cells < MIN_ISLAND or (isl & under).any(): continue
                xs, ys = np.nonzero(isl)
                floats.append((z, cells, xs.min() * CELL, ys.min() * CELL, xs.max() * CELL, ys.max() * CELL))
        below = [(zb, occ) for zb, occ in below if z - zb <= GAP_MM] + [(z, cur)]
    if floats:
        big = sorted(floats, key=lambda f: -f[1])[:3]
        for z, cells, x0, y0, x1, y1 in big:
            rep.add("FAIL", "floating", f"{cells} mm2 of print starts at z {z:.2f} with nothing under it, "
                    f"around X {x0:.0f}-{x1:.0f} Y {y0:.0f}-{y1:.0f} (a part off the bed, or an unsupported overhang)")
        if len(floats) > 3: rep.add("FAIL", "floating", f"{len(floats) - 3} more floating islands")
    else:
        lab, n = ndimage.label(ndimage.binary_dilation(raster(layers[first], shape), st, iterations=2), structure=st)
        rep.add("PASS", "floating", f"every island sits on the bed or the layer below ({n} on the first layer, {len(zs)} layers)")
    # ---- objects ----
    if args.expect_objects is not None:
        got = len(objs) if objs else None
        if got is None:
            rep.add("WARN", "objects", "couldn't read the object list")
        elif got != args.expect_objects:
            rep.add("FAIL", "objects", f"{got} parts in the slice, expected {args.expect_objects}: {objs}")
        else:
            rep.add("PASS", "objects", f"{got} parts: {objs}")
    # ---- summary ----
    fils = re.findall(r'<filament id="(\d+)"[^>]*type="([^"]*)" color="([^"]*)"[^>]*used_g="([^"]*)"', info)
    pred = re.search(r'key="prediction" value="(\d+)"', info)
    a = text.find("; MACHINE_START_GCODE_END")
    swaps = len(re.findall(r"^M620 S\d+A", text[a if a >= 0 else 0:], re.M))
    sup = s.get("enable_support", "?") == "1"
    t = int(pred.group(1)) if pred else 0
    rep.add("INFO", "summary", f"{' + '.join(f'{ty} {c} {float(g):.1f} g' for _, ty, c, g in fils) or '?'}; "
            f"{t // 3600}h{t % 3600 // 60:02d}m; {swaps} swaps; supports "
            f"{s.get('support_type', '') if sup else 'off'}")


def check(path, args):
    rep = Report(path)
    g, info, objs = read_gcode(path)
    if args.sources:
        mt = os.path.getmtime(path)
        newer = [p for p in args.sources if os.path.exists(p) and os.path.getmtime(p) > mt + 1]
        missing = [p for p in args.sources if not os.path.exists(p)]
        if newer: rep.add("FAIL", "stale", f"changed after this slice: {', '.join(os.path.basename(p) for p in newer)}")
        elif missing: rep.add("WARN", "stale", f"sources not found: {missing}")
        else: rep.add("PASS", "stale", f"slice is newer than its {len(args.sources)} sources")
    for name, text in g.items():
        check_plate(name, text, info, objs, args, rep)
    return rep


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("files", nargs="+")
    ap.add_argument("--bed", default="Textured PEI Plate", help="expected plate type ('' to skip)")
    ap.add_argument("--sources", nargs="*", default=[])
    ap.add_argument("--expect-objects", type=int)
    ap.add_argument("--json")
    a = ap.parse_args(argv)
    reps = [check(f, a) for f in a.files]
    for r in reps:
        print(f"== {r.name}")
        for row in r.rows:
            print(f"{row['level']:5} {row['check']}: {row['msg']}")
    n = {k: sum(row["level"] == k for r in reps for row in r.rows) for k in ("PASS", "WARN", "FAIL")}
    print(f"\n{n['PASS']} pass, {n['WARN']} warn, {n['FAIL']} fail")
    if a.json:
        json.dump([{"file": r.name, "rows": r.rows} for r in reps], open(a.json, "w"), indent=1)
    return 1 if n["FAIL"] else 0


if __name__ == "__main__":
    sys.exit(main())
