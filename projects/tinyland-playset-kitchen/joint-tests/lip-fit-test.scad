// Tiny Land oven insert — lip fit-test coupons. Small, fast-printing
// crops taken directly out of the REAL tray/grate geometry (not a
// separately-modeled approximation) via intersection() with a small box,
// so what you test-fit against the oven cavity's support rail is exactly
// the lip that will ship on the full parts. Two coupons print at once:
// one corner of the tray, one corner of the grate — a corner crop shows
// BOTH lip_width (long edge) and end_lip_width (short edge) in a single
// piece, joined by the rounded corner.
//
// Corner, not a straight edge: an edge-middle crop of the grate falls
// apart into loose disconnected bar fragments (verified via trimesh —
// only the frame's un-gapped border band along each edge actually ties
// the bars together, and a straight-edge-middle crop misses the
// perpendicular band). A corner crop always includes both perimeter
// frame bands, so it stays one connected, printable piece.
//
// Print this, press it into the real rail groove, confirm lip_thickness_mm
// fits (<=3mm), then dial in oven-tray.scad / oven-grate.scad and iterate.
use <model-forge/tray.scad>
use <model-forge/grate.scad>

/* [Full-part dimensions — keep in sync with oven-tray.scad / oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;
corner_radius_in = 1;

/* [Tray pocket] */
floor_thickness_mm = 5.08;
rim_height_mm       = 3.81;
inset_margin_mm      = 6.35;

/* [Grate bars] */
grate_thickness_mm   = 5.08;
frame_width_mm       = 6.35;
bar_width_mm         = 10;
gap_width_mm         = 7.6;

/* [Lip — slides into the oven cavity's support-rail groove] */
lip_width_in     = 0.12; // [0:0.01:1]  long (top/bottom) edges
end_lip_width_in = 0.5;  // [0:0.01:1]  short (left/right) edges
lip_thickness_mm = 2.5;  // [0.5:0.1:3]  must be <=3mm to fit the real rail; 2.5mm is the sweet spot

/* [Coupon] */
coupon_size_mm = 50; // [20:5:100]  edge length of each cropped square test piece
coupon_gap_mm  = 8;  // [2:1:30]    spacing between the 2 coupons on the plate

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
CROP_TALL = 100; // taller than any real part height — just needs to fully cover it

module full_tray() {
  rounded_tray(
    outer_width     = outer_w,
    outer_height    = outer_h,
    corner_radius   = corner_radius_in * IN_TO_MM,
    floor_thickness = floor_thickness_mm,
    rim_height      = rim_height_mm,
    inset_margin    = inset_margin_mm,
    lip_width       = lip_width_in * IN_TO_MM,
    end_lip_width   = end_lip_width_in * IN_TO_MM,
    lip_thickness   = lip_thickness_mm
  );
}

module full_grate() {
  oven_grate(
    outer_width   = outer_w,
    outer_height  = outer_h,
    corner_radius = corner_radius_in * IN_TO_MM,
    thickness     = grate_thickness_mm,
    frame_width   = frame_width_mm,
    bar_width     = bar_width_mm,
    gap_width     = gap_width_mm,
    lip_width     = lip_width_in * IN_TO_MM,
    end_lip_width = end_lip_width_in * IN_TO_MM,
    lip_thickness = lip_thickness_mm
  );
}

// Crop a coupon_size x coupon_size square out of the bottom-left corner
// (X=0 short edge meets Y=0 long edge) — shows both lip_width and
// end_lip_width, joined by the rounded corner, as one connected piece.
//
// Bug fixed 2026-09-11: the crop window used to start at a hardcoded
// (-1,-1), which sits INSIDE the lip's own overhang — the lip flares out
// to NEGATIVE x/y (see tray.scad's lip_ring translate([-ew,-lip_width])),
// so most of end_lip_width's overhang was silently cropped away before
// it ever reached the printed coupon. margin below starts the window at
// the lip's true outer reach instead, so the full overhang prints.
module corner_crop() {
  margin = max(lip_width_in, end_lip_width_in) * IN_TO_MM + 1;
  intersection() {
    children(0);
    translate([-margin, -margin, -1])
      cube([coupon_size_mm, coupon_size_mm, CROP_TALL]);
  }
}

step = coupon_size_mm + coupon_gap_mm;

translate([0, 0, 0])    corner_crop() full_tray();
translate([step, 0, 0]) corner_crop() full_grate();
