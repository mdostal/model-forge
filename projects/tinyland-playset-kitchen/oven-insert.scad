// Tiny Land oven cavity insert — live working file.
// Edit this directly in OpenSCAD; it auto-reloads on save
// (Design > Automatic Reload and Preview, on by default).
// Add your own grooves/indents/joinery below the base panel calls.
use <model-forge/panel.scad>

// Segment 1 of 2 (the full 285.75mm width exceeds the X1C's 256mm bed)
panel_with_cutouts(outer_width=285.75, outer_height=228.6, thickness=3,
                    seg=[0, 142.875, 0, 228.6]);

// Uncomment to see segment 2 instead:
// translate([-142.875, 0, 0])
//   panel_with_cutouts(outer_width=285.75, outer_height=228.6, thickness=3,
//                       seg=[142.875, 285.75, 0, 228.6]);
