// model-forge/rack.scad — oven-rack-style construction: individual bars
// that dovetail into mortise slots on a rail, instead of one molded
// panel. Replaces the "cut a monolithic grate in half" approach: that
// either avoids the bars entirely (leaving only 2 tiny joints holding
// the whole panel together — a weak load path) or requires a shallow
// in-plane tab carved into a thin panel edge (limited by the panel's
// own thin cross-section). A real oven rack is built this way for a
// reason: each bar's FULL cross-section becomes the tenon, engaging the
// rail through its whole thickness — much stronger than a shallow edge
// tab, and the load is distributed across every bar instead of 2 points.
//
// Tenon defaults are the validated small-scale dovetail from
// dovetail-fit-test-small.scad (tab_width=3.5, tab_depth=2.5, taper=0.8)
// at clearance=-0.1mm — the winning value from a real print test
// (-0.15 held but needed a mallet and risked overstressing the joint;
// -0.1 was solid without excessive force).
use <model-forge/joint.scad> // dovetail_tab_2d

DEFAULT_TENON_WIDTH = 3.5;
DEFAULT_TENON_DEPTH = 2.5;
DEFAULT_TENON_TAPER = 0.8;
DEFAULT_CLEARANCE   = -0.1;
// A blind pocket instead of a through-slot: leaves this much solid
// material at the BOTTOM of the mortise (z=0 to floor_thickness) so a
// bar's tenon has a real seat to rest against instead of being able to
// slide all the way through with no positive stop. User: "the middle
// can actually have a small base layer under the rail so that the edge
// rails can hold the dovetail piece without allowing it to fall
// through -- even a 1mm... would work well." Set to 0 for the old
// through-slot behavior.
DEFAULT_FLOOR_THICKNESS = 1;

// A single bar spanning `span`, with a tenon on each end (at y=0,
// pointing further -Y, and at y=span, pointing further +Y). The tenon
// itself is shortened to (thickness - floor_thickness) and lifted to
// start at z=floor_thickness, so its bottom face lands exactly on the
// rail's mortise floor instead of continuing past it.
//
// eps: the bar's own base cube overlaps span by eps on each end so it
// genuinely penetrates into the rail's solid volume, not just touches
// it flush. dovetail_tab_2d's own base_overlap already handles this for
// the tenon itself, but the FLAT part of the bar's end face (the width
// outside the tenon) was still landing exactly coincident with the
// rail's flat face -- confirmed via a non-manifold-edge check (trimesh
// found them at exactly y=rail_width and y=rail_width+span, everywhere
// except the tenon). Same class of bug as tray.scad's lip eps and
// joint.scad's tab base_overlap.
module rack_bar(
  span,
  bar_width,
  thickness,
  tenon_width     = DEFAULT_TENON_WIDTH,
  tenon_depth     = DEFAULT_TENON_DEPTH,
  tenon_taper     = DEFAULT_TENON_TAPER,
  floor_thickness = DEFAULT_FLOOR_THICKNESS
) {
  eps = 0.3;
  tenon_h = thickness - floor_thickness;
  union() {
    translate([0, -eps, 0])
      cube([bar_width, span + 2 * eps, thickness]);
    translate([bar_width / 2, 0, floor_thickness])
      rotate([0, 0, 180])
        linear_extrude(height = tenon_h)
          dovetail_tab_2d(tenon_width, tenon_depth, tenon_taper);
    translate([bar_width / 2, span, floor_thickness])
      linear_extrude(height = tenon_h)
        dovetail_tab_2d(tenon_width, tenon_depth, tenon_taper);
  }
}

// A straight rail with n_bars evenly-spaced mortise slots along its
// y=0 edge, cutting +Y into rail_width. Each slot is a blind pocket
// (see floor_thickness above), not a through-cut. Mirror this piece
// (mirror([0,1,0]) then translate) to use it as the opposite-facing
// rail in an assembly — the slot pattern is symmetric, only the facing
// direction changes.
module rack_rail(
  length,
  rail_width,
  thickness,
  n_bars,
  bar_pitch,
  first_offset,
  tenon_width     = DEFAULT_TENON_WIDTH,
  tenon_depth     = DEFAULT_TENON_DEPTH,
  tenon_taper     = DEFAULT_TENON_TAPER,
  clearance       = DEFAULT_CLEARANCE,
  floor_thickness = DEFAULT_FLOOR_THICKNESS
) {
  difference() {
    cube([length, rail_width, thickness]);
    for (i = [0 : n_bars - 1])
      translate([first_offset + i * bar_pitch, 0, floor_thickness])
        linear_extrude(height = thickness - floor_thickness + 1)
          dovetail_tab_2d(
            tenon_width + 2 * clearance,
            tenon_depth + clearance,
            tenon_taper + clearance
          );
  }
}

// A plain straight side rail (no mortises — bars don't attach to it)
// running along `length`, with an optional lip flange on its outer
// (x<0) edge for docking into the oven cavity's support-rail groove,
// same mechanism as tray.scad/grate.scad's lip. Corner-to-corner
// joinery between this and the long rails (rack_rail) isn't designed
// yet — this piece alone doesn't connect to anything.
module rack_side_rail(length, rail_width, thickness, lip_width = 0, lip_thickness = 0) {
  eps = 0.05;
  union() {
    cube([rail_width, length, thickness]);
    if (lip_width > 0 && lip_thickness > 0)
      translate([-lip_width, 0, thickness - lip_thickness])
        cube([lip_width + eps, length, lip_thickness]);
  }
}
