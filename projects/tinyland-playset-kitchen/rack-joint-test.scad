// Tiny Land oven grate v2 — rack-construction proof piece. 2 short bars
// dovetailing into a bottom rail and a top rail, at the validated
// -0.1mm clearance. Small and fast to print, just to prove the
// mechanism (alignment, tenon-into-slot fit, and that the whole thing
// fuses into one connected assembly) before scaling to the real 16-bar,
// full-length grate.
use <model-forge/rack.scad>

rail_length   = 50;
rail_width    = 6.35; // matches the grate's frame_width
thickness     = 5.08; // matches the grate's own thickness
bar_width     = 10;   // matches the grate's own bar_width
span          = 20;   // short test span — the real grate's bars are ~216mm
n_bars        = 2;
bar_pitch     = 20;
first_offset  = 10;

union() {
  // Bottom rail — slots face up (+Y, toward the bars).
  translate([0, rail_width, 0])
    mirror([0, 1, 0])
      rack_rail(rail_length, rail_width, thickness, n_bars, bar_pitch, first_offset);

  // Bars.
  for (i = [0 : n_bars - 1])
    translate([first_offset + i * bar_pitch - bar_width / 2, rail_width, 0])
      rack_bar(span, bar_width, thickness);

  // Top rail — slots face down (-Y, toward the bars), which is
  // rack_rail's natural orientation, no mirror needed.
  translate([0, rail_width + span, 0])
    rack_rail(rail_length, rail_width, thickness, n_bars, bar_pitch, first_offset);
}
