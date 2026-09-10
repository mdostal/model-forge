// Shells out to OpenSCAD to render l-bracket.scad with overridden params.
// Chosen over Onshape FeatureScript per design-discussion §2: free/open,
// scriptable, CLI-testable without a GUI.
import { spawn } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { existsSync } from "node:fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const TEMPLATE = path.join(__dirname, "..", "templates", "l-bracket.scad");

export const PARAM_NAMES = [
  "face_a_length",
  "face_b_length",
  "width",
  "thickness",
  "bend_radius",
  "hole_diameter",
  "countersink_diameter",
  "countersink_depth",
  "hole_offset",
  "slot_length",
  "slot_width",
  "slot_offset",
];

export class OpenSCADNotFoundError extends Error {
  constructor() {
    super(
      "openscad binary not found on PATH. Install it (e.g. `brew install --cask openscad` — " +
        "note: this machine's cask was Gatekeeper-disabled as of 2026-09-01, see " +
        "https://www.openscad.org/downloads.html for a direct download) before rendering."
    );
    this.name = "OpenSCADNotFoundError";
  }
}

function run(cmd, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, { stdio: ["ignore", "pipe", "pipe"] });
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

/** Build the `openscad -D name=value ...` argv for a given param set. Pure — no I/O. */
export function buildArgs(outputPath, params, { template = TEMPLATE } = {}) {
  const missing = PARAM_NAMES.filter((name) => !(name in params));
  if (missing.length > 0) {
    throw new Error(`Missing required bracket params: ${missing.join(", ")}`);
  }
  const args = ["-o", outputPath];
  for (const name of PARAM_NAMES) {
    args.push("-D", `${name}=${params[name]}`);
  }
  args.push(template);
  return args;
}

/** Render an L-bracket STL. Throws OpenSCADNotFoundError if openscad isn't installed. */
export async function renderBracket(outputPath, params, { exec = run, template = TEMPLATE } = {}) {
  if (!existsSync(template)) {
    throw new Error(`Template not found: ${template}`);
  }
  const args = buildArgs(outputPath, params, { template });
  await exec("openscad", args);
  return { outputPath };
}

export function isOpenSCADAvailable({ exec = run } = {}) {
  return exec("openscad", ["--version"]).then(
    () => true,
    (err) => (err instanceof OpenSCADNotFoundError ? false : Promise.reject(err))
  );
}
