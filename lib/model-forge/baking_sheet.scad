// model-forge/baking_sheet.scad — a rounded pan with handle tabs on both
// short ends, driven by just 5 "super simple" variables: pan_width and
// pan_height (the pan body, NOT including the handles), handle_size (how
// far each handle protrudes), handle_thickness, and pan_depth. Everything
// else — corner rounding, floor thickness, handle width/rounding, pocket
// inset, and the handle hole size — is a fixed proportion derived from
// those, per the user's own framing: "the rest scales with it, rounding
// etc." Pass handle_hole_diameter explicitly if you want to override the
// auto-scaled hole size (e.g. tune it once printed); 0 omits the hole.
//
//   use <model-forge/baking_sheet.scad>
//   baking_sheet(pan_width=247.7, pan_height=158.75, handle_size=19,
//                handle_thickness=2, pan_depth=8);
//
// Total footprint including both handles = pan_width + 2*handle_size.
// Modeled after a real paper template the user already test-fit
// (projects/tinyland-playset-kitchen/reference-photos/) at 11.25x6.25in
// overall — pan_width/handle_size below are back-derived from that
// (11.25in total, 0.75in handles each side -> pan_width = 9.75in body).
use <model-forge/tray.scad>

module baking_sheet(pan_width, pan_height, handle_size, handle_thickness, pan_depth, handle_hole_diameter = -1) {
  // Fixed proportions — not exposed as separate variables on purpose.
  corner_radius   = min(pan_width, pan_height) * 0.12;
  floor_thickness = pan_depth * 0.3;
  rim_height      = pan_depth * 0.7;
  inset_margin    = corner_radius * 0.5;
  handle_width    = pan_height * 0.5;
  handle_radius   = min(corner_radius, handle_width / 2 - 0.5, handle_size / 2 - 0.5);
  // handle_hole_diameter=-1 (the default) means "auto" — scale from the
  // handle's own footprint. Pass 0 to omit the hole entirely, or any
  // positive number to set it explicitly.
  hole_d = handle_hole_diameter >= 0 ? handle_hole_diameter : min(handle_width, handle_size) * 0.5;

  module handle_2d() {
    difference() {
      rounded_rect_2d(handle_size + corner_radius, handle_width, handle_radius);
      if (hole_d > 0)
        translate([(handle_size + corner_radius) / 2, handle_width / 2])
          circle(d = hole_d, $fn = 48);
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
    translate([-handle_size, (pan_height - handle_width) / 2, 0])
      linear_extrude(height = handle_thickness)
        handle_2d();
    // Handle on the right short edge.
    translate([pan_width - corner_radius, (pan_height - handle_width) / 2, 0])
      linear_extrude(height = handle_thickness)
        handle_2d();
  }
}
