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
// This prints 8 SEPARATE slot blocks (with a gap between each — see the
// 2026-09-12 fix note below) at different clearances, plus one tab stub
// — press the SAME tab into each slot in turn (softest to tightest) and
// note which one actually resists being pulled back out. 0.15 (the
// original, too-loose value) is included on the end for a direct
// side-by-side comparison.
//
// Bug fixed 2026-09-12: the first version cut all 8 slots into ONE
// continuous solid block using a sideways (rotated) cut whose opening
// sat at each slot's own internal x-boundary. Only slot 0 landed on a
// true exterior face — slots 1-7 had no side opening at all, sealed by
// the neighboring slot's own material. Simpler fix (per direct
// feedback: "just turn them by 90 degrees and put it at the edge"):
// drop the rotation entirely and use dovetail_tab_2d's own natural
// orientation (base at y=0, growing in +Y) directly on the comb's real
// y=0 edge — a single shared exterior face the whole width of the
// plate, so every slot is independently open no matter its X position,
// and the assembly motion is a flat +Y slide, matching how two coplanar
// wall panels actually go together (no 90-degree approach needed).
use <model-forge/joint.scad>

thickness  = 3;   // matches the flat back-wall panels
tab_width  = 15;
tab_depth  = 6;
taper      = 2;
plate_h    = 20;  // just needs to clear tab_depth + taper + margin
step       = 25;  // spacing between slot centers along the shared edge
base_h     = 20;  // tab stub's own base block height

clearances = [-0.3, -0.25, -0.2, -0.15, -0.1, -0.05, 0, 0.15];

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
  // Embossed label per slot so the winner is identifiable after printing.
  for (i = [0 : len(clearances) - 1])
    translate([i * step + 2, plate_h - 6, thickness])
      linear_extrude(height = 0.5)
        text(str(clearances[i]), size = 4.2);
}

labeled_comb();

// One tab stub, same natural orientation — the tab protrudes above its
// own block's top edge. Slide it toward whichever slot you're testing
// and push up (+Y) to mate, flat, no rotation.
translate([0, -(base_h + 15), 0])
  union() {
    cube([tab_width + 15, base_h, thickness]);
    translate([(tab_width + 15) / 2, base_h, 0])
      linear_extrude(height = thickness)
        dovetail_tab_2d(tab_width, tab_depth, taper);
  }
