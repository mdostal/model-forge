// Bunk cubby: a customizable open-top bin that slides onto rail clips
// (clip.scad). Remotes, glasses, books, toys: set the inside size, add
// dividers, and pick 1 or 2 clips.
//
// Print upright as modeled, no supports.

use <rail-clip.scad>

/* [Inside size] */
width = 60;       // along the rail
depth = 35;       // away from the rail
height = 80;      // wall height above the floor
dividers = 0;     // evenly spaced, running away from the rail
front_slot = 20;  // slot down the front wall to see and grab (0 for none)

/* [Build] */
wall = 2;
floor_t = 2.4;
corner_r = 3;
clips = 1;        // 1 or 2 rail clips
clip_pitch = 120; // clip spacing when using 2; must miss the bed's posts

/* [Fit] */
dt_clear = 0.25;

part = "cubby"; // [cubby, assembly]

/* [Hidden] */
$fn = 32;
eps = 0.01;

ow = width + 2 * wall;
od = depth + 2 * wall;
y0 = dt_block_d(dt_clear) - eps;
bot = -dt_floor();
oh = floor_t + height;
xs = clips >= 2 ? [-clip_pitch / 2, clip_pitch / 2] : [0];

module rbox(w, d, h, r) {
  hull() for (x = [r, w - r], y = [r, d - r]) translate([x, y, 0]) cylinder(r = r, h = h);
}

module bin() {
  difference() {
    translate([-ow / 2, y0, bot]) rbox(ow, od, oh, corner_r);
    translate([-width / 2, y0 + wall, bot + floor_t]) rbox(width, depth, oh, max(0.5, corner_r - wall));
    if (front_slot > 0) {
      sz = bot + floor_t + 12;
      translate([0, y0 + od + 1, 0]) rotate([90, 0, 0]) linear_extrude(wall + 2)
        polygon([[-front_slot / 2, bot + oh + 1], [-front_slot / 2, sz + front_slot / 2],
                 [0, sz], [front_slot / 2, sz + front_slot / 2], [front_slot / 2, bot + oh + 1]]);
    }
  }
  if (dividers > 0)
    for (i = [1 : dividers])
      translate([-width / 2 + i * width / (dividers + 1) - wall / 2, y0 + wall - eps, bot + floor_t - eps])
        cube([wall, depth + 2 * eps, height * 0.85]);
}

module cubby() { with_mounts(max(height, 50), dt_clear, xs) bin(); }

if (part == "assembly") bunk_assembly(xs) cubby(); else cubby();
