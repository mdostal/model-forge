# Design Discussion — bracket-gen-milestone-1

## §0 Prelude

**NORTH STAR** (`.pHive/project-profile.yaml`, kickoff 2026-09-10): open-source framework for photo/measure → model → print, own docs/showcase page, DT Forge wraps it as the full product. Solo-dad time is the bottleneck — tools must save setup time, not add ceremony.

No prior KG decisions (fresh repo, first epic).

## §1 Goal

Ship ROADMAP.md's Milestone 1 ("the measure → model assist, functional lane"): a parametric bracket generator, a measurement-intake CLI that feeds it, and PLA-strength rules — so a new toleranced part becomes "fill in numbers" instead of a from-scratch CAD job.

## §2 Proposed Approach

Three stories, matching ROADMAP.md's own Milestone 1 breakdown:

1. **bracket-gen** — OpenSCAD parametric template for L-brackets/angle-plates: thickness, face lengths, hole ⌀, slot dimensions → STL. OpenSCAD chosen over Onshape FeatureScript because it's free/open (matches ROADMAP.md's "prefer open/free tooling" constraint), scriptable (no GUI dependency for CI/testing), and its CLI (`openscad --export-format stl`) is exactly what a measurement-intake CLI needs to drive.
2. **measurement-intake** — CLI that reads a `NOTES.md`-style measurement table (or a small JSON/YAML equivalent) and emits the OpenSCAD parameter file bracket-gen consumes.
3. **pla-strength-helper** — auto-thicken + fillet rules folded into bracket-gen's parameters (not a separate tool): metal-sourced dimensions get bumped for PLA before the STL is generated, per README's own "PLA is weaker than metal" note.

**What this epic does NOT do:** generate a real STL for the actual furniture-bracket part. `projects/furniture-brackets/NOTES.md`'s measurement table is still blank — someone needs calipers on the real part first (ROADMAP.md's Milestone 0, still open). This epic builds and unit-tests the tooling against synthetic dimensions; running it for real is a follow-up once measurements exist, flagged the same way `printer-agent-link` was flagged in the DT Forge epic.

## §3 Risks

| Severity | Risk | Mitigation |
|---|---|---|
| Medium | OpenSCAD must be installed to actually render STL — CI/dev environment dependency | Check for the binary at story implementation time; degrade to a clear "install OpenSCAD" error rather than a cryptic failure |
| Low | Fillet/thickness heuristics are a guess without a real print to test-fit | Document the heuristic's source (README's own "1.5-2x thickness" note) and flag it as tunable, not authoritative, until a real print validates it |
| Low | Building tooling before Milestone 0 completes risks the parameters being wrong for the real part | Tooling is generic (any L-bracket dimensions), not furniture-bracket-specific — still useful once measurements land, not wasted work |

## §4 Dependencies

- bracket-gen requires OpenSCAD on the machine running it.
- measurement-intake depends on bracket-gen's parameter schema (build bracket-gen first, or agree the schema up front).
- pla-strength-helper is folded into bracket-gen's own parameter derivation, not a separate dependency.

## §5 Open Questions

1. **OpenSCAD vs Onshape FeatureScript** — resolved above (OpenSCAD, for CI-testability and the open/free constraint). Flag if you'd rather standardize on Onshape.
2. **Measurement input format** — NOTES.md's markdown table directly, or a small structured file (JSON/YAML) alongside it? Recommendation: structured file (`measurements.yaml` per project), since parsing a markdown table with blank "___" cells is fragile — NOTES.md stays the human-readable record, the YAML is what the CLI actually reads.

## §6 Scale Assessment

**Medium** — three related but independently-testable stories, no structured outline needed. Condensed H/V plan, same rolling-wave posture as the DT Forge epic.
