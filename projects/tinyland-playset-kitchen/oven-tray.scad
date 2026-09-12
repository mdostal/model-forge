// Tiny Land oven insert — cooking-dish tray. Standalone, printable file:
// swap the variables below, save, and re-export the STL (File > Export >
// Export as STL, or the CLI: openscad -o out.stl oven-tray.scad).
// View > Show Customizer for sliders.
use <model-forge/tray.scad>

/* [Size — inches] */
outer_width_in  = 11.25;
outer_height_in = 9;
corner_radius_in = 1;

/* [Pocket] */
floor_thickness_mm = 5.08; // [1:0.1:15]
rim_height_mm       = 3.81; // [1:0.1:15]
inset_margin_mm      = 6.35; // [1:0.1:25]

/* [Lip — slides into the oven cavity's support-rail groove] */
lip_width_in     = 0.12; // [0:0.01:1]  long (top/bottom) edges
end_lip_width_in = 0.5;  // [0:0.01:1]  short (left/right) edges
lip_thickness_mm = 2;    // [0.5:0.5:5]

IN_TO_MM = 25.4;

rounded_tray(
  outer_width     = outer_width_in * IN_TO_MM,
  outer_height    = outer_height_in * IN_TO_MM,
  corner_radius   = corner_radius_in * IN_TO_MM,
  floor_thickness = floor_thickness_mm,
  rim_height      = rim_height_mm,
  inset_margin    = inset_margin_mm,
  lip_width       = lip_width_in * IN_TO_MM,
  end_lip_width   = end_lip_width_in * IN_TO_MM,
  lip_thickness   = lip_thickness_mm
);
