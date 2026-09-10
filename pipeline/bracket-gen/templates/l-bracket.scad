// l-bracket.scad — parametric L-shaped angle bracket.
//
// Two flat faces at 90 degrees. Face A carries a countersunk hex-bolt hole;
// Face B carries an oblong adjustment slot. Modeled after the corner-bracket
// shape described in ../../../projects/furniture-brackets/NOTES.md.
//
// All parameters are overridden from the command line via `-D name=value`
// by pipeline/bracket-gen/src/render.js — do not hand-edit the defaults
// below for a real part, override them instead so the template stays
// reusable for the next bracket (per ROADMAP.md Milestone 1's "feed
// numbers, get an STL" goal).

// --- Parameters (defaults are a plausible small bracket, not a real part) ---
face_a_length   = 40;   // mm, length of the first flat face
face_b_length   = 40;   // mm, length of the second flat face
width           = 20;   // mm, bracket width (constant along both faces)
thickness       = 4;    // mm, material thickness (already PLA-bumped by the caller)
bend_radius     = 3;    // mm, inner fillet radius at the 90-degree bend

hole_diameter        = 5.5; // mm, hex-bolt clearance hole on Face A
countersink_diameter = 10;  // mm, countersink diameter on Face A
countersink_depth    = 2.5; // mm, countersink depth
hole_offset          = 10;  // mm, hole center distance from the bend, along Face A

slot_length = 14;  // mm, oblong adjustment slot length on Face B
slot_width  = 6;   // mm, oblong adjustment slot width
slot_offset = 12;  // mm, slot center distance from the bend, along Face B

$fn = 64; // smooth enough for functional PLA/PETG prints, not a display model

module l_bracket() {
  difference() {
    union() {
      // Face A: lies flat along X, thickness rises in Z
      translate([0, 0, 0])
        cube([face_a_length, width, thickness]);

      // Face B: rotated up 90 degrees from the shared bend edge at x=0
      translate([0, 0, 0])
        rotate([0, -90, 0])
          cube([face_b_length, width, thickness]);

      // Inner fillet at the bend, so the corner isn't a stress-concentrating
      // sharp inside edge (README's "add a fillet at the bend" note).
      translate([0, 0, 0])
        rotate([-90, 0, 0])
          cylinder(h = width, r = bend_radius);
    }

    // Hex-bolt hole + countersink, centered on Face A
    translate([hole_offset, width / 2, thickness - countersink_depth])
      cylinder(h = countersink_depth + 1, d1 = hole_diameter, d2 = countersink_diameter);
    translate([hole_offset, width / 2, -1])
      cylinder(h = thickness + 2, d = hole_diameter);

    // Oblong adjustment slot on Face B (cut along the face's long axis)
    translate([-thickness - 1, width / 2, slot_offset])
      rotate([0, 90, 0])
        hull() {
          translate([0, -(slot_length - slot_width) / 2, 0])
            cylinder(h = thickness + 2, d = slot_width);
          translate([0, (slot_length - slot_width) / 2, 0])
            cylinder(h = thickness + 2, d = slot_width);
        }
  }
}

l_bracket();
