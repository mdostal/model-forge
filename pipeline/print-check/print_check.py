#!/usr/bin/env python3
"""print-check: catch design mistakes before a part gets printed.

Run it on a project's checks.yaml:

    python3 pipeline/print-check/print_check.py projects/<name>/checks.yaml

Every part is exported from its OpenSCAD file (cached by content), then
three kinds of checks run and each prints PASS, WARN or FAIL with a plain
explanation. The exit code is 1 when anything FAILs.

retention  For a part that mounts onto another (a holder on a clip, a clip
           on a bed rail), slide the mounted part a little in each of the
           six directions and see which ways it can move freely. Any
           direction listed under `loads` (for example -z: gravity, a cup
           dropped in) must be blocked, or the part can be knocked off by
           ordinary use. The free directions are how it goes on and off;
           `install` says which one you meant, and anything else free is
           reported.

seat       Lower a reference object (a glass, a sippy cup: a solid of
           revolution given by its base width, top width and height) into
           a receptacle and report where it comes to rest, whether its flat
           bottom sits on a flat floor or it is wedged on a slope or rim,
           and how far it stands above the rim.

printability  Watertight, number of separate bodies, steep overhangs that
           would need supports (faces facing down more than 45 degrees,
           above the bed) and flat bridges with their span.
"""
import argparse, hashlib, json, math, os, re, subprocess, sys

import numpy as np
import trimesh
import yaml

DIRS = {"+x": (1, 0, 0), "-x": (-1, 0, 0), "+y": (0, 1, 0), "-y": (0, -1, 0), "+z": (0, 0, 1), "-z": (0, 0, -1)}
LOAD_WORDS = {"-z": "gravity / something dropped in or pressed down", "+z": "lifted or bumped from below",
              "+y": "pulled away from what it hangs on", "-y": "pushed toward what it hangs on",
              "+x": "pushed along +x", "-x": "pushed along -x"}


class Report:
    def __init__(self):
        self.rows = []

    def add(self, level, check, msg, data=None):
        self.rows.append({"level": level, "check": check, "msg": msg, **({"data": data} if data else {})})
        print(f"{level:5} {check}: {msg}", flush=True)

    @property
    def failed(self):
        return any(r["level"] == "FAIL" for r in self.rows)


# ---------- OpenSCAD export with a content cache ----------

def openscad_bin():
    return os.environ.get("OPENSCAD", "openscad")


def scad_deps(path, seen=None):
    seen = seen if seen is not None else set()
    path = os.path.abspath(path)
    if path in seen or not os.path.exists(path):
        return seen
    seen.add(path)
    for m in re.finditer(r"^\s*(?:use|include)\s*<([^>]+)>", open(path).read(), re.M):
        scad_deps(os.path.join(os.path.dirname(path), m.group(1)), seen)
    return seen


def export(spec, base, cache):
    """spec: {scad, part?, define?: {name: value}} -> (mesh, echoes)."""
    scad = os.path.join(base, spec["scad"])
    defines = dict(spec.get("define", {}))
    if "part" in spec:
        defines["part"] = spec["part"]
    h = hashlib.sha1()
    for d in sorted(scad_deps(scad)):
        h.update(d.encode()); h.update(open(d, "rb").read())
    h.update(json.dumps(defines, sort_keys=True).encode())
    key = h.hexdigest()[:16]
    os.makedirs(cache, exist_ok=True)
    stl, log = f"{cache}/{key}.stl", f"{cache}/{key}.log"
    if not os.path.exists(stl):
        args = [openscad_bin(), "-o", stl]
        for k, v in defines.items():
            args += ["-D", f"{k}={json.dumps(v) if isinstance(v, str) else v}"]
        r = subprocess.run(args + [scad], capture_output=True, text=True)
        open(log, "w").write(r.stdout + r.stderr)
        if r.returncode != 0 or not os.path.exists(stl):
            raise RuntimeError(f"OpenSCAD failed on {spec}:\n{r.stderr[-2000:]}")
    echoes = {}
    for m in re.finditer(r'ECHO: (\w+) = (.+)', open(log).read()):
        try:
            echoes[m.group(1)] = json.loads(m.group(2))
        except ValueError:
            echoes[m.group(1)] = m.group(2)
    return trimesh.load(stl, force="mesh"), echoes


# ---------- retention ----------

def to_manifold(mesh):
    import manifold3d as mf
    return mf.Manifold(mf.Mesh(vert_properties=np.asarray(mesh.vertices, np.float32),
                               tri_verts=np.asarray(mesh.faces, np.uint32)))


def free_travel(fixed, moving, direction, reach=30.0, step=0.5, tol=0.5):
    """How far `moving` can slide along `direction` before it digs into `fixed` (mm3 tol)."""
    fm, mm = to_manifold(fixed), to_manifold(moving)
    v0 = (fm ^ mm).volume()
    d = np.array(direction, float)
    t = step
    while t <= reach + 1e-9:
        moved = mm.translate(tuple(d * t))
        if (fm ^ moved).volume() - v0 > tol:
            return t - step
        t += step
    return reach


def check_retention(item, base, cache, rep):
    name = item["name"]
    fixed = trimesh.util.concatenate([export(s, base, cache)[0] for s in item["fixed"]])
    moving = export(item["moving"], base, cache)[0]
    reach = float(item.get("reach", 30))
    overlap = (to_manifold(fixed) ^ to_manifold(moving)).volume()
    if overlap > 0.5:
        rep.add("FAIL", f"retention / {name}", f"parts overlap by {overlap:.1f} mm3 where assembled; something collides")
    free = {}
    for k, v in DIRS.items():
        free[k] = free_travel(fixed, moving, v, reach)
    loose = [k for k, t in free.items() if t >= min(5.0, reach)]
    data = {"free_travel_mm": free}
    for load in item.get("loads", ["-z"]):
        if load in loose:
            rep.add("FAIL", f"retention / {name}",
                    f"slides off along {load} ({LOAD_WORDS.get(load, load)}): free for {free[load]:.1f} mm. "
                    f"Put the stop on the side that load pushes against.", data)
        else:
            rep.add("PASS", f"retention / {name}", f"holds against {load} ({LOAD_WORDS.get(load, load)}), "
                    f"moves {free[load]:.1f} mm before it bears", data)
    install = item.get("install")
    if install and install not in loose:
        rep.add("FAIL", f"retention / {name}", f"can't go on along {install} as intended (free {free[install]:.1f} mm)", data)
    extra = [k for k in loose if k != install and k not in item.get("loads", ["-z"]) and k not in item.get("allow_free", [])]
    if extra:
        rep.add("WARN", f"retention / {name}", f"also free along {', '.join(extra)}; confirm nothing pushes that way", data)


# ---------- seat ----------

def check_seat(item, base, cache, rep):
    name = item["name"]
    mesh, echoes = export(item["part"], base, cache)
    at = item["at"]
    if isinstance(at, str) and at.startswith("echo:"):
        at = echoes[at[5:]]
    cx, cy = float(at[0]), float(at[1])
    ob = item["object"]
    rb, rt, oh = ob["base_d"] / 2, ob.get("top_d", ob["base_d"]) / 2, ob["h"]

    def r_at(t):  # object radius t above its base
        return rb + (rt - rb) * np.clip(t / oh, 0, 1)

    pts, _ = trimesh.sample.sample_surface_even(mesh, 400000, seed=1)
    pts = np.vstack([pts, mesh.vertices])
    rho = np.hypot(pts[:, 0] - cx, pts[:, 1] - cy)
    # smallest t (height up the object) at which the object is wider than rho
    if rt == rb:
        tmin = np.where(rho < rb, 0.0, np.inf)
    else:
        tmin = np.where(rho < rb, 0.0, (rho - rb) / (rt - rb) * oh)
        tmin[(tmin > oh) | (tmin < 0)] = np.inf
    hit = np.isfinite(tmin)
    if not hit.any():
        rep.add("FAIL", f"seat / {name}", "nothing under the object; it falls through"); return
    zc = pts[hit, 2] - tmin[hit]
    rest = float(zc.max())
    top = float(mesh.bounds[1][2])
    proud = rest + oh - top
    on_base = tmin[hit][zc > rest - 0.3]
    # how much of the object's base disk is held by surface within 0.3 mm of the rest height
    g = np.linspace(-rb, rb, 61)
    gx, gy = np.meshgrid(g, g)
    inside = gx ** 2 + gy ** 2 <= rb ** 2
    origins = np.column_stack([gx[inside] + cx, gy[inside] + cy, np.full(inside.sum(), top + 5)])
    locs, ray_idx, _ = mesh.ray.intersects_location(origins, np.tile([0, 0, -1.0], (len(origins), 1)))
    first = np.full(len(origins), -np.inf)
    for z, i in zip(locs[:, 2], ray_idx):
        if z <= rest + 0.3:
            first[i] = max(first[i], z)
    held = float(np.mean(first > rest - 0.3))
    data = {"rest_z": rest, "proud_mm": proud, "base_held_fraction": held}
    flat = (on_base == 0).any() and held >= float(item.get("min_held", 0.25))
    if flat:
        rep.add("PASS", f"seat / {name}", f"sits flat on the floor ({held:.0%} of its base held), stands {proud:.0f} mm above the rim", data)
    else:
        where = "on its base edge on a slope or ridge" if (on_base == 0).any() else f"by its side {float(on_base.min()):.0f} mm up from its base, on the rim or a taper"
        level = "FAIL" if item.get("require_flat", True) else "WARN"
        rep.add(level, f"seat / {name}", f"wedged {where} ({held:.0%} of its base held); give it a flat floor it can reach", data)
    lo, hi = item.get("proud", [None, None])
    if lo is not None and proud < lo:
        rep.add("FAIL", f"seat / {name}", f"stands only {proud:.0f} mm above the rim (want at least {lo}); hard to grab", data)
    if hi is not None and proud > hi:
        rep.add("WARN", f"seat / {name}", f"stands {proud:.0f} mm above the rim (more than {hi}); may tip out", data)


# ---------- printability ----------

def check_printability(item, base, cache, rep):
    name = item["name"]
    mesh, _ = export(item["part"], base, cache)
    bodies = len(mesh.split(only_watertight=False))
    want = int(item.get("bodies", 1))
    if not mesh.is_watertight:
        rep.add("FAIL", f"printability / {name}", "mesh isn't watertight")
    if bodies != want:
        rep.add("FAIL", f"printability / {name}", f"{bodies} separate bodies, expected {want}")
    zmin = mesh.bounds[0][2]
    n, c, a = mesh.face_normals, mesh.triangles_center, mesh.area_faces
    above = c[:, 2] > zmin + 0.3
    bridge = above & (n[:, 2] < -0.99)
    steep = above & (n[:, 2] < -0.71) & ~bridge
    data = {"steep_mm2": float(a[steep].sum()), "bridge_mm2": float(a[bridge].sum())}
    spans = []
    if bridge.any():
        sub = mesh.submesh([np.where(bridge)[0]], append=True)
        for p in sub.split(only_watertight=False):
            ext = p.bounds[1][:2] - p.bounds[0][:2]
            spans.append(float(min(ext)))
    data["bridge_spans_mm"] = sorted(spans, reverse=True)[:5]
    limit = float(item.get("steep_limit_mm2", 2.0))
    if data["steep_mm2"] > limit:
        rep.add("WARN", f"printability / {name}", f"{data['steep_mm2']:.0f} mm2 overhangs past 45 deg; needs supports or a chamfer", data)
    max_span = float(item.get("max_bridge_mm", 30))
    long = [s for s in spans if s > max_span]
    if long:
        rep.add("WARN", f"printability / {name}", f"bridge spans {long[0]:.0f} mm (limit {max_span:.0f})", data)
    if mesh.is_watertight and bodies == want and data["steep_mm2"] <= limit and not long:
        msg = "watertight, one body, no overhangs past 45 deg" if want == 1 else f"watertight, {want} bodies, no overhangs past 45 deg"
        if spans:
            msg += f"; bridges up to {max(spans):.0f} mm"
        rep.add("PASS", f"printability / {name}", msg, data)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("checks")
    ap.add_argument("--only", help="run only checks whose name contains this")
    ap.add_argument("--json", help="write the report here")
    args = ap.parse_args(argv)
    cfg = yaml.safe_load(open(args.checks))
    base = os.path.dirname(os.path.abspath(args.checks))
    cache = os.path.join(base, cfg.get("cache", "output/check"))
    rep = Report()
    for kind, fn in (("retention", check_retention), ("seat", check_seat), ("printability", check_printability)):
        for item in cfg.get(kind, []):
            if args.only and args.only not in item["name"]:
                continue
            try:
                fn(item, base, cache, rep)
            except Exception as e:  # report and keep going
                rep.add("FAIL", f"{kind} / {item['name']}", f"check crashed: {e}")
    if args.json:
        json.dump(rep.rows, open(args.json, "w"), indent=1)
    n = {lv: sum(r["level"] == lv for r in rep.rows) for lv in ("PASS", "WARN", "FAIL")}
    print(f"\n{n['PASS']} pass, {n['WARN']} warn, {n['FAIL']} fail")
    return 1 if rep.failed else 0


if __name__ == "__main__":
    sys.exit(main())
