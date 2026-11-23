#!/usr/bin/env python3
"""preflight: the one command to run before anything goes to the printer.

  1. print-check on the model (retention, seat, printability) from its checks.yaml
  2. slice-check on every sliced plate (parts on the bed, plate type and bed temp,
     bounds and keep-out, stale slice, object count)

  python3 pipeline/preflight/preflight.py --checks projects/<name>/checks.yaml [--only text] \
      plate.gcode.3mf [...] [--sources part.stl ...] [--expect-objects N]

Either half can be skipped by leaving it out. Exit code 1 if anything FAILs.
"""
import argparse, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
PIPE = os.path.dirname(HERE)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("slices", nargs="*")
    ap.add_argument("--checks")
    ap.add_argument("--only")
    ap.add_argument("--sources", nargs="*", default=[])
    ap.add_argument("--expect-objects", type=int)
    ap.add_argument("--bed", default="Textured PEI Plate")
    a = ap.parse_args(argv)
    if not a.checks and not a.slices:
        ap.error("give --checks, slices, or both")
    results = []
    if a.checks:
        cmd = [sys.executable, f"{PIPE}/print-check/print_check.py", a.checks] + (["--only", a.only] if a.only else [])
        print(f"### model: {' '.join(cmd[1:])}", flush=True)
        results.append(("model", subprocess.call(cmd)))
    if a.slices:
        cmd = [sys.executable, f"{PIPE}/slice-check/slice_check.py", *a.slices, "--bed", a.bed]
        if a.sources: cmd += ["--sources", *a.sources]
        if a.expect_objects is not None: cmd += ["--expect-objects", str(a.expect_objects)]
        print(f"\n### slices: {len(a.slices)} file(s)", flush=True)
        results.append(("slices", subprocess.call(cmd)))
    bad = [n for n, rc in results if rc]
    print("\nPREFLIGHT " + ("FAIL: " + ", ".join(bad) if bad else "PASS: ready to print"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
