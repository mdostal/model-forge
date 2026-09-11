// CLI: node src/index.js <part.yaml> [--output-dir dir] [--base-name name]
import { readFileSync, mkdirSync } from "node:fs";
import path from "node:path";
import yaml from "js-yaml";
import { renderPanel } from "./render.js";

const IN_TO_MM = 25.4;

function toMm(value, unit) {
  if (unit === "in") return value * IN_TO_MM;
  return value; // default mm
}

export function loadPart(filePath) {
  const raw = readFileSync(filePath, "utf8");
  const doc = yaml.load(raw);
  const unit = doc.unit ?? "mm";
  return {
    outer_width: toMm(doc.outer_width, unit),
    outer_height: toMm(doc.outer_height, unit),
    thickness: doc.thickness_mm ?? 3,
    rect_cutouts: (doc.rect_cutouts ?? []).map((c) => c.map((v) => toMm(v, unit))),
    circle_cutouts: (doc.circle_cutouts ?? []).map((c) => c.map((v) => toMm(v, unit))),
    bedMax: doc.bed_max_mm ?? 250,
  };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const [, , partPath, ...rest] = process.argv;
  if (!partPath) {
    console.error("Usage: node src/index.js <part.yaml> [--output-dir dir] [--base-name name]");
    process.exit(1);
  }
  const outDirIdx = rest.indexOf("--output-dir");
  const nameIdx = rest.indexOf("--base-name");
  const outputDir = outDirIdx >= 0 ? rest[outDirIdx + 1] : path.join(path.dirname(partPath), "..", "output");
  const baseName = nameIdx >= 0 ? rest[nameIdx + 1] : path.basename(partPath, path.extname(partPath));

  const part = loadPart(partPath);
  console.log(`${baseName}: ${part.outer_width.toFixed(2)}mm x ${part.outer_height.toFixed(2)}mm, ${part.thickness}mm thick`);
  mkdirSync(outputDir, { recursive: true });

  renderPanel(outputDir, baseName, part, { bedMax: part.bedMax })
    .then((results) => {
      if (results.length > 1) {
        console.log(`Split into ${results.length} segments (bed max ${part.bedMax}mm):`);
      }
      for (const r of results) console.log(`  ${r.outputPath}`);
    })
    .catch((err) => {
      console.error(`Render failed: ${err.message}`);
      process.exit(1);
    });
}
