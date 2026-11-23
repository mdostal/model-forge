// Bunk book holder: rows of books, front to back, that hang on rail clips
// (clip.scad), lowered on from above.
//   layout = "stepped": each row's floor is a step higher than the one in front,
//            so every row's covers show over the row before it: pick one out at
//            night, put it back when done. Every row still has a lip in front of
//            its books at least `lip` tall.
//   layout = "flat":    every row on one thicker floor; the walls cover more of
//            the books, the back rows' covers sit behind the front books.
//
// Picture books are mostly 7-10 in tall (portrait 7x10, landscape 10x8, square
// 7.5-8.5) and board books about 6x6 in (Blurb and Reedsy trim-size guides).
// The walls hold the lower part of a standing book; tops stick up to grab.
//
// Cut-out shapes on the front and ends: heart, diamond, circle (a drop with a
// pointed top) or star, chosen per position and sized to fit.
//
// Print upright as modeled, no supports: the floor sits on the bed, the raised
// steps are hollow with short bridged tops, and every cutout's top is pointed
// at 45 degrees or narrow enough to bridge.

use <rail-clip.scad>

/* [Size] */
layout = "stepped"; // [stepped, flat]
width = 230;        // inside, along the rail (the tissue holder's is 232)
rows = 3;           // [1:1:4] rows of books, front to back
row_d = 30;         // front row's inside depth: 2-3 picture books
back_d = 35;        // every row behind it: 3 hardcovers or a thick board book
step = 20;          // stepped: how much higher each row's floor is than the row in front
front_h = 60;       // the front wall, above the front row's floor
lip = 55;           // stepped: the divider in front of each back row, above that row's floor
back_h = 80;        // the back wall, above the back row's floor
flat_floor_t = 3.2; // flat: the thicker one-piece floor

/* [Shapes] */
front_shapes = ["heart", "diamond", "heart", "circle", "heart"]; // left to right, as seen from the room; "" leaves a gap.
// heart, diamond and circle print clean upright. "star" works but the tops of its side arms are a near-flat
// 9 mm overhang (print-check WARNs): expect a little sag there.
end_shapes = ["heart"];  // on each end wall, rail side to front
shape_size = 26;    // [12:1:40] each shape's height
shape_frac = 0.5;   // [0.3:0.05:0.7] shape center height, as a fraction of the wall below the next row

/* [Stripes] */
stripes = 4;      // [0:1:10] bands of the second color
stripe_h = 8;     // each band's height
base_band = 10;   // first-color band at the bottom
layer_h = 0.2;    // bands are cut at multiples of this, so an AMS swaps on clean layers
stripe_part = 0;  // [0, 1, 2] 0: the whole holder; 1 or 2: that color's bands only

/* [Build] */
wall = 2;
floor_t0 = 2.4;     // stepped: floor thickness
divider = 2;
corner_r = 3;
clips = 2;
clip_pitch = 140;   // must miss the bed's posts

/* [Fit] */
dt_clear = 0.25;

part = "holder"; // [holder, assembly, rails, clips, mounted]

/* [Hidden] */
$fn = 40;
eps = 0.01;

stepped = layout == "stepped";
floor_t = stepped ? floor_t0 : flat_floor_t;
st = stepped ? step : 0;
// rows numbered from the front (room side, k = 0) to the back (rail side, k = rows - 1)
function d(k) = k == 0 ? row_d : back_d;
function depth_to(k) = k <= 0 ? 0 : d(k - 1) + divider + depth_to(k - 1);   // inside depth in front of row k
id = depth_to(rows) - divider;   // inside depth
ow = width + 2 * wall;
od = id + 2 * wall;
y0 = dt_block_d(dt_clear) - eps;
function floor_z(k) = floor_t + k * st;   // floor top of row k, from the holder bottom
// the wall in front of row k: the front wall, or the divider; flat dividers stand as tall as the front wall
function front_top(k) = floor_z(k) + (k == 0 || !stepped ? front_h : lip);
oh = floor_z(rows - 1) + back_h;   // overall height: the back wall
// end walls step up with the dividers: beside row k they stand as tall as the divider behind it
function end_top(k) = k >= rows - 1 ? oh : front_top(k + 1);
bot = dt_roof() - oh;                    // back rim flush with the socket roof
xs = clips >= 2 ? [-clip_pitch / 2, clip_pitch / 2] : [0];
// y of row k's front (room side) and rail-side edges, inside; row k = 0 is at the front (large y)
function row_y1(k) = y0 + wall + id - depth_to(k);
function row_y0(k) = row_y1(k) - d(k);

assert(layout == "stepped" || layout == "flat", str("book-holder: unknown layout ", layout));
assert(rows >= 1 && rows <= 4, "1 to 4 rows");
assert(back_h >= front_h, "the back wall must be at least as tall as the front wall");
assert(front_h >= shape_size + 12, "front wall too short for the shapes");
echo(str("book holder: ", layout, ", ", rows, " rows (", row_d, " front, ", back_d, " behind), inside ", width, " x ", id,
         ", outside ", ow, " x ", od, " x ", oh, " mm, clips ", clips));

module rbox(w, d, h, r) {
  hull() for (x = [r, w - r], y = [r, d - r]) translate([x, y, 0]) cylinder(r = r, h = h);
}

// ---- shapes, centered on the origin, height s, tops safe to print upright ----
module heart2d(s) {
  r = s * 0.27;
  // two lobes with 45-degree peaks (a round top would print as an overhang), point down
  translate([0, -s * 0.06]) {
    for (m = [-1, 1]) hull() {
      translate([m * r * 0.95, s * 0.12]) circle(r = r);
      translate([m * r * 0.95, s * 0.12 + r * 1.414]) square(0.01, center = true);
    }
    polygon([[-r * 1.95, s * 0.06], [r * 1.95, s * 0.06], [0, -s * 0.44]]);
  }
}
module star2d(s) {
  R = s / 2; r = R * 0.45;
  polygon([for (i = [0 : 9]) let(a = 90 + i * 36, q = i % 2 == 0 ? R : r) [q * cos(a), q * sin(a) - R * 0.05]]);
}
module diamond2d(s) polygon([[0, s / 2], [s * 0.38, 0], [0, -s / 2], [-s * 0.38, 0]]);
module circle2d(s) {   // teardrop: a 45-degree point on top
  rotate(90) hull() { circle(d = s * 0.9); translate([s * 0.45 * 1.414, 0]) square(0.01, center = true); }
}
module shape2d(n, s) {
  if (n == "heart") heart2d(s);
  else if (n == "star") star2d(s);
  else if (n == "diamond") diamond2d(s);
  else if (n == "circle") circle2d(s * 0.9);
}

module body() {
  difference() {
    union() {
      difference() {
        translate([-ow / 2, y0, bot]) rbox(ow, od, oh, corner_r);
        // each row's well, from its floor up
        for (k = [0 : rows - 1])
          translate([-width / 2, row_y0(k), bot + floor_z(k)]) cube([width, d(k), oh]);
        // cut each front-to-back section down to its height, across the whole width: the wall (front wall or
        // divider) in front of row k to front_top(k), and the end walls beside row k to end_top(k)
        for (k = [0 : rows - 1]) {
          ya = row_y1(k); yb = k == 0 ? y0 + od + 1 : row_y1(k) + divider;
          translate([-ow / 2 - 1, ya - eps, bot + front_top(k)]) cube([ow + 2, yb - ya + 2 * eps, oh]);
          if (k < rows - 1) translate([-ow / 2 - 1, row_y0(k) - eps, bot + end_top(k)]) cube([ow + 2, d(k) + 2 * eps, oh]);
        }
        // hollow under the raised floors, open to the bed: steps print as thin walls with bridged tops
        if (stepped) for (k = [1 : rows - 1])
          let (hw = min(d(k) - 2 * wall, 26))   // bridged top no wider than 26 mm
          translate([-width / 2, row_y0(k) + (d(k) - hw) / 2, bot - 1])
            cube([width, hw, floor_z(k) - floor_t + 1]);
      }
    }
    // front wall shapes, centered in the front row's wall
    n = len(front_shapes);
    if (n > 0) for (i = [0 : n - 1]) if (front_shapes[i] != "")
      // as seen from the room the viewer's left is +X
      translate([width / 2 - (i + 0.5) * width / n, y0 + od + 1, bot + floor_z(0) + front_h * shape_frac])
        rotate([90, 0, 0]) linear_extrude(wall + 2) shape2d(front_shapes[i], shape_size);
    // end wall shapes, one per listed row position, rail side to front
    m = len(end_shapes);
    if (m > 0) for (s = [-1, 1], j = [0 : m - 1]) if (end_shapes[j] != "") {
      yc = y0 + wall + (j + 0.5) * id / m;
      k = len([for (r = [0 : rows - 1]) if (row_y0(r) > yc) r]);   // the row this spot is beside
      h = min(end_top(min(k, rows - 1)), front_top(min(k, rows - 1)));   // the end wall is solid at least this high there
      zc = bot + min(h * shape_frac, h - shape_size / 2 - 8);
      translate([s * (ow / 2 + 1), yc, zc]) rotate([0, 0, 90]) rotate([90, 0, 0])
        linear_extrude(wall + 2, center = true) shape2d(end_shapes[j], shape_size);
    }
  }
}

module holder_whole() { with_mounts(-bot, dt_clear, xs) body(); }

// stripe bands, bottom up: base_band of color 1, then stripe_h of color 2 and of color 1 in turn, stripes times; the rest color 1
function snap(z) = round(z / layer_h) * layer_h;
function band_z(i) = snap(bot + base_band + i * stripe_h);
module stripe_slab(c) {
  big = 1000;
  for (i = [0 : 2 * stripes - 1]) if ((i % 2 == 0 ? 2 : 1) == c)
    translate([-big / 2, -big / 2, band_z(i)]) cube([big, big, band_z(i + 1) - band_z(i)]);
  if (c == 1) {
    translate([-big / 2, -big / 2, bot - big]) cube([big, big, band_z(0) - bot + big]);
    translate([-big / 2, -big / 2, band_z(2 * stripes)]) cube([big, big, big]);
  }
}
assert(stripe_part == 0 || band_z(2 * stripes) <= bot + oh - 2, "book-holder: the stripes run past the top; fewer or thinner stripes");
module holder() {
  if (stripe_part == 0 || stripes == 0) { if (stripe_part != 2) holder_whole(); }
  else intersection() { holder_whole(); stripe_slab(stripe_part); }
}

if (part == "assembly") bunk_assembly(xs) holder();
else if (part == "holder") holder();
else bunk_piece(part, xs) holder();
