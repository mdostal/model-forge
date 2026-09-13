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

// 2D wing profile: flat on the LEFT edge (x=0, where it joins a bar's
// own body), rounded on the RIGHT edge (the outer, x=width side).
// Built as a hull of two near-zero-radius points pinning the flat left
// edge and two real-radius circles rounding the right edge — same
// hull-of-circles technique as tray.scad's rounded_rect_2d.
//
// fillet_r must stay <= width/2, or the fillet circles (centered at
// width-fillet_r) bulge past x=0 and the "flat" edge disappears —
// confirmed: fillet_r=5 on width=6.35 put the circle center only
// 1.35mm from the edge with a 5mm radius, extending to x=-3.65 instead
// of stopping at x=0.
module edge_wing_2d(width, height, fillet_r) {
  hull() {
    translate([0, 0]) circle(r = 0.01, $fn = 8);
    translate([0, height]) circle(r = 0.01, $fn = 8);
    translate([width - fillet_r, fillet_r]) circle(r = fillet_r, $fn = 32);
    translate([width - fillet_r, height - fillet_r]) circle(r = fillet_r, $fn = 32);
  }
}

// An edge bar: identical tenon mechanism to rack_bar (dovetails into
// the SAME rail mortises, at the SAME pitch position as any other bar)
// but wider — extended out to the frame's true outer edge with a
// rounded outer corner, plus the lip flange for docking into the oven
// cavity's support rail. Replaces a separate perpendicular side-rail
// piece entirely: "why are you separating the side ones from the rail
// next to it -- we have 14 normal rails and 2 side rails with a nice
// rounded taper." No new joint type — same dovetail-into-mortise
// mechanism as every other bar, just a wider body on the outer end.
//
// wing_width: how far the wing extends beyond the bar's own bar_width
// (normally = frame_width_mm, reaching exactly to the true frame edge).
// Mirror this module (mirror([1,0,0]) after translating to the bar's
// own local origin) to build the RIGHT-side edge bar from the same code.
module rack_edge_bar(
  span,
  bar_width,
  thickness,
  wing_width,
  fillet_r,
  lip_width       = 0,
  lip_thickness   = 0,
  tenon_width     = DEFAULT_TENON_WIDTH,
  tenon_depth     = DEFAULT_TENON_DEPTH,
  tenon_taper     = DEFAULT_TENON_TAPER,
  floor_thickness = DEFAULT_FLOOR_THICKNESS
) {
  eps = 0.3; // same coincident-face overlap as rack_bar's own base cube
  union() {
    rack_bar(span, bar_width, thickness, tenon_width, tenon_depth, tenon_taper, floor_thickness);
    // Wing overlaps eps into the bar's own core (positive x) instead of
    // stopping exactly flush at x=0 -- same class of bug as the
    // bar/rail coincident face fixed earlier.
    //
    // Bug fixed 2026-09-13: mirroring the 2D profile BEFORE
    // linear_extrude (mirror([1,0]) on edge_wing_2d itself) inverts the
    // polygon winding -- the resulting solid was watertight on its own
    // but with is_winding_consistent=False and NEGATIVE volume. Unioned
    // with the bar's normal-winding solid, this silently produced a
    // mesh missing the wing entirely (confirmed: OpenSCAD's own "mesh
    // is not closed" warning, and the exported STL had no wing
    // geometry at all). Fix: mirror the 3D solid AFTER extrusion
    // instead, which OpenSCAD's dedicated 3D mirror handles correctly.
    translate([eps, 0, 0])
      mirror([1, 0, 0])
        linear_extrude(height = thickness)
          edge_wing_2d(wing_width, span, fillet_r);
    if (lip_width > 0 && lip_thickness > 0)
      translate([-wing_width - lip_width + eps, 0, thickness - lip_thickness])
        cube([lip_width, span, lip_thickness]);
  }
}
