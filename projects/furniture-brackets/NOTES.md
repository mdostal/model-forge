# Project: Furniture Corner-Brackets

First reverse-engineering job. Replace worn metal corner-brackets that join the wooden rails/legs (bed frame / table). Same process will repeat for **Clarabel's playset hole** (see `../playset-bracket/`).

## The part (from `reference-photos/`)

**Corrected 2026-09-10, third pass** — the hole dimensions and strip width below are the user's own direct numbers, given after two failed attempts at reading the caliper photos myself. Trust these over anything derived from photo OCR in this project.

- L-shaped **angle bracket**, two flat faces at ~90°, rounded (not sharp) bend. The two faces are **not equal length** — 21.7mm and 26mm.
- **One** face has an oval hole, **12mm long x 7mm wide**, sitting ~4mm from the part's outer edge on each side. The other face (the foot) has **no hole**.
- Strip width = 15mm (7mm hole width + 4mm margin on each side).
- Material: aged brass/bronze-toned metal, measured ~1.15mm thick (five caliper readings, 0.93-1.34mm) — doesn't match the original ~1.8mm verbal estimate; worth a real double-check.
- Print target: PLA, explicit test thicknesses of 1.75mm and 2mm (the user's own targets, not derived from native thickness).

Structured measurements now live in [`measurements.yaml`](measurements.yaml) / [`measurements-2mm.yaml`](measurements-2mm.yaml) — machine-readable, fed directly to `pipeline/measurement-intake`.

## Approach — CAD, not AI-generate
This is a toleranced hardware part → **measure + parametric CAD** (`pipeline/bracket-gen`, OpenSCAD), not Meshy. Photos are for reference/proportion only; the dimensions come from calipers.

### Measure

| Dim | Value | Notes |
|---|---|---|
| Face A length (foot, no hole) | 21.7 mm | measured (caliper) |
| Face B length (arm with hole) | 26.0 mm | measured (caliper) — the two faces are NOT equal |
| Strip width | 15.0 mm | derived: 7mm hole width + 4mm margin each side (user-confirmed) |
| Material thickness (native) | ~1.15 mm (0.93-1.34mm across 5 readings) | **Doesn't match the ~1.8mm verbal estimate — worth a real double-check.** Print targets (1.75mm / 2mm) are explicit choices, not derived from this |
| Hex hole ⌀ | n/a | This part has no separate hex-bolt hole |
| Oval hole length | 12 mm | user-confirmed |
| Oval hole width | 7 mm | user-confirmed |
| Hole-to-edge margin | ~4 mm | user-confirmed, each side |
| Slot offset from bend | 16 mm | estimate — positions the hole ~4mm from the tip; not a direct caliper reading |
| Bend/inner radius | not measured | Template computes a safe default from thickness |
| Bolt size | see screw-thread-guide.md | Closest-thread replacement found is half the length of the original — new screws likely needed |

> **PLA is weaker than metal** — thicken the part or add a fillet at the bend, or print in PETG. Test prints here use explicit 1.75mm and 2mm targets rather than an auto-derived multiplier, since the true native thickness turned out to be thinner than first estimated.

## Screws

Original screw's closest available replacement (by thread) is half the original's length — new screws are likely needed, and the exact thread should be double-checked before ordering. See [`screw-thread-guide.md`](screw-thread-guide.md).

## Licensing
Self-modeled = **ours**. Once the STL is validated, it can be committed under `dostal-3d-printing/owned/` and is fair game to sell.

## Status
- [x] Calipers on the real part → table filled, corrected twice (2026-09-10) — hole dimensions and strip width are user-confirmed direct numbers, not photo re-reads
- [ ] Model in CAD — `pipeline/bracket-gen` + `pipeline/measurement-intake` ready; real STL render pending OpenSCAD install on the dev machine
- [ ] Slice grey PLA, print, test-fit — try `measurements.yaml` (1.75mm) first
- [ ] Iterate thickness/fit — `measurements-2mm.yaml` ready if 1.75mm is too weak
- [ ] Double-check native thickness (measured ~1.15mm vs. ~1.8mm verbal estimate)
- [ ] Confirm slot_offset with a real measurement (currently an estimate)
- [ ] Sort out replacement screws — see screw-thread-guide.md
