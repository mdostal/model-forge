// Bunk cup holder: hangs on a rail clip (clip.scad). Lower it onto the
// clip from above; the roof over its socket comes down on the clip's tail,
// so the weight of a cup, or a cup dropped in, pushes it on harder.
//
// floor = "flat": a flat seat so a glass or sippy cup stands level, with a
// 45 deg fillet where the floor meets the wall. floor = "cone": the floor
// tapers at 45 deg to a flat spot cone_base across, for cups with a narrow or
// rounded bottom (a flat-bottomed cup wider than the spot wedges instead).
// Both have a drain hole.
//
// Stripes (finish "striped"): stripe_part = 1 or 2 gives one color's bands,
// cut at whole-layer heights so an AMS swaps cleanly between them.
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
slots = "none";   // [none, both] a slot down each side from the rim, for a mug handle or little fingers
slot_w = 22;      // slot width; mug handles are mostly 10-20 mm thick
slot_keep = 20;   // solid wall kept between the floor and the slot bottom
floor = "flat";   // [flat, cone]
cone_base = 60;   // cone: the flat spot's width at the bottom

/* [Stripes] */
stripes = 3;      // [0:1:8] bands of the second color
stripe_h = 7;     // each band's height
base_band = 12;   // first-color band at the bottom, covering the floor
layer_h = 0.2;    // bands are cut at multiples of this
stripe_part = 0;  // [0, 1, 2] 0: the whole holder; 1 or 2: that color's bands only

/* [Fit] */
dt_clear = 0.25;  // dovetail clearance, from the fit test

part = "holder"; // [holder, assembly, rails, clips, mounted]

/* [Hidden] */
$fn = 96;
eps = 0.01;

ro = cup_id / 2 + cup_wall;
rim = dt_roof();                 // rim flush with the top of the socket roof
cone_h = floor == "cone" ? (cup_id - cone_base) / 2 : 0;   // 45 deg
bot = rim - depth - floor_t;
cy = dt_block_d(dt_clear) + ro - cup_wall;
echo(seat_center = [0, cy]);
assert(floor == "flat" || floor == "cone", str("cup-holder: unknown floor ", floor));
assert(floor == "flat" || (cone_base >= 30 && cone_h < depth - 15), "cup-holder: cone_base too small, or the cone is taller than the cup is deep");
assert(slots == "none" || depth - slot_keep >= 25,
       str("cup-holder: handle slots need depth >= ", slot_keep + 25, " (", slot_keep, " mm of wall under a 25 mm slot)"));
slot_bot = bot + floor_t + slot_keep;   // slot bottom, measured from the floor's top

module cup() {
  difference() {
    translate([0, cy, bot]) union() {
      translate([0, 0, cone_h]) cylinder(r = ro, h = rim - bot - cone_h);
      if (cone_h > 0) cylinder(r1 = cone_base / 2 + cup_wall * 1.414, r2 = ro, h = cone_h + eps);   // outside follows the cone
    }
    translate([0, cy, bot + floor_t]) union() {
      translate([0, 0, cone_h]) cylinder(r = cup_id / 2, h = depth + 1);
      if (cone_h > 0) cylinder(r1 = cone_base / 2, r2 = cup_id / 2, h = cone_h + eps);
    }
    translate([0, cy, bot - 1]) cylinder(d = drain_d, h = floor_t + 2);
    // handle slots, left and right, round-bottomed; upright print, so no overhang
    if (slots == "both") for (sx = [-1, 1]) translate([sx * ro, cy, 0]) hull() {
      translate([0, 0, slot_bot + slot_w / 2]) rotate([0, 90, 0]) cylinder(d = slot_w, h = cup_wall * 4, center = true);
      translate([0, 0, rim + 1]) rotate([0, 90, 0]) cylinder(d = slot_w, h = cup_wall * 4, center = true);
    }
  }
  if (floor == "flat") translate([0, cy, bot + floor_t - eps]) rotate_extrude()
    polygon([[cup_id / 2 - fillet, 0], [cup_id / 2 + eps, 0], [cup_id / 2 + eps, fillet]]);
}

// stripe bands, bottom up: base_band of color 1, then stripe_h of color 2 and of
// color 1 in turn, stripes times; the rest is color 1. Cut at whole layers.
function snap(z) = round(z / layer_h) * layer_h;
function band_z(i) = snap(bot + base_band + i * stripe_h);   // band edges above the base band
module stripe_slab(c) {
  big = 1000;
  for (i = [0 : 2 * stripes])   // edges 0..2*stripes; odd intervals are color 2
    if ((i % 2 == 0 ? 2 : 1) == c && i < 2 * stripes)
      translate([-big / 2, -big / 2, band_z(i)]) cube([big, big, band_z(i + 1) - band_z(i)]);
  if (c == 1) {
    translate([-big / 2, -big / 2, bot - big]) cube([big, big, band_z(0) - bot + big]);
    translate([-big / 2, -big / 2, band_z(2 * stripes)]) cube([big, big, big]);
  }
}
echo(stripe_top = band_z(2 * stripes), rim = rim);
assert(stripe_part == 0 || band_z(2 * stripes) <= rim - 2, "cup-holder: the stripes run past the rim; fewer or thinner stripes");

module holder_whole() { with_mounts(-bot, dt_clear) cup(); }
module holder() {
  if (stripe_part == 0) holder_whole();
  else intersection() { holder_whole(); stripe_slab(stripe_part); }
}

if (part == "assembly") bunk_assembly() holder();
else if (part == "holder") holder();
else bunk_piece(part) holder();
