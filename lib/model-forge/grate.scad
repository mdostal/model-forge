// model-forge/grate.scad — rounded-corner panel cut into an oven-rack-
// style bar grate: a solid frame border, parallel bars across the
// interior with open gaps between them.
//
//   use <model-forge/grate.scad>
//   oven_grate(outer_width=285.75, outer_height=228.6, corner_radius=25.4,
//              thickness=5.08, frame_width=6.35, bar_width=10, gap_width=7.6);
//
// Bars run parallel to the height (vertical bars spanning the width),
// starting and ending with a solid bar against the frame — real oven
// racks don't have a gap right at the edge. Spacing is pitch-based
// (bar_width + gap_width repeating); it won't divide the interior
// perfectly evenly on every size, so the last bar absorbs any leftover
// width. Tune bar_width/gap_width and re-render if that's visible.
use <model-forge/tray.scad> // rounded_rect_2d

module oven_grate(outer_width, outer_height, corner_radius, thickness, frame_width, bar_width, gap_width) {
  inner_width = outer_width - 2 * frame_width;
  inner_height = outer_height - 2 * frame_width;
  pitch = bar_width + gap_width;
  n_gaps = floor((inner_width - bar_width) / pitch);

  difference() {
    linear_extrude(height = thickness)
      rounded_rect_2d(outer_width, outer_height, corner_radius);
    for (i = [0 : n_gaps - 1]) {
      x = frame_width + bar_width + i * pitch;
      translate([x, frame_width, -1])
        cube([gap_width, inner_height, thickness + 2]);
    }
  }
}
