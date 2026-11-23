// Bunk book holder: three stepped rows of books, front to back, that hang on
// rail clips (clip.scad), lowered on from above. Each row's floor is a step
// higher than the one in front, so every row of books shows over the one
// before it: pick one out at night, put it back when done.
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
width = 230;        // inside, along the rail (the tissue holder's is 232)
rows = 3;           // [1:1:4] rows of books, front to back
row_d = 30;         // inside depth of each row: 2-3 picture books, or one thick board book
step = 25;          // how much higher each row's floor is than the row in front
front_h = 60;       // front row's wall height above its floor
back_extra = 20;    // the back wall rises this much above the row in front's top

/* [Shapes] */
front_shapes = ["heart", "diamond", "heart", "circle", "heart"]; // left to right, as seen from the room; "" leaves a gap.
// heart, diamond and circle print clean upright. "star" works but the tops of its side arms are a near-flat
// 9 mm overhang (print-check WARNs): expect a little sag there.
end_shapes = ["heart"];  // on each end wall, rail side to front
shape_size = 26;    // [12:1:40] each shape's height
shape_frac = 0.5;   // [0.3:0.05:0.7] shape center height, as a fraction of the wall below the next row

/* [Build] */
wall = 2;
floor_t = 2.4;
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

id = rows * row_d + (rows - 1) * divider;   // inside depth
ow = width + 2 * wall;
od = id + 2 * wall;
y0 = dt_block_d(dt_clear) - eps;
// rows numbered from the front (room side, k = 0) to the back (rail side, k = rows - 1)
function floor_z(k) = floor_t + k * step;   // floor top of row k, from the holder bottom
function wall_top(k) = floor_z(k) + front_h;                              // its wall/divider top
oh = wall_top(rows - 1) + back_extra;    // overall height
bot = dt_roof() - oh;                    // back rim flush with the socket roof
xs = clips >= 2 ? [-clip_pitch / 2, clip_pitch / 2] : [0];
// y of row k's near (rail-side) and far edges, inside; row k = 0 is at the front (large y)
function row_y1(k) = y0 + wall + id - k * (row_d + divider);   // front edge
function row_y0(k) = row_y1(k) - row_d;                         // rail-side edge

assert(rows >= 1 && rows <= 4, "1 to 4 rows");
assert(front_h >= shape_size + 12, "front wall too short for the shapes");
echo(str("book holder: ", rows, " rows of ", row_d, " mm, inside ", width, " x ", id,
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
          translate([-width / 2, row_y0(k), bot + floor_z(k)]) cube([width, row_d, oh]);
        // each wall is cut down to its row's top: the space above row k's top, in front of row k+1
        for (k = [0 : rows - 2])
          translate([-ow / 2 - 1, row_y0(k) - divider - eps, bot + wall_top(k)])
            cube([ow + 2, (row_y1(0) + wall + 1) - (row_y0(k) - divider), oh]);
        // hollow under the raised floors, open to the bed: steps print as thin walls with bridged tops
        for (k = [1 : rows - 1])
          translate([-width / 2, row_y0(k) + wall, bot - 1])
            cube([width, row_d - 2 * wall, floor_z(k) - floor_t + 1]);
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
      k = max(0, min(rows - 1, floor((row_y1(0) - yc) / (row_d + divider))));   // the row this spot is beside
      zc = bot + min(wall_top(k) * shape_frac, wall_top(k) - shape_size / 2 - 8);   // the end wall there is solid from the bottom up to wall_top(k)
      translate([s * (ow / 2 + 1), yc, zc]) rotate([0, 0, 90]) rotate([90, 0, 0])
        linear_extrude(wall + 2, center = true) shape2d(end_shapes[j], shape_size);
    }
  }
}

module holder() { with_mounts(-bot, dt_clear, xs) body(); }

if (part == "assembly") bunk_assembly(xs) holder();
else if (part == "holder") holder();
else bunk_piece(part, xs) holder();
