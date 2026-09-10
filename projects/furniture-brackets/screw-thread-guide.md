# Screw Thread ID Guide — furniture-brackets

Your situation (from the 2026-09-10 photo drop): you have the **original screw** (aged, hex socket cap) and a **replacement candidate** (bright A2 stainless, hex socket cap, marked `A2` on the head) that's the closest thread match you could find — but it's about **half the length** of the original. This guide is how to lock in the exact thread spec so you can order the right length, rather than guessing again.

## The four numbers that fully specify a machine screw

A metric hex socket cap screw (SHCS) is fully described by four numbers: **M[diameter] x [pitch], [length]mm, [hex socket size]**. Example: `M4 x 0.7, 12mm, 3mm hex`. Get these four and any hardware supplier can match it exactly.

### 1. Diameter (the "M" number)

Measure the **major diameter** — the widest point across the threads, not the smooth shank if there is one. Calipers, jaws closed across the threads at their widest.

Common furniture-hardware sizes and their standard (coarse) pitch:

| Nominal | Measured diameter | Standard pitch |
|---|---|---|
| M3 | ~3.0mm | 0.5mm |
| M4 | ~4.0mm | 0.7mm |
| M5 | ~5.0mm | 0.8mm |
| M6 | ~6.0mm | 1.0mm |

Round your caliper reading to the nearest whole mm — ±0.1-0.2mm is normal manufacturing tolerance, real threads never read exactly 4.00mm.

### 2. Pitch (thread spacing)

Pitch is the distance between two adjacent thread peaks, in mm. Two ways to get it without a thread pitch gauge:

- **Pitch gauge** (cheap, ~$8 for a set): a fan of blades, each stamped with a pitch value. Try blades against the threads until one seats flush with no light showing through — that's your pitch.
- **Manual count method** (no tool needed): lay the screw against a ruler, measure a 10mm span along the threaded shaft, count how many complete thread peaks fall in that span. `pitch = 10 / count`. E.g. 14 peaks in 10mm → pitch ≈ 0.71mm → round to the standard 0.7mm (M4).

If your diameter measurement already points to a standard size (table above), the pitch is very likely that size's standard coarse pitch — furniture hardware almost never uses fine-pitch threads. Use the count method as a sanity check, not a from-scratch measurement.

### 3. Length

Measure from **directly under the head** to the tip — for a socket cap screw that's the flat underside of the head, not the top. Head height is never part of the stated length. This is the number you already know needs to change (original is ~2x your replacement).

### 4. Hex socket size (drive size)

The Allen-key size that fits the socket. Standard pairings:

| Screw size | Hex socket |
|---|---|
| M3 | 2.5mm |
| M4 | 3mm |
| M5 | 4mm |
| M6 | 5mm |

Confirm with a hex key set — try keys until one seats fully in the socket with no wobble.

## Your comparison

Fill this in with both screws side by side:

| | Original (aged) | Replacement (A2 stainless) |
|---|---|---|
| Diameter | ___ mm | ___ mm |
| Pitch | ___ mm | ___ mm |
| Length (under head to tip) | ___ mm | ___ mm |
| Hex socket size | ___ mm | ___ mm |
| Head diameter | ___ mm | ___ mm |

If diameter, pitch, and hex socket all match between the two, you've already found the right thread — the replacement candidate confirms it. You just need the same spec (`M__ x __`) in the **original's length**, not the replacement's.

## Where to order once you have the spec

- **McMaster-Carr** — sells metric SHCS by exact length in 1mm+ increments, A2/A4 stainless available, fastest way to get an exact match once you know `M[x] x [pitch], [length]mm`.
- **Amazon** — search `M[x] x [pitch] socket head cap screw [length]mm stainless` — multi-packs, works fine for a one-off repair.
- **Local hardware store** — bring both screws; most stores with a loose hex-bolt bin let you match by eye against your pitch-gauge reading. Fastest if you don't want to wait on shipping.

## Notes

- The replacement's `A2` marking is a real stainless steel grade stamp (A2 = 18-8 / 304-equivalent stainless) — a legitimate quality screw, it's just the wrong length for this job.
- Don't assume the original and replacement share a pitch just because they look alike — confirm with the count method or a gauge before ordering; a mismatched pitch will cross-thread and strip the bracket's hole.
