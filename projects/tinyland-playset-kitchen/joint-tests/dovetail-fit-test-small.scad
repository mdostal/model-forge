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
//
// Bug fixed 2026-09-12, same root cause as dovetail-fit-test.scad: slots
// cut sideways into one continuous block landed on internal boundaries,
// not a real exterior face, so only slot 0 was reachable. Fixed the same
// way -- dovetail_tab_2d's natural orientation, directly on the comb's
// shared y=0 edge, no rotation.
use <model-forge/joint.scad>

thickness  = 5.08; // matches the grate's own thickness, not the 3mm wall panels
tab_width  = 3.5;
tab_depth  = 2.5;
taper      = 0.8;
plate_h    = 8;    // just needs to clear tab_depth + taper + margin
step       = 10;   // spacing between slot centers along the shared edge
base_h     = 8;    // tab stub's own base block height

clearances = [-0.2, -0.15, -0.1, -0.05, -0.02, 0, 0.05, 0.15];

module labeled_comb() {
  difference() {
    cube([len(clearances) * step, plate_h, thickness]);
    for (i = [0 : len(clearances) - 1]) {
      c = clearances[i];
      translate([i * step + step / 2, 0, -1])
        linear_extrude(height = thickness + 2)
          dovetail_tab_2d(tab_width + 2 * c, tab_depth + c, taper + c);
    }
  }
  for (i = [0 : len(clearances) - 1])
    translate([i * step + 1, plate_h - 3, thickness])
      linear_extrude(height = 0.4)
        text(str(clearances[i]), size = 2.4);
}

labeled_comb();

// One tab stub — same natural orientation, protrudes above its own
// block's top edge. Slide toward whichever slot you're testing, push
// up (+Y) to mate, flat, no rotation.
translate([0, -(base_h + 8), 0])
  union() {
    cube([tab_width + 8, base_h, thickness]);
    translate([(tab_width + 8) / 2, base_h, 0])
      linear_extrude(height = thickness)
        dovetail_tab_2d(tab_width, tab_depth, taper);
  }
