// Tiny Land — small test block for trying Bambu Studio's own Cut Tool
// connector types (Dowel, Snap, Plug, its own Dovetail) directly, at
// low cost, instead of burning a full-size part on each experiment.
//
// This isn't a joint design of ours — it's just a plain flat rectangle,
// deliberately featureless, sized like the back-wall-joint-test.scad
// stubs (~real panel thickness) so a cut through it and Bambu's
// generated connector are representative of the actual wall/grate
// panels. Import into Bambu Studio, use the Cut tool to slice it in
// half, try each connector type on the two halves, adjust size/depth/
// tolerance, re-slice, look at the preview — then print whichever pair
// of halves you want to physically test.
//
// thickness/plate_w/plate_h below match back-wall-joint-test.scad's
// stub proportions; bump thickness to 5.08 if you want to test at the
// grate's thickness instead.
thickness = 3;
plate_w   = 80;
plate_h   = 40;

cube([plate_w, plate_h, thickness]);
