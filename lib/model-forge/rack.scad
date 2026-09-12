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

// A single bar spanning `span`, with a tenon on each end (at y=0,
// pointing further -Y, and at y=span, pointing further +Y).
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
  tenon_width = DEFAULT_TENON_WIDTH,
  tenon_depth = DEFAULT_TENON_DEPTH,
  tenon_taper = DEFAULT_TENON_TAPER
) {
  eps = 0.3;
  union() {
    translate([0, -eps, 0])
      cube([bar_width, span + 2 * eps, thickness]);
    translate([bar_width / 2, 0, 0])
      rotate([0, 0, 180])
        linear_extrude(height = thickness)
          dovetail_tab_2d(tenon_width, tenon_depth, tenon_taper);
    translate([bar_width / 2, span, 0])
      linear_extrude(height = thickness)
        dovetail_tab_2d(tenon_width, tenon_depth, tenon_taper);
  }
}

// A straight rail with n_bars evenly-spaced mortise slots along its
// y=0 edge, cutting +Y into rail_width. Mirror this piece (mirror
// ([0,1,0]) then translate) to use it as the opposite-facing rail in an
// assembly — the slot pattern is symmetric, only the facing direction
// changes.
module rack_rail(
  length,
  rail_width,
  thickness,
  n_bars,
  bar_pitch,
  first_offset,
  tenon_width = DEFAULT_TENON_WIDTH,
  tenon_depth = DEFAULT_TENON_DEPTH,
  tenon_taper = DEFAULT_TENON_TAPER,
  clearance   = DEFAULT_CLEARANCE
) {
  difference() {
    cube([length, rail_width, thickness]);
    for (i = [0 : n_bars - 1])
      translate([first_offset + i * bar_pitch, 0, -1])
        linear_extrude(height = thickness + 2)
          dovetail_tab_2d(
            tenon_width + 2 * clearance,
            tenon_depth + clearance,
            tenon_taper + clearance
          );
  }
}
