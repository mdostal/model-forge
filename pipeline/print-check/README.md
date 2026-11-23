# print-check

Checks a design for mistakes before it's printed, and fails loudly when it finds one. It was built after the first bunk cup holder (2026-11-12) went on its clip the wrong way round, so a dropped cup could push it off, and had a funnel floor that a glass wedged into instead of standing on. Both of those are now FAILs.

```
python3 pipeline/print-check/print_check.py projects/<name>/checks.yaml [--only text] [--json report.json]
python3 -m pytest pipeline/print-check -q
```

It needs `openscad` on PATH (or set `OPENSCAD`), plus the Python packages trimesh, manifold3d and pyyaml. Exports are cached by file content under the project's `output/check/`. The exit code is 1 if any check FAILs.

## Checks

| Check | What it does | What fails |
|---|---|---|
| `retention` | Puts the mounted part where it sits in use, then slides it up to 30 mm in each of the six directions to find which ways are free. | Any direction in `loads` is free; the `install` direction isn't free; the parts overlap where assembled. Other free directions WARN unless listed in `allow_free`. |
| `seat` | Lowers a reference object (base width, top width, height) into a receptacle at `at`. That can be `[x, y]` or `echo:<name>` for a value the .scad echoes. | The object wedges on a taper or rim instead of standing on a flat floor, or stands less than `proud[0]` mm above the rim. |
| `printability` | Checks the exported part in its print orientation. | It isn't watertight, or the body count is wrong. WARNs for faces overhanging past 45°, bridges (flat undersides held at both ends) longer than `max_bridge_mm`, and ledges (flat undersides held on one side only) reaching more than `max_ledge_mm`, 1.2 by default. A 2 mm ledge on a tall clip curled and spaghettied twice on 2026-11-15. |

Every part spec is `{scad, part?, define?}`. `part` is passed as `-D part="..."`, so each model exposes its pieces (for example `rails`, `clips`, `mounted`) through its `part` switch. See `projects/bunk-accessories/checks.yaml`.

## Using it

Each project that hangs, mounts, clips or holds something gets a `checks.yaml`. Its `loads` list should name every way the part gets pushed in real use, such as a dropped cup, a kid pulling it, or something leaned on it. Run it after every model change and before slicing. A FAIL is a design bug, not a warning to ignore.

Not modelled yet: flexing (snap fits are treated as rigid), strength under load, and friction.
