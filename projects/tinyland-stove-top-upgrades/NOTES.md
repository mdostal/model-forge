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

Uses multi-layer printing itself as the effect: a red (or orange) layer sits *underneath* a grey/black top layer. A physical shift — sliding, rotating, or a knob-actuated cam — moves an opaque layer aside (or rotates a windowed disc) to reveal the red layer beneath, simulating "the burner is on" with zero electronics.

Mechanism candidates to prototype:
- **Rotating disc**: a windowed grey disc over a solid red disc, twist the (fake) knob to align the window over the "burner" — like an iris or a old-style oven timer
- **Sliding shutter**: a thin grey slider with cutouts, pulled/pushed to reveal red circles beneath — simplest to print, needs a track/rail (reuse `lib/model-forge/joint.scad` ideas, or a simple dovetail channel)
- Advantage: unbreakable, no batteries ever needed, safe for a toddler; disadvantage: not actually lit, just color-reveal

## Option 3 — Lights AND sound, configurable

The full upgrade: LEDs per burner plus sound effects (sizzle/click/beep), with real configuration options (color choice, sound choice, on/off modes). Needs:
- A small microcontroller (attiny/ARM board, whatever's cheap and small enough to hide in the stove housing) — TBD which
- Speaker or small piezo buzzer
- Power + a real on/off switch (battery life matters for a toy)
- This is the "choose your own adventure" tier — write it up so someone can configure just lights, just sound, or both

## Open questions (unresolved, needs real measurement/decision before designing housings)

- Exact stock stove-top footprint and burner-hole positions — no measurements yet, need photos + calipers like the other Tiny Land parts
- Which microcontroller/LED/speaker parts are actually cheap+available for Option 3 — no parts research done yet
- Whether Option 2's mechanism should be a rotating disc or sliding shutter — needs a quick physical prototype of both to compare

## Status

- [ ] Measure the stock stove top (photos + calipers, same process as `../tinyland-playset-kitchen/`)
- [ ] Prototype Option 2's mechanism (cheapest to test, no electronics needed) — likely first real build here
- [ ] Parts research for Option 1 (LED + diffuser approach)
- [ ] Parts research for Option 3 (microcontroller + speaker options)
- [ ] Write up the three options as a real comparison doc once at least one is prototyped, for the eventual open-source release
