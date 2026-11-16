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


LEDGE_SCAD = textwrap.dedent("""
    reach = 2;   // how far the shelf sticks out past the post
    held = 0;     // 1: a second post holds the shelf's far end, so it's a bridge
    cube([10, 4, 30]);
    translate([0, -reach, 30]) cube([10, 4 + reach, 3]);
    if (held > 0) translate([0, -reach - 4, 0]) cube([10, 4, 33]);
""")


def ledge(tmp_path, define):
    (tmp_path / "l.scad").write_text(LEDGE_SCAD)
    (tmp_path / "checks.yaml").write_text(json.dumps({"printability": [{"name": "shelf", "part": {"scad": "l.scad", "define": define}}]}))
    out = tmp_path / "r.json"
    code = print_check.main([str(tmp_path / "checks.yaml"), "--json", str(out)])
    return code, json.loads(out.read_text())


def test_a_long_ledge_over_air_is_called_out(tmp_path):
    # the 2026-11-15 hook clip: a 2 mm flat ledge printed over air spaghetti'd twice
    code, rows = ledge(tmp_path, {"reach": 2})
    assert any(r["level"] == "WARN" and "ledge sticks out 2.0 mm" in r["msg"] for r in rows), rows


def test_a_short_ledge_passes(tmp_path):
    code, rows = ledge(tmp_path, {"reach": 1})
    assert code == 0 and rows[0]["level"] == "PASS", rows


def test_a_shelf_held_at_both_ends_is_a_bridge_not_a_ledge(tmp_path):
    code, rows = ledge(tmp_path, {"reach": 6, "held": 1})
    assert code == 0 and "bridges" in rows[0]["msg"], rows
