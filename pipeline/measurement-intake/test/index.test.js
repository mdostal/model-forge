import test from "node:test";
import assert from "node:assert/strict";
import { deriveParams, MissingMeasurementsError } from "../src/index.js";

const BASE = {
  face_a_length: 40,
  face_b_length: 38,
  width: 20,
  material_thickness: 2,
  hole_diameter: 6,
  countersink_diameter: 11,
  countersink_depth: 3,
  hole_offset: 12,
  slot_length: 16,
  slot_width: 7,
  slot_offset: 14,
};

test("deriveParams throws MissingMeasurementsError naming every missing field", () => {
  assert.throws(() => deriveParams({ face_a_length: 40 }), (err) => {
    assert.ok(err instanceof MissingMeasurementsError);
    assert.ok(err.missingFields.includes("hole_diameter"));
    return true;
  });
});

test("deriveParams bumps thickness 1.75x by default (metal source, PLA print)", () => {
  const { params, notes } = deriveParams(BASE);
  assert.equal(params.thickness, 3.5); // 2 * 1.75
  assert.ok(notes.some((n) => n.includes("bumped 2mm -> 3.5mm")));
});

test("deriveParams leaves thickness alone when print_material is PETG", () => {
  const { params, notes } = deriveParams({ ...BASE, print_material: "PETG" });
  assert.equal(params.thickness, 2);
  assert.ok(notes.some((n) => n.includes("PETG chosen instead")));
});

test("deriveParams leaves thickness alone when the source is already print-native", () => {
  const { params, notes } = deriveParams({ ...BASE, material_source: "print-native" });
  assert.equal(params.thickness, 2);
  assert.equal(notes.length, 0 + (params.bend_radius > 0 ? 0 : 0)); // no thickness note expected
});

test("deriveParams computes a safe default bend_radius from thickness", () => {
  const { params } = deriveParams(BASE);
  // thickness is 3.5 after the PLA bump; default ratio is 0.75
  assert.equal(params.bend_radius, 2.63);
});

test("deriveParams raises a too-thin measured bend_radius rather than trusting it verbatim", () => {
  const { params, notes } = deriveParams({ ...BASE, bend_radius: 0.5 });
  assert.ok(params.bend_radius > 0.5);
  assert.ok(notes.some((n) => n.includes("bend_radius raised")));
});

test("deriveParams respects a measured bend_radius that's already safe", () => {
  const { params, notes } = deriveParams({ ...BASE, bend_radius: 5 });
  assert.equal(params.bend_radius, 5);
  assert.ok(!notes.some((n) => n.includes("bend_radius raised")));
});

test("deriveParams passes through the plain dimensional fields untouched", () => {
  const { params } = deriveParams(BASE);
  assert.equal(params.face_a_length, 40);
  assert.equal(params.slot_offset, 14);
});
