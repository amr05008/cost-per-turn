#!/usr/bin/env python3
"""Task 4 effort sweep — blind spot-check for the three models a human has never graded.

The `shippable = recall 5/5` rule came from task 4's human pass, which covered
Opus, Sonnet and Kimi. Haiku, GPT-5.4-mini and GPT-5.4-nano are being scored by
a rule that was never validated on them. This builds a small stratified sample
to check it, in BOTH directions:

  * 6 runs the scorer called shippable   -> would a human actually send them?
  * 6 runs the scorer rejected           -> is the scorer right to reject them?

The second half matters more. The claim being extrapolated is that missing A4
makes a list unusable. If a haiku list that dropped two items still reads fine,
the metric is wrong for these models and the sweep's conclusions need softening.

Balanced across the three models, deterministic (sampled by hash of run id, so
re-running gives the same sample), and blind: SPOT-CHECK.md carries anonymous
labels only. The map lives in runs/spot-map.csv, which stays closed until
runs/spot-grades.csv is written.

  ./spot-check.py           build SPOT-CHECK.md + runs/spot-map.csv
  ./spot-check.py --join    after grading: spot-grades.csv -> merged into grades.csv
"""
import csv, hashlib, pathlib, sys, collections

HERE = pathlib.Path(__file__).parent
RUNS = HERE / "runs"
MODELS = ["haiku", "mini", "nano"]
N_PER_STRATUM = 6

h = lambda s: hashlib.sha256(s.encode()).hexdigest()


def load():
    key = {r["run_id"]: r for r in csv.DictReader(open(RUNS / "key.csv"))}
    sc = {r["run_id"]: r for r in csv.DictReader(open(RUNS / "scores.csv"))}
    return [(rid, key[rid]["model"], key[rid]["effort"], sc[rid])
            for rid in sc if key.get(rid, {}).get("model") in MODELS]


def join():
    gp = RUNS / "spot-grades.csv"
    if not gp.exists():
        sys.exit("write runs/spot-grades.csv first (label,verdict,note)")
    m = {r["label"]: r["run_id"] for r in csv.DictReader(open(RUNS / "spot-map.csv"))}
    out = RUNS / "grades.csv"
    rows = [r for r in csv.DictReader(open(out))] if out.exists() else []
    seen = {r["run_id"] for r in rows}
    for r in csv.DictReader(open(gp)):
        rid = m.get(r["label"])
        if rid and rid not in seen:
            rows.append({"run_id": rid, "verdict": r["verdict"], "note": r.get("note", "")})
    with open(out, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=["run_id", "verdict", "note"])
        w.writeheader(); w.writerows(rows)
    print(f"wrote {out} ({len(rows)} rows) — extract-runs.py will fold it in")


def build():
    rows = load()
    strata = {True: collections.defaultdict(list), False: collections.defaultdict(list)}
    for rid, model, effort, s in rows:
        strata[s["recall"] == "5"][model].append(rid)

    picked = []
    for shippable in (True, False):
        # Balanced across the three models, topped up from the pool if a model
        # is short (nano has only one shippable run in the whole sweep).
        per = {m: sorted(strata[shippable][m], key=h) for m in MODELS}
        quota, take = N_PER_STRATUM // len(MODELS), []
        for m in MODELS:
            take += per[m][:quota]
        pool = sorted({r for m in MODELS for r in per[m]} - set(take), key=h)
        take += pool[:N_PER_STRATUM - len(take)]
        picked += take

    picked = sorted(set(picked), key=lambda r: h(r + "scramble"))
    meta = {rid: (model, effort, s) for rid, model, effort, s in rows}

    with open(RUNS / "spot-map.csv", "w", newline="") as fh:
        w = csv.writer(fh); w.writerow(["label", "run_id", "model", "effort", "recall", "surplus"])
        lines = ["# Task 4 effort sweep — spot check\n",
                 "Would you send this list as the follow-up from that call, unedited?",
                 "`favorite` / `acceptable` / `unusable`.\n",
                 "Record in `runs/spot-grades.csv` as `label,verdict,note`, then",
                 "`./spot-check.py --join`.\n",
                 "Do not open `runs/spot-map.csv` or `runs/key.csv` until that file is written.\n"]
        for i, rid in enumerate(picked, 1):
            label = f"#{i:02d}"
            model, effort, s = meta[rid]
            w.writerow([label, rid, model, effort, s["recall"], s["surplus"]])
            body = (RUNS / rid / "action-items.md").read_text().strip()
            lines += ["---\n", f"## {label}\n", body, ""]
    (HERE / "SPOT-CHECK.md").write_text("\n".join(lines) + "\n")

    ship = sum(1 for r in picked if meta[r][2]["recall"] == "5")
    print(f"wrote SPOT-CHECK.md — {len(picked)} lists "
          f"({ship} the scorer called shippable, {len(picked)-ship} it rejected)")
    print("map is runs/spot-map.csv — KEEP IT CLOSED until runs/spot-grades.csv is written")


join() if "--join" in sys.argv else build()
