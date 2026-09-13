// Tiny Land oven grate v2 — rack-construction proof piece.
//
// Bug fixed 2026-09-13: the first version union()'d the rail and bars
// together in OpenSCAD, so it printed as one pre-fused solid -- there
// was nothing left to actually test, since the joint was assembled in
// software instead of by hand. Same mistake class as the sealed test
// comb from 2026-09-12: a "test" only tests something if the pieces
// print SEPARATE and get assembled for real.
//
// Now prints 3 separate objects: one rail (2 slots) and two bars (each
// with a tenon on both ends). Press a bar's tenon into a rail slot by
// hand to actually test the -0.1mm fit before scaling to the real
// 16-bar, full-length grate.
use <model-forge/rack.scad>

rail_length   = 50;
rail_width    = 6.35; // matches the grate's frame_width
thickness     = 5.08; // matches the grate's own thickness
bar_width     = 10;   // matches the grate's own bar_width
span          = 20;   // short test span — the real grate's bars are ~216mm
n_bars        = 2;
bar_pitch     = 20;
first_offset  = 10;

// The rail — slots open on its y=0 edge (rack_rail's natural
// orientation), so a bar's tenon presses straight in from above.
rack_rail(rail_length, rail_width, thickness, n_bars, bar_pitch, first_offset);

// Two separate bars, laid out beside the rail with clear gaps.
translate([0, rail_width + 15, 0])
  rack_bar(span, bar_width, thickness);

translate([bar_width + 15, rail_width + 15, 0])
  rack_bar(span, bar_width, thickness);
