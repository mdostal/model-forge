#!/usr/bin/env python3
"""makerworld-pack: turn a project's customizable models into upload packages for MakerWorld's Parametric Model Maker
(and Printables / Thingiverse, which take the same files).

MakerWorld runs the .scad on its own servers and often can't load a model's own `use <...>`/`include <...>` files, so each
package's .scad is self-contained: every local `use`/`include` is inlined (a `use`d file is inlined without its top-level
geometry, which is what `use` means). The tool checks the flattened file exports the same part as the original (same
volume and bounds), and writes per model:
  <out>/<name>/<name>.scad    the self-contained, customizable model
  <out>/<name>/default.stl    the default part (MakerWorld's PMM default-file name)
  <out>/<name>/cover.png      a 3D render for the listing (label it a render)
  <out>/<name>/LICENSE.md     the project's license
  <out>/<name>/listing.md     title, description and print settings from the project's makerworld.yaml

usage: python3 pipeline/makerworld-pack/pack.py projects/<project>/makerworld.yaml [--out <dir>]
"""
import argparse, os, re, shutil, subprocess, sys
import trimesh, yaml

OPENSCAD = os.environ.get("OPENSCAD", "openscad")
INC = re.compile(r"^\s*(use|include)\s*<([^>]+)>\s*;?\s*$", re.M)


def top_level_geometry_free(src):
    """A `use`d file contributes only its modules and functions; drop anything else at its top level (calls, echoes)."""
    out, depth = [], 0
    for line in src.splitlines():
        stripped = line.strip()
        if depth == 0 and stripped and not stripped.startswith(("//", "/*", "*", "module ", "function ", "$")) \
                and not re.match(r"^[A-Za-z_]\w*\s*=", stripped) and not stripped.startswith("}"):
            continue
        out.append(line)
        depth += line.count("{") - line.count("}")
    return "\n".join(out)


def flatten(path, seen=None):
    seen = set() if seen is None else seen
    path = os.path.abspath(path)
    src = open(path).read()
    def repl(m):
        kind, rel = m.group(1), m.group(2)
        dep = os.path.join(os.path.dirname(path), rel)
        if not os.path.exists(dep): return m.group(0)   # a library MakerWorld provides (BOSL2 and so on): leave it
        if dep in seen: return f"// ({rel} already inlined above)"
        seen.add(dep)
        body = flatten(dep, seen)
        if kind == "use": body = top_level_geometry_free(body)
        return f"// ---- inlined from {rel} ({kind}) ----\n{body}\n// ---- end of {rel} ----"
    return INC.sub(repl, src)


def export(scad, out, defines=None):
    args = [OPENSCAD, "-o", out]
    for k, v in (defines or {}).items(): args += ["-D", f"{k}={v}"]
    r = subprocess.run(args + [scad], capture_output=True, text=True, cwd=os.path.dirname(os.path.abspath(scad)))
    if r.returncode != 0 or not os.path.exists(out): raise SystemExit(f"OpenSCAD failed on {scad}:\n{r.stderr[-1500:]}")
    return out


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("config"); ap.add_argument("--out")
    a = ap.parse_args(argv)
    cfg = yaml.safe_load(open(a.config)); base = os.path.dirname(os.path.abspath(a.config))
    out_root = a.out or os.path.join(base, "output", "makerworld")
    lic = os.path.join(base, cfg.get("license_file", "LICENSE.md"))
    ok = True
    for m in cfg["models"]:
        name, src = m["name"], os.path.join(base, m["scad"])
        d = os.path.join(out_root, name); shutil.rmtree(d, ignore_errors=True); os.makedirs(d)
        flat = flatten(src)
        if m.get("part"): flat = re.sub(r'^part\s*=\s*"[^"]*"', f'part = "{m["part"]}"', flat, count=1, flags=re.M)
        header = f"// {m['title']}. {cfg.get('credit', '')}\n// License: {cfg.get('license', '')}. Self-contained for MakerWorld's Parametric Model Maker.\n"
        flat_path = os.path.join(d, f"{name}.scad"); open(flat_path, "w").write(header + flat)
        orig = trimesh.load(export(src, os.path.join(d, "_orig.stl"), {"part": f'"{m["part"]}"'} if m.get("part") else None), force="mesh")
        new = trimesh.load(export(flat_path, os.path.join(d, "default.stl")), force="mesh")
        same = abs(orig.volume - new.volume) < 0.01 * abs(orig.volume) and (abs(orig.bounds - new.bounds) < 0.05).all()
        os.remove(os.path.join(d, "_orig.stl"))
        subprocess.run([OPENSCAD, "-o", os.path.join(d, "cover.png"), "--imgsize=1200,900", "--viewall", "--autocenter",
                        "--colorscheme=Tomorrow"] + [x for k, v in m.get("cover_defines", {}).items() for x in ("-D", f"{k}={v}")] + [flat_path],
                       capture_output=True)
        if os.path.exists(lic): shutil.copy(lic, os.path.join(d, "LICENSE.md"))
        open(os.path.join(d, "listing.md"), "w").write(
            f"# {m['title']}\n\n{m['description'].strip()}\n\n## Print settings\n\n{cfg.get('print_settings', '').strip()}\n\n"
            f"## License\n\n{cfg.get('license', '')}. {cfg.get('license_note', '')}\n")
        print(f"{'OK  ' if same else 'DIFF'} {name}: flattened {len(flat.splitlines())} lines, volume {new.volume:.0f} vs {orig.volume:.0f} mm3", flush=True)
        ok &= same
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
