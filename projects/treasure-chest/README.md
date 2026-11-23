# Treasure chest

A lidded treasure chest that closes around the [school supply caddy](../school-caddy/). The caddy drops in as an insert. Its two end lips poke out through slots in the chest's end walls, so they work as the chest's handles and lift the whole insert straight out.

The default size is 240 x 186 x 207 mm closed, with a 252 mm wide lid. That height leaves room for the pencils and colored pencils standing in the caddy.

## Colors without a multi-color printer

Each color is its own part, glued on after printing:

| Part | Color | Print orientation |
|---|---|---|
| Base | brown | upright |
| Lid | brown | upside down |
| Straps, printed twice | black | on edge (`print_straps` is one lid strap and one base strap) |
| Name plate and lock plate | yellow | flat |

Planks are engraved into the base and lid, and the straps sit in shallow channels so they line up on their own.

## Make your own

Open `treasure-chest.scad` in OpenSCAD and use the Customizer. The `caddy_*` variables describe the insert, so set them to match your caddy. Everything else sizes itself from them. The file uses `../school-caddy/school-caddy.scad` for its clearance check.

```sh
openscad -D 'part="print_base"' -o chest-base.stl treasure-chest.scad
openscad -D 'part="print_lid"' -o chest-lid.stl treasure-chest.scad
openscad -D 'part="print_straps"' -o chest-straps.stl treasure-chest.scad
openscad -D 'part="print_plates"' -D 'name="Your Name"' -o chest-plates.stl treasure-chest.scad
```

## Printing and assembly

All parts print with no supports. A Bambu X1C slice at 0.20 mm, 2 walls and 15% infill in PLA estimates:

- Base: 5 h 36 min, 261 g
- Lid: 8 h 56 min, 398 g
- Straps: 18 min and 17 g per run, two runs
- Plates: 23 min, 13 g

The total is about 15.5 h and 705 g. The lid is 252 mm wide, so on a 256 mm bed there is no room for a brim.

1. Pin the hinge with two 55 mm pieces of 1.75 mm filament.
2. Glue the straps into their channels: two over the lid, two under the base.
3. Glue the name plate onto the lid front and the lock plate below the latch.
4. Lower the caddy in, sliding its lips down the end slots.

## Checks

- `fit_check`: the chest closed around the caddy and its stand-in supplies. An empty result means they fit.
- `hinge_check`: the base against the lid at several open angles. The only expected overlap is the latch bump at the first angle, which is the click.

The default font is Liberation Sans, which ships with OpenSCAD.

## Lock styles

Set `lock_style` to pick the front of the chest. Today's default doesn't change.

| `lock_style` | Look | What holds the lid |
|---|---|---|
| `plate` | Decorative keyhole plate on the base | Hidden snap tab |
| `none` | Plain front | Hidden snap tab |
| `painted` | Hasp and hoops drawn flush, low on the base | Hidden snap tab |
| `painted-seam` | The same look drawn across the seam, where a real hasp attaches | Hidden snap tab, colored as part of the art |
| `plate-seam` | The keyhole plate drawn across the seam | Hidden snap tab, colored as part of the art |
| `hasp` | Working flap on a 1.75 mm filament pin, swinging over a loop, with a flat key through the loop | The flap and key |

For `hasp`, export `print_hasp` for the flap and key. They print flat, front face up. The loop prints with the base and the knuckles print with the lid, with no supports. The key is a small part, so keep it away from children under 3. The hasp is checked in CAD only and hasn't been printed yet.

## License

CC BY-NC-SA 4.0: print it, change it, and share it non-commercially with credit. Ask before selling prints or files. See [LICENSE.md](LICENSE.md).
