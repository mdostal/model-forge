// Tiny Land baking sheet — handle peg/socket fit test.
//
// The current baking_sheet.scad molds handles onto the pan as one
// piece. This tests a different approach: separate handles that PUSH
// STRAIGHT IN to a socket in the pan's side wall (not a sliding
// dovetail like everything else this session) -- "how close to
// basically a dovetail that inserts directly in rather than sliding."
//
// Two things from tonight's research applied directly here:
// - Hexagonal cross-section, not round or square -- confirmed FDM-
//   specific: a round peg takes up interference by stretching the
//   WHOLE circumference (cracks/delaminates sooner); a hex peg
//   concentrates the give at 6 corners, gentler for the same fit.
// - A tapered peg (frustum, via linear_extrude's scale=) is a real
//   self-locking mechanism (Morse taper) independent of the hex shape --
//   pushed straight in, it wedges tighter the deeper it seats. Below a
//   critical half-angle (~7deg for dry steel; PLA-on-PLA friction runs
//   higher, so probably steeper before it stops self-locking) it holds
//   by friction alone, no barb/snap needed. Starting taper here (~7deg
//   half-angle) is right at the steel threshold as a first guess --
//   this print will tell us if PLA needs it steeper.
//
// Comb of 7 sockets at different clearances (same sweep methodology as
// the dovetail tests), plus one matching peg to press into each.
use <model-forge/joint.scad>

wall_thickness = 10;  // representative pan-wall cross-section to test into
wall_height    = 20;

peg_base_size = 8;    // hex across-flats at the peg's base (wide end)
peg_depth     = 8;    // how far it reaches in
tip_scale     = 0.75; // taper: tip is 75% of the base size (~7deg half-angle)

clearances = [-0.3, -0.2, -0.15, -0.1, -0.05, 0, 0.1];
step = 16;

module hexagon_2d(across_flats) {
  r = across_flats / cos(30) / 2;
  circle(r = r, $fn = 6);
}

// One socket, opening on the wall's top face (z=wall_height), tapering
// DOWN into the wall -- pushing a peg straight down (-Z) wedges it in.
module socket_at(x_center, clearance) {
  translate([x_center, wall_thickness / 2, wall_height - peg_depth])
    linear_extrude(height = peg_depth + 1, scale = tip_scale)
      hexagon_2d(peg_base_size + 2 * clearance);
}

module test_wall() {
  difference() {
    cube([len(clearances) * step, wall_thickness, wall_height]);
    for (i = [0 : len(clearances) - 1])
      socket_at(i * step + step / 2, clearances[i]);
    for (i = [0 : len(clearances) - 1])
      translate([i * step + 2, wall_thickness - 3, wall_height - 6])
        rotate([90, 0, 0])
          linear_extrude(height = 0.5)
            text(str(clearances[i]), size = 3);
  }
}

module test_peg() {
  linear_extrude(height = peg_depth, scale = tip_scale)
    hexagon_2d(peg_base_size);
}

// A split peg: same tapered hex, but with a slit cut down the middle
// (parallel to the push axis) splitting it into two prongs that
// compress toward each other going in, then spring back once seated --
// a real, well-established technique (split dowels/spring pins), and
// your "dovetail with a cut on it" idea applied to this shape. Tune
// slit_gap and prong_flex_margin once printed: gap is currently 0 (a
// true slit, print-thin), and the peg is oversized by
// prong_oversize before splitting so the sprung-together diameter
// still presses against the socket.
slit_width = 0.6;         // roughly one nozzle width — thin, printable slit
prong_oversize = 0.4;     // extra size split across the two prongs before slitting

module split_test_peg() {
  // Bug fixed: cube(..., center=true) centers ALL 3 axes, but the peg's
  // own Z-range is 0..peg_depth (linear_extrude's default), not
  // centered on Z=0 -- the slit only cut through the bottom half,
  // leaving the two prongs still joined at the top (confirmed via
  // trimesh: came back as ONE component instead of 2). Fixed by
  // explicitly spanning the slit's own Z range with margin, matching
  // the peg's real Z position instead of assuming it's centered.
  full_w = peg_base_size + prong_oversize;
  difference() {
    linear_extrude(height = peg_depth, scale = tip_scale)
      hexagon_2d(full_w);
    translate([-slit_width / 2, -full_w / 2, -1])
      cube([slit_width, full_w, peg_depth + 2]);
  }
}

test_wall();

// A few loose pegs to press-test into the sockets above.
for (i = [0 : 2])
  translate([i * (peg_base_size + 6), wall_thickness + 15, 0])
    test_peg();

// Two split pegs, off to the side, to compare against the plain ones.
for (i = [0 : 1])
  translate([i * (peg_base_size + 6), wall_thickness + 15 + peg_base_size + 10, 0])
    split_test_peg();
