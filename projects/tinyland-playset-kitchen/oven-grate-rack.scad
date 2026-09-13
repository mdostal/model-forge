// Tiny Land oven grate v2 — full-scale rack construction: 16 real bars
// dovetailing into a top rail and a bottom rail, at the validated
// -0.1mm clearance. Same numbers as the original oven_grate()'s
// auto-fit bar pattern (16 bars, 10mm wide, 7.537mm gaps) so this sits
// in the exact same footprint.
//
// The rails (285.75mm) still exceed the 256mm bed by ~30mm -- that
// splice is meant to be done with Bambu Studio's own sliding Dovetail
// cut mode (the tool and orientation already validated and preferred),
// not hand-rolled here. Import rail.stl, use the Cut tool on it.
//
// The 16 bars (215.9mm each) all fit the bed individually and are laid
// out here as one printable plate.
use <model-forge/rack.scad>

/* [Size — inches, matches oven-grate.scad] */
outer_width_in  = 11.25;
outer_height_in = 9;

/* [Bars] */
frame_width_mm = 6.35;
bar_width_mm   = 10;
n_bars         = 16;

IN_TO_MM = 25.4;
outer_w = outer_width_in * IN_TO_MM;
outer_h = outer_height_in * IN_TO_MM;
thickness = 5.08;

inner_w = outer_w - 2 * frame_width_mm;
inner_h = outer_h - 2 * frame_width_mm;
actual_gap = (inner_w - n_bars * bar_width_mm) / (n_bars - 1);
bar_pitch = bar_width_mm + actual_gap;
first_offset = frame_width_mm + bar_width_mm / 2;

// One rail — 16 slots, 285.75mm long (exceeds the bed; splice via
// Bambu Studio's sliding Dovetail cut, not here). Same rail design
// works as both top and bottom (mirror it for the opposite-facing
// slots — see rack.scad).
module grate_rail() {
  rack_rail(outer_w, frame_width_mm, thickness, n_bars, bar_pitch, first_offset);
}

// One bar — 215.9mm, fits the bed on its own.
module grate_bar() {
  rack_bar(inner_h, bar_width_mm, thickness);
}

grate_rail();

// All 16 bars, tiled on one plate below the rail.
bar_gap = 3;
for (i = [0 : n_bars - 1])
  translate([i * (bar_width_mm + bar_gap), frame_width_mm + 20, 0])
    grate_bar();
