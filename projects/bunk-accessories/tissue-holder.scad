// Bunk tissue box holder: an open-top tray that slides onto rail clips
// (clip.scad) and holds a flat tissue box lying down, long side along the
// rail, so tissues pull from its top. A hole in the floor lets you push
// the box up to swap it.
//
// Box defaults are a PLACEHOLDER for a Costco Kleenex flat box; measure
// yours (length, width, height) and change the Box values.
//
// Print upright as modeled, no supports: the floor sits on the bed and
// the windows have 45 deg pointed tops.

use <rail-clip.scad>

/* [Box, measure yours] */
box_l = 240;      // along the rail (placeholder)
box_w = 125;      // away from the rail (placeholder)
box_h = 95;       // placeholder
box_clear = 3;    // added to length and width
hold = 0.6;       // fraction of the box height the tray walls cover

/* [Tray] */
tray_wall = 2;
floor_t = 2.4;
ledge = 16;       // floor rim the box sits on; the middle is open
windows = true;
clips = 2;        // 1 or 2 rail clips
clip_pitch = 140; // clip spacing when using 2; must miss the bed's posts

/* [Fit] */
dt_clear = 0.25;

part = "holder"; // [holder, assembly]

/* [Hidden] */
eps = 0.01;

il = box_l + box_clear;
iw = box_w + box_clear;
ol = il + 2 * tray_wall;
y0 = dt_block_d(dt_clear) - eps;
ow = iw + 2 * tray_wall;
bot = -dt_floor();
th = floor_t + box_h * hold;             // tray height
xs = clips >= 2 ? [-clip_pitch / 2, clip_pitch / 2] : [0];

module win(w, h, len) {
  // pointed-top window in the XZ plane, cut through len along Y
  rotate([90, 0, 0]) translate([0, 0, -len / 2]) linear_extrude(len)
    polygon([[-w / 2, 0], [w / 2, 0], [w / 2, h], [0, h + w / 2], [-w / 2, h]]);
}

module tray() {
  wz = bot + floor_t + 10;
  room = bot + th - 8 - wz;              // window height available
  difference() {
    translate([-ol / 2, y0, bot]) cube([ol, ow, th]);
    translate([-il / 2, y0 + tray_wall, bot + floor_t]) cube([il, iw, th]);
    translate([-il / 2 + ledge, y0 + tray_wall + ledge, bot - 1])
      cube([il - 2 * ledge, iw - 2 * ledge, floor_t + 2]);
    if (windows && room > 20) {
      // front wall: three windows; side walls: one each
      fw = min(50, room);
      for (i = [-1, 0, 1]) translate([i * il / 3, y0 + ow, wz]) win(fw, room - fw / 2, 8);
      sw = min(iw * 0.5, room);
      for (s = [-1, 1]) translate([s * ol / 2, y0 + ow / 2, wz]) rotate([0, 0, 90])
        win(sw, room - sw / 2, 8);
    }
  }
}

module holder() { with_mounts(max(th - floor_t, 50), dt_clear, xs) tray(); }

if (part == "assembly") bunk_assembly(xs) holder(); else holder();
