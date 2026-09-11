// Tiny Land oven insert — live working file. Edit directly; OpenSCAD
// auto-reloads on save (Design > Automatic Reload and Preview, on by
// default). Four rough drafts side by side per the 2026-09-11 conversation
// — pick a direction, tune the numbers, or tell me what to change.
use <model-forge/tray.scad>
use <model-forge/grate.scad>
use <model-forge/baking_sheet.scad>
use <model-forge/board.scad>

// --- Draft A: rounded tray with a recessed cooking-dish pocket ---
// Bug fixed 2026-09-11: the lip was a full solid disc, not a ring, so it
// capped the pocket shut once moved to the top. Now a proper ring — see
// tray.scad for the fix. Same numbers as before otherwise.
rounded_tray(
  outer_width    = 285.75,  // 11.25in
  outer_height   = 228.6,   // 9in
  corner_radius  = 25.4,    // 1in
  floor_thickness = 5.08,   // 0.2in
  rim_height      = 3.81,   // 0.15in
  inset_margin    = 6.35,   // 0.25in
  lip_width       = 3,      // rough guess — check against the rail groove
  lip_thickness   = 2       // rough guess — check against the rail groove
);

// --- Draft B: same footprint, rounded, real oven-grate bar pattern ---
// thickness is its own explicit parameter, same as every other draft here.
translate([0, 260, 0])
  oven_grate(
    outer_width   = 285.75,
    outer_height  = 228.6,
    corner_radius = 25.4,
    thickness     = 5.08,   // <- settable independently
    frame_width   = 6.35,
    bar_width     = 10,
    gap_width     = 7.6
  );

// --- Draft C: baking sheet with handles, matching the paper template
// you already test-fit (11.25 x 6.25in overall). Now with a hand-hole in
// each handle (handle_hole_diameter — auto-scaled by default, or pass 0
// to omit / a number to override). handle_size/thickness are still rough
// guesses pending you checking against the real paper template.
translate([0, -200, 0])
  baking_sheet(
    pan_width       = 247.65,  // 9.75in body (11.25in total - 2*0.75in handles)
    pan_height      = 158.75,  // 6.25in
    handle_size     = 19.05,   // 0.75in — rough guess, confirm against the paper template
    handle_thickness = 2,      // <- settable independently
    pan_depth       = 8,       // controls floor+rim thickness together
    handle_hole_diameter = -1  // -1 = auto; try 0 to see it without a hole
  );

// --- Draft D: plain flat rounded board — the "upgrade" on the original
// playset's flat wood shelves (same idea, rounded corners instead of
// sharp). Sized here to the fridge rack (11.25 x 7in); thickness is its
// own explicit parameter.
translate([0, -400, 0])
  rounded_board(
    outer_width   = 285.75,  // 11.25in
    outer_height  = 177.8,   // 7in
    corner_radius = 25.4,
    thickness     = 5.08     // <- settable independently
  );
