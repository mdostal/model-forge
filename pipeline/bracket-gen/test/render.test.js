import test from "node:test";
import assert from "node:assert/strict";
import { buildArgs, renderBracket, isOpenSCADAvailable, OpenSCADNotFoundError, PARAM_NAMES } from "../src/render.js";

const FULL_PARAMS = Object.fromEntries(PARAM_NAMES.map((n, i) => [n, i + 1]));

test("buildArgs produces one -D flag per required param, in a stable order", () => {
  const args = buildArgs("/tmp/out.stl", FULL_PARAMS, { template: "/tmp/fake.scad" });
  assert.equal(args[0], "-o");
  assert.equal(args[1], "/tmp/out.stl");
  assert.equal(args.at(-1), "/tmp/fake.scad");
  const dFlags = args.filter((a) => a === "-D").length;
  assert.equal(dFlags, PARAM_NAMES.length);
  assert.ok(args.includes(`thickness=${FULL_PARAMS.thickness}`));
});

test("buildArgs throws naming every missing param", () => {
  const partial = { face_a_length: 40 };
  assert.throws(() => buildArgs("/tmp/out.stl", partial), /hole_diameter/);
});

test("renderBracket shells out to openscad with the built args", async () => {
  let seenCmd, seenArgs;
  const exec = async (cmd, args) => {
    seenCmd = cmd;
    seenArgs = args;
  };
  const result = await renderBracket("/tmp/out.stl", FULL_PARAMS, {
    exec,
    template: new URL("../templates/l-bracket.scad", import.meta.url).pathname,
  });
  assert.equal(seenCmd, "openscad");
  assert.ok(seenArgs.includes("/tmp/out.stl"));
  assert.deepEqual(result, { outputPath: "/tmp/out.stl" });
});

test("renderBracket rejects when the template file doesn't exist", async () => {
  await assert.rejects(
    renderBracket("/tmp/out.stl", FULL_PARAMS, { exec: async () => {}, template: "/tmp/does-not-exist.scad" }),
    /Template not found/
  );
});

test("isOpenSCADAvailable returns false (not a throw) when the binary is missing", async () => {
  const exec = async () => {
    throw new OpenSCADNotFoundError();
  };
  assert.equal(await isOpenSCADAvailable({ exec }), false);
});

test("isOpenSCADAvailable returns true when the binary responds", async () => {
  const exec = async () => {};
  assert.equal(await isOpenSCADAvailable({ exec }), true);
});

test("real environment check (informational, not a failure): is openscad actually installed here?", async () => {
  const available = await isOpenSCADAvailable();
  console.log(`  [info] openscad on PATH: ${available}`);
  // Deliberately not asserting either way — this machine's brew cask is
  // Gatekeeper-disabled (see OpenSCADNotFoundError message), so "false" is
  // an expected, non-failing result here, not a bug.
});
