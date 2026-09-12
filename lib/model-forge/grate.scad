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
// racks don't have a gap right at the edge.
//
// Auto-fit spacing (fixed 2026-09-11): bar_width/gap_width are a
// requested PITCH, not exact — the number of bars is chosen to best
// match that pitch, then the GAP width (not the bar width) is adjusted
// slightly so the whole pattern divides the interior exactly, ending
// flush with the frame on both sides. The earlier version kept a fixed
// gap count and dumped whatever didn't divide evenly into one oversized
// final bar ("thick on one side") — this keeps every bar the same width
// and instead makes the gaps a hair wider or narrower than requested,
// which is far less visually obvious.
use <model-forge/tray.scad> // rounded_rect_2d

module oven_grate(outer_width, outer_height, corner_radius, thickness, frame_width, bar_width, gap_width) {
  inner_width = outer_width - 2 * frame_width;
  inner_height = outer_height - 2 * frame_width;

  approx_n_bars = round((inner_width + gap_width) / (bar_width + gap_width));
  n_bars = max(approx_n_bars, 2);
  actual_gap_width = (inner_width - n_bars * bar_width) / (n_bars - 1);

  difference() {
    linear_extrude(height = thickness)
      rounded_rect_2d(outer_width, outer_height, corner_radius);
    for (i = [0 : n_bars - 2]) {
      x = frame_width + bar_width + i * (bar_width + actual_gap_width);
      translate([x, frame_width, -1])
        cube([actual_gap_width, inner_height, thickness + 2]);
    }
  }
}
