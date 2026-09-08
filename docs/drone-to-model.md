# Drone / Floorplan → 3D House Model

The gimmicky-but-real sales hook: turn a drone flight (+ the floor plan) of a property into a **3D model of the house** — another deliverable stacked onto the Dostal Aerial property-intelligence report.

## Why it fits
- We already have the drone-hub voxel/Minecraft exporter (LiDAR → DEM → `.schem`) proven for terrain.
- A *house* model is the next tier up: exterior massing from drone photogrammetry + interior layout from the floor plan.
- Sells as a "see your property in 3D" add-on — memorable, shareable, differentiates the aerial report.

## Two inputs, two techniques
1. **Exterior shell** → drone photogrammetry (orbit the structure) → mesh in RealityCapture/Meshroom → clean in Blender.
2. **Interior layout** → the floor plan (we have the old-house plan) → extrude walls to scale (CAD or Blender) → align to the exterior shell.

## First test subject
**The old Prado house** — we have the floor plan and drone footage already. Build it as the proof-of-concept, then it becomes an Aerial demo asset.
> ⚠️ Reuse the drone footage rules: any clip with Clarabel on camera is cut before anything public (per prado-drone-footage rules).

## Where it connects
- Feeds **`drone-hub`** / Dostal Aerial as a productized upsell (not built here — this repo is the modeling R&D).
- Shares the photogrammetry pipeline with `photo-to-3d.md`.
