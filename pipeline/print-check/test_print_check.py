"""print-check catches the two mistakes found on the first bunk cup holder
(2026-11-12): a mount whose stop is on the wrong end, so a downward load
slides it off, and a funnel floor a glass wedges in instead of standing on.

Run: python3 -m pytest pipeline/print-check -q   (needs openscad on PATH)
"""
import json, os, sys, textwrap

sys.path.insert(0, os.path.dirname(__file__))
import print_check

SCAD = textwrap.dedent("""
    part = "peg";
    stop = "roof";   // roof: sleeve capped above the peg; floor: capped below it
    floor_kind = "flat";
    module peg() { translate([-5, -5, 0]) cube([10, 10, 40]); }
    module sleeve() {
      difference() {
        translate([-8, -8, stop == "roof" ? 10 : -3]) cube([16, 16, 33]);
        translate([-5.3, -5.3, stop == "roof" ? 9 : -0.01]) cube([10.6, 10.6, 31.01]);
      }
    }
    module cup() {
      difference() {
        cylinder(r = 30, h = 40, $fn = 64);
        if (floor_kind == "flat") translate([0, 0, 2]) cylinder(r = 28, h = 40, $fn = 64);
        else { translate([0, 0, 2]) cylinder(r1 = 2, r2 = 28, h = 26, $fn = 64);
               translate([0, 0, 28]) cylinder(r = 28, h = 13, $fn = 64); }
      }
    }
    if (part == "peg") peg(); else if (part == "sleeve") sleeve(); else cup();
""")


def run(tmp_path, cfg):
    (tmp_path / "t.scad").write_text(SCAD)
    (tmp_path / "checks.yaml").write_text(json.dumps(cfg))
    out = tmp_path / "r.json"
    code = print_check.main([str(tmp_path / "checks.yaml"), "--json", str(out)])
    return code, json.loads(out.read_text())


def retention(stop):
    return {"retention": [{"name": stop, "fixed": [{"scad": "t.scad", "part": "peg"}],
                           "moving": {"scad": "t.scad", "part": "sleeve", "define": {"stop": stop}},
                           "loads": ["-z"], "install": "+z" if stop == "roof" else "-z",
                           "allow_free": ["-z" if stop == "roof" else "+z"]}]}


def test_floor_stop_fails_under_a_downward_load(tmp_path):
    code, rows = run(tmp_path, retention("floor"))
    assert code == 1
    assert any(r["level"] == "FAIL" and "slides off along -z" in r["msg"] for r in rows)


def test_roof_stop_holds_a_downward_load(tmp_path):
    code, rows = run(tmp_path, retention("roof"))
    assert code == 0, rows
    assert any(r["level"] == "PASS" and "holds against -z" in r["msg"] for r in rows)


def seat(kind):
    return {"seat": [{"name": kind, "part": {"scad": "t.scad", "part": "cup", "define": {"floor_kind": kind}},
                      "at": [0, 0], "object": {"base_d": 40, "h": 60}}]}


def test_funnel_floor_is_called_out(tmp_path):
    code, rows = run(tmp_path, seat("funnel"))
    assert code == 1
    assert any(r["level"] == "FAIL" and "wedged" in r["msg"] for r in rows)


def test_flat_floor_seats_the_cup(tmp_path):
    code, rows = run(tmp_path, seat("flat"))
    assert code == 0, rows
    r = rows[0]
    assert "sits flat" in r["msg"] and abs(r["data"]["rest_z"] - 2) < 0.1
