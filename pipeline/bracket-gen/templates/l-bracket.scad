// l-bracket.scad — parametric L-shaped angle bracket.
//
// Corrected 2026-09-13 from direct photo inspection (reference-photos/),
// superseding the earlier asymmetric NOTES.md reading: this is a SYMMETRIC
// bracket — both faces the same length, both faces carry the same vertical
// oval hole, and every corner (the bend AND the outer plate corners) is
// rounded. The old version had unequal faces, a hex-bolt-hole+countersink
// on Face A only (the real part has no such hole at all), an oblong slot
// oriented along the face's length instead of vertically, sharp outer
// corners, and a bend fillet that bulged out the WRONG side (unclipped
// cylinder extends into the outside-the-bend quadrant too, not just the
// inside corner it's meant to fill).
//
// All parameters are overridden from the command line via `-D name=value`
// by pipeline/bracket-gen/src/render.js — do not hand-edit the defaults
// below for a real part, override them instead so the template stays
// reusable for the next bracket (per ROADMAP.md Milestone 1's "feed
// numbers, get an STL" goal).

// --- Parameters (defaults are a plausible small bracket, not a real part) ---
face_length     = 26;   // mm, BOTH faces share this length (real part: equal)
width           = 15;   // mm, bracket width (constant along both faces)
thickness       = 4;    // mm, material thickness (already PLA-bumped by the caller)
bend_radius     = 3;    // mm, inner fillet radius at the 90-degree bend
outer_corner_radius = 2; // mm, rounding on each face's 2 outer plate corners

hole_length  = 12;  // mm, oval hole's LONG axis — oriented vertically (across width)
hole_width   = 7;   // mm, oval hole's SHORT axis — along the face's length direction
hole_offset  = 16;  // mm, hole center distance from the bend, along the face length

$fn = 64; // smooth enough for functional PLA/PETG prints, not a display model

// A face plate: face_length x width, with 2 outer corners rounded (the 2
// corners at the far end, away from the bend — the bend-side edge stays
// square since it's consumed by the bend fillet) and a vertical oval hole
// cut through it.
module face_plate_2d() {
  difference() {
    hull() {
      // Bend-side edge (x=0): left square, no rounding — the bend fillet
      // covers this edge.
      translate([0, 0]) square([0.01, width]);
      // Far edge (x=face_length): rounded corners.
      translate([face_length - outer_corner_radius, outer_corner_radius])
        circle(r = outer_corner_radius);
      translate([face_length - outer_corner_radius, width - outer_corner_radius])
        circle(r = outer_corner_radius);
    }
    // Vertical oval: long axis (hole_length) across width, short axis
    // (hole_width) along the face length — hull of 2 circles stacked
    // along the width (Y) direction.
    translate([hole_offset, width / 2])
      hull() {
        translate([0, -(hole_length - hole_width) / 2]) circle(d = hole_width);
        translate([0, (hole_length - hole_width) / 2]) circle(d = hole_width);
      }
  }
}

module l_bracket() {
  eps = 0.05; // small overlap so the fillet genuinely welds to both faces
              // instead of meeting them at an exactly-coincident face
  union() {
    // Face A: lies flat along X, thickness rises in Z
    linear_extrude(height = thickness)
      face_plate_2d();

    // Face B: rotated up 90 degrees from the shared bend edge at x=0
    rotate([0, -90, 0])
      linear_extrude(height = thickness)
        face_plate_2d();

    // Inner fillet at the bend. Bug fixed 2026-09-13: a bare cylinder
    // centered on the bend axis bulges into the OUTSIDE-the-bend
    // quadrant too (x<0 or z<0), not just the inside corner it's meant
    // to fill -- that's the "weird bump on the bottom" from the real
    // print. Clipped with an intersection to only the inside-the-bend
    // quadrant (x>=0 and z>=0), so it fills the concave inner corner
    // without adding any material outside the bracket's own footprint.
    intersection() {
      translate([0, 0, 0])
        rotate([-90, 0, 0])
          cylinder(h = width, r = bend_radius + eps);
      translate([-eps, -eps, -eps])
        cube([bend_radius + eps, width + 2 * eps, bend_radius + eps]);
    }
  }
}

l_bracket();
