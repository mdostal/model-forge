// Treasure chest -- a lidded chest that closes around the school supply caddy.
// The caddy drops in as an insert; its two end lips poke out through slots in
// the chest's end walls, so they double as the chest's handles and lift the
// insert straight out. All sizes below are editable.
//
// Two ways to get the colors (color_mode):
//   glued      - separate parts, so no multi-color printer is needed
//   multicolor - one painted print per half for an AMS: the straps, name plate
//                and lock are flush inlays, assigned to filaments 1 to 3
// Glued colors:
//   brown  - chest base and lid (wood planks are engraved in)
//   black  - four straps that sit in shallow channels
//   yellow - lock plate and name plate
// Print with no supports: base upright, lid upside down, straps on their edge,
// plates flat (the print_* parts are already oriented). Glue the straps and
// plates into their channels. Hinge pins are 1.75 mm filament, like the art box.

/* [Insert (the caddy) -- match these to your caddy] */
caddy_w = 230;          // [120:1:240] body width, without the lips
caddy_d = 176;          // [100:1:200] front to back
caddy_h = 70;           // [30:1:110]  body height
caddy_lip_out = 10;     // [0:1:16]    how far each end lip sticks out, 0 for none
caddy_lip_len = 70;     // [40:1:120]
caddy_lip_tall = 14;    // [8:1:24]
caddy_lip_center_y = 94; // [40:1:160] measured from the caddy's front
supply_top = 198;       // [60:1:240] tallest supply, measured from the caddy's bottom
caddy_clear = 1;        // [0.5:0.25:3] gap around the caddy

/* [Chest shape] */
wall = 4;               // [3:0.2:6]
floor_t = 3;            // [2:0.2:5]
top_t = 2.4;            // [1.6:0.2:4]
headroom = 4;           // [0:1:20] space above the tallest supply
roof_chamfer = 22;      // [0:1:40] angled lid edges front and back, 45 degrees so they print clean
end_chamfer = 8;        // [0:1:40] angled lid edges on the ends; keep small so tall supplies at the ends fit
lid_overhang = 6;       // [0:1:10] lid sticks out past the base at each end, room for scissor handles
corner_r = 8;           // [2:1:16]
plank_pitch = 24;       // [12:1:40] engraved plank lines, 0 for none
plank_depth = 0.6;      // [0.3:0.1:1.2]

/* [Lid fit] */
lip_h = 3;              // [0:0.5:6]
lip_t = 1.6;            // [1.2:0.2:3]
lip_clear = 0.35;       // [0.15:0.05:0.8]

/* [Hinge] */
knuckle_r = 5;          // [4:0.5:7]
hinge_gap = 0.3;        // [0.2:0.05:1]
hinge_groups = [0.36, 0.64]; // centers, as fractions of the width
base_knuckle_len = 16;  // [8:1:30]
lid_knuckle_len = 24;   // [8:1:40]
knuckle_gap = 0.5;      // [0.3:0.05:1]
pin_hole_base = 2.0;    // [1.6:0.05:3]
pin_hole_lid = 2.4;     // [1.8:0.05:3.5]

/* [Latch] */
latch_w = 18;           // [12:1:30]
tab_t = 1.6;            // [1.2:0.1:2.4]
tab_up = 18;            // [8:1:40] how far up the lid the tab's flexing part reaches
tab_drop = 10;          // [7:1:16]
latch_engage = 1.2;     // [0.6:0.1:1.8]
latch_clear = 0.3;      // [0.15:0.05:0.6]
grip_out = 2.4;         // [1:0.2:4]

/* [Straps (black)] */
strap_x = [0.15, 0.85]; // centers, as fractions of the width; keep symmetric and clear of the hinge
strap_w = 14;           // [6:1:30]
strap_in = 1.0;         // [0.4:0.1:2] channel depth
strap_out = 0.6;        // [0:0.1:2] how far the strap stands proud
strap_clear = 0.2;      // [0.1:0.05:0.5]

/* [Name and lock (yellow)] */
name = "";              // on the name plate; "|" starts a new line, e.g. "First|Middle|Last"
font_name = "Liberation Sans:style=Bold";
name_size = 20;         // [8:1:30] first line
line_scale = 0.75;      // [0.5:0.05:1] size of the later lines
name_fit = 1;           // [0.1:0.0001:1] extra shrink for the whole name; the shop's tools set it so every letter stays inside the plate border
plate_w = 130;          // [60:1:180] minimum; grows to fit the name
plate_h = 34;           // [20:1:90] minimum; grows to fit more lines
plate_t = 2.4;          // [1.6:0.2:4]
text_t = 1.2;           // [0.6:0.2:2]
recess = 1.0;           // [0.4:0.1:2] depth of the plate pockets
plate_clear = 0.3;      // [0.1:0.05:0.6]
lock_w = 30;            // [20:1:50]
lock_h = 38;            // [24:1:60]

/* [Lock style] */
// plate   - keyhole plate on the base (decoration), hidden snap tab holds the lid
// none    - plain front, hidden snap tab holds the lid
// painted - hasp and hoops drawn flush on the base, below the seam, hidden snap tab holds the lid
// painted-seam - the same look drawn where a real hasp attaches, across the seam; the snap tab
//           is colored as part of it. Still a hidden snap tab holding the lid
// plate-seam - the keyhole plate drawn across the seam the same way
// hasp    - working flap on a pin that swings over a loop; a key slides through the loop
lock_style = "plate";   // [plate, plate-seam, painted, painted-seam, hasp, none]
hasp_w = 26;            // [20:1:40] flap width
hasp_t = 3;             // [2:0.2:5] flap thickness
hasp_clear = 0.4;       // [0.2:0.05:0.8] gap between the flap and the chest
hasp_r = 3.5;           // [2.5:0.25:5] hinge barrel radius
hasp_knuckle_len = 8;   // [5:1:14] each fixed knuckle on the lid
hasp_hinge_up = 7;      // [5:1:14] hinge height above the seam
loop_w = 8;             // [6:1:12] loop width
loop_center_down = 14;  // [10:1:24] loop center below the seam
key_hole = 6.4;         // [5:0.1:8] hole through the loop

/* [Color mode] */
color_mode = "glued";   // [glued, multicolor]
inlay_text = 0.6;       // [0.4:0.1:1] multicolor: depth of the dark name and border inlay
mc_region_id = "body";  // [body, straps, name, plate-border, plate, lock, hasp-flap, hasp-rivets, hasp-knuckles, hasp-loop, hasp-key] for part=mc_region
mc_half = "lid";        // [base, lid]
mc_filament = 1;        // [1:brown body, 2:black straps and name, 3:yellow plates] multicolor print part

/* [Output] */
scale_factor = 1;       // [0.8:0.05:1.2]
part = "closed";        // [closed, open, base, lid, straps, plates, lid_straps, base_straps, lock, nameplate, name_reach, print_base, print_lid, print_straps, print_plates, mc_closed, mc_closed_part, mc_region, mc_base_part, mc_lid_part, mc_print_lid, mc_print_base, with_caddy, fit_check, hinge_check]
open_angle = 105;       // [0:5:185]

/* [Hidden] */
$fn = 40;
eps = 0.01;
edge_r = 2;

W = caddy_w + 2*caddy_clear + 2*wall;
D = caddy_d + 2*caddy_clear + 2*wall;
Hb = floor_t + caddy_h + lip_h + 0.5;      // seam sits just above the caddy
H = floor_t + supply_top + headroom + top_t;
lid_h = H - Hb;
ch = min(roof_chamfer, lid_h - 20);
chx = min(end_chamfer, lid_h - 20);
ov = lid_overhang;
LW = W + 2*ov;   // lid width
axis_y = D + hinge_gap + knuckle_r;
axis_z = Hb;
group_len = 2*base_knuckle_len + lid_knuckle_len + 2*knuckle_gap;
cx = W/2;

z_tip = Hb - tab_drop;
z_root = Hb + tab_up;
z_win_bot = z_tip + 3;
z_bump_bot = z_win_bot + 0.2;
z_bump_top = z_bump_bot + 1.0 + latch_engage*1.8;
z_win_top = z_bump_top + 0.6;
recess_d = tab_t + latch_clear;
boss_t = 2.2;

slot_y0 = wall + caddy_clear + caddy_lip_center_y - caddy_lip_len/2 - 1.5;
slot_len = caddy_lip_len + 3;
slot_z0 = floor_t + caddy_h - caddy_lip_tall - 2;
name_z = (z_root + 8 + H - max(ch, chx))/2;
plate_hh = len(name) > 0 ? max(plate_h, name_block_h() + 14) : plate_h;   // plate height used
// The plate grows to fit the longest line, up to the gap between the straps;
// past that the text shrinks. Glyph width is estimated (OpenSCAD 2021 can't measure text).
char_w = 0.8;
name_est_w = len(name) > 0 ? max([for (k = [0:len(name_lines()) - 1]) len(name_lines()[k])*line_size(k)*char_w]) : 0;
plate_max = W*(strap_x[1] - strap_x[0]) - strap_w - 6;
plate_ww = min(plate_max, max(plate_w, name_est_w + 16));   // plate width used
// name_fit shrinks it further, for fonts whose letters run wider or taller than the count allows for.
text_fit = (name_est_w > 0 ? min(1, (plate_ww - 16)/name_est_w) : 1)*name_fit;
lock_z = z_tip - 16 - lock_h/2;
has_tab = lock_style != "hasp";                          // hidden snap tab
has_lock_art = lock_style == "plate" || lock_style == "painted";
has_hasp = lock_style == "hasp";
has_seam_art = lock_style == "painted-seam" || lock_style == "plate-seam";
hasp_ay = -(hasp_clear + hasp_r);                        // hinge axis, in front of the lid face
hasp_az = Hb + hasp_hinge_up;
loop_z = Hb - loop_center_down;
loop_hole_y = -(hasp_clear + hasp_t + 0.8 + key_hole/2); // the key clears the closed flap
loop_tip_y = loop_hole_y - key_hole/2 - 2;
loop_top = loop_z + key_hole/2*sqrt(2) + 2;              // teardrop tip plus a wall
loop_under = loop_z - key_hole/2 - 2;
slot_top = loop_top + 0.6;
slot_bot = loop_under + (loop_tip_y + hasp_clear) - 0.6; // clears the loop's 45-degree underside
hasp_bot = slot_bot - 6.5;

module rrect(w, d, r) {
  rr = min(r, min(w, d)/2 - eps);
  translate([rr, rr]) offset(r = rr) square([w - 2*rr, d - 2*rr]);
}
module outline(inset = 0) {
  translate([inset, inset]) rrect(W - 2*inset, D - 2*inset, max(1, corner_r - inset));
}
module lid_outline(ix = 0, iy = 0) {
  translate([-ov + ix, iy]) rrect(LW - 2*ix, D - 2*iy, max(1, corner_r - min(ix, iy)));
}
module along_x(x0, len) {
  translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) children();
}
module along_y(y0, len) {
  translate([0, y0 + len, 0]) rotate([90, 0, 0]) linear_extrude(len) children();
}
module teardrop(d, up = true) {
  rotate(up ? 0 : 180) union() {
    circle(d = d);
    polygon([[-d/2*cos(45), d/2*sin(45)], [0, d/2*sqrt(2)], [d/2*cos(45), d/2*sin(45)]]);
  }
}

// Outside shapes, grown (g > 0) or shrunk (g < 0) for strap channels and straps.
module base_solid(g = 0, ztop = Hb) {
  translate([0, 0, -g]) linear_extrude(ztop + g) outline(-g);
}
// 45 degree insets of the lid's outside at height z, ends (x) and front/back (y)
function lid_ix(z) = max(0, z - (H - chx));
function lid_iy(z) = max(0, z - (H - ch));
module lid_solid(g = 0, zbot = Hb) {
  z1 = H - max(ch, chx);
  z2 = H - min(ch, chx);
  hull() {
    translate([0, 0, zbot]) linear_extrude(z1 - zbot) lid_outline(-g, -g);
    for (z = [z2, H]) translate([0, 0, z + (z == H ? g - eps : 0)]) linear_extrude(eps)
      lid_outline(lid_ix(z) - g*0.414, lid_iy(z) - g*0.414);
  }
}

// ---------- base ----------

module base_knuckle(x0, len) {
  difference() {
    along_x(x0, len) hull() {
      translate([axis_y, axis_z]) circle(r = knuckle_r);
      translate([D - 1, axis_z - 3*knuckle_r]) square([1, 3*knuckle_r]);
    }
    translate([x0 - 1, D - 5, axis_z]) cube([len + 2, 5 + hinge_gap - 0.1, knuckle_r + 1]);
  }
}
module base() {
  difference() {
    union() {
      difference() {
        hull() {
          linear_extrude(eps) outline(0.6);
          translate([0, 0, 0.6]) linear_extrude(Hb - 0.6) outline();
        }
        translate([0, 0, floor_t]) linear_extrude(Hb) outline(wall);
      }
      for (g = hinge_groups) let (x0 = W*g - group_len/2) {
        base_knuckle(x0, base_knuckle_len);
        base_knuckle(x0 + group_len - base_knuckle_len, base_knuckle_len);
      }
    }
    // lip slots, open at the top, with a finger pocket under each lip
    for (x = [-1, W - wall - 1]) translate([x, slot_y0, slot_z0]) cube([wall + 2, slot_len, Hb]);
    for (s = [0, 1]) translate([s ? W - 2.6 : -1, slot_y0, slot_z0 - 16]) cube([3.6, slot_len, 17]);
    // latch recess and finger scoop
    if (has_tab) {
      translate([cx - latch_w/2 - 1, -1, z_tip - 1.5]) cube([latch_w + 2, recess_d + 1, Hb]);
      translate([cx, -(9 - 1.6), z_tip - 5]) sphere(r = 9);
    }
    for (g = hinge_groups)
      along_x(W*g - group_len/2 - 1, group_len + 2) translate([axis_y, axis_z]) teardrop(pin_hole_base, true);
    // plank lines, strap channels, lock pocket
    if (plank_pitch > 0) difference() {   // plank lines stop at the color inlays
      for (z = [plank_pitch:plank_pitch:Hb - 8]) translate([0, 0, z])
        linear_extrude(0.8) difference() { outline(-1); outline(plank_depth); }
      if (color_mode == "multicolor") { base_strap_vol(); if (has_lock_art) face_vol(lock_z, recess) offset(delta = 1) lock_shape(); if (has_seam_art) seam_vol() offset(delta = 1) square_hull_seam(); }
    }
    if (color_mode == "glued") {
      base_strap_vol();
      if (has_lock_art) translate([cx, -eps, lock_z]) rotate([90, 0, 0]) translate([0, 0, -recess])
        linear_extrude(recess + 1) offset(delta = plate_clear) lock_shape();
    }
  }
  if (has_tab) along_x(cx - (latch_w - 8)/2, latch_w - 8) polygon([
    [recess_d + eps, z_bump_bot], [recess_d - latch_engage, z_bump_bot],
    [recess_d - latch_engage, z_bump_bot + 1.0], [recess_d + eps, z_bump_top]]);
  if (has_hasp) hasp_loop();
}

// ---------- lid ----------

module lid_knuckle(x0, len) {
  top = min(3*knuckle_r, lid_h - max(ch, chx) - 1);
  difference() {
    along_x(x0, len) hull() {
      translate([axis_y, axis_z]) circle(r = knuckle_r);
      translate([D - 1, axis_z]) square([1, top]);
    }
    translate([x0 - 1, D - 5, axis_z - knuckle_r - 1]) cube([len + 2, 5 + hinge_gap - 0.1, knuckle_r + 1]);
  }
}
module lid_cavity() {
  t = wall;
  zb = Hb + 4;              // narrow rim band that rests on the base
  zw = zb + ov + 1;         // 45 degrees out to the wider lid
  zt = H - top_t;
  hull() {
    translate([0, 0, Hb - eps]) linear_extrude(zb - Hb + eps) outline(t);
    translate([0, 0, zw]) linear_extrude(eps) lid_outline(t, t);
    for (z = [H - max(ch, chx) - 0.414*t, H - min(ch, chx) - 0.414*t, zt])
      translate([0, 0, z]) linear_extrude(eps) lid_outline(max(t, lid_ix(z) + 1.414*t), max(t, lid_iy(z) + 1.414*t));
  }
  // open the rim band over the lip slots so tall things at the ends clear it
  for (x = [-ov + t - 1, W - wall - 0.5]) translate([x, slot_y0, Hb - lip_h - 1]) cube([ov + wall - t + 1.5, slot_len, 4 + ov + 2 + lip_h + 1]);
}
module lid() {
  difference() {
    union() {
      difference() { lid_solid(); lid_cavity(); }
      if (lip_h > 0) difference() {
        hull() {
          translate([0, 0, Hb - lip_h]) linear_extrude(eps) outline(wall + lip_clear + 0.8);
          translate([0, 0, Hb - lip_h + 0.8]) linear_extrude(lip_h - 0.8 + eps) outline(wall + lip_clear);
        }
        translate([0, 0, Hb - lip_h - 1]) linear_extrude(lip_h + 2) outline(wall + lip_clear + lip_t);
        if (has_tab) translate([cx - latch_w/2 - 7, 0, Hb - lip_h - 1]) cube([latch_w + 14, wall + boss_t + 2, lip_h + 2]);
        for (x = [-1, W - wall - lip_clear - lip_t - 1]) translate([x, slot_y0, Hb - lip_h - 1]) cube([wall + lip_clear + lip_t + 2, slot_len, lip_h + 2]);
      }
      for (g = hinge_groups)
        lid_knuckle(W*g - group_len/2 + base_knuckle_len + knuckle_gap, lid_knuckle_len);
    }
    if (has_tab) translate([cx - latch_w/2 - 1, -1, Hb - lip_h - 1]) cube([latch_w + 2, wall + 2, z_root - Hb + lip_h + 1]);
    for (g = hinge_groups)
      along_x(W*g - group_len/2 - 1, group_len + 2) translate([axis_y, axis_z]) teardrop(pin_hole_lid, false);
    if (plank_pitch > 0) difference() {   // plank lines stop at the color inlays
      union() {
        for (z = [Hb + plank_pitch:plank_pitch:H - max(ch, chx) - 6]) translate([0, 0, z])
          linear_extrude(0.8) difference() { lid_outline(-1, -1); lid_outline(plank_depth, plank_depth); }
        for (y = [plank_pitch:plank_pitch:D - plank_pitch/2])
          if (y > ch + 4 && y < D - ch - 4)
            translate([-ov + chx + 2, y, H - plank_depth]) cube([LW - 2*chx - 4, 0.8, 1]);
      }
      if (color_mode == "multicolor") { lid_strap_vol(); face_vol(name_z, recess) offset(delta = 1) plate_2d(); }
    }
    if (color_mode == "glued") {
      lid_strap_vol();
      translate([cx - plate_ww/2 - plate_clear, -1, name_z - plate_hh/2 - plate_clear])
        cube([plate_ww + 2*plate_clear, recess + 1, plate_hh + 2*plate_clear]);
    }
  }
  if (has_hasp) hasp_knuckles();
  // latch tab
  if (has_tab) difference() {
    union() {
      translate([cx - latch_w/2, 0, z_tip]) cube([latch_w, tab_t, z_root - z_tip + 1]);
      along_x(cx - latch_w/2, latch_w)
        polygon([[eps, z_tip], [-grip_out, z_tip], [-grip_out, z_tip + 0.8], [eps, z_tip + 0.8 + grip_out]]);
    }
    translate([cx - (latch_w - 6)/2, -1, z_win_bot]) cube([latch_w - 6, tab_t + 2, z_win_top - z_win_bot]);
    along_x(cx - latch_w/2 - 1, latch_w + 2)
      polygon([[tab_t - 0.9, z_tip - eps], [tab_t + 1, z_tip - eps], [tab_t + 1, z_tip + 1.9]]);
  }
}

// ---------- color parts ----------

// strap channels: cut away for glued straps, filled black for multicolor
module lid_strap_vol() for (f = strap_x) intersection() {
  translate([W*f - strap_w/2, -10, Hb + 0.4]) cube([strap_w, D + 40, lid_h + 10]);
  difference() { lid_solid(1, Hb - 5); lid_solid(-strap_in, Hb - 5); }
}
module base_strap_vol() for (f = strap_x) intersection() {
  translate([W*f - strap_w/2, -10, -10]) cube([strap_w, D + 40, Hb + 9.7]);
  difference() { base_solid(1, Hb + 5); base_solid(-strap_in, Hb + 5); }
}
// a 2D shape pressed into the front face, depth d
module face_vol(z, d) translate([cx, d, z]) rotate([90, 0, 0]) linear_extrude(d + 1) children();
module plate_2d() translate([-plate_ww/2, -plate_hh/2]) rrect(plate_ww, plate_hh, 5);
module name_border_2d() translate([-plate_ww/2 + 3, -plate_hh/2 + 3]) difference() {
  rrect(plate_ww - 6, plate_hh - 6, 3);
  translate([1.2, 1.2]) rrect(plate_ww - 8.4, plate_hh - 8.4, 2);
}
module name_dark_2d() {
  name_border_2d();
  if (len(name) > 0) name_text();
}
module hoop_2d(x) translate([x, 0]) difference() { circle(r = 7); circle(r = 4); }
module lock_2d() {
  if (lock_style == "painted") {
    difference() { translate([-11, -lock_h/2]) rrect(22, lock_h, 3); translate([0, -lock_h*0.12]) circle(r = 5); }
    hoop_2d(-21); hoop_2d(21);
  } else difference() {
    lock_shape();
    translate([0, lock_h*0.12]) circle(r = lock_w*0.14);
    translate([0, lock_h*0.12]) polygon([[-lock_w*0.08, 0], [lock_w*0.08, 0], [lock_w*0.12, -lock_h*0.3], [-lock_w*0.12, -lock_h*0.3]]);
  }
}
// ---------- hasp drawn across the seam, at the working hasp's position ----------
scoop_z = z_tip - 5;
module seam_vol() translate([cx, inlay_text, 0]) rotate([90, 0, 0]) linear_extrude(inlay_text + 3) children();   // takes in the tab's grip
module seam_flap_2d() {
  if (lock_style == "plate-seam") difference() {   // keyhole on the tab, above the tab's window
    hull() {
      translate([-lock_w/2, z_tip - 10.5]) rrect(lock_w, z_root - z_tip + 7, 4);
      translate([0, z_tip - 20.5]) circle(r = 2);
    }
    translate([0, scoop_z]) circle(r = 6.5);
    translate([0, z_root - 9.5]) circle(r = 3.4);
    polygon([[-2, z_root - 9.5], [2, z_root - 9.5], [3, z_root - 17.5], [-3, z_root - 17.5]]);
  } else difference() {
    translate([-hasp_w/2, hasp_bot]) rrect(hasp_w, hasp_az + hasp_r - hasp_bot, 3);
    translate([0, scoop_z]) circle(r = 9.5);
    for (x = [-hasp_w/2 + 4, hasp_w/2 - 4], z = [hasp_bot + 3.5, hasp_az - 2]) translate([x, z]) circle(r = 1.6);
  }
}
module seam_hoop_2d() if (lock_style == "painted-seam") {
  translate([0, scoop_z]) difference() { circle(r = 8.5); circle(r = 6); }
  for (s = [-1, 1]) translate([s*(hasp_w/2 + 0.5 + hasp_knuckle_len/2) - hasp_knuckle_len/2, hasp_az - hasp_r]) rrect(hasp_knuckle_len, 2*hasp_r, 1.5);
  for (x = [-hasp_w/2 + 4, hasp_w/2 - 4], z = [hasp_bot + 3.5, hasp_az - 2]) translate([x, z]) circle(r = 1.6);
}
module square_hull_seam() { seam_flap_2d(); seam_hoop_2d(); }
// ---------- working hasp ----------
// The loop prints as part of the base and the knuckles as part of the lid, both with
// no supports. The flap and key print flat, front face up. Hinge pin: 1.75 mm filament.
module hasp_loop() difference() {
  along_x(cx - loop_w/2, loop_w) polygon([[0.3, loop_top], [loop_tip_y, loop_top], [loop_tip_y, loop_under], [0.3, loop_under + loop_tip_y - 0.3]]);
  along_x(cx - loop_w/2 - 1, loop_w + 2) translate([loop_hole_y, loop_z]) teardrop(key_hole, true);
}
module hasp_knuckles() for (s = [-1, 1]) let (x0 = s < 0 ? cx - hasp_w/2 - 0.5 - hasp_knuckle_len : cx + hasp_w/2 + 0.5)
  difference() {
    along_x(x0, hasp_knuckle_len) hull() {
      translate([hasp_ay, hasp_az]) circle(r = hasp_r);
      polygon([[0.3, hasp_az - hasp_r], [0.3, hasp_az + hasp_r - hasp_ay + 0.3], [0, hasp_az]]);   // 45-degree gusset, printed upside down
    }
    along_x(x0 - 1, hasp_knuckle_len + 2) translate([hasp_ay, hasp_az]) teardrop(pin_hole_base, false);
  }
module hasp_rivet_vol() translate([cx, -(hasp_clear + hasp_t) + inlay_text, 0]) rotate([90, 0, 0]) linear_extrude(inlay_text + 0.1)
  for (x = [-hasp_w/2 + 4, hasp_w/2 - 4], z = [hasp_bot + 3.5, hasp_az - 8]) translate([x, z]) circle(r = 1.6);
module hasp_flap_solid() difference() {
  union() {
    along_x(cx - hasp_w/2, hasp_w) translate([hasp_ay, hasp_az]) circle(r = hasp_r);
    translate([cx, -hasp_clear, 0]) rotate([90, 0, 0]) linear_extrude(hasp_t)
      translate([-hasp_w/2, hasp_bot]) rrect(hasp_w, hasp_az - hasp_bot, 3);
  }
  along_x(cx - hasp_w/2 - 1, hasp_w + 2) translate([hasp_ay, hasp_az]) rotate(90) teardrop(pin_hole_lid);
  translate([cx - loop_w/2 - 0.8, -(hasp_clear + hasp_t) - 1, slot_bot]) cube([loop_w + 1.6, hasp_t + 2, slot_top - slot_bot]);
}
module hasp_flap() difference() { hasp_flap_solid(); hasp_rivet_vol(); }
module hasp_rivets() intersection() { hasp_flap_solid(); hasp_rivet_vol(); }
// a flat key: the shaft slides through the loop, the ring takes a cord
module hasp_key() translate([0, loop_hole_y + 1.6, loop_z]) rotate([90, 0, 0]) linear_extrude(3.2) {
  translate([cx - loop_w/2 - 2, -2.5]) square([loop_w + 2 + 6.5, 5]);
  translate([cx + loop_w/2 + 13, 0]) difference() { circle(r = 8.5); circle(r = 4); }
}
module print_hasp() {   // flap and key, front faces up
  translate([-cx + hasp_w/2, 0, 0]) rotate([-90, 0, 0]) translate([0, hasp_clear, -hasp_az]) { hasp_flap(); hasp_rivets(); }
  translate([-cx + hasp_w + 8, 0, 0]) rotate([-90, 0, 0]) translate([0, -(loop_hole_y + 1.6), -loop_z]) hasp_key();
}
// multicolor: one region of each half, c = 1 brown, 2 black, 3 yellow
module mc_lid(c) {
  if (c == 1) difference() { lid(); lid_strap_vol(); face_vol(name_z, recess) plate_2d(); if (has_hasp) hasp_knuckles(); if (has_seam_art) seam_vol() square_hull_seam(); }
  else if (c == 2) intersection() { lid(); union() { lid_strap_vol(); face_vol(name_z, inlay_text) name_dark_2d(); } }
  else intersection() { lid(); difference() { face_vol(name_z, recess) plate_2d(); face_vol(name_z, inlay_text) name_dark_2d(); } }
}
// every separately colorable region, per half (web viewers and color editors)
module mc_region(id, half) {
  if (id == "hasp-flap") hasp_flap();
  else if (id == "hasp-rivets") hasp_rivets();
  else if (id == "hasp-key") hasp_key();
  else if (id == "hasp-loop") hasp_loop();
  else if (id == "hasp-knuckles") hasp_knuckles();
  else if (id == "lock" && has_seam_art) intersection() { if (half == "base") base(); else lid(); seam_vol() seam_flap_2d(); }
  else if (id == "lock-hoop") intersection() { if (half == "base") base(); else lid(); seam_vol() seam_hoop_2d(); }
  else if (half == "base") {
    if (id == "body") mc_base(1);
    else if (id == "straps") mc_base(2);
    else if (id == "lock") mc_base(3);
  } else {
    if (id == "body") mc_lid(1);
    else if (id == "straps") intersection() { lid(); lid_strap_vol(); }
    else if (id == "name" && len(name) > 0) intersection() { lid(); face_vol(name_z, inlay_text) name_text(); }
    else if (id == "plate-border") intersection() { lid(); face_vol(name_z, inlay_text) name_border_2d(); }
    else if (id == "plate") mc_lid(3);
  }
}
module mc_base(c) {
  if (c == 1) difference() { base(); base_strap_vol(); if (has_lock_art) face_vol(lock_z, recess) lock_2d(); if (has_hasp) hasp_loop(); if (has_seam_art) seam_vol() square_hull_seam(); }
  else if (c == 2) intersection() { base(); base_strap_vol(); }
  else if (has_lock_art) intersection() { base(); face_vol(lock_z, recess) lock_2d(); }
}
module print_lid_pose() translate([ov, axis_y + knuckle_r, H]) rotate([180, 0, 0]) children();

module strap_lid(f) {
  intersection() {
    translate([W*f - strap_w/2 + strap_clear, -10, Hb + 0.4]) cube([strap_w - 2*strap_clear, D + 40, lid_h + 10]);
    difference() { lid_solid(strap_out, Hb - 5); lid_solid(-strap_in + strap_clear, Hb - 5); }
  }
}
module strap_base(f) {
  intersection() {
    translate([W*f - strap_w/2 + strap_clear, -10, -10]) cube([strap_w - 2*strap_clear, D + 40, Hb + 9.6]);
    difference() { base_solid(strap_out, Hb + 5); base_solid(-strap_in + strap_clear, Hb + 5); }
  }
}
module straps() { for (f = strap_x) { strap_lid(f); strap_base(f); } }

// Multi-line names: separate lines with "|", e.g. "First|Middle|Last".
// The first line is name_size; later lines are name_size * line_scale.
function split_name(s, i = 0, cur = "") =
  i >= len(s) ? [cur] : s[i] == "|" ? concat([cur], split_name(s, i + 1, "")) : split_name(s, i + 1, str(cur, s[i]));
function name_lines() = split_name(name);
function line_size(k) = k == 0 ? name_size : name_size*line_scale;
function name_block_h(n = len(name_lines())) = n == 0 ? 0 : line_size(0) + (n - 1)*(name_size*line_scale + name_size*0.3);
module name_text() {
  L = name_lines();
  T = name_block_h();
  for (k = [0:len(L) - 1]) scale([text_fit, text_fit])
    translate([0, T/2 - (k == 0 ? line_size(0)/2 : line_size(0) + name_size*0.3 + (k - 1)*(name_size*line_scale + name_size*0.3) + line_size(k)/2)])
      text(L[k], size = line_size(k), font = font_name, halign = "center", valign = "center");
}

module lock_shape() {
  if (lock_style == "painted") { translate([-11, -lock_h/2]) rrect(22, lock_h, 3); translate([-21, 0]) circle(r = 7); translate([21, 0]) circle(r = 7); }
  else
  hull() {
    translate([-lock_w/2, -lock_h/2 + lock_w*0.3]) rrect(lock_w, lock_h - lock_w*0.3, 4);
    translate([0, -lock_h/2 + 2]) circle(r = 2);
  }
}
module lock_plate() {
  linear_extrude(plate_t) difference() {
    lock_shape();
    translate([0, lock_h*0.12]) circle(r = lock_w*0.14);
    translate([0, lock_h*0.12]) polygon([[-lock_w*0.08, 0], [lock_w*0.08, 0], [lock_w*0.12, -lock_h*0.3], [-lock_w*0.12, -lock_h*0.3]]);
  }
}
module name_plate() {
  linear_extrude(plate_t) difference() {
    translate([-plate_ww/2, -plate_hh/2]) rrect(plate_ww, plate_hh, 5);
    translate([-plate_ww/2 + 3, -plate_hh/2 + 3]) difference() {   // border groove
      rrect(plate_ww - 6, plate_hh - 6, 3);
      translate([1.2, 1.2]) rrect(plate_ww - 8.4, plate_hh - 8.4, 2);
    }
  }
  if (len(name) > 0)
    translate([0, 0, plate_t - eps]) linear_extrude(text_t)
      name_text();
}
// plates placed on the chest, for the preview
module placed_lock() { translate([cx, recess, lock_z]) rotate([90, 0, 0]) lock_plate(); }
module placed_name() { translate([cx, recess, name_z]) rotate([90, 0, 0]) name_plate(); }
module plates() { placed_lock(); placed_name(); }

module lid_open(a) {
  translate([0, axis_y, axis_z]) rotate([-a, 0, 0]) translate([0, -axis_y, -axis_z]) children();
}
module caddy() {
  translate([wall + caddy_clear, wall + caddy_clear, floor_t + 0.05]) organizer();
}
module caddy_supplies() {
  translate([wall + caddy_clear, wall + caddy_clear, floor_t + 0.05]) supplies();
}

use <../school-caddy/school-caddy.scad>

echo(PLATE = [plate_ww, plate_hh], PLATE_SPACE = [z_root + 8, H - max(ch, chx)], NAME_Z = name_z,
  SIZE = [W, D, H], LID_W = LW, BASE_H = Hb, LID_H = lid_h, FOOTPRINT_Y = axis_y + knuckle_r, PIN_LEN = group_len);
// What the name plate's sizing reads, for tools that predict it: the text scale, and the inputs of plate_ww and plate_hh above.
echo(TEXT_FIT = text_fit, NAME_EST_W = name_est_w, PLATE_RULE = [plate_w, plate_h, char_w, W, strap_x, strap_w, cx], NAME_FIT = name_fit, NAME_SIZE = name_size);

scale(scale_factor) {
  if (part == "closed") { color("SaddleBrown") { base(); lid(); } color("#222") straps(); color("Gold") { placed_name(); if (has_lock_art) placed_lock(); if (has_hasp) { hasp_flap(); hasp_rivets(); hasp_key(); } } }
  else if (part == "open") {
    color("SaddleBrown") base(); color("#222") for (f = strap_x) strap_base(f);
    if (has_lock_art) color("Gold") placed_lock();
    lid_open(open_angle) { color("SaddleBrown") lid(); color("#222") for (f = strap_x) strap_lid(f);
      color("Gold") placed_name(); }
    caddy();
  }
  else if (part == "base") base();
  else if (part == "lid") lid();
  else if (part == "straps") straps();
  else if (part == "plates") plates();
  else if (part == "lid_straps") for (f = strap_x) strap_lid(f);
  else if (part == "base_straps") for (f = strap_x) strap_base(f);
  else if (part == "lock") placed_lock();
  else if (part == "nameplate") placed_name();
  else if (part == "name_reach" && len(name) > 0) face_vol(name_z, inlay_text) name_text();   // the letters where they sit, before the lid trims them: what the shop's tools measure the border shrink from
  else if (part == "print_hasp") print_hasp();
  else if (part == "print_base") base();
  else if (part == "print_lid") print_lid_pose() lid();
  else if (part == "mc_closed") for (c = [1:3]) color(["SaddleBrown", "#222", "Gold"][c - 1]) { mc_base(c); mc_lid(c); }
  else if (part == "mc_closed_part") { mc_base(mc_filament); mc_lid(mc_filament); }   // one color of the closed chest, for web viewers
  else if (part == "mc_region") mc_region(mc_region_id, mc_half);   // one color region of one half, for web viewers
  else if (part == "mc_base_part") mc_base(mc_filament);   // one color, base only (web viewers animate the lid)
  else if (part == "mc_lid_part") mc_lid(mc_filament);
  else if (part == "mc_print_lid") print_lid_pose() mc_lid(mc_filament);
  else if (part == "mc_print_base") mc_base(mc_filament);
  else if (part == "print_straps") {   // one lid strap and one base strap on edge; print once per strap position
    x0 = W*strap_x[0] - strap_w/2 + strap_clear;
    translate([H + 1, 0, 0]) rotate([0, -90, 0]) translate([-x0, 0, 0]) strap_lid(strap_x[0]);
    translate([H + 11, 0, 0]) rotate([0, -90, 0]) translate([-x0, 0, 0]) strap_base(strap_x[0]);
  }
  else if (part == "print_plates") {
    name_plate();
    translate([plate_ww/2 + lock_w/2 + 8, 0, 0]) lock_plate();
  }
  else if (part == "with_caddy") { base(); caddy(); }
  else if (part == "fit_check") intersection() { union() { base(); lid(); } union() { caddy(); caddy_supplies(); } }
  else if (part == "hinge_check")
    for (a = [1, 30, 60, 90, 120, 150, 180]) intersection() { base(); lid_open(a) lid(); }
}
