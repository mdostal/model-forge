// Tiny Land oven grate v3b — "oven grate half": the 2-part comparison
// piece. Same cut-the-real-shape principle as oven-grate-separated.scad
// (calls oven_grate() directly, untouched), but a single seam right
// down the middle instead of 2 seams near the edges.
//
// Cut at bar 9's center (151.64mm) -- the bar closest to the true
// center (142.875mm, which falls in a gap, same distance from bar 8 as
// bar 9). Same lesson as the 3-part fix: cut THROUGH a bar's own body,
// not a gap, so there's continuous material for the joint.
//
// "2-fold" redundant joint per direct request: one large dovetail
// through the bar's own body (main structural connection) PLUS two
// smaller dovetails in the top and bottom frame bands (which run
// continuously regardless of x-position) -- three separate connection
// points spread across the height at the one seam, for twist
// resistance, not just one big one.
//
// This seam sits at the point of PEAK bending moment for a
// center-loaded, both-ends-supported shelf (unlike oven-grate-
// separated.scad's 2 seams, which sit near the supports where moment
// is near zero) -- structurally the worse location for a joint in
// theory. Printing both to compare for real.
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

/* [Main seam joint — through the bar's own body] */
main_tenon_width = 190;
main_tenon_depth = 3;
main_tenon_taper = 1;

/* [Frame-band joints — smaller scale, fits inside the 6.35mm band] */
band_tenon_width = 3.5;
band_tenon_depth = 2.5;
band_tenon_taper = 0.8;

seam_clearance  = -0.1;  // validated winning value
floor_thickness = 1;     // matches the bar/rail mortise floor elsewhere

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
cut_x = 151.64; // bar 9's center — see header comment
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

module tab_at(y_center, width, depth, taper) {
  translate([cut_x, y_center, 0])
    rotate([0, 0, -90])
      linear_extrude(height = tenon_h)
        dovetail_tab_2d(width, depth, taper);
}

module slot_at(y_center, width, depth, taper) {
  translate([cut_x, y_center, -1])
    rotate([0, 0, -90])
      linear_extrude(height = tenon_h + 1)
        dovetail_tab_2d(
          width + 2 * seam_clearance,
          depth + seam_clearance,
          taper + seam_clearance
        );
}

module left_half() {
  union() {
    intersection() {
      full_grate();
      translate([-BIG, -BIG, -1])
        cube([BIG + cut_x, outer_h + 2 * BIG, thickness_mm + 2]);
    }
    tab_at(outer_h / 2, main_tenon_width, main_tenon_depth, main_tenon_taper);
    tab_at(frame_width_mm / 2, band_tenon_width, band_tenon_depth, band_tenon_taper);
    tab_at(outer_h - frame_width_mm / 2, band_tenon_width, band_tenon_depth, band_tenon_taper);
  }
}

module right_half() {
  difference() {
    intersection() {
      full_grate();
      translate([cut_x, -BIG, -1])
        cube([outer_w - cut_x + BIG, outer_h + 2 * BIG, thickness_mm + 2]);
    }
    slot_at(outer_h / 2, main_tenon_width, main_tenon_depth, main_tenon_taper);
    slot_at(frame_width_mm / 2, band_tenon_width, band_tenon_depth, band_tenon_taper);
    slot_at(outer_h - frame_width_mm / 2, band_tenon_width, band_tenon_depth, band_tenon_taper);
  }
}

left_half();
translate([0, -(outer_h + 20), 0]) right_half();
