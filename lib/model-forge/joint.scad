// model-forge/joint.scad — dovetail finger-joint tabs for snap-fit panel
// segmentation. One segment gets protruding tabs (union onto its edge),
// the matching segment gets slightly-larger slots (difference cut into
// its edge) so the two press together with a light interference/snap fit.
//
// Both modules produce a 2D profile running along the X axis, centered
// on the boundary line (y=0), for a boundary of the given edge_length.
// The caller extrudes and positions/rotates it onto the actual seam
// (see back-wall-joint-test.scad for a worked example on a vertical seam).
//
//   use <model-forge/joint.scad>
//   linear_extrude(height=thickness)
//     dovetail_tabs_2d(edge_length=60, tab_width=15, tab_depth=6, taper=2);
//   // on the MATING piece, subtract:
//   linear_extrude(height=thickness+2)
//     dovetail_tabs_2d(edge_length=60, tab_width=15, tab_depth=6, taper=2, clearance=0.15);

module dovetail_tab_2d(tab_width, tab_depth, taper, base_overlap = 0.5) {
  // Trapezoid: narrow at the base, wider at the tip (y=tab_depth) — the
  // taper is what makes it a dovetail (can't pull straight out sideways
  // once the mating slot is filled) and gives the snap/interference feel
  // as it's pressed in along Y. The base extends base_overlap PAST y=0
  // (the seam line) on purpose: a cut/union placed exactly flush with a
  // piece's boundary face (zero overlap) is a classic OpenSCAD/CGAL
  // gotcha — coincident faces produce degenerate, non-manifold results
  // (confirmed here: without the overlap this rendered as a distorted
  // sliver instead of a clean notch). The overlap guarantees real overlap
  // for both the union (tab) and difference (slot) uses.
  polygon(points = [
    [-tab_width / 2, -base_overlap],
    [tab_width / 2, -base_overlap],
    [tab_width / 2 + taper, tab_depth],
    [-tab_width / 2 - taper, tab_depth],
  ]);
}

/**
 * A row of dovetail tabs spanning edge_length, evenly spaced and centered,
 * each tab_width wide with tab_depth of protrusion and the given taper.
 * Pass clearance > 0 (e.g. 0.15-0.2mm) when using this as a SLOT cutout on
 * the mating piece, so the tab has just enough room to press in.
 */
module dovetail_tabs_2d(edge_length, tab_width, tab_depth, taper, clearance = 0) {
  // Growing the slot via offset(delta=clearance) produced a disconnected
  // sliver fragment at the corner (confirmed with --render: 3 volumes
  // instead of 2, a known OpenSCAD quirk with delta-mode offset on a
  // trapezoid). Scaling the tab's own dimensions directly instead avoids
  // offset() entirely and renders as the expected 2 volumes.
  pitch = tab_width * 2;
  n = max(1, floor(edge_length / pitch));
  row_width = n * pitch - tab_width;
  start_x = -row_width / 2;
  for (i = [0 : n - 1]) {
    translate([start_x + i * pitch, 0])
      dovetail_tab_2d(tab_width + 2 * clearance, tab_depth + clearance, taper + clearance);
  }
}
