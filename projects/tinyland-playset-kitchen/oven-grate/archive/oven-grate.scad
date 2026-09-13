// Tiny Land oven insert — grate/rack variant. Standalone, printable file.
// View > Show Customizer for sliders.
use <model-forge/grate.scad>

/* [Size — inches] */
outer_width_in  = 11.25;
outer_height_in = 9;
corner_radius_in = 1;

/* [Bars] */
thickness_mm   = 5.08; // [1:0.1:15]  settable independently of everything else
frame_width_mm = 6.35; // [2:0.5:20]  solid border
bar_width_mm   = 10;   // [3:0.5:30]  requested pitch — auto-fit keeps every bar this width
gap_width_mm   = 7.6;  // [2:0.5:20]  requested pitch — auto-fit tunes this slightly to divide evenly

/* [Lip — slides into the oven cavity's support-rail groove] */
lip_width_in     = 0.12; // [0:0.01:1]  long (top/bottom) edges
end_lip_width_in = 0.5;  // [0:0.01:1]  short (left/right) edges
lip_thickness_mm = 2.5;  // [0.5:0.1:3]  must be <=3mm to fit the real rail; 2.5mm is the sweet spot

IN_TO_MM = 25.4;

oven_grate(
  outer_width   = outer_width_in * IN_TO_MM,
  outer_height  = outer_height_in * IN_TO_MM,
  corner_radius = corner_radius_in * IN_TO_MM,
  thickness     = thickness_mm,
  frame_width   = frame_width_mm,
  bar_width     = bar_width_mm,
  gap_width     = gap_width_mm,
  lip_width     = lip_width_in * IN_TO_MM,
  end_lip_width = end_lip_width_in * IN_TO_MM,
  lip_thickness = lip_thickness_mm
);
