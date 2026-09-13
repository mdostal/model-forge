// Tiny Land oven grate v2 — full-scale rack construction: 16 bars
// dovetailing into a top rail and a bottom rail, at the validated
// -0.1mm clearance. Same numbers as the original oven_grate()'s
// auto-fit bar pattern (16 bars, 10mm wide, 7.537mm gaps) so this sits
// in the exact same footprint.
//
// 14 normal bars + 2 edge bars (2026-09-13): the outermost bar on each
// side is wider — extended out to the frame's true edge with a rounded
// outer corner and the docking lip — instead of a separate perpendicular
// side-rail piece. Same tenon-into-mortise mechanism as every other bar,
// just a wider body on the outer end. No new joint type, no separate
// corner joinery to design.
//
// The rail (285.75mm) doesn't need a cut: it's only 6.35mm wide, and
// rotated ~45 degrees on the bed its bounding box drops to
// ~206.5 x 206.5mm, comfortably inside the 256mm bed. Rotate it in
// Bambu Studio and print it whole.
use <model-forge/rack.scad>

/* [Size — inches, matches oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;

/* [Bars] */
frame_width_mm = 6.35;
bar_width_mm   = 10;
n_bars         = 16;

/* [Edge bars — the outermost bar on each side, wider with a rounded
   outer corner and the lip that docks into the oven cavity's rail] */
end_lip_width_in = 0.5;  // matches the short-edge lip from oven-tray.scad/oven-grate.scad
lip_thickness_mm = 2.5;  // matches the validated 2.5mm rail-fit thickness
edge_fillet_mm   = 3;    // must stay <= wing_width/2 (frame_width_mm/2 = 3.175) or the
                          // fillet circle bulges past the flat edge instead of blending into it

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;

// One rail — 16 slots, 285.75mm long. Same rail design works as both
// top and bottom (mirror it for the opposite-facing slots — see
// rack.scad).
module grate_rail() {
  rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);
}

// One normal bar — 215.9mm, fits the bed on its own.
module grate_bar() {
  rack_bar(inner_h, bar_width_mm, thickness);
}

// The left edge bar — wing extends further left (outward), lip beyond that.
module grate_edge_bar_left() {
  rack_edge_bar(inner_h, bar_width_mm, thickness, frame_width_mm, edge_fillet_mm,
    end_lip_width_in * IN_TO_MM, lip_thickness_mm);
}

// The right edge bar — same piece, mirrored so its wing/lip extend right.
module grate_edge_bar_right() {
  mirror([1, 0, 0])
    grate_edge_bar_left();
}

grate_rail();

// The 14 normal bars (positions 1 through 14 of 16), tiled on one plate.
bar_gap = 3;
for (i = [1 : n_bars - 2])
  translate([(i - 1) * (bar_width_mm + bar_gap), frame_width_mm + 20, 0])
    grate_bar();

// The 2 edge bars (positions 0 and 15), off to the side.
translate([0, frame_width_mm + 20 + inner_h + 20, 0])
  grate_edge_bar_left();
translate([bar_width_mm + frame_width_mm + edge_fillet_mm + 10, frame_width_mm + 20 + inner_h + 20, 0])
  grate_edge_bar_right();
