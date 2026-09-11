import test from "node:test";
import assert from "node:assert/strict";
import { existsSync, rmSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { computeSegments, buildArgs, renderPanel, OpenSCADNotFoundError } from "../src/render.js";

const OPENSCAD_AVAILABLE = spawnSync("openscad", ["--version"]).error === undefined;

test("computeSegments returns one whole-panel segment when it fits the bed", () => {
  const segs = computeSegments(200, 150, 250);
  assert.equal(segs.length, 1);
  assert.deepEqual(segs[0], { index: 0, x0: 0, x1: 200, y0: 0, y1: 150 });
});

test("computeSegments splits along X when the width exceeds bed_max", () => {
  const segs = computeSegments(285.75, 228.6, 250);
  assert.equal(segs.length, 2);
  assert.equal(segs[0].x0, 0);
  assert.equal(segs[1].x1, 285.75);
  // segments tile exactly, no gap or overlap
  assert.equal(segs[0].x1, segs[1].x0);
  for (const s of segs) {
    assert.equal(s.y0, 0);
    assert.equal(s.y1, 228.6);
  }
});

test("computeSegments splits both axes when both exceed bed_max", () => {
  const segs = computeSegments(500, 400, 250);
  assert.equal(segs.length, 4); // 2 x 2
});

test("buildArgs encodes cutout arrays as valid OpenSCAD vector literals", () => {
  const args = buildArgs("/tmp/out.stl", { outer_width: 100, outer_height: 80, thickness: 3, rect_cutouts: [[1, 2, 3, 4]], circle_cutouts: [[5, 6, 7]] }, { x0: 0, x1: 100, y0: 0, y1: 80 });
  const joined = args.join(" ");
  assert.match(joined, /rect_cutouts=\[\[1,2,3,4\]\]/);
  assert.match(joined, /circle_cutouts=\[\[5,6,7\]\]/);
  assert.match(joined, /seg=\[0,100,0,80\]/);
  assert.ok(args[0] === "-o" && args[1] === "/tmp/out.stl");
});

test("buildArgs defaults empty cutout arrays to []", () => {
  const args = buildArgs("/tmp/out.stl", { outer_width: 100, outer_height: 80, thickness: 3 }, { x0: 0, x1: 100, y0: 0, y1: 80 });
  assert.ok(args.includes("rect_cutouts=[]"));
  assert.ok(args.includes("circle_cutouts=[]"));
});

test("renderPanel calls exec once per segment with distinct output paths", async () => {
  const calls = [];
  const exec = async (cmd, args) => calls.push({ cmd, args });
  await renderPanel("/tmp/panels", "oven-insert", { outer_width: 285.75, outer_height: 228.6, thickness: 3 }, { exec, bedMax: 250 });
  assert.equal(calls.length, 2);
  assert.match(calls[0].args[1], /oven-insert-seg1-of-2\.stl$/);
  assert.match(calls[1].args[1], /oven-insert-seg2-of-2\.stl$/);
});

test("renderPanel writes a single unsuffixed STL when the panel fits one bed", async () => {
  const calls = [];
  const exec = async (cmd, args) => calls.push({ cmd, args });
  const results = await renderPanel("/tmp/panels", "fridge-rack", { outer_width: 150, outer_height: 100, thickness: 3 }, { exec, bedMax: 250 });
  assert.equal(results.length, 1);
  assert.equal(path.basename(results[0].outputPath), "fridge-rack.stl");
});

test("renderPanel propagates OpenSCADNotFoundError instead of swallowing it", async () => {
  const exec = async () => {
    throw new OpenSCADNotFoundError();
  };
  await assert.rejects(
    renderPanel("/tmp/panels", "x", { outer_width: 50, outer_height: 50, thickness: 3 }, { exec }),
    OpenSCADNotFoundError
  );
});

test("real render: renders an actual multi-segment STL pair via the installed openscad binary", { skip: !OPENSCAD_AVAILABLE && "openscad not installed" }, async (t) => {
  const outDir = "/tmp/model-forge-panel-gen-test";
  const { mkdirSync } = await import("node:fs");
  mkdirSync(outDir, { recursive: true });
  t.after(() => rmSync(outDir, { recursive: true, force: true }));

  const results = await renderPanel(
    outDir,
    "test-oven-insert",
    { outer_width: 285.75, outer_height: 228.6, thickness: 3, rect_cutouts: [[100, 90, 60, 40]] },
    { bedMax: 250 }
  );

  assert.equal(results.length, 2);
  for (const r of results) {
    assert.ok(existsSync(r.outputPath), `expected ${r.outputPath} to exist`);
  }
});
