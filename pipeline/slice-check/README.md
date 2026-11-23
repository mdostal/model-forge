# slice-check

Reads a sliced Bambu `.gcode.3mf` (or plain `.gcode`) and fails loudly on mistakes that ruin a print however good the model is. It was built after the bunk storage trays failed on 2026-11-19. The small tray was set 10 mm above the bed beside a taller one, so it printed into thin air and spaghettied. print-check passed the model, and the plate was the problem.

```
python3 pipeline/slice-check/slice_check.py plate.gcode.3mf [...] [--bed "Textured PEI Plate"] [--sources a.stl ...] [--expect-objects N] [--json r.json]
python3 -m pytest pipeline/slice-check -q
```

It needs numpy and scipy. The exit code is 1 on any FAIL.

| Check | What fails |
|---|---|
| `floating` | A new patch of print that has nothing under it on the layer below and isn't on the bed. This catches a part placed above the bed and a whole region starting in mid-air. Bridges and ordinary overhangs pass, because their ends sit on the layer below. Spots under 4 mm² are ignored. |
| `bed` | The plate type isn't the expected one (Textured PEI by default; `--bed ''` skips this), or PLA's bed temperature for that plate is outside 45–65 °C. |
| `bounds` | A printed move is off the printable area, the print is taller than the printer allows, or the first layer enters the X1C's front-left keep-out. |
| `stale` | With `--sources`: a source STL or `.scad` changed after the slice was made, so the file opened in Studio is out of date. |
| `objects` | With `--expect-objects`: the plate holds the wrong number of objects. |
| `summary` | INFO only: filaments, colors, grams, time, swaps and supports. |

The start and end G-code and the filament-change flush blocks are left out, so purge lines and the poop chute don't count.

## preflight: run everything

`pipeline/preflight/preflight.py` runs print-check on the model and slice-check on the plates in one go, and ends with `PREFLIGHT PASS` or `PREFLIGHT FAIL`:

```
python3 pipeline/preflight/preflight.py --checks projects/bunk-accessories/checks.yaml --only "storage tray" \
    trays-pink.gcode.3mf --sources output/storage-tray-small.stl output/storage-tray-large.stl --expect-objects 2
```

Run it before any plate is opened in Studio for printing.

Not checked: wet filament, the AMS feed, the plate's cleanliness, or a part being knocked loose while it prints. Those happen at the printer, not in the file.
