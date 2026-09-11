// model-forge/board.scad — a plain flat rounded-corner board. The
// original Tiny Land shelves are just flat rectangular wood pieces; this
// is the same idea with rounded corners (the "upgrade") instead of sharp
// ones, driven by a single explicit thickness parameter.
//
//   use <model-forge/board.scad>
//   rounded_board(outer_width=285.75, outer_height=177.8, corner_radius=25.4, thickness=3);
use <model-forge/tray.scad> // rounded_rect_2d

module rounded_board(outer_width, outer_height, corner_radius, thickness) {
  linear_extrude(height = thickness)
    rounded_rect_2d(outer_width, outer_height, corner_radius);
}
