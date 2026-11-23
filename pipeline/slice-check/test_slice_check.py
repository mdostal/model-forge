"""Tests for slice-check on small synthetic gcode (no slicer needed)."""
import os, sys, time
sys.path.insert(0, os.path.dirname(__file__))
import slice_check as sc

HEAD = """; curr_bed_type = {bed}
; textured_plate_temp = {temp}
; cool_plate_temp = 35
; filament_type = PLA
; printable_area = 0x0,256x0,256x256,0x256
; printable_height = 250
; bed_exclude_area = 0x0,18x0,18x28,0x28
; MACHINE_START_GCODE_END
M83
"""


def square(x, y, w, z):
    s = f"; Z_HEIGHT: {z}\n; FEATURE: Outer wall\nG1 X{x} Y{y} F3000\n"
    for px, py in ((x + w, y), (x + w, y + w), (x, y + w), (x, y)):
        s += f"G1 X{px} Y{py} E1\n"
    return s


def gcode(tmp_path, parts, bed="Textured PEI Plate", temp=55, top=20):
    """parts: list of (x, y, w, z_start)."""
    body, z = "", 0.2
    while z <= top + 1e-6:
        for x, y, w, z0 in parts:
            if z >= z0 - 1e-6:
                body += square(x, y, w, round(z, 2))
        z += 0.2
    p = tmp_path / "plate.gcode"
    p.write_text(HEAD.format(bed=bed, temp=temp) + body + "; MACHINE_END_GCODE_START\n")
    return str(p)


def run(path, *extra):
    return sc.check(path, sc.argparse.Namespace(bed="Textured PEI Plate", sources=list(extra), expect_objects=None))


def levels(rep, check):
    return [r["level"] for r in rep.rows if r["check"] == check]


def test_two_parts_on_bed_pass(tmp_path):
    rep = run(gcode(tmp_path, [(50, 50, 30, 0.2), (120, 50, 30, 0.2)]))
    assert not rep.failed, rep.rows


def test_part_starting_in_air_fails(tmp_path):
    # the 2026-11-19 tray: the second part's first layer is 10 mm up
    rep = run(gcode(tmp_path, [(50, 50, 30, 0.2), (120, 50, 30, 10.2)]))
    assert "FAIL" in levels(rep, "floating")


def test_off_plate_fails(tmp_path):
    assert "FAIL" in levels(run(gcode(tmp_path, [(240, 50, 30, 0.2)])), "bounds")


def test_keep_out_fails(tmp_path):
    assert "FAIL" in levels(run(gcode(tmp_path, [(2, 2, 10, 0.2)])), "bounds")


def test_wrong_plate_fails(tmp_path):
    assert "FAIL" in levels(run(gcode(tmp_path, [(50, 50, 30, 0.2)], bed="Cool Plate")), "bed")


def test_cold_pla_bed_fails(tmp_path):
    assert "FAIL" in levels(run(gcode(tmp_path, [(50, 50, 30, 0.2)], temp=35)), "bed")


def test_stale_source_fails(tmp_path):
    g = gcode(tmp_path, [(50, 50, 30, 0.2)])
    src = tmp_path / "part.stl"; src.write_text("x")
    t = os.path.getmtime(g); os.utime(src, (t + 60, t + 60))
    assert "FAIL" in levels(run(g, str(src)), "stale")
    os.utime(src, (t - 60, t - 60))
    assert "PASS" in levels(run(g, str(src)), "stale")


def _layers(path, runs):
    """runs: list of (z_from, z_to, square) with square = (x, y, w); layers with nothing are left out, as a slicer's gap layer is."""
    body = HEAD.format(bed="Textured PEI Plate", temp=55)
    for z0, z1, sq in runs:
        z = z0
        while z <= z1 + 1e-6:
            body += square(*sq, round(z, 2)); z += 0.2
    path.write_text(body + "; MACHINE_END_GCODE_START\n")
    return str(path)


def test_one_layer_support_gap_passes(tmp_path):
    # support resting on a part's top starts one layer up (the slicer's support bottom z gap): not floating
    g = _layers(tmp_path / "gap.gcode", [(0.2, 20.0, (50, 50, 30)), (20.4, 22.0, (50, 50, 30))])
    assert "FAIL" not in levels(run(g), "floating")


def test_two_layer_gap_fails(tmp_path):
    g = _layers(tmp_path / "gap2.gcode", [(0.2, 20.0, (50, 50, 30)), (20.6, 22.0, (50, 50, 30))])
    assert "FAIL" in levels(run(g), "floating")
