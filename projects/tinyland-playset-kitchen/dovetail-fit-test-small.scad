// Tiny Land — SMALL-SCALE dovetail interference sweep.
//
// dovetail-fit-test.scad swept clearance at the wall's tab size (15mm
// tab_width). That number doesn't necessarily transfer to the grate's
// per-bar joints, which have to fit inside a 10mm-wide bar -- a fixed
// ~0.1-0.2mm print inaccuracy is a much bigger fraction of a 3.5mm tab
// than a 15mm one, so small features generally need their own tuned
// clearance, not the same number as the big parts.
//
// Same comb-and-tab layout as dovetail-fit-test.scad, just re-scaled to
// tab_width=3.5/tab_depth=2.5/taper=0.8 -- the exact size already used
// in oven-grate-halves.scad's frame-band joint (and the size any
// per-bar grate joint would need too). Press the same tab into each
// slot, find the one that actually snaps/holds.
use <model-forge/joint.scad>

thickness  = 5.08; // matches the grate's own thickness, not the 3mm wall panels
tab_width  = 3.5;
tab_depth  = 2.5;
taper      = 0.8;
// dovetail_tabs_2d's pitch is tab_width*2 = 7mm -- edge_length must stay
// under that so floor(edge_length/pitch) still comes out to exactly 1
// tab per slot, not 2. Kept separate from plate_h (the block's own
// height, which just needs room for the tab band + a label above it).
tab_edge_length = 6;
tab_y_offset    = 4;  // where the tab band sits within the block
plate_h         = 16;
step            = 10; // per-slot block width on the comb

clearances = [-0.2, -0.15, -0.1, -0.05, -0.02, 0, 0.05, 0.15];

module labeled_comb() {
  difference() {
    cube([len(clearances) * step, plate_h, thickness]);
    for (i = [0 : len(clearances) - 1])
      translate([i * step, tab_y_offset, -1])
        rotate([0, 0, -90])
          linear_extrude(height = thickness + 2)
            dovetail_tabs_2d(
              edge_length = tab_edge_length,
              tab_width   = tab_width,
              tab_depth   = tab_depth,
              taper       = taper,
              clearance   = clearances[i]
            );
  }
  for (i = [0 : len(clearances) - 1])
    translate([i * step + 1, plate_h - 5, thickness])
      linear_extrude(height = 0.4)
        text(str(clearances[i]), size = 2.4);
}

labeled_comb();

// One tab stub — the same physical tab pressed into each slot above.
translate([0, plate_h + 8, 0])
  union() {
    cube([12, plate_h, thickness]);
    translate([12, tab_y_offset, 0])
      rotate([0, 0, -90])
        linear_extrude(height = thickness)
          dovetail_tabs_2d(edge_length = tab_edge_length, tab_width = tab_width, tab_depth = tab_depth, taper = taper);
  }
