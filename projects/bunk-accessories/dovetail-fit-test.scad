// Dovetail fit test for the bunk rail system. Print both parts, then try
// the tail in each of the three sockets.
//
//   1 dot  = 0.15 clearance (tightest)
//   2 dots = 0.25 (the default)
//   3 dots = 0.35 (loosest)
//
// Pick the tightest socket the tail slides fully into by hand without
// forcing, and that doesn't rattle. Set dt_clear in each accessory to that
// value. Both parts print upright as modeled, no supports.

use <rail-clip.scad>

part = "both"; // [both, tail, sockets]
clears = [0.15, 0.25, 0.35];
h = 30;

module tail_piece() {
  // plate with a long tail, grip tab above the tail so it can be pulled out
  translate([-15, -3, 0]) cube([30, 3, h + 15]);
  dt_tail(0, h + 15);
}

module socket_piece() {
  bw = dt_block_w(0.35);
  pitch = bw + 4;
  difference() {
    translate([-pitch * 1.5, 0, 0]) cube([pitch * 3, dt_block_d(0.35), h]);
    for (i = [0 : 2]) {
      x = (i - 1) * pitch;
      translate([x, 0, -1]) dt_socket(0, h + 2, clears[i]);
      // dots on the top face, between this socket and the back face
      for (k = [0 : i]) translate([x + (k - i / 2) * 4, dt_block_d(0.35) - 1.4, h - 0.6])
        cylinder(d = 1.8, h = 1, $fn = 16);
    }
  }
}

if (part == "tail") tail_piece();
else if (part == "sockets") socket_piece();
else { tail_piece(); translate([0, 25, 0]) socket_piece(); }
