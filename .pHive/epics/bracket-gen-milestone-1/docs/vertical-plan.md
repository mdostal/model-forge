# Vertical Plan — bracket-gen-milestone-1

1. **bracket-gen** — `openscad --export-format stl` renders a valid L-bracket STL from a parameter file. Working state: hand-write a params file, get a printable STL.
2. **measurement-intake** — CLI turns a project's `measurements.yaml` into bracket-gen's params file, including the PLA-strength bump. Working state: the whole chain runs end to end on synthetic dimensions.

Both stories ship together as one working loop (measurements.yaml → params → STL); pla-strength-helper is folded into measurement-intake's param derivation per design-discussion §2, not a third story.

Real furniture-bracket generation is explicitly deferred — `projects/furniture-brackets/measurements.yaml` doesn't exist until someone takes calipers to the real part (ROADMAP.md Milestone 0).
