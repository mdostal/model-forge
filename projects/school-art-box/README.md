# School art box

A lay-flat supply box with a hinged lid and a click latch, so a child's supplies stay shut in a classroom cubby. A separate lift-out insert tray gives every supply its own section.

- **Box:** a hinged lid with an engraved name (optional) and picture icons. A flexing tab clicks over a bump on the base. Pull the tab's lip outward to open.
- **Insert tray, a separate print:** eight sections, front to back:

  | Left | Right |
  |---|---|
  | 8 markers | spare spot |
  | 8 pencils | spare spot |
  | glue bottle, with scissors on top | eraser |
  | crayon and colored pencil boxes | 2 glue sticks |

  Each section has a picture on its floor. Lift the tray out by the tabs on each end.

The default size is 236 x 238 x 70 mm closed, 248 mm front to back including the hinge. The width is kept under 237 mm so the base and lid miss the Bambu X1C's corner keep-out zone.

## Make your own

Open `art-box.scad` in OpenSCAD and use the Customizer. These are all variables:

- The inside size, walls, lid fit, hinge, latch and name.
- Every insert row depth and section width (`markers_row`, `markers_w`, `pencils_row`, `pencils_w`, `bottle_row`, `bottle_w`, `boxes_w`).
- The insert's height, floor and clearance.
- The lid art: `icon_scale` and `star_scale` scale each picture and star about its own origin, and the spacing stays fixed.

Set `channel_d` above 0 for a single fixed divider instead of the insert.

```sh
openscad -D 'part="print_base"' -o art-box-base.stl art-box.scad
openscad -D 'part="print_lid"' -D 'name="Your Name"' -o art-box-lid.stl art-box.scad
openscad -D 'part="print_insert"' -o art-box-insert.stl art-box.scad
```

`part="name_cut"` exports only the name's cutter. `part="art_cut"` does the same for the pictures and stars, always in the layout a named lid uses, and it ignores `name` and `show_icons`.

## Printing and assembly

All parts print with no supports. Print the base upright, the lid upside down as `print_lid` exports it, and the insert floor down. A Bambu X1C slice at 0.20 mm, 2 walls and 15% infill in PLA estimates:

- Base: 5 h 7 min, 260 g
- Lid: 3 h 30 min, 161 g
- Insert: 3 h 34 min, 218 g

The base and lid are 248 mm front to back. If the slicer's auto-arrange can't place them, put them in the back right corner, away from the keep-out zone at the front left.

The hinge pins are two 55 mm pieces of 1.75 mm filament. Push each one through a set of three knuckles. The base knuckle holes are tight, so the pins stay in, and the lid holes are loose, so the lid swings. If a pin is hard to push, adjust `pin_hole_base`. If the latch is too stiff or too loose, adjust `tab_t` or `latch_engage`.

## Checks

- `fit_check`: stand-in supplies in their sections, inside the closed box. An empty result means they fit.
- `insert_check`: the insert against the base and lid. It should come out empty.
- `hinge_check`: the base against the lid at several open angles. The only expected overlap is the latch bump at the first angle, which is the click.

The stand-in sizes are estimates, not measurements, so check them against your own supplies.

## License

CC BY-NC-SA 4.0: print it, change it, and share it non-commercially with credit. Ask before selling prints or files. See [LICENSE.md](LICENSE.md).
