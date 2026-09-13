// Tiny Land fridge rack — plain flat rounded board, the "upgrade" on the
// original playset's flat wood shelves. Standalone, printable file.
// View > Show Customizer for sliders.
use <model-forge/board.scad>

/* [Size — inches] */
outer_width_in   = 11.25;
outer_height_in  = 7;
corner_radius_in = 1;

/* [Thickness] */
thickness_mm = 5.08; // [1:0.1:15]  settable independently

IN_TO_MM = 25.4;

rounded_board(
  outer_width   = outer_width_in * IN_TO_MM,
  outer_height  = outer_height_in * IN_TO_MM,
  corner_radius = corner_radius_in * IN_TO_MM,
  thickness     = thickness_mm
);
