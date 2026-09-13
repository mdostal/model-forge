// Tiny Land oven grate v3 — "oven grate separated": cut from the REAL
// grate (lib/model-forge/grate.scad's oven_grate(), unmodified), not
// rebuilt from primitives. The previous rack version reconstructed
// rails/bars/edge wings from scratch, which introduced a string of new
// bugs (a wrong fillet radius, a mirror-winding bug, a corner radius
// that ate into the tenon margin) that don't exist in the original
// geometry, which already has the right shapes and sections for the
// end caps. This version calls oven_grate() directly (the archived
// oven-grate.scad and the library module are both left untouched) and
// CUTS it into 3 pieces with dovetail joints at the seams — the same
// principle as Bambu Studio's own Cut Tool, applied here so the joint
// can be parametric and reused across the whole part family.
//
// The end-cap-to-middle seam tab runs along X (perpendicular cut,
// dovetail_tab_2d rotated -90) while the existing bar-to-rail tenons
// inside the middle piece run along Y — a 90-degree relationship
// between the two joint systems, as asked for.
//
// Cut position (33.89mm from each edge) lands exactly at the boundary
// between bar 2 and the gap after it — no bar gets sliced, and it's
// comfortably past the 25.4mm corner-radius zone so there's solid,
// full-thickness frame material for the tenon (no fragile margin like
// the old wrap-around edge bar had).
//
// Fill orientation, confirmed twice: the two ROUNDED EDGE pieces carry
// the tab, positioned fill-on-top / tenon-from-bottom (z=0 up to
// thickness-floor_thickness, solid above that) — these pieces are
// loaded by the whole rack pulling against the oven cavity's side
// groove, not by weight from above. The MIDDLE piece gets the matching
// slot at the same z-range. This is a SEPARATE joint from the existing
// bar-into-rail system inside the middle piece (unchanged, still
// floor-at-bottom there — those bars ARE loaded from above).
//
// Middle piece checked at 217.97 x 228.6mm — fits the 256mm bed flat,
// no rotation or further cut needed.
use <model-forge/grate.scad>
use <model-forge/joint.scad>

/* [Size — inches] */
outer_width_in  = 11.25;
outer_height_in = 9;
corner_radius_in = 1;

/* [Bars] */
thickness_mm   = 5.08;
frame_width_mm = 6.35;
bar_width_mm   = 10;
gap_width_mm   = 7.6;

/* [Lip — docks into the oven cavity's support rail] */
lip_width_in     = 0.12;
end_lip_width_in = 0.5;
lip_thickness_mm = 2.5;

/* [Seam joint — ONE large dovetail spanning most of the seam height,
   not a small centered tab. We no longer need many distributed joints
   here (that was specifically for cutting through 16 repeated bars,
   which doesn't apply to this plain frame-to-frame seam) — a single
   big, tight-fitting dovetail across almost the full height is
   simpler and stronger, same principle as the Bambu sliding-dovetail.
   190mm leaves ~19mm margin on each end within the piece's 228.6mm
   height; checked that x=cut_x=33.89 is already 8.49mm past the
   25.4mm corner-radius zone, so full height is available there, no
   tapering-margin concern like the old wrap-around edge bar had. */
seam_tenon_width = 190;
seam_tenon_depth = 6;
seam_tenon_taper = 2;
seam_clearance   = -0.1;   // validated winning value
floor_thickness  = 1;      // matches the bar/rail mortise floor elsewhere

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
cut_x = 33.89; // see header comment — lands in the gap after bar 2
tenon_h = thickness_mm - floor_thickness;
BIG = 1000;

module full_grate() {
  oven_grate(
    outer_width   = outer_w,
    outer_height  = outer_h,
    corner_radius = corner_radius_in * IN_TO_MM,
    thickness     = thickness_mm,
    frame_width   = frame_width_mm,
    bar_width     = bar_width_mm,
    gap_width     = gap_width_mm,
    lip_width     = lip_width_in * IN_TO_MM,
    end_lip_width = end_lip_width_in * IN_TO_MM,
    lip_thickness = lip_thickness_mm
  );
}

// The tab, on the seam plane, centered on the piece's own y-midpoint.
// z=0 to (thickness-floor_thickness): fill-on-top / tenon-from-bottom.
module seam_tab(y_center) {
  translate([cut_x, y_center, 0])
    rotate([0, 0, -90])
      linear_extrude(height = tenon_h)
        dovetail_tab_2d(seam_tenon_width, seam_tenon_depth, seam_tenon_taper);
}

module seam_slot(y_center) {
  translate([cut_x, y_center, -1])
    rotate([0, 0, -90])
      linear_extrude(height = tenon_h + 1)
        dovetail_tab_2d(
          seam_tenon_width + 2 * seam_clearance,
          seam_tenon_depth + seam_clearance,
          seam_tenon_taper + seam_clearance
        );
}

module left_edge_piece() {
  union() {
    intersection() {
      full_grate();
      translate([-BIG, -BIG, -1])
        cube([BIG + cut_x, outer_h + 2 * BIG, thickness_mm + 2]);
    }
    seam_tab(outer_h / 2);
  }
}

module right_edge_piece() {
  mirror([1, 0, 0])
    translate([-outer_w, 0, 0])
      left_edge_piece();
}

module middle_piece() {
  difference() {
    intersection() {
      full_grate();
      translate([cut_x, -BIG, -1])
        cube([outer_w - 2 * cut_x, outer_h + 2 * BIG, thickness_mm + 2]);
    }
    seam_slot(outer_h / 2);
    translate([outer_w, 0, 0])
      mirror([1, 0, 0])
        seam_slot(outer_h / 2);
  }
}

left_edge_piece();
translate([0, outer_h + 20, 0]) right_edge_piece();
translate([0, -(outer_h + 20), 0]) middle_piece();
