// Bunk rail clip: hooks over the bed's top guardrail rail and carries the
// dovetail tail every accessory slides onto. The same clip works on the
// inside or the outside of the bed; turn it round. Print one per socket.
//
// The exported clip is flipped for printing: saddle flat on the bed,
// plate, far leg and tail standing up from it, no supports. (Printed the
// other way up, the far leg would start in mid-air.)

use <rail-clip.scad>

/* [Mount] */
// top: hangs on the top rail, J under the middle bar
// middle: clips onto one middle bar by itself
// mid-bottom: hangs on a middle bar, J under the bottom frame
mount = "top";    // [top, middle, mid-bottom]

/* [Rails, measure yours] */
rail_d = 20.74;   // top rail, front to back
rail_h = 20.38;   // top rail height
rail_gap = 80.54; // gap between rails (top to middle, middle to bottom: equal on our bed)
clear = 0.4;      // added to a rail's depth for the saddle
low_h = 15.42;    // middle bar height
low_d = 15.42;    // middle bar, front to back
low_set = 2.47;   // how far the middle bar's near face sits behind the top rail's
bot_h = 40.21;    // bottom frame height
bot_d = 20.74;    // bottom frame, front to back
bot_set = 0;      // how far the bottom frame's near face sits behind the top rail's
catch_reach = 1.5; // [0.5:0.25:5] hook catch: how far the lip reaches under the next rail
nub_h = 2;        // [1:0.5:4] j catch: how far the nub turns up behind the next rail

/* [Clip] */
hook_w = 40;      // along the rail
wall = 3;         // saddle and plate thickness
leg_t = 2.5;      // far leg thickness (this is the part that flexes)
lip = 1.0;        // how far the snap lip reaches under the rail
lip_h = 2.5;
brace = 7.5;      // how far the plate laps over the next rail's face
catch = "j";      // [none, hook, j] hook: a lip snaps under the next rail so a bump from below can't lift the clip

label = "";       // short mark engraved on the far leg's outside (test plates: which variant is which)

part = "clip"; // [clip, assembly, rails, onrail]  rails/onrail: pieces for print-check

// what this clip hangs from (h) and what it catches (l), per mount
hd = mount == "top" ? rail_d : low_d;
hh = mount == "top" ? rail_h : low_h;
ld = mount == "top" ? low_d : bot_d;
lh = mount == "top" ? low_h : bot_h;
ls = mount == "top" ? low_set : bot_set - low_set;   // relative to the hanging rail's face
wrap = mount == "middle";
assert(mount == "top" || mount == "middle" || mount == "mid-bottom", str("clip: unknown mount ", mount));

module the_clip() rail_clip(hd, hh, rail_gap, hook_w, wall, leg_t, lip, lip_h, brace, clear,
            catch = catch, low_h = lh, low_d = ld, low_set = ls, catch_reach = catch_reach, nub_h = nub_h, wrap = wrap);
module the_rails() if (wrap) rail_ghost(hd, hh, -hh, hd, hh, 0);
                   else rail_ghost(hd, hh, rail_gap, ld, lh, ls);

if (part == "rails") the_rails();
else if (part == "onrail") the_clip();
else if (part == "assembly") { the_rails(); color("orchid") the_clip(); }
else translate([0, 0, hh + wall]) rotate([180, 0, 0]) difference() {
  the_clip();
  if (label != "") translate([0, -(hd + clear / 2 + leg_t) - 0.01, hh / 2]) rotate([90, 0, 0])
    translate([0, 0, -0.6]) linear_extrude(0.62)
      text(label, size = min(8, hh * 0.5), font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
}
