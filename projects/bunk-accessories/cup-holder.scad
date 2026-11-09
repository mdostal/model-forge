// Bunk cup holder: slides onto a rail clip (clip.scad). Cup ring with a
// 45 deg funnel floor and a drain hole.
//
// Print upright as modeled, no supports: the funnel tip and the mount
// block share the bed, and the funnel rises at 45 deg.

use <rail-clip.scad>

/* [Cup] */
cup_id = 80;      // fits cups up to about 2 mm narrower than this
cup_wall = 2.4;
drain_d = 12;
height = 111;     // above the socket floor; 111 puts the rim level with the clip's saddle

/* [Fit] */
dt_clear = 0.25;  // dovetail clearance, from the fit test

part = "holder"; // [holder, assembly]

/* [Hidden] */
$fn = 96;
eps = 0.01;

ro = cup_id / 2 + cup_wall;
bot = -dt_floor();
funnel = ro;
ring_bot = bot + funnel;
cy = dt_block_d(dt_clear) + ro - cup_wall;

module cup() {
  difference() {
    union() {
      translate([0, cy, ring_bot]) cylinder(r = ro, h = height - ring_bot);
      translate([0, cy, bot]) cylinder(r1 = drain_d / 2 + cup_wall, r2 = ro, h = funnel + eps);
    }
    translate([0, cy, ring_bot]) cylinder(r = cup_id / 2, h = height - ring_bot + 1);
    translate([0, cy, bot + cup_wall * 1.414])
      cylinder(r1 = drain_d / 2, r2 = cup_id / 2 + 0.01, h = funnel - cup_wall * 1.414 + eps);
    translate([0, cy, bot - 1]) cylinder(d = drain_d, h = cup_wall * 2 + 2);
  }
}

module holder() { with_mounts(height, dt_clear) cup(); }

if (part == "assembly") bunk_assembly() holder(); else holder();
