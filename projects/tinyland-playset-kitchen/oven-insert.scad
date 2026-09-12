// Tiny Land oven insert — live working file. Edit directly; OpenSCAD
// auto-reloads on save (Design > Automatic Reload and Preview, on by
// default). Four rough drafts side by side per the 2026-09-11 conversation.
//
// Customizer sliders: View > Show Customizer (or the toolbar icon) turns
// the variables below into real sliders/inputs, grouped by draft. Values
// declared as plain top-level variables — like these — are what
// Customizer can see; a number buried inside a function call argument
// isn't editable there, which was the actual issue with the old handle
// hole size.
use <model-forge/tray.scad>
use <model-forge/grate.scad>
use <model-forge/baking_sheet.scad>
use <model-forge/board.scad>

/* [Draft A — Tray] */
tray_lip_width_in     = 0.12; // [0:0.05:1] long (top/bottom) edges
tray_end_lip_width_in = 0.5;  // [0:0.05:1] short (left/right) edges — bigger, semi-handle
tray_lip_thickness_mm = 2;    // [0.5:0.5:5]

/* [Draft C — Baking sheet] */
handle_size_in       = 0.75; // [0.25:0.05:2]
handle_thickness_mm  = 2;    // [0.5:0.5:6]
pan_depth_mm         = 8;    // [2:1:20]
handle_hole_margin_mm = -1;  // [-1:0.5:15]  -1 = auto; 0 = no cutout (solid tab)

// --- Draft A: rounded tray with a recessed cooking-dish pocket ---
// Bug fixed 2026-09-11: the lip was a full solid disc, not a ring, so it
// capped the pocket shut once moved to the top — now a proper ring.
// Per feedback: the short (left/right) sides now get a bigger lip
// (0.5in default above) than the long sides — "a semi mix between the
// handled one and it."
rounded_tray(
  outer_width    = 285.75,  // 11.25in
  outer_height   = 228.6,   // 9in
  corner_radius  = 25.4,    // 1in
  floor_thickness = 5.08,   // 0.2in
  rim_height      = 3.81,   // 0.15in
  inset_margin    = 6.35,   // 0.25in
  lip_width       = tray_lip_width_in * 25.4,
  end_lip_width   = tray_end_lip_width_in * 25.4,
  lip_thickness   = tray_lip_thickness_mm
);

// --- Draft B: same footprint, rounded, real oven-grate bar pattern ---
translate([0, 260, 0])
  oven_grate(
    outer_width   = 285.75,
    outer_height  = 228.6,
    corner_radius = 25.4,
    thickness     = 5.08,   // settable independently
    frame_width   = 6.35,
    bar_width     = 10,
    gap_width     = 7.6
  );

// --- Draft C: baking sheet with handles, matching the paper template
// you already test-fit (11.25 x 6.25in overall). Each handle is now a
// thick loop (oval cutout following the handle's own outline, inset by
// handle_hole_margin_mm) instead of a solid tab with a small hole —
// "truly separate but pretty thick and attached." Negative margin = auto.
translate([0, -200, 0])
  baking_sheet(
    pan_width       = 247.65,  // 9.75in body (11.25in total - 2*0.75in handles)
    pan_height      = 158.75,  // 6.25in
    handle_size     = handle_size_in * 25.4,
    handle_thickness = handle_thickness_mm,
    pan_depth       = pan_depth_mm,
    handle_hole_margin = handle_hole_margin_mm
  );

// --- Draft D: plain flat rounded board — the "upgrade" on the original
// playset's flat wood shelves. Sized to the fridge rack (11.25 x 7in).
translate([0, -400, 0])
  rounded_board(
    outer_width   = 285.75,  // 11.25in
    outer_height  = 177.8,   // 7in
    corner_radius = 25.4,
    thickness     = 5.08     // settable independently
  );
