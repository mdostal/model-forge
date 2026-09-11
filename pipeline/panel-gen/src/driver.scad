// Thin CLI driver: overridden via -D by render.js, calls into the real
// library at ../../../lib/model-forge/panel.scad (the same one installed
// at ~/Documents/OpenSCAD/libraries/model-forge for hand-written designs).
use <model-forge/panel.scad>

outer_width = 100;
outer_height = 100;
thickness = 3;
rect_cutouts = [];
circle_cutouts = [];
seg = undef;

panel_with_cutouts(
  outer_width = outer_width,
  outer_height = outer_height,
  thickness = thickness,
  rect_cutouts = rect_cutouts,
  circle_cutouts = circle_cutouts,
  seg = seg
);
