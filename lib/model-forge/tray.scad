// model-forge/tray.scad — rounded-corner outer panel with a recessed
// inset pocket (e.g. a "cooking dish" recess): a raised rim around the
// edge, floor thickness under the pocket, and an optional thin lip
// flange around the base — sized to slide into a support-rail groove
// (like the wooden rails inside the real Tiny Land oven cavity) rather
// than just resting loose.
//
//   use <model-forge/tray.scad>
//   rounded_tray(outer_width=285.75, outer_height=228.6, corner_radius=25.4,
//                floor_thickness=5.08, rim_height=3.81, inset_margin=6.35,
//                lip_width=3, lip_thickness=2);
//
// Shape: outer_width x outer_height slab, rounded corners (corner_radius),
// total height = floor_thickness + rim_height. A pocket is cut from the
// top, inset_margin in from every edge, cutting down through rim_height
// and stopping at floor_thickness from the bottom — so floor_thickness is
// what's left under the pocket, rim_height is how tall the surrounding
// wall stands above the pocket floor.
//
// The lip (lip_width/lip_thickness) is a thin flange at the very bottom
// (z=0 to lip_thickness), sticking out lip_width beyond the main body on
// every side — the part that actually slides into a rail groove. Both
// default to 0 (no lip) so existing calls keep working unchanged.

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

module rounded_tray(
  outer_width,
  outer_height,
  corner_radius,
  floor_thickness,
  rim_height,
  inset_margin,
  lip_width = 0,
  lip_thickness = 0
) {
  total_height = floor_thickness + rim_height;

  union() {
    if (lip_width > 0 && lip_thickness > 0) {
      translate([-lip_width, -lip_width, 0])
        linear_extrude(height = lip_thickness)
          rounded_rect_2d(outer_width + 2 * lip_width, outer_height + 2 * lip_width, corner_radius + lip_width);
    }
    difference() {
      linear_extrude(height = total_height)
        rounded_rect_2d(outer_width, outer_height, corner_radius);
      translate([inset_margin, inset_margin, floor_thickness])
        cube([outer_width - 2 * inset_margin, outer_height - 2 * inset_margin, rim_height + 1]);
    }
  }
}
