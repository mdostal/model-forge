// School art box -- a lay-flat supply box with a hinged lid and a click latch,
// for keeping a child's supplies closed up in a classroom cubby.
// All sizes below are editable.
//
// Inside: an open bay with a separate lift-out insert tray (its own print) that
// gives every supply its own section: markers, pencils, glue bottle (scissors
// ride on top of it), eraser, crayon and colored pencil boxes, glue sticks, and
// two spare spots. Set channel_d above 0 for a single fixed divider instead.
// The lid clicks shut with a flexing tab that hooks over a bump on the base, so
// it stays closed if the box gets knocked over. Pull the tab's lip out to open.
//
// Print two parts with no supports: the base upright, the lid upside down
// (set part to "print_base" / "print_lid"). Join them with two pieces of
// 1.75 mm filament pushed through the hinge knuckles as pins.
// Default sizes are estimates, so measure your own supplies and adjust.

/* [Inside size] */
inside_w = 228;     // [150:1:246] left to right; outside stays under 237 so it misses the X1C bed corner keep-out
channel_d = 0;      // [0:1:80] fixed front channel, 0 for none (use the insert instead)
bay_d = 230;        // [80:1:236] main bay, front to back
inside_h = 65;      // [40:1:100] total inside height, base plus lid
lid_h = 14;         // [10:1:30] outside height of the lid
divider_h = 36;     // [10:1:60] height of the channel divider above the floor

/* [Walls] */
wall = 4;           // [2.4:0.2:5]
floor_t = 2.4;      // [1.6:0.2:4]
top_t = 2.4;        // [1.6:0.2:4]
divider_t = 2;      // [1.2:0.2:4]
corner_r = 10;      // [4:1:20]
floor_fillet = 1;   // [0:0.5:4] rounded inside floor edge; keep below insert_clear
boss_t = 0;         // [0:0.2:3] extra wall behind the latch; 0 is fine with a 4 mm wall

/* [Lid fit] */
lip_h = 3;          // [0:0.5:6] lid lip that drops inside the base, 0 for none
lip_t = 1.6;        // [1.2:0.2:3]
lip_clear = 0.35;   // [0.15:0.05:0.8]

/* [Hinge] */
knuckle_r = 5;          // [4:0.5:7]
hinge_gap = 0.3;        // [0.2:0.05:1]
hinge_groups = [0.22, 0.78]; // centers, as fractions of the width
base_knuckle_len = 16;  // [8:1:30]
lid_knuckle_len = 24;   // [8:1:40]
knuckle_gap = 0.5;      // [0.3:0.05:1]
pin_hole_base = 2.0;    // [1.6:0.05:3] tight on 1.75 mm filament so the pin stays put
pin_hole_lid = 2.4;     // [1.8:0.05:3.5] loose so the lid swings

/* [Latch] */
latch_count = 1;    // [1:1:3]
latch_w = 18;       // [12:1:30] tab width
tab_t = 1.6;        // [1.2:0.1:2.4] thinner opens easier, thicker holds harder
tab_drop = 10;      // [7:1:16] how far the tab reaches down the base
latch_engage = 1.1; // [0.6:0.1:1.8] how far the bump sticks out
latch_clear = 0.3;  // [0.15:0.05:0.6]
grip_out = 2.2;     // [1:0.2:4] lip on the tab tip for little fingers

/* [Insert tray (separate print)] */
insert_clear = 1;    // [0.4:0.1:3] gap to the box walls
insert_wall = 1.6;   // [1.2:0.2:3]
insert_floor = 1.6;  // [0:0.2:3] 0 for a floorless divider grid
insert_h = 38;       // [15:1:50] outer wall height
divider_h2 = 30;     // [10:1:50] section dividers
tab_w = 34;          // [20:1:50] lift tab on each end
tab_h = 10;          // [6:1:14]
// Rows, front to back. The last row takes whatever depth is left.
markers_row = 32;    // [20:1:60] 8 markers, 2 wide by 4 high
markers_w = 144;     // [100:1:200] the rest of the row is a spare spot
pencils_row = 28;    // [18:1:50] 8 pencils, about 3 by 3
pencils_w = 194;     // [100:1:230] the rest of the row is a spare spot
bottle_row = 68;     // [40:1:90] glue bottle on its side, scissors on top
bottle_w = 150;      // [100:1:200] the rest of the row is the eraser spot
boxes_w = 192;       // [100:1:220] crayon and colored pencil boxes; the rest is glue sticks
section_icons = true;

/* [Name and pictures] */
name = "";          // engraved on the lid; "|" starts a new line, e.g. "First|Middle|Last"
font_name = "Liberation Sans:style=Bold";
name_size = 24;     // [10:1:40] first line
line_scale = 0.75;  // [0.5:0.05:1] size of the later lines
show_icons = true;
icon_scale = 1.15;  // [0.5:0.05:1.6] lid pictures, each about its own origin; the spacing stays put
star_scale = 0.8;   // [0.5:0.05:1.6] lid stars, each about its own origin; they stay put
engrave = 0.8;      // [0.4:0.1:1.5]

/* [Output] */
scale_factor = 1;   // [0.8:0.05:1.3]
part = "closed";    // [closed, open, base, lid, name_cut, art_cut, insert, with_insert, print_base, print_lid, print_insert, supplies, fit_check, insert_check, hinge_check]
open_angle = 110;   // [0:5:185]

/* [Hidden] */
$fn = 48;
eps = 0.01;
edge_r = 3;

W = inside_w + 2*wall;
D = channel_d + (channel_d > 0 ? divider_t : 0) + bay_d + 2*wall;
H = floor_t + inside_h + top_t;   // closed height
Hb = H - lid_h;                   // base height, the seam
axis_y = D + hinge_gap + knuckle_r;
axis_z = Hb;
group_len = 2*base_knuckle_len + lid_knuckle_len + 2*knuckle_gap;
bay_y0 = wall + (channel_d > 0 ? channel_d + divider_t : 0);

z_tip = Hb - tab_drop;            // bottom of the latch tab
bar_h = 3;                        // tab material below the window
z_win_bot = z_tip + bar_h;
z_bump_bot = z_win_bot + 0.2;
bump_flat = 1.0;
z_bump_top = z_bump_bot + bump_flat + latch_engage*1.8;
z_win_top = z_bump_top + 0.6;
recess_d = tab_t + latch_clear;

function latch_x(i) = W*(i + 1)/(latch_count + 1);

module rrect(w, d, r) {
  rr = min(r, min(w, d)/2 - eps);
  translate([rr, rr]) offset(r = rr) square([w - 2*rr, d - 2*rr]);
}
module outline(inset = 0) {
  translate([inset, inset]) rrect(W - 2*inset, D - 2*inset, max(1, corner_r - inset));
}
// 2D profile in (y, z), extruded along x from x0 for len.
module along_x(x0, len) {
  translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) children();
}
module teardrop(d, up = true) {
  rotate(up ? 0 : 180) union() {
    circle(d = d);
    polygon([[-d/2*cos(45), d/2*sin(45)], [0, d/2*sqrt(2)], [d/2*cos(45), d/2*sin(45)]]);
  }
}

// ---------- base ----------

module base_shell() {
  hull() {
    linear_extrude(eps) outline(0.6);
    translate([0, 0, 0.6]) linear_extrude(Hb - 0.6) outline();
  }
}
module base_cavity() {
  fr = max(floor_fillet, 0.01);
  translate([0, 0, floor_t]) hull() {
    for (a = [0:15:90])
      translate([0, 0, fr*(1 - cos(a))]) linear_extrude(eps) outline(wall + fr*(1 - sin(a)));
    translate([0, 0, Hb]) linear_extrude(eps) outline(wall);
  }
}
module base_knuckle(x0, len) {
  difference() {
    along_x(x0, len) hull() {
      translate([axis_y, axis_z]) circle(r = knuckle_r);
      translate([D - 1, axis_z - 3*knuckle_r]) square([1, 3*knuckle_r]);
    }
    translate([x0 - 1, D - 5, axis_z]) cube([len + 2, 5 + hinge_gap - 0.1, knuckle_r + 1]);
  }
}
module latch_bump(cx) {
  bw = latch_w - 8;
  along_x(cx - bw/2, bw) polygon([
    [recess_d + eps, z_bump_bot], [recess_d - latch_engage, z_bump_bot],
    [recess_d - latch_engage, z_bump_bot + bump_flat], [recess_d + eps, z_bump_top]]);
}
module base() {
  difference() {
    union() {
      difference() {
        base_shell();
        base_cavity();
      }
      if (channel_d > 0)
        translate([wall - eps, wall + channel_d, floor_t - eps])
          cube([inside_w + 2*eps, divider_t, divider_h]);
      if (boss_t > 0) for (i = [0:latch_count - 1])   // backing behind each latch recess
        translate([latch_x(i) - latch_w/2 - 6, wall - eps, floor_t - eps])
          cube([latch_w + 12, boss_t, Hb - floor_t + eps]);
      for (g = hinge_groups) let (x0 = W*g - group_len/2) {
        base_knuckle(x0, base_knuckle_len);
        base_knuckle(x0 + group_len - base_knuckle_len, base_knuckle_len);
      }
    }
    for (i = [0:latch_count - 1]) let (cx = latch_x(i)) {
      translate([cx - latch_w/2 - 1, -1, z_tip - 1.5]) cube([latch_w + 2, recess_d + 1, Hb]);
      translate([cx, -(9 - 1.6), z_tip - 5]) sphere(r = 9);   // finger scoop
    }
    for (g = hinge_groups)
      along_x(W*g - group_len/2 - 1, group_len + 2)
        translate([axis_y, axis_z]) teardrop(pin_hole_base, true);
  }
  for (i = [0:latch_count - 1]) latch_bump(latch_x(i));
}

// ---------- lid ----------

module lid_shell() {
  translate([0, 0, Hb]) hull() {
    linear_extrude(lid_h - edge_r) outline();
    for (a = [15:15:90])
      translate([0, 0, lid_h - edge_r + edge_r*sin(a)]) linear_extrude(eps)
        outline(edge_r*(1 - cos(a)));
  }
}
module lid_lip() {
  if (lip_h > 0) {
    ch = min(0.8, lip_h/2);
    difference() {
      hull() {
        translate([0, 0, Hb - lip_h]) linear_extrude(eps) outline(wall + lip_clear + ch);
        translate([0, 0, Hb - lip_h + ch]) linear_extrude(lip_h - ch + eps) outline(wall + lip_clear);
      }
      translate([0, 0, Hb - lip_h - 1]) linear_extrude(lip_h + 2) outline(wall + lip_clear + lip_t);
      for (i = [0:latch_count - 1])
        translate([latch_x(i) - latch_w/2 - 7, 0, Hb - lip_h - 1]) cube([latch_w + 14, wall + max(boss_t, lip_clear + lip_t) + 2, lip_h + 2]);
    }
  }
}
module lid_knuckle(x0, len) {
  top = min(3*knuckle_r, lid_h - 1);
  difference() {
    along_x(x0, len) hull() {
      translate([axis_y, axis_z]) circle(r = knuckle_r);
      translate([D - 1, axis_z]) square([1, top]);
    }
    translate([x0 - 1, D - 5, axis_z - knuckle_r - 1]) cube([len + 2, 5 + hinge_gap - 0.1, knuckle_r + 1]);
  }
}
module latch_tab(cx) {
  z_root = H - top_t;
  difference() {
    union() {
      translate([cx - latch_w/2, 0, z_tip]) cube([latch_w, tab_t, z_root - z_tip + eps]);
      along_x(cx - latch_w/2, latch_w)   // grip lip, 45 degree face for printing
        polygon([[eps, z_tip], [-grip_out, z_tip], [-grip_out, z_tip + 0.8], [eps, z_tip + 0.8 + grip_out]]);
    }
    translate([cx - (latch_w - 6)/2, -1, z_win_bot]) cube([latch_w - 6, tab_t + 2, z_win_top - z_win_bot]);
    along_x(cx - latch_w/2 - 1, latch_w + 2)   // lead-in so the tab rides over the bump
      polygon([[tab_t - 0.9, z_tip - eps], [tab_t + 1, z_tip - eps], [tab_t + 1, z_tip + 1.9]]);
  }
}
// The engraved name alone, in place. part="name_cut" exports it for quick per-order name swaps.
module name_cut() {
  if (len(name) > 0)
    translate([W/2, D*0.6, H - engrave]) linear_extrude(engrave + 1)
      name_text();
}
module art_icons(icons_y) {
  n = 6;
  step = min(36, (W - 40)/n);
  for (i = [0:n - 1])
    translate([W/2 + (i - (n - 1)/2)*step, icons_y, H - engrave]) linear_extrude(engrave + 1)
      scale(icon_scale) icon(i);
}
module art_stars() {
  for (s = [-1, 1])
    translate([W/2 + s*(W/2 - 22), D*0.6, H - engrave]) linear_extrude(engrave + 1)
      scale(star_scale) icon_star();
}
// The pictures and stars alone, in place, for quick per-order art swaps. part="art_cut" exports it.
// Always the named layout, whatever name and show_icons say, because stock lids are cut from a named export.
module art_cut() {
  art_icons(D*0.3);
  art_stars();
}
module lid_art() {
  name_cut();
  if (show_icons) {
    art_icons(len(name) > 0 ? D*0.3 : D*0.5);
    if (len(name) > 0) art_stars();
  }
}
module lid() {
  difference() {
    union() {
      difference() {
        lid_shell();
        translate([0, 0, Hb - eps]) linear_extrude(lid_h - top_t + eps) outline(wall);
      }
      lid_lip();
      for (g = hinge_groups)
        lid_knuckle(W*g - group_len/2 + base_knuckle_len + knuckle_gap, lid_knuckle_len);
    }
    for (i = [0:latch_count - 1])   // slot around each tab
      translate([latch_x(i) - latch_w/2 - 1, -1, Hb - lip_h - 1]) cube([latch_w + 2, wall + 2, lid_h - top_t + lip_h + 1]);
    for (g = hinge_groups)
      along_x(W*g - group_len/2 - 1, group_len + 2)
        translate([axis_y, axis_z]) teardrop(pin_hole_lid, false);
    lid_art();
  }
  for (i = [0:latch_count - 1]) latch_tab(latch_x(i));
}

// ---------- pictures, about 24 tall, centered ----------

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
  for (k = [0:len(L) - 1])
    translate([0, T/2 - (k == 0 ? line_size(0)/2 : line_size(0) + name_size*0.3 + (k - 1)*(name_size*line_scale + name_size*0.3) + line_size(k)/2)])
      text(L[k], size = line_size(k), font = font_name, halign = "center", valign = "center");
}

module icon_palette() {
  difference() {
    scale([1.2, 0.9]) circle(r = 11);
    translate([5, -4]) circle(r = 2.6);
    translate([11, -9]) circle(r = 5);
    for (p = [[-7, 2], [-2, 6], [4, 5], [-6, -4]]) translate(p) circle(r = 1.9);
  }
}
module icon_crayon() {
  rotate(-35) difference() {
    union() {
      translate([-4, -6]) square([8, 17]);
      polygon([[-4, -6], [4, -6], [1.6, -12], [-1.6, -12]]);
    }
    translate([-5, -2]) square([10, 1.4]);
    translate([-5, 6]) square([10, 1.4]);
  }
}
module icon_pencil() {
  rotate(-35) union() {
    translate([-4, -6]) square([8, 18]);
    polygon([[-4, -6], [4, -6], [0, -13]]);
    translate([-4, 13]) square([8, 3]);
  }
}
module icon_marker() {
  rotate(-35) difference() {
    union() {
      translate([-5, -6]) rrect(10, 19, 2);
      polygon([[-3.5, -5], [3.5, -5], [1.2, -13], [-1.2, -13]]);
    }
    translate([-6, 5]) square([12, 1.4]);
  }
}
module icon_scissors() {
  difference() {
    union() {
      rotate(14)  translate([-1.4, -3]) polygon([[0, 0], [2.8, 0], [1.8, 15], [0.6, 15]]);
      rotate(-14) translate([-1.4, -3]) polygon([[0, 0], [2.8, 0], [2.2, 15], [1, 15]]);
      translate([-4, -7.5]) circle(r = 4.5);
      translate([4, -7.5]) circle(r = 4.5);
      polygon([[-3, -4], [-0.5, -1], [0.5, -1], [3, -4], [1, -6], [-1, -6]]);
    }
    translate([-4.2, -7.5]) circle(r = 2.4);
    translate([4.2, -7.5]) circle(r = 2.4);
  }
}
module icon_glue_stick() {
  union() {
    translate([-6, -12]) rrect(12, 14, 1.5);
    translate([-4.5, 3.4]) rrect(9, 8.8, 2.4);
  }
}
module icon_star() {
  polygon([for (i = [0:9]) let (r = i % 2 == 0 ? 11 : 4.8, a = 90 + i*36) [r*cos(a), r*sin(a)]]);
}
module icon(i) {
  if (i == 0) icon_palette();
  else if (i == 1) icon_crayon();
  else if (i == 2) icon_marker();
  else if (i == 3) icon_pencil();
  else if (i == 4) icon_scissors();
  else icon_glue_stick();
}

// ---------- insert tray ----------

ins_x0 = wall + insert_clear;            // tray outside, in box coordinates
ins_y0 = wall + insert_clear;
ins_w = inside_w - 2*insert_clear;
ins_d = (D - 2*wall) - 2*insert_clear;
ix0 = ins_x0 + insert_wall;              // tray inside
iy0 = ins_y0 + insert_wall;
iw = ins_w - 2*insert_wall;
id_ = ins_d - 2*insert_wall;
iz0 = floor_t + insert_floor;            // top of the tray floor
dt = insert_wall;
rowA = iy0;
rowB = rowA + markers_row + dt;
rowC = rowB + pencils_row + dt;
rowD = rowC + bottle_row + dt;
boxes_row = iy0 + id_ - rowD;
// [x, y, w, d, icon]  icons: 0 marker, 1 star, 2 pencil, 3 glue bottle, 4 eraser, 5 crayon box, 6 glue stick
sections = [
  [ix0, rowA, markers_w, markers_row, 0],
  [ix0 + markers_w + dt, rowA, iw - markers_w - dt, markers_row, 1],
  [ix0, rowB, pencils_w, pencils_row, 2],
  [ix0 + pencils_w + dt, rowB, iw - pencils_w - dt, pencils_row, 1],
  [ix0, rowC, bottle_w, bottle_row, 3],
  [ix0 + bottle_w + dt, rowC, iw - bottle_w - dt, bottle_row, 4],
  [ix0, rowD, boxes_w, boxes_row, 5],
  [ix0 + boxes_w + dt, rowD, iw - boxes_w - dt, boxes_row, 6]];
r_in = max(1, corner_r - wall - insert_clear);

module tray_outline(inset = 0) {
  translate([ins_x0 + inset, ins_y0 + inset]) rrect(ins_w - 2*inset, ins_d - 2*inset, max(0.5, r_in - inset));
}
module section_icon(k) {
  if (k == 0) icon_marker();
  else if (k == 1) icon_star();
  else if (k == 2) rotate(-55) icon_pencil();
  else if (k == 3) icon_glue_bottle();
  else if (k == 4) icon_eraser();
  else if (k == 5) icon_crayon_box();
  else icon_glue_stick();
}
module insert() {
  difference() {
    union() {
      translate([0, 0, floor_t]) linear_extrude(insert_h) difference() {
        tray_outline();
        tray_outline(insert_wall);
      }
      if (insert_floor > 0) translate([0, 0, floor_t]) linear_extrude(insert_floor) tray_outline();
      // section walls
      for (y = [rowB, rowC, rowD]) translate([ix0 - eps, y - dt, floor_t]) cube([iw + 2*eps, dt, divider_h2 + insert_floor]);
      for (sct = sections) if (sct[0] > ix0 + 1)
        translate([sct[0] - dt, sct[1] - eps, floor_t]) cube([dt, sct[3] + 2*eps, divider_h2 + insert_floor]);
      // lift tabs on both ends, thickened inward
      for (s = [0, 1]) let (x = s ? ins_x0 + ins_w - 3 : ins_x0)
        translate([x, ins_y0 + ins_d/2 - tab_w/2, floor_t]) cube([3, tab_w, insert_h + tab_h]);
    }
    for (s = [0, 1]) let (x = s ? ins_x0 + ins_w - 4 : ins_x0 - 1)
      translate([x, ins_y0 + ins_d/2, floor_t + insert_h + tab_h/2 - 0.5]) rotate([0, 90, 0])
        linear_extrude(5) hull() for (dy = [-7, 7]) translate([0, dy]) circle(r = 3.5);
    if (section_icons && insert_floor > 0.8)
      for (sct = sections) {
        sc = min(1, (min(sct[2], sct[3]) - 4)/26);
        translate([sct[0] + sct[2]/2, sct[1] + sct[3]/2, iz0 - 0.6]) linear_extrude(1) scale(sc) section_icon(sct[4]);
      }
  }
}
module icon_glue_bottle() {
  union() {
    translate([-8, -12]) rrect(16, 16, 3);
    polygon([[-5, 3], [5, 3], [2.5, 8], [-2.5, 8]]);
    polygon([[-2.5, 7], [2.5, 7], [0.8, 13], [-0.8, 13]]);
  }
}
module icon_eraser() {
  rotate(15) difference() {
    translate([-14, -7]) rrect(28, 14, 2.5);
    translate([-5.6, -8]) square([1.4, 16]);
  }
}
module icon_crayon_box() {
  union() {
    translate([-11, -12]) rrect(22, 13, 1.5);
    for (i = [0:3]) let (x = -7.5 + 5*i)
      polygon([[x - 2, 0], [x + 2, 0], [x + 2, 5], [x + 0.8, 10], [x - 0.8, 10], [x - 2, 5]]);
  }
}

// ---------- stand-in supplies for the clearance check ----------

module supplies() {
  if (channel_d > 0) {
    x0 = wall + 3;
    z0 = floor_t + 0.05;
    for (i = [0:4]) translate([x0 + 3, wall + 7 + 9*i, z0 + 4.4]) rotate([0, 90, 0]) cylinder(d = 8.5, h = 190, $fn = 6);
    for (i = [0:2]) translate([x0 + 3, wall + 11.5 + 9*i, z0 + 13]) rotate([0, 90, 0]) cylinder(d = 8.5, h = 190, $fn = 6);
    for (j = [0:2], i = [0:(j < 2 ? 2 : 1)])
      translate([x0 + 3, wall + 10.75 + 16*i, z0 + 25 + 14.7*j]) rotate([0, 90, 0]) cylinder(d = 14.5, h = 140);
  } else {
    z0 = iz0 + 0.05;
    // markers 2 wide, 4 high
    for (i = [0:1], j = [0:3]) translate([ix0 + 2, rowA + 1.2 + 7.25 + 15*i, z0 + 7.25 + 14.6*j]) rotate([0, 90, 0]) cylinder(d = 14.5, h = 140);
    // pencils 3 by 3, eight of them
    for (k = [0:7]) let (i = k % 3, j = floor(k/3))
      translate([ix0 + 2, rowB + 1 + 4.25 + 8.7*i, z0 + 4.25 + 8.7*j]) rotate([0, 90, 0]) cylinder(d = 8.5, h = 190, $fn = 6);
    translate([ix0 + 2, rowC + 2, z0]) linear_extrude(32) rrect(146, 64, 8);   // glue bottle
    translate([ix0 + 4, rowC + 1, z0 + 32.2]) cube([65, 66, 13]);             // scissor handles
    translate([ix0 + 69, rowC + 22, z0 + 35]) cube([62, 24, 7]);              // scissor blades
    translate([ix0 + bottle_w + dt + 4, rowC + 4, z0]) cube([60, 22, 13]);   // eraser
    translate([ix0 + 1, rowD + 1.5, z0]) cube([190, 89, 19]);                 // colored pencils box
    translate([ix0 + 4, rowD + 1.5, z0 + 19.2]) cube([104, 89, 28]);          // crayons box
    for (j = [0:1]) translate([ix0 + boxes_w + dt + (iw - boxes_w - dt)/2, rowD + 3, z0 + 11.5 + 23.1*j])
      rotate([-90, 0, 0]) cylinder(d = 23, h = 76);                           // glue sticks, stacked
  }
}

module lid_open(a) {
  translate([0, axis_y, axis_z]) rotate([-a, 0, 0]) translate([0, -axis_y, -axis_z]) lid();
}

echo(SIZE = [W, D, H], INSERT = [ins_w, ins_d, insert_h + tab_h], BOXES_ROW = boxes_row, BASE_H = Hb, FOOTPRINT_Y = axis_y + knuckle_r, PIN_LEN = group_len);
// The lid's hinge axis, [y, z]: it runs along x. A viewer opening the lid turns it about this line.
echo(HINGE_AXIS = [axis_y, axis_z]);

scale(scale_factor) {
  if (part == "closed") { base(); lid(); }
  else if (part == "open") { base(); lid_open(open_angle); }
  else if (part == "base" || part == "print_base") base();
  else if (part == "lid") lid();
  else if (part == "name_cut") name_cut();
  else if (part == "art_cut") art_cut();
  else if (part == "print_lid") translate([0, axis_y + knuckle_r, H]) rotate([180, 0, 0]) lid();
  else if (part == "insert") insert();
  else if (part == "with_insert") { base(); insert(); }
  else if (part == "print_insert") translate([-ins_x0, -ins_y0, -floor_t]) insert();
  else if (part == "supplies") supplies();
  else if (part == "fit_check") intersection() { union() { base(); lid(); if (channel_d == 0) insert(); } supplies(); }
  else if (part == "insert_check") intersection() { union() { base(); lid(); } insert(); }
  else if (part == "hinge_check")   // should come out empty at every angle
    for (a = [1, 30, 60, 90, 120, 150, 180]) intersection() { base(); lid_open(a); }
}
