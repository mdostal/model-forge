# model-forge

The 3D **model** side of the maker stack — creating and owning models, separate from printing them. Sibling to (not part of) `video-utils` and `drone-hub`.

- **`../dostal-3d-printing`** = shop floor (slice, print, licensing log).
- **`model-forge`** (here) = where models are *made*: AI-3D, CAD, photo-to-3D, and the drone→house-model bridge.

The whole point: **own the models we print and sell.** Downloaded models are personal-use only; models we forge here are ours.

## Two lanes (match the tool to the part)

| Lane | For | Tools |
|---|---|---|
| 🐉 **Organic** | gnomes, dragons, creatures, art | Meshy Pro → Blender repair |
| ⚙️ **Functional** | brackets, organizers, snap-fits, enclosures | Onshape / Tinkercad (parametric CAD) |
| 📷 **Reverse-engineer** | replacing a real physical part | photo-to-3D (photogrammetry) or caliper→CAD |

> Don't AI-generate toleranced parts. A furniture bracket gets measured and CAD'd; a dragon gets generated.

## Layout

```
projects/
  furniture-brackets/   # first real project: replace worn furniture corner-brackets
    reference-photos/    the physical part, photographed
    NOTES.md             approach, measurements, licensing
pipeline/               # tools we build (photogrammetry, mesh-repair, batch prep)
docs/
  photo-to-3d.md        # the reverse-engineering workflow + tool comparison
  drone-to-model.md     # drone/floorplan → 3D house model (Dostal Aerial upsell)
```

## Why "build the tools" and not just buy the bracket

We could buy a bracket. The point is the **repeatable process** — photo/measure → model → print a real replacement — and building the glue that makes it fast. That capability is the product: it feeds the shop, and (per `drone-to-model.md`) it feeds Dostal Aerial.
