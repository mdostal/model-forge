// Tiny Land baking sheet — handle RECESS fit test (companion to
// handle-peg-test.scad).
//
// Real design insight: a flush butt joint plus a thin peg only resists
// shear, not bending/prying -- nothing stops the two flat faces from
// rocking apart except the peg's own strength. Recessing a section of
// the handle INTO a matching pocket in the pan wall gives it bearing
// surface on multiple sides instead, so it can't rock or peel away --
// same principle as a mortise-and-tenon vs. a dowel butted against a
// flat face. This tests how tight that pocket fit can get -- aiming
// close to a snap-together press fit, not just a loose slip fit.
//
// Rounded-corner rectangular plug/pocket (not a small peg): the point
// here is a BROAD bearing surface, not a stress-concentrated small
// feature. Small corner radius still gets the FDM stress-distribution
// benefit (give concentrates at the corners, not a full-perimeter hoop
// strain) without shrinking the contact area like a round peg would.
//
// Same clearance-sweep methodology as every other tolerance test
// tonight -- comb of pockets at different clearances, one matching plug
// to press-test into each.
use <model-forge/tray.scad> // rounded_rect_2d

wall_thickness = 12;
wall_height    = 20;

plug_w = 14;   // the recessed section's width (along the wall's length)
plug_h = 10;   // how tall the pocket is (matches a chunk of wall_height)
plug_depth = 6; // how deep the plug seats into the wall
corner_r = 1.5; // small radius -- FDM stress-distribution benefit without losing bearing area

clearances = [-0.3, -0.2, -0.15, -0.1, -0.05, 0];
step = 20;

// One pocket, opening on the wall's top face, straight-walled (no
// taper -- this is about bearing-surface fit, not a self-locking
// wedge like the peg test).
module pocket_at(x_center, clearance) {
  w = plug_w + 2 * clearance;
  h = plug_h + 2 * clearance;
  r = max(0.2, corner_r + clearance);
  translate([x_center - w / 2, wall_thickness / 2 - h / 2, wall_height - plug_depth - 1])
    linear_extrude(height = plug_depth + 2)
      rounded_rect_2d(w, h, r);
}

module test_wall() {
  difference() {
    cube([len(clearances) * step, wall_thickness, wall_height]);
    for (i = [0 : len(clearances) - 1])
      pocket_at(i * step + step / 2, clearances[i]);
    for (i = [0 : len(clearances) - 1])
      translate([i * step + 3, wall_thickness - 3, wall_height - 4])
        rotate([90, 0, 0])
          linear_extrude(height = 0.5)
            text(str(clearances[i]), size = 3);
  }
}

module test_plug() {
  linear_extrude(height = plug_depth)
    rounded_rect_2d(plug_w, plug_h, corner_r);
}

test_wall();

// Loose plugs to press-test into the pockets above.
for (i = [0 : 2])
  translate([i * (plug_w + 8), wall_thickness + 15, 0])
    test_plug();
