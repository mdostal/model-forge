import test from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { generateFromFile } from "../src/index.js";

test("generateFromFile reads a real measurements.yaml and drives render() with derived params", async (t) => {
  const dir = mkdtempSync(path.join(tmpdir(), "measurement-intake-"));
  t.after(() => rmSync(dir, { recursive: true, force: true }));

  const yamlPath = path.join(dir, "measurements.yaml");
  writeFileSync(
    yamlPath,
    `
face_a_length: 45
face_b_length: 40
width: 22
material_thickness: 2.5
hole_diameter: 6
countersink_diameter: 11
countersink_depth: 3
hole_offset: 13
slot_length: 18
slot_width: 7
slot_offset: 15
`.trim()
  );

  let renderedWith = null;
  const fakeRender = async (outputPath, params) => {
    renderedWith = { outputPath, params };
    return { outputPath };
  };

  const result = await generateFromFile(yamlPath, "/tmp/furniture-bracket.stl", { render: fakeRender });

  assert.equal(result.outputPath, "/tmp/furniture-bracket.stl");
  assert.equal(renderedWith.params.face_a_length, 45);
  assert.equal(renderedWith.params.thickness, 4.38); // 2.5 * 1.75, rounded
  assert.ok(result.notes.some((n) => n.includes("bumped")));
});
