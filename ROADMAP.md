# model-forge — Roadmap / Tool Backlog

This is the **Hive target**: the tools to build so the photo/measure → model → print loop is fast and repeatable. Scoped as stories a Hive plan can pick up. Start small; each earns its place by making a real print easier.

## Guiding constraints
- **Own the models** (personal-use downloads never enter the sellable path).
- Match tool to part: CAD for functional, AI/photogrammetry for organic.
- Solo-dad time is the bottleneck — tools must *save* setup time, not add ceremony.

## Milestone 0 — validate the loop by hand (no tools yet)
- [ ] Furniture bracket: caliper → CAD → grey PLA → test-fit (proves the manual loop).
- [ ] Playset hole: same loop again. If both fit, the loop is real → automate it.

## Milestone 1 — the "measure → model" assist (functional lane)
- [ ] **`bracket-gen`**: parametric template (Onshape FeatureScript or OpenSCAD) for L-brackets/angle-plates — feed thickness, face lengths, hole ⌀, slot dims → get a printable STL. Turns each new bracket into filling in numbers.
- [ ] **Measurement intake**: a simple form/CLI that takes the NOTES.md measurement table and emits the OpenSCAD params.
- [ ] **PLA-strength helper**: auto-thicken + fillet rules so metal→PLA parts don't snap.

## Milestone 2 — photogrammetry glue (organic lane)
- [ ] Evaluate RealityCapture vs Meshroom vs Polycam vs Apple Object Capture on one real object; pick one.
- [ ] **`scan-clean`**: photogrammetry mesh → Blender 3D-Print-Toolbox repair → watertight STL, scripted.
- [ ] Capture guide (photo count, lighting, matte-spray) baked into the pipeline.

## Milestone 3 — Meshy → print (creatures)
- [ ] Meshy Pro API wrapper: prompt/image → model → auto-repair → hand to Bambu Studio.
- [ ] Licensing stamp: every generated model gets a provenance record (safe-to-sell).

## Milestone 4 — drone → house model (Aerial upsell)
- [ ] See `docs/drone-to-model.md`. Exterior photogrammetry + floor-plan wall-extrude, aligned. Prado house = proof-of-concept.

## Notes for the Hive
- This repo is **modeling R&D**, not the shop floor (`../dostal-3d-printing`) and not the printer.
- Prefer open/free tooling (Onshape free, OpenSCAD, Blender, Meshroom) over revenue-capped traps (Fusion 360 free caps at <$1k/yr).
- Ship the smallest thing that removes a manual step; validate against a real print each milestone.
