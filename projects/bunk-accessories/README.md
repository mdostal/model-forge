# Bunk bed accessories

A rail clip for bunk and loft beds, and accessories that slide onto it on one shared dovetail. Every piece is
customizable in OpenSCAD's Customizer, sized from your own bed's measurements.

| File | What it is |
|---|---|
| `clip.scad` | The rail clip. `mount`: `top` (hangs on the top rail, J under the bar below), `middle` (round one middle bar) or `mid-bottom` (middle bar to the bottom frame). `catch`: `j` (default), `hook` or `none`. `nub_h` 2 mm, or 4 for a firmer grip. |
| `cup-holder.scad` | Cup holder: ring, depth, handle slots, `floor` flat or cone, stripes for an AMS |
| `tissue-holder.scad` | Tissue box holder; the defaults fit the Kleenex Trusted Care flat box |
| `book-holder.scad` | Book holder: `layout` stepped or flat, rows and depths, cut-out shapes, stripes |
| `storage-tray.scad` | Storage tray: small, large or custom; even grid, a big middle compartment, or drawn divider lines |
| `cubby.scad` | A simple bin with dividers |
| `rail-clip.scad` | The shared library: the clip itself, the dovetail, and mounting helpers |
| `checks.yaml` | print-check: does each piece stay on what it hangs from, and does it print |
| `makerworld.yaml` | Upload packages for MakerWorld's Parametric Model Maker, Printables and Thingiverse |

## Measure your bed

Use calipers and measure in millimeters (a ruler gives a looser fit):

1. The top rail, front to back, and its height.
2. The gap from the underside of the top rail to the top of the next bar down.
3. A middle bar, front to back and its height.
4. Lay a straightedge flat on the top rail's front face and measure in to the middle bar's front face (the setback). 0 if they're flush.
5. Only for the `mid-bottom` mount: the bottom frame, front to back, its height and its setback.

The defaults are our loft bed: a 20.74 x 20.38 mm top rail, an 80.54 mm gap, and 15.42 mm square middle bars set 2.47 mm back.

## Print

- **Settings:** PLA, 0.20 mm layers, 2 walls, 15% infill, Textured PEI plate.
- **Accessories:** print upright as modeled, with no supports.
- **Clips:** export flipped (saddle on the bed). Print them with tree supports under the J hook and snap the supports off.
- **Fitting:** put the clips on the bed first: hook the J under the bar, then rock it in. Then lower the accessory straight down onto them.

## Check before printing

From the repo root:

```
python3 pipeline/print-check/print_check.py projects/bunk-accessories/checks.yaml
python3 pipeline/preflight/preflight.py --checks projects/bunk-accessories/checks.yaml <plate>.gcode.3mf --sources <part>.stl
```

## MakerWorld and other sites

```
python3 pipeline/makerworld-pack/pack.py projects/bunk-accessories/makerworld.yaml
```

This writes `output/makerworld/<model>/` for each model. Each folder has:
- a self-contained `.scad`: MakerWorld can't load a model's own `use` files, so the shared library is inlined and checked against the original;
- `default.stl`;
- a `cover.png` render;
- `LICENSE.md`;
- `listing.md`.

Never enter these in MakerWorld's Exclusive program: they stay open source and are listed elsewhere too.

## License

CC BY-NC-SA 4.0. See `LICENSE.md`.
