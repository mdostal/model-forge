// Tiny Land oven insert — grate, split into 2 printable halves.
//
// The grate's own footprint (311mm incl. the lip flare) only exceeds
// the 256mm bed on the X axis, so ONE cut is enough — no 2x2 grid like
// the back wall needs. The cut sits at outer_width/2 (142.875mm), which
// lands exactly in the gap between bar 8 and bar 9 of the bar pattern
// (verified against the grate's own auto-fit bar/gap math: bars run
// 10mm on a 17.537mm pitch, and that pitch happens to put a gap right
// at the panel's center). So NEITHER half needs to touch a structural
// bar — every bar stays fully intact inside one half or the other. The
// only things that actually cross the seam are the continuous top and
// bottom frame border strips (each only frame_width_mm=6.35mm tall),
// so that's the only place a joint goes: one small dovetail per strip,
// not a full tab row like the wall's — "alternating small ends into
// larger hollow ends," same principle, scaled down to fit inside a
// 6.35mm-tall strip on a 5.08mm-thick panel.
//
// joint_clearance below is a PLACEHOLDER pending dovetail-fit-test.scad's
// physical result — replace it with whichever slot on that comb actually
// snapped/held once it's been tested, then re-render.
use <model-forge/grate.scad>
use <model-forge/joint.scad>

/* [Size — inches, matches oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;
corner_radius_in = 1;

/* [Bars] */
thickness_mm   = 5.08;
frame_width_mm = 6.35;
bar_width_mm   = 10;
gap_width_mm   = 7.6;

/* [Lip] */
lip_width_in     = 0.12;
end_lip_width_in = 0.5;
lip_thickness_mm = 2.5;

/* [Joint — placeholder, tune from dovetail-fit-test.scad] */
joint_clearance = -0.15; // PLACEHOLDER — swap for the tested winning value
joint_tab_width = 3.5;   // scaled down to fit inside the 6.35mm frame band
joint_tab_depth = 2.5;
joint_taper     = 0.8;

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
cut_x = outer_w / 2; // lands in the bar8/bar9 gap — see header comment
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

// One small dovetail, on the seam line, centered on a frame band.
// Same orientation trick as joint.scad's own worked example: rotate
// -90 so the tab/slot protrudes further +X from a right-facing edge.
module frame_band_tab(y_center) {
  translate([cut_x, y_center, 0])
    rotate([0, 0, -90])
      linear_extrude(height = thickness_mm)
        dovetail_tab_2d(joint_tab_width, joint_tab_depth, joint_taper);
}

module frame_band_slot(y_center) {
  translate([cut_x, y_center, -1])
    rotate([0, 0, -90])
      linear_extrude(height = thickness_mm + 2)
        dovetail_tab_2d(
          joint_tab_width + 2 * joint_clearance,
          joint_tab_depth + joint_clearance,
          joint_taper + joint_clearance
        );
}

module half_A() {
  union() {
    intersection() {
      full_grate();
      translate([-BIG, -BIG, -1])
        cube([BIG + cut_x, outer_h + 2 * BIG, thickness_mm + 2]);
    }
    frame_band_tab(frame_width_mm / 2);
    frame_band_tab(outer_h - frame_width_mm / 2);
  }
}

module half_B() {
  difference() {
    intersection() {
      full_grate();
      translate([cut_x, -BIG, -1])
        cube([BIG + (outer_w - cut_x), outer_h + 2 * BIG, thickness_mm + 2]);
    }
    frame_band_slot(frame_width_mm / 2);
    frame_band_slot(outer_h - frame_width_mm / 2);
  }
}

half_A();
translate([0, outer_h + 20, 0]) half_B();
