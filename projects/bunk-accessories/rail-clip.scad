// Bunk rail system, shared library.
//
// A rail clip hooks over a bed's top guardrail rail. Its plate carries a
// vertical dovetail tail; every accessory (cup, tissue box, cubby, and
// later a wardrobe rod or hooks) has a matching socket on its back. The
// socket is open at the bottom and capped by a roof at the top: you lower
// the accessory from above, the tail enters through the socket's bottom
// mouth, and the roof comes down onto the tail's top end. Weight and a
// dropped cup push the roof harder onto the tail, so a load can't slide
// the accessory off; only lifting it does. Wide accessories take two or
// more clips.
//
// (Before 2026-11-12 the stop was a floor at the socket's bottom, which
// meant the accessory went on by being pushed UP and any downward load
// slid it off. pipeline/print-check's retention check now fails that.)
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
// accessory's back face is y = 0 and the underside of the socket roof
// (where the tail's top end bears) is z = 0. The roof is z = 0 to
// dt_roof(); the accessory hangs below.

// ---- dovetail interface (keep these fixed so all parts interchange) ----
function dt_base() = 16;    // tail width at the plate
function dt_tip() = 22;     // tail width at its face
function dt_depth() = 6;    // how far the tail stands off the plate
function dt_wall() = 3;     // accessory material around the socket
function dt_roof() = 2.4;   // socket roof over the tail's top end; carries the load
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
// accessory body, starting at y = dt_block_d(c). The block runs from
// z = -h up to the roof's top (dt_roof()); its socket is open at the
// bottom and stops at the roof. h is how much tail the socket takes; a
// longer tail just shows below the block. xs are the socket centers along
// X (a clip each).
module with_mounts(h, c = 0.25, xs = [0]) {
  bw = dt_block_w(c);
  bd = dt_block_d(c);
  assert(h >= 30, str("with_mounts: only ", h, " mm of tail engaged; 30 is the minimum"));
  difference() {
    union() {
      children();
      for (x = xs) translate([x - bw / 2, 0, -h]) cube([bw, bd + 0.01, h + dt_roof()]);
    }
    for (x = xs) translate([x, 0, 0]) dt_socket(-h - 1, 0, c);
    // 45 deg lead-in chamfer at each socket's bottom mouth
    for (x = xs) translate([x, 0, 0]) hull() {
      translate([0, 0, -h - 0.01]) linear_extrude(0.01) offset(delta = c + 1.2) dt_profile();
      translate([0, 0, -h + 1.2]) linear_extrude(0.01) offset(delta = c) dt_profile();
    }
  }
}

// ---- clip ----
function clip_top(rail_h = 20.38, wall = 3) = rail_h + wall;
function clip_foot(rail_gap = 80.54, brace = 7.5) = -(rail_gap + brace);
function clip_mount_y(clear = 0.4, wall = 3) = clear / 2 + wall;

module rail_clip(rail_d = 20.74, rail_h = 20.38, rail_gap = 80.54,
                 hook_w = 40, wall = 3, leg_t = 2.5, lip = 1.0, lip_h = 2.5,
                 brace = 7.5, clear = 0.4, eps = 0.01,
                 catch = "none", low_h = 15.5, low_d = 20.18,
                 catch_clear = 0.6, catch_reach = 1.5, catch_t = 2.5) {
  top_z = clip_top(rail_h, wall);
  foot_z = clip_foot(rail_gap, brace);
  near_y = clear / 2;
  far_y = -(rail_d + clear / 2);
  // catch = "hook": the plate runs on past the next rail and a lip snaps
  // under that rail's bottom edge, so a bump from below can't lift the
  // clip off. Its top face is flat (it holds), its underside is a 45 deg
  // ramp so the plate flexes out and over both rails as the clip goes on.
  low_face = -rail_d / 2 + low_d / 2;            // next rail's near face (centered under the top rail, as rail_ghost)
  catch_z = -(rail_gap + low_h) - catch_clear;   // underside of the next rail, plus play
  tip_y = low_face - catch_reach;
  ramp = near_y - tip_y;
  plate_z = catch == "hook" ? catch_z - catch_t - ramp : foot_z;
  assert(catch == "none" || catch == "hook", str("rail_clip: unknown catch ", catch));
  // plate down the near face, resting on the next rail's face
  translate([-hook_w / 2, near_y, plate_z]) cube([hook_w, wall, top_z - plate_z]);
  if (catch == "hook") translate([hook_w / 2, 0, 0]) rotate([0, -90, 0]) linear_extrude(hook_w)
    polygon([[catch_z, near_y + eps], [catch_z, tip_y], [catch_z - catch_t, tip_y],
             [catch_z - catch_t - ramp, near_y + eps]]);
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
module on_clip(x = 0, clear = 0.4, wall = 3, rail_h = 20.38) {
  translate([x, clip_mount_y(clear, wall), clip_top(rail_h, wall)])
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

// pieces of the assembly one at a time, for the print-check tool
module bunk_piece(which, xs = [0]) {
  if (which == "rails") rail_ghost();
  else if (which == "clips") for (x = xs) translate([x, 0, 0]) rail_clip();
  else if (which == "mounted") on_clip() children();
}
