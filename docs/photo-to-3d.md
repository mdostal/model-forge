# Photo-to-3D & Reverse-Engineering Workflow

How we turn a real physical part (or a photo of one) into a printable model — and the quality levers once it's printing.

## Two honest paths — pick by part type

### 1. Functional / hard-surface part → **measure + CAD** (recommended)
For brackets, sinks, snap-fits, anything with holes/slots/tolerances. Photogrammetry is *bad* at clean flat faces and exact hole diameters. Faster and more accurate:
- Calipers on the real part → parametric model in **Onshape** (free, no revenue cap) or **Tinkercad** (dead simple).
- Photos = reference for proportion/shape only.
- This is the bracket + playset workflow. **Don't AI-generate these.**

### 2. Organic / complex-surface object → **photogrammetry (true photo-to-3D)**
For a sculpted, curvy, or irregular object where you can't just measure it:
- Capture 30–60 photos all around, even lighting, matte object (dust with powder if shiny).
- Tools to trial (this is what the Hive should build glue around): **RealityCapture** (now free for many uses), **Meshroom** (open source), **Polycam** (phone, easiest), or Apple **Object Capture**.
- Output mesh → **Blender + 3D Print Toolbox** to clean/repair → slice.
- Expect cleanup. Photogrammetry gives you *a* mesh, not a tolerance.

> Rule of thumb: if you'd reach for a caliper, use CAD. If you'd reach for a camera because it's un-measurable, use photogrammetry.

## Quality levers (when you want it smoother)

Cheapest → most effort:
1. **Smaller layer height on the current 0.4mm nozzle** — drop to 0.1mm layers in Studio. No hardware swap, just slower. Biggest smoothness-per-effort win.
2. **Smaller nozzle** — the **0.2mm** from the nozzle pack for fine detail/crisper walls (much slower; more clog-prone). We have the full hardened pack (0.2 / 0.4 default / 0.6 / 0.8 + the silicone sock). Swapping a nozzle = **re-run calibration in Studio** (flow/pressure advance) before printing.
3. **Bigger nozzle (0.6 / 0.8)** — the *opposite* goal: faster + stronger for chunky functional parts where looks don't matter (good for brackets).
4. **Post-processing** — sand the surface (internal bores too), or fill/prime/paint. For a hidden bracket this is overkill; for display it's the finisher.

**For the brackets/playset:** grey PLA, defaults (or even 0.6mm nozzle for speed/strength). Smoothness doesn't matter on a hidden structural part — function first, iterate fit.

## The loop
photo/measure → CAD or photogrammetry → repair (Blender) → slice (Bambu Studio) → print grey → test-fit → tweak → (optional) refine smoothness.
