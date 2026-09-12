// model-forge/baking_sheet.scad — a rounded pan with handle tabs on both
// short ends, driven by just 5 "super simple" variables: pan_width and
// pan_height (the pan body, NOT including the handles), handle_size (how
// far each handle protrudes), handle_thickness, and pan_depth. Everything
// else — corner rounding, floor thickness, handle width/rounding, pocket
// inset — is a fixed proportion derived from those, per the user's own
// framing: "the rest scales with it, rounding etc."
//
// Each handle is a thick loop, not a solid tab with a small hole: an
// oval cutout follows the handle's own rounded outline, inset by
// handle_hole_margin on every side, so a consistent "wall" of material
// remains all the way around — a real hand-grip loop, "truly separate
// but pretty thick and attached." handle_hole_margin defaults to a
// fraction of the handle's own size (auto), or set it explicitly — pass
// 0 for a solid tab with no cutout at all.
//
//   use <model-forge/baking_sheet.scad>
//   baking_sheet(pan_width=247.7, pan_height=158.75, handle_size=19,
//                handle_thickness=2, pan_depth=8, handle_hole_margin=6);
//
// Total footprint including both handles = pan_width + 2*handle_size.
// Modeled after a real paper template the user already test-fit
// (projects/tinyland-playset-kitchen/reference-photos/) at 11.25x6.25in
// overall — pan_width/handle_size below are back-derived from that
// (11.25in total, 0.75in handles each side -> pan_width = 9.75in body).
use <model-forge/tray.scad>

module baking_sheet(pan_width, pan_height, handle_size, handle_thickness, pan_depth, handle_hole_margin = -1) {
  // Fixed proportions — not exposed as separate variables on purpose.
  corner_radius   = min(pan_width, pan_height) * 0.12;
  floor_thickness = pan_depth * 0.3;
  rim_height      = pan_depth * 0.7;
  total_height    = floor_thickness + rim_height;
  handle_z        = (total_height - handle_thickness) / 2; // centered in the pan's thickness, not flush with the bottom
  inset_margin    = corner_radius * 0.5;
  handle_width    = pan_height * 0.5;
  handle_length   = handle_size + corner_radius; // local X span of the handle_2d() shape below
  handle_radius   = min(corner_radius, handle_width / 2 - 0.5, handle_size / 2 - 0.5);
  // -1 (the default) means "auto" — a margin that leaves a visibly thick
  // loop wall. Pass 0 to skip the cutout (solid tab), or set your own.
  margin = handle_hole_margin >= 0 ? handle_hole_margin : min(handle_width, handle_length) * 0.28;
  oval_w = handle_length - 2 * margin;
  oval_h = handle_width - 2 * margin;

  module handle_2d() {
    difference() {
      rounded_rect_2d(handle_length, handle_width, handle_radius);
      if (margin > 0 && oval_w > 0 && oval_h > 0)
        translate([handle_length / 2, handle_width / 2])
          scale([oval_w / 2, oval_h / 2, 1])
            circle(r = 1, $fn = 64);
    }
  }

  union() {
    rounded_tray(
      outer_width = pan_width,
      outer_height = pan_height,
      corner_radius = corner_radius,
      floor_thickness = floor_thickness,
      rim_height = rim_height,
      inset_margin = inset_margin
    );
    // Handle on the left short edge — extends into negative X.
    translate([-handle_size, (pan_height - handle_width) / 2, handle_z])
      linear_extrude(height = handle_thickness)
        handle_2d();
    // Handle on the right short edge.
    translate([pan_width - corner_radius, (pan_height - handle_width) / 2, handle_z])
      linear_extrude(height = handle_thickness)
        handle_2d();
  }
}
