# Project: Furniture Corner-Brackets

First reverse-engineering job. Replace worn metal corner-brackets that join the wooden rails/legs (bed frame / table). Same process will repeat for **Clarabel's playset hole** (see `../playset-bracket/`).

## The part (from `reference-photos/`)
- L-shaped **angle bracket**, two flat faces at ~90°.
- One face has a **countersunk hex-bolt hole** (Allen/hex socket screw).
- Other face has an **oblong adjustment slot** (lets the leg position shift).
- Material now: brass/steel. Print target: PLA/PETG grey (functional, hidden — smoothness doesn't matter here).

## Approach — CAD, not AI-generate
This is a toleranced hardware part → **measure + parametric CAD** (Onshape/Tinkercad), not Meshy. Photos are for reference/proportion only; the dimensions come from calipers.

### Measure (drop real numbers in here)
| Dim | Value | Notes |
|---|---|---|
| Face A length | ___ mm | |
| Face B length | ___ mm | |
| Material thickness | ___ mm | drives strength — bump for PLA |
| Hex hole ⌀ | ___ mm | + countersink angle |
| Slot length × width | ___ × ___ mm | |
| Bend/inner radius | ___ mm | |
| Bolt size | M__ | measure the screw |

> **PLA is weaker than metal** — thicken the part ~1.5–2× and add a fillet at the bend, or print in PETG. It's a first test print, so cheap to iterate.

## Licensing
Self-modeled = **ours**. Once the STL is validated, it can be committed under `dostal-3d-printing/owned/` and is fair game to sell.

## Status
- [ ] Calipers on the real part → fill the table
- [ ] Model in CAD
- [ ] Slice grey PLA, print, test-fit
- [ ] Iterate thickness/fit
