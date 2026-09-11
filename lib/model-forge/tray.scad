// model-forge/tray.scad — rounded-corner outer panel with a recessed
// inset pocket (e.g. a "cooking dish" recess): a raised rim around the
// edge, floor thickness under the pocket.
//
//   use <model-forge/tray.scad>
//   rounded_tray(outer_width=285.75, outer_height=228.6, corner_radius=25.4,
//                floor_thickness=5.08, rim_height=6.35, inset_margin=6.35);
//
// Shape: outer_width x outer_height slab, rounded corners (corner_radius),
// total height = floor_thickness + rim_height. A pocket is cut from the
// top, inset_margin in from every edge, cutting down through rim_height
// and stopping at floor_thickness from the bottom — so floor_thickness is
// what's left under the pocket, rim_height is how tall the surrounding
// wall stands above the pocket floor.

// hull-of-4-circles rounded rect — much faster to render than a
// minkowski-based approach for this shape (no minkowski sum needed).
module rounded_rect_2d(w, h, r) {
  hull() {
    translate([r, r]) circle(r = r, $fn = 64);
    translate([w - r, r]) circle(r = r, $fn = 64);
    translate([r, h - r]) circle(r = r, $fn = 64);
    translate([w - r, h - r]) circle(r = r, $fn = 64);
  }
}

module rounded_tray(outer_width, outer_height, corner_radius, floor_thickness, rim_height, inset_margin) {
  total_height = floor_thickness + rim_height;
  difference() {
    linear_extrude(height = total_height)
      rounded_rect_2d(outer_width, outer_height, corner_radius);
    translate([inset_margin, inset_margin, floor_thickness])
      cube([outer_width - 2 * inset_margin, outer_height - 2 * inset_margin, rim_height + 1]);
  }
}
