// model-forge/grate.scad — rounded-corner panel cut into an oven-rack-
// style bar grate: a solid frame border, parallel bars across the
// interior with open gaps between them.
//
//   use <model-forge/grate.scad>
//   oven_grate(outer_width=285.75, outer_height=228.6, corner_radius=25.4,
//              thickness=5.08, frame_width=6.35, bar_width=10, gap_width=7.6,
//              lip_width=3, end_lip_width=12.7, lip_thickness=2.5);
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
//
// Lip added 2026-09-11: the grate had no way to physically dock into the
// oven cavity's support rail at all. Same ring mechanism as tray.scad's
// lip — a thin overhang at the TOP of the piece, lip_width on the long
// (top/bottom) edges, end_lip_width on the short (left/right) edges
// (defaults to lip_width when unset). All three lip params default to 0
// (no lip) so existing calls keep working unchanged.
use <model-forge/tray.scad> // rounded_rect_2d

module oven_grate(
  outer_width,
  outer_height,
  corner_radius,
  thickness,
  frame_width,
  bar_width,
  gap_width,
  lip_width = 0,
  lip_thickness = 0,
  end_lip_width = -1 // -1 sentinel = "same as lip_width"
) {
  inner_width = outer_width - 2 * frame_width;
  inner_height = outer_height - 2 * frame_width;
  ew = end_lip_width < 0 ? lip_width : end_lip_width;

  approx_n_bars = round((inner_width + gap_width) / (bar_width + gap_width));
  n_bars = max(approx_n_bars, 2);
  actual_gap_width = (inner_width - n_bars * bar_width) / (n_bars - 1);

  module bars() {
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

  module lip_ring() {
    eps = 0.05; // tiny overlap into the grate's own outline — see tray.scad for why
    expanded_r = corner_radius + min(lip_width, ew);
    translate([0, 0, thickness - lip_thickness])
      linear_extrude(height = lip_thickness)
        difference() {
          translate([-ew, -lip_width])
            rounded_rect_2d(outer_width + 2 * ew, outer_height + 2 * lip_width, expanded_r);
          translate([eps, eps])
            rounded_rect_2d(outer_width - 2 * eps, outer_height - 2 * eps, corner_radius - eps);
        }
  }

  union() {
    if ((lip_width > 0 || ew > 0) && lip_thickness > 0) lip_ring();
    bars();
  }
}
