// Tiny Land oven grate v2 — ASSEMBLY PREVIEW ONLY, not for printing.
//
// Positions every real piece from oven-grate-rack.scad exactly where it
// goes when assembled: top rail, bottom rail, 14 normal bars + 2 edge
// bars between them. The edge bars (wider, rounded outer corner, carry
// the lip) replace what used to be a separate perpendicular side-rail
// piece — same tenon-into-mortise mechanism as every other bar, just a
// wider body on the outer end. No separate corner joint to design.
//
// View this in OpenSCAD to see the whole thing fit together before
// printing the real (separate) pieces from oven-grate-rack.scad.
use <model-forge/rack.scad>

outer_width_in  = 11.25;
outer_height_in = 9;
frame_width_mm  = 6.35;
bar_width_mm    = 10;
n_bars          = 16;
end_lip_width_in = 0.5;
lip_thickness_mm = 2.5;
edge_fillet_mm   = 3;

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;

color("SteelBlue") {
  // Bottom rail — slots face up toward the bars.
  translate([0, frame_width_mm, 0])
    mirror([0, 1, 0])
      rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);

  // Top rail — slots face down toward the bars (natural orientation).
  translate([0, frame_width_mm + inner_h, 0])
    rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);
}

color("Goldenrod")
  for (i = [1 : n_bars - 2])
    translate([first_offset + i * bar_pitch - bar_width_mm / 2, frame_width_mm, 0])
      rack_bar(inner_h, bar_width_mm, thickness);

color("FireBrick") {
  // Left edge bar — wing/lip extend further left (outward).
  translate([first_offset - bar_width_mm / 2, frame_width_mm, 0])
    rack_edge_bar(inner_h, bar_width_mm, thickness, frame_width_mm, edge_fillet_mm,
      end_lip_width_in * IN_TO_MM, lip_thickness_mm);

  // Right edge bar — mirrored so its wing/lip extend right (outward).
  last_center = first_offset + (n_bars - 1) * bar_pitch;
  translate([last_center + bar_width_mm / 2, frame_width_mm, 0])
    mirror([1, 0, 0])
      rack_edge_bar(inner_h, bar_width_mm, thickness, frame_width_mm, edge_fillet_mm,
        end_lip_width_in * IN_TO_MM, lip_thickness_mm);
}
