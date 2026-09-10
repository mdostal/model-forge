# Project: Furniture Corner-Brackets

First reverse-engineering job. Replace worn metal corner-brackets that join the wooden rails/legs (bed frame / table). Same process will repeat for **Clarabel's playset hole** (see `../playset-bracket/`).

## The part (from `reference-photos/`)

**Corrected 2026-09-10** from the second photo drop (14 photos, real caliper measurements) — simpler than first assumed:

- L-shaped **angle bracket**, two flat faces at ~90°, rounded (not sharp) bend.
- **One** face has a large **oval/slot hole**. The other face (the foot) has **no hole** — there is no separate hex-bolt hole on this part.
- Material: aged brass/bronze-toned metal, ~1.8mm thick, single sample (light variance/bend from age/use).
- Print target: PLA (first attempt near-native thickness; PETG or thicker PLA as a strengthen-and-retest fallback).

Structured measurements now live in [`measurements.yaml`](measurements.yaml) / [`measurements-2mm.yaml`](measurements-2mm.yaml) — machine-readable, fed directly to `pipeline/measurement-intake`.

## Approach — CAD, not AI-generate
This is a toleranced hardware part → **measure + parametric CAD** (`pipeline/bracket-gen`, OpenSCAD), not Meshy. Photos are for reference/proportion only; the dimensions come from calipers.

### Measure

| Dim | Value | Notes |
|---|---|---|
| Face A length | 26 mm | "26mm per bracket direction" — both faces treated as equal |
| Face B length | 26 mm | |
| Material thickness | 1.8 mm (measured) | Printing at 1.75mm first (near-native), 2mm as a strengthen fallback — see `measurements-2mm.yaml` |
| Hex hole ⌀ | n/a | This part has no separate hex-bolt hole — corrected from the original speculative description above |
| Slot (oval hole) | ~15mm long, 4-7mm wide | Described as narrower (~4mm) in the middle, wider (~7mm) at the ends — possibly a keyhole shape rather than a plain stadium slot. First print approximates with a constant 5.5mm width (template limitation); revisit if the screw doesn't seat right |
| Bend/inner radius | not measured | Template computes a safe default from thickness |
| Bolt size | see screw-thread-guide.md | Closest-thread replacement found is half the length of the original — new screws likely needed |
| Width (strip width) | 12 mm | **ASSUMPTION** — not explicitly measured in this drop, estimated from photo proportions. Needs a real caliper reading before a final print. |

> **PLA is weaker than metal** — thicken the part ~1.5-2x and add a fillet at the bend, or print in PETG. First attempt here deliberately skips the auto-bump to test near-native thickness; `measurements-2mm.yaml` is the strengthen iteration if needed.

## Screws

Original screw's closest available replacement (by thread) is half the original's length — new screws are likely needed, and the exact thread should be double-checked before ordering. See [`screw-thread-guide.md`](screw-thread-guide.md).

## Licensing
Self-modeled = **ours**. Once the STL is validated, it can be committed under `dostal-3d-printing/owned/` and is fair game to sell.

## Status
- [x] Calipers on the real part → table filled (2026-09-10), two open assumptions flagged (strip width, slot shape)
- [ ] Model in CAD — `pipeline/bracket-gen` + `pipeline/measurement-intake` ready; real STL render pending OpenSCAD install on the dev machine
- [ ] Slice grey PLA, print, test-fit — try `measurements.yaml` (1.75mm) first
- [ ] Iterate thickness/fit — `measurements-2mm.yaml` ready if 1.75mm is too weak
- [ ] Confirm strip width with a real measurement (currently an assumption)
- [ ] Sort out replacement screws — see screw-thread-guide.md
