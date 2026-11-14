// Bunk cup holder: hangs on a rail clip (clip.scad). Lower it onto the
// clip from above; the roof over its socket comes down on the clip's tail,
// so the weight of a cup, or a cup dropped in, pushes it on harder.
//
// Flat floor so a glass or sippy cup stands level on it, a 45 deg fillet
// where the floor meets the wall, and a drain hole.
//
// Print upright as modeled, no supports: the floor and mount block sit on
// the bed; the socket roof is a short bridge.

use <rail-clip.scad>

/* [Cup] */
cup_id = 94;      // Duralex Picardie 250/310 ml are 86-90 mm across the top
depth = 55;       // floor to rim; a 90 mm glass stands about 35 mm proud
cup_wall = 2.4;
floor_t = 2.4;
fillet = 2;       // 45 deg ring where floor meets wall; the flat seat is cup_id - 2 * fillet across
drain_d = 10;

/* [Fit] */
dt_clear = 0.25;  // dovetail clearance, from the fit test

part = "holder"; // [holder, assembly, rails, clips, mounted]

/* [Hidden] */
$fn = 96;
eps = 0.01;

ro = cup_id / 2 + cup_wall;
rim = dt_roof();                 // rim flush with the top of the socket roof
bot = rim - depth - floor_t;
cy = dt_block_d(dt_clear) + ro - cup_wall;
echo(seat_center = [0, cy]);

module cup() {
  difference() {
    translate([0, cy, bot]) cylinder(r = ro, h = rim - bot);
    translate([0, cy, bot + floor_t]) cylinder(r = cup_id / 2, h = depth + 1);
    translate([0, cy, bot - 1]) cylinder(d = drain_d, h = floor_t + 2);
  }
  translate([0, cy, bot + floor_t - eps]) rotate_extrude()
    polygon([[cup_id / 2 - fillet, 0], [cup_id / 2 + eps, 0], [cup_id / 2 + eps, fillet]]);
}

module holder() { with_mounts(-bot, dt_clear) cup(); }

if (part == "assembly") bunk_assembly() holder();
else if (part == "holder") holder();
else bunk_piece(part) holder();
