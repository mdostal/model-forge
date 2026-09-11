import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { loadPart } from "../src/index.js";

test("loadPart converts inches to mm when unit: in", (t) => {
  const dir = mkdtempSync(path.join(tmpdir(), "panel-gen-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const p = path.join(dir, "part.yaml");
  writeFileSync(
    p,
    `
unit: in
outer_width: 11.25
outer_height: 9
thickness_mm: 3
rect_cutouts:
  - [1, 1, 2, 2]
`.trim()
  );
  const part = loadPart(p);
  assert.ok(Math.abs(part.outer_width - 285.75) < 0.001);
  assert.ok(Math.abs(part.outer_height - 228.6) < 0.001);
  assert.equal(part.thickness, 3);
  // cutout values converted too
  assert.ok(Math.abs(part.rect_cutouts[0][0] - 25.4) < 0.001);
});

test("loadPart defaults to mm when unit is omitted", (t) => {
  const dir = mkdtempSync(path.join(tmpdir(), "panel-gen-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const p = path.join(dir, "part.yaml");
  writeFileSync(p, "outer_width: 100\nouter_height: 80\n");
  const part = loadPart(p);
  assert.equal(part.outer_width, 100);
  assert.equal(part.outer_height, 80);
  assert.equal(part.thickness, 3); // default
});

test("loadPart defaults bedMax to 250mm (X1C bed minus margin) when omitted", (t) => {
  const dir = mkdtempSync(path.join(tmpdir(), "panel-gen-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));
  const p = path.join(dir, "part.yaml");
  writeFileSync(p, "outer_width: 100\nouter_height: 80\n");
  const part = loadPart(p);
  assert.equal(part.bedMax, 250);
});
