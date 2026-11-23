// School supply caddy -- one-piece stepped sorter. All sizes below are editable.
//
// Deep section (back): a long box slot, colored pencil box, crayon box,
//                      pencils and scissors (blades down).
// Medium section:      glue bottle, 8 markers, 2 glue sticks.
// Shallow tray (front): eraser pocket and a flat tray for small things.
//
// Print upright as modeled, no supports. Slots are roomy on purpose: items
// should drop in and lift out easily. Default sizes are estimates, so measure
// your own supplies and adjust.

/* [Section heights] */
back_h  = 70; // [40:1:110] deep section
mid_h   = 44; // [25:1:80]  medium section
front_h = 22; // [14:1:50]  shallow tray section

/* [Deep section: boxes] */
long_box_w = 222; // [100:1:222] slot along the back, for a box of markers
long_box_t = 32;  // [18:1:50]
pencil_box_w = 98; // [80:1:150]
pencil_box_t = 27; // [14:1:45]
crayon_box_w = 96; // [70:1:125]
crayon_box_t = 34; // [20:1:50]

/* [Deep section: pencils and scissors] */
pencil_count = 8;  // [2:1:12]
pencil_d = 12;     // [9:0.5:16]
pencil_pitch = 16; // [13:0.5:22]
scissor_w = 46;    // [30:1:60] keep narrower than the scissor handles
scissor_t = 18;    // [10:1:25]

/* [Medium section] */
bottle_w = 76;    // [50:1:95]
bottle_t = 42;    // [28:1:55]
marker_d = 19;    // [12:0.5:24] hole diameter
marker_pitch = 22; // [15:0.5:30]
stick_d = 26;     // [18:0.5:34] hole diameter
stick_gap = 3;    // [2:0.5:6]
stick_depth = 30; // [15:1:60]

/* [Shallow tray] */
tray_row_t = 30;   // [18:1:45] front-to-back size of this row
eraser_w = 70;     // [35:1:90]
eraser_depth = 18; // [8:1:40]
tray_depth = 10;   // [4:1:30]

/* [Walls and lift lips] */
outer_wall = 4;   // [3:0.5:6]
inner_wall = 3;   // [2:0.5:5]
floor_t = 4;      // [2:0.5:6]
lip_out = 10;     // [6:1:16] set 0 for no lips
lip_tall = 14;    // [10:1:24]
lip_len = 70;     // [50:1:120] front-to-back length, about one small hand wide
lip_center_y = 94; // [50:1:150] keep near the loaded balance point, front to back

/* [Personalize] */
name = "";          // engraved on the back, one line only, empty for none
name_size = 22;     // [10:1:40] text size of the name
font_name = "Liberation Sans:style=Bold";
show_icons = true;
engrave = 0.8;      // [0.4:0.1:1.5]

/* [Output] */
scale_factor = 1;   // [0.8:0.05:1.3] scales everything, including the slots
part = "organizer"; // [organizer, supplies, name_cut, fit_check]

/* [Hidden] */
$fn = 64;
edge_r = 3;
corner_r = 10;
eps = 0.01;

// Layout: x left to right, y front to back. Rows run front to back.
marker_block = marker_pitch*3 + marker_d;
pencil_block = pencil_pitch*(pencil_count - 1) + pencil_d;
inner_w = max(
  bottle_w + inner_wall + marker_block + inner_wall + stick_d*2 + stick_gap,
  pencil_box_w + inner_wall + crayon_box_w,
  pencil_block + inner_wall + scissor_w,
  long_box_w);
total_w = outer_wall*2 + inner_w;

mid_t = max(bottle_t, marker_pitch + marker_d);
back_row_t = max(pencil_box_t, crayon_box_t);
y_tray = outer_wall;
y_mid = y_tray + tray_row_t + inner_wall;
y_small = y_mid + mid_t + inner_wall;
small_t = max(scissor_t, pencil_d);
y_boxes = y_small + small_t + inner_wall;
y_long = y_boxes + back_row_t + inner_wall;
total_d = y_long + long_box_t + outer_wall;

step_mid = y_mid - inner_wall;     // front face of the medium section
step_back = y_small - inner_wall;  // front face of the deep section

crayon_x = total_w - outer_wall - crayon_box_w;
long_x = (total_w - long_box_w)/2;
function pencil_x(i) = outer_wall + pencil_d/2 + i*pencil_pitch;
scissor_x = total_w - outer_wall - scissor_w;
marker_x0 = outer_wall + bottle_w + inner_wall + marker_d/2;
function marker_x(i) = marker_x0 + i*marker_pitch;
function marker_y(j) = y_mid + (mid_t - marker_pitch - marker_d)/2 + marker_d/2 + j*marker_pitch;
stick_x1 = total_w - outer_wall - stick_d*1.5 - stick_gap;
stick_x2 = total_w - outer_wall - stick_d/2;
stick_y = y_mid + mid_t/2;
tray_x = outer_wall + eraser_w + inner_wall;
tray_w = total_w - outer_wall - tray_x;
name_at = [total_w/2, total_d, back_h/2 - 2];   // the name's center, on the back face

module rrect(w, d, r) {
  rr = min(r, min(w, d)/2 - eps);
  translate([rr, rr]) offset(r = rr) square([w - 2*rr, d - 2*rr]);
}

// Rounded solid: small bottom chamfer, softly rounded top.
module tier(y, d, h) {
  translate([0, y, 0]) hull() {
    linear_extrude(eps) offset(delta = -0.6) rrect(total_w, d, corner_r);
    translate([0, 0, 0.6]) linear_extrude(h - edge_r - 0.6) rrect(total_w, d, corner_r);
    for (a = [15:15:90])
      translate([0, 0, h - edge_r + edge_r*sin(a)]) linear_extrude(eps)
        offset(delta = -edge_r*(1 - cos(a))) rrect(total_w, d, corner_r);
  }
}

// Pocket cut down from z_top: rounded floor edge, flared lip so things drop in.
module well(x, y, w, d, z_top, depth, r = 4, flare = 1.2) {
  fr = min(3, depth/3, min(w, d)/2 - 1);
  translate([x, y, z_top - depth]) hull() {
    for (a = [0:15:90])
      translate([0, 0, fr*(1 - cos(a))]) linear_extrude(eps)
        offset(delta = -fr*(1 - sin(a))) rrect(w, d, r);
    translate([0, 0, depth - flare]) linear_extrude(eps) rrect(w, d, r);
    translate([0, 0, depth + eps]) linear_extrude(1) offset(delta = flare) rrect(w, d, r);
  }
}
module hole(cx, cy, dia, z_top, depth) {
  well(cx - dia/2, cy - dia/2, dia, dia, z_top, depth, dia/2, 0.6);
}

// Finger lip on each end, centered near the loaded balance point and kept high
// so the grip stays above that point. A short side wall carries the part of the
// lip that reaches past the deep section. 45 degree underside, no supports.
module lips() {
  if (lip_out > 0) {
    y0 = lip_center_y - lip_len/2;
    for (side = [0, 1]) {
      intersection() {
        translate([side ? total_w - 1 : -lip_out, y0, 0]) linear_extrude(back_h)
          rrect(lip_out + 1, lip_len, 5);
        translate([side ? total_w : 0, 0, 0]) mirror([side ? 0 : 1, 0, 0])
          rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(total_d)
            polygon([[-1, back_h - lip_tall - 1], [0, back_h - lip_tall],
                     [lip_out, back_h - lip_tall + lip_out],
                     [lip_out, back_h - 1.5], [lip_out - 1.5, back_h], [-1, back_h]]);
      }
      if (y0 < step_back + corner_r)
        translate([side ? total_w - outer_wall : 0, y0, mid_h - 6]) rotate([90, 0, 90])
          linear_extrude(outer_wall) rrect(step_back + corner_r - y0, back_h - mid_h + 6, 5);
    }
  }
}

// Picture labels, about 24 tall, centered on the origin.
module icon_pencil() {
  rotate(-35) union() {
    translate([-4, -6]) square([8, 18]);
    polygon([[-4, -6], [4, -6], [0, -13]]);
    translate([-4, 13]) square([8, 3]);
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
module icon_eraser() {
  rotate(15) difference() {
    translate([-14, -7]) rrect(28, 14, 2.5);
    translate([-5.6, -8]) square([1.4, 16]);
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
module icon_glue_bottle() {
  union() {
    translate([-8, -12]) rrect(16, 16, 3);
    polygon([[-5, 3], [5, 3], [2.5, 8], [-2.5, 8]]);
    polygon([[-2.5, 7], [2.5, 7], [0.8, 13], [-0.8, 13]]);
  }
}
module icon_glue_stick() {
  union() {
    translate([-6, -12]) rrect(12, 14, 1.5);
    translate([-4.5, 3.4]) rrect(9, 8.8, 2.4);
  }
}
module icon_box_base() { translate([-11, -12]) rrect(22, 13, 1.5); }
module icon_colored_pencil_box() {
  union() {
    icon_box_base();
    for (i = [0:4]) let (x = -8 + 4*i)
      polygon([[x - 1.5, 0], [x + 1.5, 0], [x + 1.5, 6], [x, 11], [x - 1.5, 6]]);
  }
}
module icon_crayon_box() {
  union() {
    icon_box_base();
    for (i = [0:3]) let (x = -7.5 + 5*i)
      polygon([[x - 2, 0], [x + 2, 0], [x + 2, 5], [x + 0.8, 10], [x - 0.8, 10], [x - 2, 5]]);
  }
}
module icon_marker_box() {
  union() {
    icon_box_base();
    for (i = [0:2]) translate([-6.5 + 6.5*i - 2.5, 0]) rrect(5, 10, 2);
  }
}
module icon_star() {
  polygon([for (i = [0:9]) let (r = i % 2 == 0 ? 11 : 4.8, a = 90 + i*36) [r*cos(a), r*sin(a)]]);
}
module cut_face(cx, y, z) {
  translate([cx, y, z]) rotate([90, 0, 0]) translate([0, 0, -engrave])
    linear_extrude(engrave + 1) children();
}

module organizer() {
  difference() {
    union() {
      tier(0, total_d, front_h);
      tier(step_mid, total_d - step_mid, mid_h);
      tier(step_back, total_d - step_back, back_h);
      lips();
    }

    // Deep section
    well(long_x, y_long, long_box_w, long_box_t, back_h, back_h - floor_t);
    well(outer_wall, y_boxes, pencil_box_w, pencil_box_t, back_h, back_h - floor_t);
    well(crayon_x, y_boxes, crayon_box_w, crayon_box_t, back_h, back_h - floor_t);
    for (i = [0:pencil_count - 1])
      hole(pencil_x(i), y_small + small_t/2, pencil_d, back_h, back_h - floor_t);
    well(scissor_x, y_small + (small_t - scissor_t)/2, scissor_w, scissor_t, back_h, back_h - floor_t);

    // Medium section
    well(outer_wall, y_mid + (mid_t - bottle_t)/2, bottle_w, bottle_t, mid_h, mid_h - floor_t, 8);
    for (i = [0:3], j = [0:1]) hole(marker_x(i), marker_y(j), marker_d, mid_h, mid_h - floor_t);
    hole(stick_x1, stick_y, stick_d, mid_h, stick_depth);
    hole(stick_x2, stick_y, stick_d, mid_h, stick_depth);

    // Shallow tray
    well(outer_wall, y_tray, eraser_w, tray_row_t, front_h, eraser_depth);
    well(tray_x, y_tray, tray_w, tray_row_t, front_h, tray_depth);

    if (show_icons) {
      // Deep section labels, roughly above the slots they describe.
      z_back = (mid_h + back_h)/2 - 1;
      cut_face(outer_wall + pencil_block*0.22, step_back, z_back) scale(0.8) icon_pencil();
      cut_face(outer_wall + pencil_box_w*0.68, step_back, z_back) scale(0.8) icon_colored_pencil_box();
      cut_face(total_w*0.5, step_back, z_back) scale(0.8) icon_marker_box();
      cut_face(crayon_x + crayon_box_w*0.26, step_back, z_back) scale(0.8) icon_crayon_box();
      cut_face(scissor_x + scissor_w/2, step_back, z_back) scale(0.8) icon_scissors();

      // Medium section labels
      z_mid = (front_h + mid_h)/2 - 1;
      cut_face(outer_wall + bottle_w/2, step_mid, z_mid) scale(0.65) icon_glue_bottle();
      cut_face(marker_x0 + marker_pitch*1.5, step_mid, z_mid) scale(0.65) icon_marker();
      cut_face((stick_x1 + stick_x2)/2, step_mid, z_mid) scale(0.65) icon_glue_stick();

      // Tray labels
      cut_face(outer_wall + eraser_w/2, 0, front_h/2) scale(0.6) icon_eraser();
      cut_face(tray_x + tray_w/2, 0, front_h/2) scale(0.6) icon_star();
    }

    name_cut();
  }
}
// The engraved name alone, in place. part="name_cut" exports it for quick per-order name swaps.
module name_cut() {
  if (len(name) > 0)
    translate(name_at) rotate([90, 0, 180])
      translate([0, 0, -engrave]) linear_extrude(engrave + 1)
        text(name, size = name_size, font = font_name, halign = "center", valign = "center");
}

// Stand-ins for the supplies, used for the clearance check.
module supplies() {
  z = floor_t + 3.5;
  translate([total_w/2 - 65, y_long + (long_box_t - 24)/2, z]) cube([130, 24, 140]);   // box of markers
  translate([outer_wall + (pencil_box_w - 89)/2, y_boxes + (pencil_box_t - 19)/2, z]) cube([89, 19, 190]);
  translate([crayon_x + (crayon_box_w - 89)/2, y_boxes + (crayon_box_t - 28)/2, z]) cube([89, 28, 104]);
  for (i = [0:pencil_count - 1]) translate([pencil_x(i), y_small + small_t/2, z]) cylinder(d = 8.5, h = 190, $fn = 6);
  translate([scissor_x + scissor_w/2 - 12, y_small + (small_t - 7)/2, z]) cube([24, 7, 62]);
  translate([scissor_x + scissor_w/2 - 33, y_small + (small_t - 13)/2, back_h + 1]) cube([66, 13, 65]);
  translate([outer_wall + (bottle_w - 64)/2, y_mid + (mid_t - 32)/2, z]) linear_extrude(146) rrect(64, 32, 8);
  for (i = [0:3], j = [0:1]) translate([marker_x(i), marker_y(j), z]) cylinder(d = 14.5, h = 140);
  for (x = [stick_x1, stick_x2]) translate([x, stick_y, mid_h - stick_depth + 3.5]) cylinder(d = 23, h = 76);
  translate([outer_wall + 5, y_tray + 4, front_h - eraser_depth + 3.5]) cube([60, 22, 13]);
}

echo(LAYOUT = [total_w, total_d, y_tray, y_mid, y_small, y_boxes, y_long, step_mid, step_back, crayon_x, long_x, scissor_x, marker_x0, marker_y(0), stick_x1, stick_x2, stick_y, tray_x, tray_w, small_t, mid_t, pencil_x(0)]);
echo(NAME_AT = name_at);

scale(scale_factor) {
  if (part == "organizer") organizer();
  else if (part == "supplies") supplies();
  else if (part == "name_cut") name_cut();
  else if (part == "fit_check") intersection() { organizer(); supplies(); }
}
