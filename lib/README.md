# model-forge OpenSCAD library

This is a real OpenSCAD library, installed the same way BOSL2 or MCAD are — not a custom app bolted onto OpenSCAD. `scripts/install-openscad-lib.sh` symlinks this directory into `~/Documents/OpenSCAD/libraries/model-forge` (OpenSCAD's actual user library path — confirm yours via Help → Library Info in the app). Once installed, any `.scad` file, hand-written or tool-generated, can do:

```scad
use <model-forge/panel.scad>
panel_with_cutouts(outer_width=285.75, outer_height=228.6, thickness=3);
```

## Why a library, not a custom app

OpenSCAD has no plugin/addon API for embedding custom UI panels (unlike, say, a Blender addon) — its real extension mechanism is exactly this: drop `.scad` modules into the library folder. So "our tools attached to OpenSCAD" means:

- **Reusable geometry** (this directory) — plain OpenSCAD modules/functions, `use`-able from anything, including your own hand-written designs layering grooves/indents/joinery on top.
- **AI-assisted parameter derivation** (`pipeline/*/src/`) — Node CLI tools that turn measurements or a part spec into the numbers these modules need, then shell out to `openscad` to render. They write/update a `.scad` working file; OpenSCAD's own auto-reload (Design → Automatic Reload and Preview, on by default) picks up the change live — no custom viewer needed.

## Modules

| File | Exports | Used by |
|---|---|---|
| `model-forge/panel.scad` | `panel_with_cutouts()`, `panel_segments()` | `pipeline/panel-gen` |

## Adding a module

Same pattern as `panel.scad`: take explicit arguments (no globals), so it composes inside a caller's own design. Update the table above and add a corresponding `pipeline/<tool>/` CLI if it needs AI-derived parameters.
