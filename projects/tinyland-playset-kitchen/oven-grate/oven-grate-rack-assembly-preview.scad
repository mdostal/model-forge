// Tiny Land oven grate v2 — ASSEMBLY PREVIEW ONLY, not for printing.
//
// Positions every real piece from oven-grate-rack.scad exactly where it
// goes when assembled: top rail, bottom rail, 14 normal bars + 2 edge
// bars between them. The rail's own ends and the edge bars are both
// cropped to the SAME true rounded silhouette (22mm corner radius, not
// the original 25.4mm — see oven-grate-rack.scad's header for why), so
// they line up into one continuous rounded-rectangle outline once
// assembled — the original grate's shape, built from 3 piece types.
//
// The 2 end slots (edge bars) have floor-at-top/tenon-from-bottom,
// opposite the 14 middle slots (normal bars, floor-at-bottom) — the
// edge bars are loaded by the rack pulling against the oven cavity's
// side groove, not by weight from above, so the floor goes on the side
// that actually resists that force. See oven-grate-rack.scad's
// grate_rail() comment for the full reasoning.
//
// View this in OpenSCAD to see the whole thing fit together before
// printing the real (separate) pieces from oven-grate-rack.scad.
use <model-forge/rack.scad>
use <model-forge/joint.scad>
use <model-forge/tray.scad>

outer_width_in  = 11.25;
outer_height_in = 9;
frame_width_mm  = 6.35;
bar_width_mm    = 10;
n_bars          = 16;
end_lip_width_in = 0.5;
lip_thickness_mm = 2.5;
modular_corner_radius = 22;

TENON_WIDTH = 3.5;
TENON_DEPTH = 2.5;
TENON_TAPER = 0.8;
CLEARANCE   = -0.1;

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;
floor_thickness = 1;
tenon_h = thickness - floor_thickness;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;
crop_x = frame_width_mm + bar_width_mm;

module rail_shape() {
  intersection() {
    difference() {
      cube([outer_w, frame_width_mm, thickness]);
      for (i = [0 : n_bars - 1]) {
        x = first_offset + i * bar_pitch;
        flip_this_one = (i == 0 || i == n_bars - 1);
        z0 = flip_this_one ? -1 : floor_thickness;
        h  = thickness - floor_thickness + 1;
        translate([x, 0, z0])
          linear_extrude(height = h)
            dovetail_tab_2d(
              TENON_WIDTH + 2 * CLEARANCE,
              TENON_DEPTH + CLEARANCE,
              TENON_TAPER + CLEARANCE
            );
      }
    }
    linear_extrude(height = thickness + 2)
      rounded_rect_2d(outer_w, outer_h, modular_corner_radius);
  }
}

module edge_bar_left_shape() {
  eps = 0.05;
  lip_w = end_lip_width_in * IN_TO_MM;
  union() {
    intersection() {
      linear_extrude(height = thickness)
        rounded_rect_2d(outer_w, outer_h, modular_corner_radius);
      translate([-1, -1, -1])
        cube([crop_x + 1, outer_h + 2, thickness + 2]);
    }
    // Tenons at z=0 (floor-at-top) — matches the flipped rail slots.
    translate([first_offset, frame_width_mm, 0])
      rotate([0, 0, 180])
        linear_extrude(height = tenon_h)
          dovetail_tab_2d(TENON_WIDTH, TENON_DEPTH, TENON_TAPER);
    translate([first_offset, outer_h - frame_width_mm, 0])
      linear_extrude(height = tenon_h)
        dovetail_tab_2d(TENON_WIDTH, TENON_DEPTH, TENON_TAPER);
    translate([-lip_w, frame_width_mm, thickness - lip_thickness_mm])
      cube([lip_w + eps, inner_h, lip_thickness_mm]);
  }
}

color("SteelBlue") {
  // Bottom rail — slots face up toward the bars.
  translate([0, frame_width_mm, 0])
    mirror([0, 1, 0])
      rail_shape();

  // Top rail — slots face down toward the bars (natural orientation).
  translate([0, frame_width_mm + inner_h, 0])
    rail_shape();
}

color("Goldenrod")
  for (i = [1 : n_bars - 2])
    translate([first_offset + i * bar_pitch - bar_width_mm / 2, frame_width_mm, 0])
      rack_bar(inner_h, bar_width_mm, thickness);

color("FireBrick") {
  edge_bar_left_shape();
  mirror([1, 0, 0])
    translate([-outer_w, 0, 0])
      edge_bar_left_shape();
}
