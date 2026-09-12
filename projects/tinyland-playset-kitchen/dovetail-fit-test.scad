// Tiny Land back wall — dovetail INTERFERENCE sweep test.
//
// back-wall-joint-test.scad used clearance=0.15mm (slot printed larger
// than the tab, per joint.scad's own doc comment: "just enough room to
// press in"). Real test-fit result: tabs and slots line up perfectly,
// but there's zero tightness — nothing to hold a shelf or a wall seam.
// A positive clearance only ever gives a loose sliding fit; an actual
// interference/snap fit needs NEGATIVE clearance (tab printed slightly
// LARGER than the nominal slot), and the right amount of "negative" is
// specific to this printer + filament's real dimensional accuracy, not
// something to guess twice in a row.
//
// This prints one comb with 8 slots at different clearances, plus one
// tab stub — press the SAME tab into each slot in turn (softest to
// tightest) and note which one actually resists being pulled back out.
// 0.15 (the original, too-loose value) is included on the end for a
// direct side-by-side comparison.
use <model-forge/joint.scad>

thickness  = 3;   // matches the flat back-wall panels
tab_width  = 15;
tab_depth  = 6;
taper      = 2;
plate_h    = 40;  // matches back-wall-joint-test.scad's stub_h — same 1-tab-per-edge pitch
step       = 25;  // per-slot block width on the comb

clearances = [-0.3, -0.25, -0.2, -0.15, -0.1, -0.05, 0, 0.15];

module labeled_comb() {
  difference() {
    cube([len(clearances) * step, plate_h, thickness]);
    for (i = [0 : len(clearances) - 1])
      translate([i * step, plate_h / 2, -1])
        rotate([0, 0, -90])
          linear_extrude(height = thickness + 2)
            dovetail_tabs_2d(
              edge_length = plate_h,
              tab_width   = tab_width,
              tab_depth   = tab_depth,
              taper       = taper,
              clearance   = clearances[i]
            );
  }
  // Embossed label per slot so the winner is identifiable after printing.
  for (i = [0 : len(clearances) - 1])
    translate([i * step + 2, plate_h - 9, thickness])
      linear_extrude(height = 0.5)
        text(str(clearances[i]), size = 4.2);
}

labeled_comb();

// One tab stub — the same physical tab pressed into each slot above.
translate([0, plate_h + 15, 0])
  union() {
    cube([30, plate_h, thickness]);
    translate([30, plate_h / 2, 0])
      rotate([0, 0, -90])
        linear_extrude(height = thickness)
          dovetail_tabs_2d(edge_length = plate_h, tab_width = tab_width, tab_depth = tab_depth, taper = taper);
  }
