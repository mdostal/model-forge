# School supply caddy

A one-piece stepped caddy that keeps a child's school supplies upright and lets the whole set lift out of a homework box with two hands.

- **Deep back section:** long slot for a box of markers, a 24-count colored pencil box, a 24-count crayon box, 8 pencils, and scissors with blades down.
- **Medium middle section:** glue bottle, 8 loose markers, and 2 glue sticks.
- **Shallow front tray:** eraser pocket and a flat tray for small things.

Overall size is 250 x 176 x 70 mm including the end lips.

## Make your own

Open `school-caddy.scad` in OpenSCAD and use the Customizer. Every slot size, section height, wall, and lip is a variable. Leave `name` empty, or set it to engrave one line on the back. `name_size` sets its text size, 22 by default.

From the command line:

```sh
openscad -D 'name="Your Name"' -o school-caddy.stl school-caddy.scad
```

The default font is Liberation Sans Bold (SIL Open Font License), which ships with OpenSCAD. Change `font_name` to use another font.

## Printing

Print upright with no supports. On a 256 mm bed, the 250 mm width leaves no room for a brim. A Bambu X1C slice at 0.20 mm, 2 walls, and 15% infill in PLA estimates 8 h 47 min and 405 g.

## Sizes

Slots are roomy on purpose, so items should drop in and lift out easily. The defaults come from rough estimates and store listings, not caliper measurements, so check them against your own supplies. Set `part` to `fit_check` to intersect the caddy with the stand-in supplies. An empty result means those stand-ins fit.

## License

CC BY-NC-SA 4.0: print it, change it, and share it non-commercially with credit. Ask before selling prints or files. See [LICENSE.md](LICENSE.md).
