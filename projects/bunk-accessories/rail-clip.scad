// Bunk rail system, shared library.
//
// A rail clip hooks over a bed's top guardrail rail. Its plate carries a
// vertical dovetail tail; every accessory (cup, tissue box, cubby, and
// later a wardrobe rod or hooks) has a matching socket on its back and
// slides down onto the tail from above until the tail's bottom end sits
// on the socket floor. Wide accessories take two or more clips.
//
// Defaults are the owner's caliper readings (2026-11-08) of a Bellemave
// twin low loft (FST00301-TB-AH): top rail 20.74 front-to-back x 20.38
// tall, lower rails about 15.5 tall x 20.18, 80.54 from the top rail's
// bottom to the next rail's top. The owner reports the rails are 80 apart
// all the way down.
//
// Clip axes: X runs along the rail, Y points away from the rail toward
// the accessory, Z is up. The top rail's bottom face is z = 0 and its
// accessory-side face is y = 0. Inside or outside the bed is the same
// part turned the other way round.
//
// Accessory axes: X along the rail, Y away from the clip, Z up. The
// accessory's back face is y = 0 and the socket floor (where the tail's
// foot rests) is z = 0. Everything below z = 0 is the socket floor.

// ---- dovetail interface (keep these fixed so all parts interchange) ----
function dt_base() = 16;    // tail width at the plate
function dt_tip() = 22;     // tail width at its face
function dt_depth() = 6;    // how far the tail stands off the plate
function dt_wall() = 3;     // accessory material around the socket
function dt_floor() = 2.4;  // socket floor under the tail's foot
function dt_block_w(c) = dt_tip() + 2 * c + 2 * dt_wall();
function dt_block_d(c) = dt_depth() + c + dt_wall();

module dt_profile() {
  polygon([[-dt_base() / 2, 0], [dt_base() / 2, 0],
           [dt_tip() / 2, dt_depth()], [-dt_tip() / 2, dt_depth()]]);
}

// male tail on the clip, standing on y = 0, from z0 to z1
module dt_tail(z0, z1) {
  translate([0, 0, z0]) linear_extrude(z1 - z0) dt_profile();
}

// socket cut, clearance c on every mating face, open through y < 0
module dt_socket(z0, z1, c) {
  translate([0, 0, z0]) linear_extrude(z1 - z0) union() {
    offset(delta = c) dt_profile();
    translate([-dt_base() / 2 - c - 1, -1]) square([dt_base() + 2 * c + 2, 1 + c]);
  }
}

// Give an accessory its mount block(s) and socket(s). Children are the
// accessory body, starting at y = dt_block_d(c). h is the block height
// above the socket floor; xs are the socket centers along X (a clip each).
module with_mounts(h, c = 0.25, xs = [0]) {
  bw = dt_block_w(c);
  bd = dt_block_d(c);
  difference() {
    union() {
      children();
      for (x = xs) translate([x - bw / 2, 0, -dt_floor()]) cube([bw, bd + 0.01, h + dt_floor()]);
    }
    for (x = xs) translate([x, 0, 0]) dt_socket(0, h + 1, c);
    // lead-in chamfer at each socket mouth
    for (x = xs) translate([x, 0, h - 1.5])
      linear_extrude(1.51, scale = 1.25) offset(delta = 0.25) dt_profile();
  }
}

// ---- clip ----
function clip_top(rail_h = 20.38, wall = 3) = rail_h + wall;
function clip_foot(rail_gap = 80.54, brace = 7.5) = -(rail_gap + brace);
function clip_mount_y(clear = 0.4, wall = 3) = clear / 2 + wall;

module rail_clip(rail_d = 20.74, rail_h = 20.38, rail_gap = 80.54,
                 hook_w = 40, wall = 3, leg_t = 2.5, lip = 1.0, lip_h = 2.5,
                 brace = 7.5, clear = 0.4, eps = 0.01) {
  top_z = clip_top(rail_h, wall);
  foot_z = clip_foot(rail_gap, brace);
  near_y = clear / 2;
  far_y = -(rail_d + clear / 2);
  // plate down the near face, resting on the next rail's face
  translate([-hook_w / 2, near_y, foot_z]) cube([hook_w, wall, top_z - foot_z]);
  // saddle across the rail top
  translate([-hook_w / 2, far_y - leg_t, rail_h])
    cube([hook_w, rail_d + clear + leg_t + wall, wall]);
  // far leg down the rail's far face
  translate([-hook_w / 2, far_y - leg_t, -lip_h]) cube([hook_w, leg_t, rail_h + lip_h + eps]);
  // snap lip under the rail's far edge, lead-in chamfer on its lower face
  translate([hook_w / 2, far_y, -lip_h]) rotate([0, -90, 0]) linear_extrude(hook_w)
    polygon([[0, 0], [lip_h, 0], [lip_h, lip], [lip_h - lip, lip]]);
  // dovetail tail on the plate's outer face, full plate height
  translate([0, clip_mount_y(clear, wall) - eps, 0]) dt_tail(foot_z, top_z);
}

// place an accessory (in accessory axes) on a default clip at x
module on_clip(x = 0, clear = 0.4, wall = 3, rail_gap = 80.54, brace = 7.5) {
  translate([x, clip_mount_y(clear, wall), clip_foot(rail_gap, brace)])
    children();
}

// the bed's rails, for renders only (accessory side is +Y)
module rail_ghost(rail_d = 20.74, rail_h = 20.38, rail_gap = 80.54, low_d = 20.18, low_h = 15.5) {
  color("pink", 0.5) {
    translate([-200, -rail_d, 0]) cube([400, rail_d, rail_h]);
    translate([-200, -rail_d / 2 - low_d / 2, -rail_gap - low_h]) cube([400, low_d, low_h]);
  }
}

// assembly preview: rails, clips at xs, accessory. The clip is the same
// part inside or outside the bed; it just goes on the other way round.
module bunk_assembly(xs = [0]) {
  rail_ghost();
  for (x = xs) color("orchid") translate([x, 0, 0]) rail_clip();
  color("plum") on_clip() children();
}
