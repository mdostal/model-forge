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

**Output convention:** `--output` is caller-specified, not defaulted by the
tool. Always point it at the *project's* output folder
(`projects/furniture-brackets/output/`), never at a path under `pipeline/` —
`pipeline/*/output/` is scratch/dev space for the tool itself, not where
printable deliverables live. (Fixed 2026-09-13: the first two brackets had
landed in `pipeline/bracket-gen/output/` instead of
`projects/furniture-brackets/output/`, inconsistent with every other part in
this repo.)
