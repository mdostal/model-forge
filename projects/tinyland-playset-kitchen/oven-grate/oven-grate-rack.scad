// Tiny Land oven grate v2 — full-scale rack construction: 16 real bars
// dovetailing into a top rail and a bottom rail, at the validated
// -0.1mm clearance. Same numbers as the original oven_grate()'s
// auto-fit bar pattern (16 bars, 10mm wide, 7.537mm gaps) so this sits
// in the exact same footprint.
//
// Bug fixed 2026-09-13: the rail (285.75mm) doesn't actually need a
// cut. It's only 6.35mm wide -- rotated ~45 degrees on the bed, its
// bounding box drops to ~206.5 x 206.5mm, well inside the 256mm bed
// (checked: it fits anywhere from ~28 to ~62 degrees, not just exactly
// 45). This is the same bed-diagonal rotation trick discussed earlier
// for the full grate panel, which correctly does NOT help there (it's
// 235mm wide, too wide for rotation to save it) -- just hadn't been
// re-applied to this much narrower rail. Rotate it in Bambu Studio and
// print it in one piece; no Cut Tool step needed here at all.
//
// The 16 bars (215.9mm each) all fit the bed individually and are laid
// out here as one printable plate.
use <model-forge/rack.scad>

/* [Size — inches, matches oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;

/* [Bars] */
frame_width_mm = 6.35;
bar_width_mm   = 10;
n_bars         = 16;

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;

// One rail — 16 slots, 285.75mm long (exceeds the bed; splice via
// Bambu Studio's sliding Dovetail cut, not here). Same rail design
// works as both top and bottom (mirror it for the opposite-facing
// slots — see rack.scad).
module grate_rail() {
  rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);
}

// One bar — 215.9mm, fits the bed on its own.
module grate_bar() {
  rack_bar(inner_h, bar_width_mm, thickness);
}

grate_rail();

// All 16 bars, tiled on one plate below the rail.
bar_gap = 3;
for (i = [0 : n_bars - 1])
  translate([i * (bar_width_mm + bar_gap), frame_width_mm + 20, 0])
    grate_bar();
