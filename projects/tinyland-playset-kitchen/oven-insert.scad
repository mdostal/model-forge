// Tiny Land oven insert — live working file. Edit directly; OpenSCAD
// auto-reloads on save (Design > Automatic Reload and Preview, on by
// default). Two rough drafts side by side per the 2026-09-11 conversation
// — pick a direction, tune the numbers, or tell me what to change.
use <model-forge/tray.scad>
use <model-forge/grate.scad>
use <model-forge/baking_sheet.scad>

// --- Draft A: rounded tray with a recessed cooking-dish pocket ---
// 1in corner radius, 0.2in floor. Updated 2026-09-11 per feedback: drop
// brought in (rim_height 0.25in -> 0.15in) and a thin lip added around
// the base to slide into the oven cavity's wooden support-rail grooves
// (see reference-photos/ for the rail). lip_width/lip_thickness are a
// rough first guess (3mm / 2mm) — no caliper reading of the actual groove
// yet; adjust once you check it against the real rail.
rounded_tray(
  outer_width    = 285.75,  // 11.25in
  outer_height   = 228.6,   // 9in
  corner_radius  = 25.4,    // 1in
  floor_thickness = 5.08,   // 0.2in
  rim_height      = 3.81,   // 0.15in — brought in from 0.25in
  inset_margin    = 6.35,   // 0.25in
  lip_width       = 3,      // rough guess — check against the rail groove
  lip_thickness   = 2       // rough guess — check against the rail groove
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

// --- Draft C: baking sheet with handles, matching the paper template
// you already test-fit (11.25 x 6.25in overall). 5 simple variables;
// everything else (rounding, floor thickness, handle width) scales from
// them automatically. handle_size is a rough guess (0.75in) backed out
// of the paper template's overall width — tell me the real handle
// length/thickness once you check it against the paper and I'll adjust
// pan_width to keep the 11.25in total exact.
translate([0, -200, 0])
  baking_sheet(
    pan_width       = 247.65,  // 9.75in body (11.25in total - 2*0.75in handles)
    pan_height      = 158.75,  // 6.25in
    handle_size     = 19.05,   // 0.75in — rough guess, confirm against the paper template
    handle_thickness = 2,      // rough guess — thin flat grip tab
    pan_depth       = 8        // rough guess — how deep the pan cavity is
  );
