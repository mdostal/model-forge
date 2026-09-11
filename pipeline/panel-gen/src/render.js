// Drives the model-forge OpenSCAD library (../../lib/model-forge/panel.scad)
// — the same library any hand-written .scad file can `use` directly once
// it's installed at ~/Documents/OpenSCAD/libraries/model-forge (see
// scripts/install-openscad-lib.sh). This wrapper's only job is: given a
// full panel size + cutouts, decide how many bed-sized segments it needs,
// then shell out to openscad once per segment.
import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

// Repo's lib/ dir (parent of lib/model-forge/) — set as OPENSCADPATH so
// `use <model-forge/panel.scad>` resolves for OUR render pipeline even if
// the user hasn't (yet) installed the library into their personal
// ~/Documents/OpenSCAD/libraries/ — that install step is for THEIR
// hand-written .scad files, not required for this tool to work.
const REPO_LIB_DIR = path.resolve(fileURLToPath(new URL("../../../lib", import.meta.url)));

export class OpenSCADNotFoundError extends Error {
  constructor() {
    super(
      "openscad binary not found on PATH. Install it (direct download from " +
        "openscad.org if the brew cask is Gatekeeper-disabled) before rendering."
    );
    this.name = "OpenSCADNotFoundError";
  }
}

function run(cmd, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, {
      stdio: ["ignore", "pipe", "pipe"],
      env: { ...process.env, OPENSCADPATH: REPO_LIB_DIR },
    });
    let stderr = "";
    child.stderr.on("data", (d) => (stderr += d));
    child.on("error", (err) => {
      if (err.code === "ENOENT") reject(new OpenSCADNotFoundError());
      else reject(err);
    });
    child.on("close", (code) => {
      if (code === 0) resolve();
      else reject(new Error(`openscad exited ${code}: ${stderr.trim()}`));
    });
  });
}

/** Pure — tile a panel's footprint into bed_max-sized segments. Mirrors
 * the OpenSCAD `panel_segments()` function in panel.scad (kept in sync by
 * hand; both are simple enough that a shared implementation isn't worth
 * the cross-language plumbing). Returns [{x0,x1,y0,y1,index}, ...]. */
export function computeSegments(outerWidth, outerHeight, bedMax) {
  const nx = Math.ceil(outerWidth / bedMax);
  const ny = Math.ceil(outerHeight / bedMax);
  const segW = outerWidth / nx;
  const segH = outerHeight / ny;
  const segments = [];
  for (let iy = 0; iy < ny; iy++) {
    for (let ix = 0; ix < nx; ix++) {
      segments.push({
        index: iy * nx + ix,
        x0: ix * segW,
        x1: (ix + 1) * segW,
        y0: iy * segH,
        y1: (iy + 1) * segH,
      });
    }
  }
  return segments;
}

function scadVec(rows) {
  return "[" + rows.map((r) => "[" + r.join(",") + "]").join(",") + "]";
}

/** Build the -D args for one segment. Exported for testing without a real openscad call. */
export function buildArgs(outputPath, params, segment) {
  const rectCutouts = params.rect_cutouts ?? [];
  const circleCutouts = params.circle_cutouts ?? [];
  return [
    "-o",
    outputPath,
    "-D",
    `outer_width=${params.outer_width}`,
    "-D",
    `outer_height=${params.outer_height}`,
    "-D",
    `thickness=${params.thickness}`,
    "-D",
    `rect_cutouts=${scadVec(rectCutouts)}`,
    "-D",
    `circle_cutouts=${scadVec(circleCutouts)}`,
    "-D",
    `seg=[${segment.x0},${segment.x1},${segment.y0},${segment.y1}]`,
    path.join(import.meta.dirname, "driver.scad"),
  ];
}

/**
 * Render a panel, splitting into as many bed_max-sized segments as needed.
 * Writes one STL per segment (or a single unsuffixed STL if it fits on one
 * bed). Returns [{ outputPath, segment }, ...].
 */
export async function renderPanel(outputDir, baseName, params, { exec = run, bedMax = 250 } = {}) {
  const segments = computeSegments(params.outer_width, params.outer_height, bedMax);
  const results = [];
  for (const seg of segments) {
    const outputPath =
      segments.length > 1
        ? path.join(outputDir, `${baseName}-seg${seg.index + 1}-of-${segments.length}.stl`)
        : path.join(outputDir, `${baseName}.stl`);
    await exec("openscad", buildArgs(outputPath, params, seg));
    results.push({ outputPath, segment: seg });
  }
  return results;
}
