// Tiny Land oven insert — live working file. Edit directly; OpenSCAD
// auto-reloads on save (Design > Automatic Reload and Preview, on by
// default). Two rough drafts side by side per the 2026-09-11 conversation
// — pick a direction, tune the numbers, or tell me what to change.
use <model-forge/tray.scad>
use <model-forge/grate.scad>

// --- Draft A: rounded tray with a recessed cooking-dish pocket ---
// 1in corner radius, 0.2in floor, 0.25in rim above the pocket floor,
// pocket inset 0.25in from every edge.
rounded_tray(
  outer_width    = 285.75,  // 11.25in
  outer_height   = 228.6,   // 9in
  corner_radius  = 25.4,    // 1in
  floor_thickness = 5.08,   // 0.2in
  rim_height      = 6.35,   // 0.25in
  inset_margin    = 6.35    // 0.25in
);

// --- Draft B: same footprint, rounded, real oven-grate bar pattern ---
translate([0, 260, 0])
  oven_grate(
    outer_width   = 285.75,
    outer_height  = 228.6,
    corner_radius = 25.4,   // matches Draft A's rounding
    thickness     = 5.08,   // 0.2in, same as Draft A's floor
    frame_width   = 6.35,   // 0.25in solid border
    bar_width     = 10,     // ~0.4in bars
    gap_width     = 7.6     // ~0.3in gaps between bars
  );
