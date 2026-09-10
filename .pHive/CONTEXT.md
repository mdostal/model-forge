# Project CONTEXT

The model-*making* half of the maker stack — an open-source framework/library for turning photos, measurements, and prompts into print-ready models. Sibling to DT Forge (`../dostal-3d-printing`), which is the full product that wraps this library with its own UI.

## Terminology

- **Organic lane** — creatures, art, gnomes, dragons. Tool: Meshy Pro (AI generation) → Blender repair.
- **Functional lane** — brackets, organizers, snap-fits, enclosures. Tool: Onshape/Tinkercad (parametric CAD). Never AI-generate a toleranced part.
- **Reverse-engineer lane** — replacing a real physical part. Tool: photo-to-3D (photogrammetry) or caliper → CAD.
- **Milestone 0-4** — the ROADMAP.md backlog, explicitly ordered: M0 validate the manual loop by hand (no tools yet) → M1 measure→model assist (`bracket-gen` + measurement-intake CLI) → M2 photogrammetry glue (`scan-clean`) → M3 Meshy→print wrapper with licensing stamp → M4 drone→house model (Dostal Aerial upsell). M1 depends on M0 being validated first — don't skip ahead.
- **`bracket-gen`** — planned parametric template (Onshape FeatureScript or OpenSCAD) for L-brackets/angle-plates: feed thickness, face lengths, hole ⌀, slot dims → get a printable STL. Not built yet.
- **`projects/<name>/NOTES.md`** — per-job record: the part being reverse-engineered, approach, a measurement table (calipers, not estimates), and licensing status.
- **Owned models** — self-modeled or commercially-licensed files, safe to sell. Committed under `dostal-3d-printing/owned/` once validated (not in this repo).
- **DT Forge** — the sibling app repo (`../dostal-3d-printing`) that owns the showcase site, the BYOK app shell, and (eventually) the chat "studio" that calls into this library's tools.

## Key paths

- `ROADMAP.md` — the Hive-plannable backlog; read this before proposing new scope.
- `projects/furniture-brackets/NOTES.md` — first reverse-engineering job; has reference photos, measurement table still blank.
- `projects/playset-bracket/NOTES.md` — second job, queued to run the same loop after furniture-brackets.
- `docs/photo-to-3d.md`, `docs/drone-to-model.md` — workflow write-ups for the reverse-engineer and drone lanes.
- `pipeline/` — reusable tools land here as they're built (currently empty besides a README).

## Conventions

- Match the tool to the part: CAD for anything toleranced/functional, AI/photogrammetry for organic/artistic. Never the reverse.
- Every new reverse-engineering job gets its own `projects/<kebab-case-name>/` with `reference-photos/` and a `NOTES.md` measurement table.
- Solo-dad time is the bottleneck (ROADMAP.md) — a new tool has to *save* setup time, not add ceremony, or it doesn't ship.

## Canonical references

- [README.md](../README.md) — two-lane tool matching, layout, why-build-tools rationale.
- [ROADMAP.md](../ROADMAP.md) — the milestone backlog and guiding constraints.
- `.pHive/project-profile.yaml` → `north_star` — the framework-vs-app boundary with DT Forge, clarified at kickoff (2026-09-10).
