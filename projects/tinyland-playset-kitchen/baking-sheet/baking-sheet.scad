// Tiny Land baking sheet with handles — matches the paper template
// (11.25 x 6.25in overall). Standalone, printable file.
// View > Show Customizer for sliders. Per the design: only 5 "super
// simple" variables drive the pan itself (pan_width/height, handle_size,
// handle_thickness, pan_depth) — corner rounding, floor thickness, and
// handle width all scale automatically. handle_hole_margin_mm controls
// the hand-grip loop cutout.
use <model-forge/baking_sheet.scad>

/* [Pan — inches] */
pan_width_in  = 9.75;  // body only, NOT including handles (total with handles = pan_width_in + 2*handle_size_in)
pan_height_in = 6.25;

/* [Handles] */
handle_size_in       = 0.75; // [0.25:0.05:2]   how far each handle protrudes
handle_thickness_mm  = 2;    // [0.5:0.5:6]
handle_hole_margin_mm = -1;  // [-1:0.5:15]  -1 = auto-scaled loop thickness; 0 = solid tab, no cutout

/* [Pan depth] */
pan_depth_mm = 8; // [2:1:20]  controls floor + rim thickness together

IN_TO_MM = 25.4;

baking_sheet(
  pan_width          = pan_width_in * IN_TO_MM,
  pan_height         = pan_height_in * IN_TO_MM,
  handle_size        = handle_size_in * IN_TO_MM,
  handle_thickness   = handle_thickness_mm,
  pan_depth          = pan_depth_mm,
  handle_hole_margin = handle_hole_margin_mm
);
