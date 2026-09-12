# Project: Stove Top Upgrades

Beginning info, captured 2026-09-11 — nothing built yet. Goal: replace the Tiny Land stove top with something nicer than stock, offered as a family of options so other makers can pick their own complexity/budget level once this is open-sourced (see `../tinyland-playset-kitchen/` — same open-source plan applies here).

The stock stove top has a lit "burner" effect. Three upgrade directions, roughly ordered by build complexity:

## Option 1 — Nicer lights (same idea, better execution)

Same concept as stock (lit burner indicators) but done better: brighter/more even diffusion, better color, cleaner light-pipe geometry so the light source itself stays hidden. Needs:
- An LED (or small LED strip) per burner, or a shared light source with light-pipes to each burner
- A diffuser layer — likely a translucent/white filament layer over a colored (red/orange) layer, or a dedicated frosted insert
- Power: batteries (simplest) vs. USB — needs a decision before designing the housing
- This is the most "electronics" of the three simple options short of Option 3

## Option 2 — Purely mechanical (no electronics at all)

**Goal mechanism, confirmed 2026-09-11: a shift lens.** The moving part itself is a translucent/tinted lens (not an opaque shutter with a plain cutout) that physically shifts into alignment over a red/orange layer underneath — the lens is what does the "revealing," giving the burner a lit/glassy look purely through material and motion, with zero electronics. This supersedes the earlier "rotating disc vs. sliding shutter" framing below as an either/or — a shift lens is specifically a *sliding*, translucent element, not a disc.

Working idea:
- **Base layer**: solid red/orange, printed first, stays fixed
- **Lens layer**: a translucent or tinted (red/amber) piece — could be a separate resin-clear insert, or just a thin printed shell over the red layer that reads as "glowing" once shifted into place — slides laterally to align over the burner position
- Needs a track/rail so the lens shifts predictably and stays captured (reuse `lib/model-forge/joint.scad`'s dovetail idea, or a simple channel — the shift lens moves in ONE axis, so this is a simpler case than a full 2-axis snap-fit)
- Advantage: unbreakable, no batteries ever needed, safe for a toddler; the "lens" framing is what makes it look like it's actually lit rather than just a color-reveal gimmick

## Option 3 — Lights AND sound, configurable

The full upgrade: LEDs per burner plus sound effects (sizzle/click/beep), with real configuration options (color choice, sound choice, on/off modes). Needs:
- A small microcontroller (attiny/ARM board, whatever's cheap and small enough to hide in the stove housing) — TBD which
- Speaker or small piezo buzzer
- Power + a real on/off switch (battery life matters for a toy)
- This is the "choose your own adventure" tier — write it up so someone can configure just lights, just sound, or both

## Open questions (unresolved, needs real measurement/decision before designing housings)

- Exact stock stove-top footprint and burner-hole positions — no measurements yet, need photos + calipers like the other Tiny Land parts
- Which microcontroller/LED/speaker parts are actually cheap+available for Option 3 — no parts research done yet
- Whether the lens layer is a separate translucent-filament insert or a single-print thin-shell effect — needs a quick print test to see which reads as "lit" better

## Status

- [ ] Measure the stock stove top (photos + calipers, same process as `../tinyland-playset-kitchen/`)
- [ ] Prototype Option 2's shift lens (cheapest to test, no electronics needed) — likely first real build here
- [ ] Parts research for Option 1 (LED + diffuser approach)
- [ ] Parts research for Option 3 (microcontroller + speaker options)
- [ ] Write up the three options as a real comparison doc once at least one is prototyped, for the eventual open-source release
