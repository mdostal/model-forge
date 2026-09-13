// Tiny Land oven grate v2 — full-scale rack construction: 16 bars
// dovetailing into a top rail and a bottom rail, at the validated
// -0.1mm clearance. Same bar pattern as the original oven_grate()'s
// auto-fit (16 bars, 10mm wide, 7.537mm gaps) so this sits in the exact
// same footprint.
//
// 14 normal bars + 2 edge bars. The outermost bar on each side is wider
// — extended to the frame's true edge, wrapping around the rail's own
// end with a rounded corner, plus the docking lip — instead of a
// separate perpendicular side-rail piece. Same tenon-into-mortise
// mechanism as every other bar, no new joint type.
//
// corner_radius here is 22mm, not the original design's 25.4mm.
// Checked directly: with the true 25.4mm radius, the rounded silhouette
// eats into where bar 1's own tenon connects to the rail (corner_radius
// > frame_width, so the curve reaches well past the corner square) —
// margin came out to just 0.2mm, too fragile to print reliably. 22mm
// keeps a safe 2mm margin there while staying visually very close to
// the original curve. The rail's own ends are cropped to this same
// curve (not a plain square cut) so the two pieces' silhouettes line up
// exactly where they meet.
//
// The rail (285.75mm) doesn't need a cut: it's only 6.35mm wide, and
// rotated ~45 degrees on the bed its bounding box drops to
// ~206.5 x 206.5mm, comfortably inside the 256mm bed. Rotate it in
// Bambu Studio and print it whole.
use <model-forge/rack.scad>
use <model-forge/joint.scad> // dovetail_tab_2d
use <model-forge/tray.scad>  // rounded_rect_2d

/* [Size — inches, matches oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;

/* [Bars] */
frame_width_mm = 6.35;
bar_width_mm   = 10;
n_bars         = 16;

/* [Edge bars — the outermost bar on each side, wrapped around the
   rail's end with a rounded corner and the lip that docks into the
   oven cavity's rail] */
end_lip_width_in    = 0.5;  // matches the short-edge lip from oven-tray.scad/oven-grate.scad
lip_thickness_mm    = 2.5;  // matches the validated 2.5mm rail-fit thickness
modular_corner_radius = 22; // see header comment — reduced from 25.4mm for a safe tenon margin

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;
floor_thickness = 1; // matches rack.scad's DEFAULT_FLOOR_THICKNESS
tenon_h = thickness - floor_thickness;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;
last_offset = first_offset + (n_bars - 1) * bar_pitch;
crop_x = frame_width_mm + bar_width_mm; // boundary between the edge bar and the first normal bar

// Crops a shape (already in the rail's own y:[0,frame_width_mm] local
// frame) to the true rounded silhouette, using the y=0 edge of the
// curve — works for either the top or bottom rail since the curve is
// identical (mirrored) at both ends; mirror the RESULT to flip which
// edge it represents, same as before.
module corner_crop_2d() {
  intersection() {
    children(0);
    rounded_rect_2d(outer_w, outer_h, modular_corner_radius);
  }
}

// One rail — 16 slots, ends tapered to the true rounded silhouette
// (not a plain square cut) so it lines up exactly with the edge bars'
// own wrap. Same rail works as both top and bottom (mirror it for the
// opposite-facing slots — see rack.scad).
module grate_rail() {
  intersection() {
    rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);
    linear_extrude(height = thickness + 2)
      translate([0, 0])
        rounded_rect_2d(outer_w, outer_h, modular_corner_radius);
  }
}

// One normal bar — 215.9mm, fits the bed on its own.
module grate_bar() {
  rack_bar(inner_h, bar_width_mm, thickness);
}

// An edge bar: the true rounded silhouette cropped to just this bar's
// own column (x: 0 to crop_x), plus tenons at the same y-positions
// where the rail sits, plus the lip on the outer edge. Wraps all the
// way around the rail's end instead of butting a separate piece
// against it.
module grate_edge_bar_left() {
  eps = 0.05;
  lip_w = end_lip_width_in * IN_TO_MM;
  union() {
    intersection() {
      linear_extrude(height = thickness)
        rounded_rect_2d(outer_w, outer_h, modular_corner_radius);
      translate([-1, -1, -1])
        cube([crop_x + 1, outer_h + 2, thickness + 2]);
    }
    // Tenon into the bottom rail (protrudes further -Y).
    translate([first_offset, frame_width_mm, floor_thickness])
      rotate([0, 0, 180])
        linear_extrude(height = tenon_h)
          dovetail_tab_2d(3.5, 2.5, 0.8);
    // Tenon into the top rail (protrudes further +Y).
    translate([first_offset, outer_h - frame_width_mm, floor_thickness])
      linear_extrude(height = tenon_h)
        dovetail_tab_2d(3.5, 2.5, 0.8);
    // Lip on the outer (x<0) edge, spanning the same run as a normal bar.
    translate([-lip_w, frame_width_mm, thickness - lip_thickness_mm])
      cube([lip_w + eps, inner_h, lip_thickness_mm]);
  }
}

// The right edge bar — same piece, mirrored so its wrap/lip extend right.
module grate_edge_bar_right() {
  mirror([1, 0, 0])
    translate([-outer_w, 0, 0])
      grate_edge_bar_left();
}

grate_rail();

// The 14 normal bars (positions 1 through 14 of 16), tiled on one plate.
bar_gap = 3;
for (i = [1 : n_bars - 2])
  translate([(i - 1) * (bar_width_mm + bar_gap), frame_width_mm + 20, 0])
    grate_bar();

// The 2 edge bars, off to the side.
translate([0, frame_width_mm + 20 + inner_h + 20, 0])
  grate_edge_bar_left();
translate([crop_x + 15, frame_width_mm + 20 + inner_h + 20, 0])
  grate_edge_bar_right();
