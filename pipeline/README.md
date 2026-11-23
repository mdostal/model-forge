# pipeline/

Tools live here once the Hive builds them. See ../ROADMAP.md.

## Setup

```
cd pipeline && npm install
npm test
```

## bracket-gen (Milestone 1)

Parametric OpenSCAD L-bracket template + render wrapper. Requires
[OpenSCAD](https://openscad.org/) on PATH to actually render — not yet
installed on this dev machine (brew cask is Gatekeeper-disabled as of
2026-09-01; a direct download from openscad.org works around that).

```
node bracket-gen/src/render.js   # library, not a standalone CLI — see measurement-intake below
```

## measurement-intake (Milestone 1)

Turns a project's `measurements.yaml` into bracket-gen's params, with the
PLA-strength bump (README's own "1.5-2x thickness, or print PETG" rule)
folded in.

```
node measurement-intake/src/index.js path/to/measurements.yaml               # dry run — prints derived params
node measurement-intake/src/index.js path/to/measurements.yaml --output part.stl   # renders (needs OpenSCAD)
```

`measurements.yaml` schema (all lengths in mm):

```yaml
face_a_length: 45
face_b_length: 40
width: 22
material_thickness: 2.5      # the ORIGINAL part's thickness, before any PLA bump
hole_diameter: 6
countersink_diameter: 11
countersink_depth: 3
hole_offset: 13
slot_length: 18
slot_width: 7
slot_offset: 15
# optional:
bend_radius: 3                # raised automatically if thinner than the wall allows
material_source: metal        # metal (default) | print-native — print-native skips the PLA bump
print_material: PLA           # PLA (default, gets thickened) | PETG (left alone)
```

No `measurements.yaml` exists yet for `projects/furniture-brackets/` — its
`NOTES.md` measurement table is still blank. That's Milestone 0 (calipers on
the real part), still open.

## Before printing: print-check, slice-check, preflight

Three Python tools catch mistakes before anything reaches the printer. Each tool's README explains its checks.

| Tool | What it checks |
|---|---|
| `print-check/` | The model: does it stay on what it hangs from, does a cup seat, does it print without bad overhangs (`checks.yaml` per project). |
| `slice-check/` | The sliced plate: every part on the bed, the right plate and bed temperature, on the plate and clear of the keep-out, not stale. |
| `preflight/` | Runs both in one command and ends in `PREFLIGHT PASS` or `PREFLIGHT FAIL`. |

```
python3 pipeline/preflight/preflight.py --checks projects/<name>/checks.yaml plate.gcode.3mf --sources part.stl
```
