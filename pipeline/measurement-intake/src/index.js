// Turns a project's measurements.yaml into bracket-gen's OpenSCAD params,
// applying the PLA-strength bump README.md calls for: "PLA is weaker than
// metal — thicken the part ~1.5-2x and add a fillet at the bend, or print
// in PETG." Folds pla-strength-helper into this derivation rather than
// shipping it as a separate tool (design-discussion §2).
import { readFileSync } from "node:fs";
import yaml from "js-yaml";
import { renderBracket } from "../../bracket-gen/src/render.js";

const REQUIRED_FIELDS = [
  "face_a_length",
  "face_b_length",
  "width",
  "material_thickness",
  "hole_diameter",
  "countersink_diameter",
  "countersink_depth",
  "hole_offset",
  "slot_length",
  "slot_width",
  "slot_offset",
];

const PLA_THICKNESS_MULTIPLIER = 1.75; // mid-point of README's "1.5-2x" range
const DEFAULT_BEND_RADIUS_RATIO = 0.75; // bend_radius >= thickness * this, so the fillet is never thinner than the wall

export class MissingMeasurementsError extends Error {
  constructor(missingFields) {
    super(`measurements.yaml is missing required field(s): ${missingFields.join(", ")}`);
    this.name = "MissingMeasurementsError";
    this.missingFields = missingFields;
  }
}

/**
 * Pure derivation: raw caliper measurements -> bracket-gen's full param set,
 * with the PLA-strength bump applied and notes explaining what changed.
 */
export function deriveParams(measurements) {
  const missing = REQUIRED_FIELDS.filter((f) => measurements[f] === undefined || measurements[f] === null);
  if (missing.length > 0) {
    throw new MissingMeasurementsError(missing);
  }

  const printMaterial = measurements.print_material ?? "PLA";
  const sourceMaterial = measurements.material_source ?? "metal";
  const notes = [];

  let thickness = measurements.material_thickness;
  if (sourceMaterial !== "print-native" && printMaterial === "PLA") {
    const bumped = round2(thickness * PLA_THICKNESS_MULTIPLIER);
    notes.push(`thickness bumped ${thickness}mm -> ${bumped}mm (metal->PLA, ${PLA_THICKNESS_MULTIPLIER}x per README's strength note)`);
    thickness = bumped;
  } else if (sourceMaterial !== "print-native" && printMaterial === "PETG") {
    notes.push(`thickness left at ${thickness}mm — PETG chosen instead of thickening, per README's alternative`);
  }

  const minBendRadius = round2(thickness * DEFAULT_BEND_RADIUS_RATIO);
  const bendRadius = measurements.bend_radius !== undefined ? Math.max(measurements.bend_radius, minBendRadius) : minBendRadius;
  if (measurements.bend_radius !== undefined && bendRadius > measurements.bend_radius) {
    notes.push(`bend_radius raised ${measurements.bend_radius}mm -> ${bendRadius}mm — measured radius was thinner than the wall, which would print as a weak point`);
  }

  const params = {
    face_a_length: measurements.face_a_length,
    face_b_length: measurements.face_b_length,
    width: measurements.width,
    thickness,
    bend_radius: bendRadius,
    hole_diameter: measurements.hole_diameter,
    countersink_diameter: measurements.countersink_diameter,
    countersink_depth: measurements.countersink_depth,
    hole_offset: measurements.hole_offset,
    slot_length: measurements.slot_length,
    slot_width: measurements.slot_width,
    slot_offset: measurements.slot_offset,
  };

  return { params, notes };
}

export function loadMeasurements(filePath) {
  const raw = readFileSync(filePath, "utf8");
  return yaml.load(raw);
}

export async function generateFromFile(measurementsPath, outputStlPath, { render = renderBracket } = {}) {
  const measurements = loadMeasurements(measurementsPath);
  const { params, notes } = deriveParams(measurements);
  const result = await render(outputStlPath, params);
  return { ...result, params, notes };
}

function round2(n) {
  return Math.round(n * 100) / 100;
}

// CLI entry: node src/index.js <measurements.yaml> [--output out.stl]
if (import.meta.url === `file://${process.argv[1]}`) {
  const [, , measurementsPath, ...rest] = process.argv;
  if (!measurementsPath) {
    console.error("Usage: node src/index.js <measurements.yaml> [--output out.stl]");
    process.exit(1);
  }
  const outputIdx = rest.indexOf("--output");
  const outputPath = outputIdx >= 0 ? rest[outputIdx + 1] : null;

  const measurements = loadMeasurements(measurementsPath);
  const { params, notes } = deriveParams(measurements);

  console.log("Derived params:");
  for (const [k, v] of Object.entries(params)) console.log(`  ${k} = ${v}`);
  if (notes.length) {
    console.log("\nNotes:");
    for (const n of notes) console.log(`  - ${n}`);
  }

  if (outputPath) {
    renderBracket(outputPath, params)
      .then(() => console.log(`\nRendered: ${outputPath}`))
      .catch((err) => {
        console.error(`\nRender failed: ${err.message}`);
        process.exit(1);
      });
  } else {
    console.log("\n(dry run — pass --output <file.stl> to render)");
  }
}
