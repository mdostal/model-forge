// model-forge/panel.scad — parametric flat panel with cutouts, splittable
// into print-bed-sized segments.
//
// This is a real OpenSCAD library module, installed the same way BOSL2 or
// MCAD are: dropped into OpenSCAD's user library folder, then any .scad
// file (hand-written or tool-generated) does:
//
//   use <model-forge/panel.scad>
//   panel_with_cutouts(outer_width=285.75, outer_height=228.6, thickness=3);
//
// This module takes explicit arguments rather than reading globals, so it
// composes cleanly inside a larger hand-written design (per-user
// grooves/indents/joinery layered on top via a normal difference()/union()
// in the caller's own file) instead of only working as a standalone
// top-level script.

/**
 * A rectangular panel with rectangular/circular cutouts, optionally
 * clipped to one print-bed-sized segment.
 *
 * @param outer_width, outer_height, thickness  Full panel size in mm.
 * @param rect_cutouts    [[x, y, w, h], ...] — corner + size, origin at
 *                        the panel's bottom-left.
 * @param circle_cutouts  [[x, y, d], ...] — center + diameter.
 * @param seg  Optional [x0, x1, y0, y1] clip box — omit (or pass
 *             [0, outer_width, 0, outer_height]) to render the whole
 *             panel unclipped. See panel-gen/src/render.js for how a
 *             full panel gets split into bed-sized segments.
 */
module panel_with_cutouts(
  outer_width,
  outer_height,
  thickness,
  rect_cutouts = [],
  circle_cutouts = [],
  seg = undef
) {
  seg_box = seg == undef ? [0, outer_width, 0, outer_height] : seg;

  module cutouts() {
    for (c = rect_cutouts) {
      translate([c[0], c[1], -1])
        cube([c[2], c[3], thickness + 2]);
    }
    for (c = circle_cutouts) {
      translate([c[0], c[1], -1])
        cylinder(h = thickness + 2, d = c[2], $fn = 48);
    }
  }

  intersection() {
    difference() {
      cube([outer_width, outer_height, thickness]);
      cutouts();
    }
    translate([seg_box[0], seg_box[2], -1])
      cube([seg_box[1] - seg_box[0], seg_box[3] - seg_box[2], thickness + 2]);
  }
}

/**
 * Tile a panel's footprint into segments no larger than bed_max on a
 * side. Pure function — no geometry — used by both the CLI renderer and
 * (if you `use` this file directly) your own hand-written .scad.
 * Returns [[x0,x1,y0,y1], ...].
 */
function panel_segments(outer_width, outer_height, bed_max) =
  let(
    nx = ceil(outer_width / bed_max),
    ny = ceil(outer_height / bed_max),
    seg_w = outer_width / nx,
    seg_h = outer_height / ny
  )
  [for (iy = [0 : ny - 1], ix = [0 : nx - 1])
    [ix * seg_w, (ix + 1) * seg_w, iy * seg_h, (iy + 1) * seg_h]
  ];
