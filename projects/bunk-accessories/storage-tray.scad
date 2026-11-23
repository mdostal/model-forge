// Bunk storage tray: an open-top rectangular tray with compartments that
// hangs on rail clips (clip.scad), lowered on from above. Remotes, glasses,
// books, toys: pick a size preset, or set "custom" and give every column
// width and row depth yourself.
//
//   small: 3 compartments in a row, 1 clip
//   large: 3 x 2 = 6 compartments, 2 clips
//
// Each compartment is sized for a TV remote standing up (most are about
// 40-50 mm wide and 20-25 mm thick). Columns run along the rail; rows run
// away from it, row 1 nearest the rail.
//
// Layout style:
//   grid:    even columns x rows (col_w / row_d)
//   feature: one big middle compartment with small ones at the sides
//            (small: narrow | wide | narrow; large: big middle, 2 small
//            stacked each side)
//   lines:   draw your own. Each line is one divider wall, [x1, y1, x2, y2]
//            in mm on the tray's inside floor, as seen standing in the room
//            facing the bed: x from the left wall (0) to the right wall, y from the rail-side wall (0) to the front
//            wall. Lines run straight across (x1 == x2 or y1 == y2), and
//            each end must land on a wall or on another line, like drawing
//            wall to wall. This is what the shop's draw-your-own editor sends.
//
// Print upright as modeled, no supports: the floor sits on the bed and the
// finger scoops are open at the top.

use <rail-clip.scad>

size = "small"; // [small, large, custom]
style = "grid";  // [grid, feature, lines]
lines = [[60, 0, 60, 40], [0, 20, 60, 20]]; // style = lines: [x1, y1, x2, y2] in mm

/* [Custom compartments (size = custom)] */
col_w = [50, 50, 50]; // each column's inside width, along the rail
row_d = [42];         // each row's inside depth, away from the rail
height = 60;          // wall height above the floor
clips = 1;            // 1 or 2 rail clips
clip_pitch = 120;     // clip spacing when using 2; must miss the bed's posts

/* [Build] */
wall = 2;
divider = 1.6;        // divider thickness
divider_frac = 0.85;  // divider height as a fraction of the wall height
floor_t = 2.4;
corner_r = 3;
scoop = 15;           // finger dip in the front wall of each column (0 for none)
scoop_frac = 0.6;     // dip width as a fraction of the column width

/* [Fit] */
dt_clear = 0.25;

part = "tray"; // [tray, assembly, rails, clips, mounted]

/* [Hidden] */
$fn = 40;
eps = 0.01;

P = size == "small" ? [[50, 50, 50], [42], 60, 1, 120]
  : size == "large" ? [[55, 55, 55], [38, 38], 70, 2, 120]
  : [col_w, row_d, height, clips, clip_pitch];
cw = P[0]; rd = P[1]; ht = P[2]; nclips = P[3]; pitch = P[4];

function sum(v, n) = n <= 0 ? 0 : v[n - 1] + sum(v, n - 1);

assert(len(cw) >= 1 && len(rd) >= 1, "need at least one column and one row");
for (w = cw) assert(w >= 15, str("column width ", w, " is under 15 mm"));
for (d = rd) assert(d >= 15, str("row depth ", d, " is under 15 mm"));
assert(scoop < ht - 15, "scoop must leave at least 15 mm of front wall");

iw = sum(cw, len(cw)) + (len(cw) - 1) * divider;  // inside width
id = sum(rd, len(rd)) + (len(rd) - 1) * divider;  // inside depth
ow = iw + 2 * wall;
od = id + 2 * wall;
oh = floor_t + ht;
y0 = dt_block_d(dt_clear) - eps;
bot = dt_roof() - oh;  // rim flush with the socket roof
xs = nclips >= 2 ? [-pitch / 2, pitch / 2] : [0];
dh = ht * divider_frac;

// ---- dividers as lines (centerlines, inside-floor mm) ----
function cumsum(v, i) = i <= 0 ? 0 : v[i - 1] + cumsum(v, i - 1);
grid_lines = concat(
  [for (i = [1 : len(cw) - 1]) let(x = cumsum(cw, i) + (i - 0.5) * divider) [x, 0, x, id]],
  len(rd) > 1 ? [for (j = [1 : len(rd) - 1]) let(y = cumsum(rd, j) + (j - 0.5) * divider) [0, y, iw, y]] : []);
fs = len(rd) > 1;  // large-style: stack the side cells
side = min(48, iw * 0.28);
feature_lines = concat([[side, 0, side, id], [iw - side, 0, iw - side, id]],
  fs ? [[0, id / 2, side, id / 2], [iw - side, id / 2, iw, id / 2]] : []);
L = style == "grid" ? grid_lines : style == "feature" ? feature_lines : lines;

E = 0.01;
function on_seg(p, l) =  // point p on line l (within E)
  l[0] == l[2] ? (abs(p[0] - l[0]) < E + divider / 2 && p[1] >= min(l[1], l[3]) - E && p[1] <= max(l[1], l[3]) + E)
               : (abs(p[1] - l[1]) < E + divider / 2 && p[0] >= min(l[0], l[2]) - E && p[0] <= max(l[0], l[2]) + E);
function on_wall(p) = abs(p[0]) < E || abs(p[0] - iw) < E || abs(p[1]) < E || abs(p[1] - id) < E;
function anchored(p, k) = on_wall(p) || len([for (m = [0 : len(L) - 1]) if (m != k && on_seg(p, L[m])) 1]) > 0;

for (k = [0 : len(L) - 1]) let(l = L[k]) {
  assert(len(l) == 4, str("line ", k, " needs [x1, y1, x2, y2]"));
  assert(l[0] == l[2] || l[1] == l[3], str("line ", k, " must run straight across (x1 == x2 or y1 == y2)"));
  assert(min(l[0], l[2]) >= -E && max(l[0], l[2]) <= iw + E && min(l[1], l[3]) >= -E && max(l[1], l[3]) <= id + E,
         str("line ", k, " leaves the tray (inside is ", iw, " x ", id, " mm)"));
  assert(anchored([l[0], l[1]], k) && anchored([l[2], l[3]], k),
         str("line ", k, " must start and end on a wall or another line"));
}

// front-wall compartments: split the front wall at every line that reaches it
function qsort(v) = len(v) <= 1 ? v : let(p = v[0])
  concat(qsort([for (x = v) if (x < p) x]), [for (x = v) if (x == p) x], qsort([for (x = v) if (x > p) x]));
// model axes: the room-side viewer's left is +X, so flip x
G = [for (l = L) [iw - l[0], l[1], iw - l[2], l[3]]];
front_x = qsort(concat([0, iw], [for (l = G) if (l[0] == l[2] && max(l[1], l[3]) >= id - E) l[0]]));

echo(str("storage tray ", size, " / ", style, ": ", len(L), " dividers, inside ", iw, " x ", id,
         ", outside ", ow, " x ", od, " x ", oh, " mm, clips ", nclips));

module rbox(w, d, h, r) {
  hull() for (x = [r, w - r], y = [r, d - r]) translate([x, y, 0]) cylinder(r = r, h = h);
}

module body() {
  difference() {
    translate([-ow / 2, y0, bot]) rbox(ow, od, oh, corner_r);
    translate([-iw / 2, y0 + wall, bot + floor_t]) rbox(iw, id, oh, max(0.5, corner_r - wall));
    if (scoop > 0)
      for (i = [0 : len(front_x) - 2]) let(a = front_x[i], b = front_x[i + 1], cwid = b - a - divider)
        if (cwid >= 15) let(sw = cwid * scoop_frac)
          // round-bottomed dip in the front wall, open at the top
          translate([-iw / 2 + (a + b) / 2, y0 + od + 1, bot + oh - scoop + sw / 2]) rotate([90, 0, 0])
            hull() { cylinder(d = sw, h = wall + 2); translate([-sw / 2, 0, 0]) cube([sw, scoop + 1, wall + 2]); }
  }
  // dividers: each line widened by the divider thickness, clipped to the inside
  intersection() {
    translate([-iw / 2 - E, y0 + wall - E, bot + floor_t - E]) cube([iw + 2 * E, id + 2 * E, dh]);
    for (l = G)
      translate([-iw / 2 + min(l[0], l[2]) - divider / 2, y0 + wall + min(l[1], l[3]) - divider / 2, bot + floor_t - E])
        cube([abs(l[2] - l[0]) + divider, abs(l[3] - l[1]) + divider, dh]);
  }
}

module tray() { with_mounts(-bot, dt_clear, xs) body(); }

if (part == "assembly") bunk_assembly(xs) tray();
else if (part == "tray") tray();
else bunk_piece(part, xs) tray();
