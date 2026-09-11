// Snap-fit joint proof piece for the back wall (13.25 x 17.5in — exceeds
// the X1C bed on BOTH axes, so the real back wall needs a 2x2 segment
// grid with joints on both internal seams). Per the plan: print this
// small test first, confirm the snap fit, THEN build the full segmented
// wall using the same tab/slot numbers.
//
// Two independent stubs, meant to print separately and be pressed
// together by hand — not pre-assembled in this file.
use <model-forge/joint.scad>

thickness = 3;     // matches the other flat panels (oven-insert, fridge-rack)
tab_width = 15;    // mm, each dovetail tab's base width
tab_depth = 6;     // mm, how far the tab protrudes / the slot recesses
taper = 2;         // mm, dovetail flare — bigger = more mechanical lock, harder to press in
clearance = 0.15;  // mm, slot oversize for the snap/interference fit — tune after a real test-fit
stub_w = 60;
stub_h = 40;

// Stub A — tabs protruding from its right edge
union() {
  cube([stub_w, stub_h, thickness]);
  translate([stub_w, stub_h / 2, 0])
    rotate([0, 0, -90])
      linear_extrude(height = thickness)
        dovetail_tabs_2d(edge_length = stub_h, tab_width = tab_width, tab_depth = tab_depth, taper = taper);
}

// Stub B — matching slots cut into its left edge. Offset away from A so
// they print as two clearly separate parts on the bed.
translate([stub_w + tab_depth + 25, 0, 0])
  difference() {
    cube([stub_w, stub_h, thickness]);
    translate([0, stub_h / 2, -1])
      rotate([0, 0, -90])
        linear_extrude(height = thickness + 2)
          dovetail_tabs_2d(edge_length = stub_h, tab_width = tab_width, tab_depth = tab_depth, taper = taper, clearance = clearance);
  }
