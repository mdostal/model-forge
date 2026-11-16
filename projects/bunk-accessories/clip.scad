// Bunk rail clip: hooks over the bed's top guardrail rail and carries the
// dovetail tail every accessory slides onto. The same clip works on the
// inside or the outside of the bed; turn it round. Print one per socket.
//
// The exported clip is flipped for printing: saddle flat on the bed,
// plate, far leg and tail standing up from it, no supports. (Printed the
// other way up, the far leg would start in mid-air.)

use <rail-clip.scad>

/* [Rail, measure yours] */
rail_d = 20.74;   // top rail, front to back
rail_h = 20.38;   // top rail height
rail_gap = 80.54; // top rail bottom to next rail top
clear = 0.4;      // added to the rail's depth for the saddle
low_h = 15.5;     // next rail's height (the hook catches its underside)
low_d = 20.18;    // next rail, front to back

/* [Clip] */
hook_w = 40;      // along the rail
wall = 3;         // saddle and plate thickness
leg_t = 2.5;      // far leg thickness (this is the part that flexes)
lip = 1.0;        // how far the snap lip reaches under the rail
lip_h = 2.5;
brace = 7.5;      // how far the plate laps over the next rail's face
catch = "hook";   // [none, hook] hook: a lip snaps under the next rail so a bump from below can't lift the clip

part = "clip"; // [clip, assembly, rails, onrail]  rails/onrail: pieces for print-check

if (part == "rails") rail_ghost(rail_d, rail_h, rail_gap, low_d, low_h);
else if (part == "onrail") rail_clip(rail_d, rail_h, rail_gap, hook_w, wall, leg_t, lip, lip_h, brace, clear,
            catch = catch, low_h = low_h, low_d = low_d);
else if (part == "assembly") { rail_ghost(rail_d, rail_h, rail_gap, low_d, low_h); color("orchid")
  rail_clip(rail_d, rail_h, rail_gap, hook_w, wall, leg_t, lip, lip_h, brace, clear,
            catch = catch, low_h = low_h, low_d = low_d); }
else translate([0, 0, rail_h + wall]) rotate([180, 0, 0])
  rail_clip(rail_d, rail_h, rail_gap, hook_w, wall, leg_t, lip, lip_h, brace, clear,
            catch = catch, low_h = low_h, low_d = low_d);
