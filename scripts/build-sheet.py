#!/usr/bin/env python3
"""Join every run in the repo into one sheet, for looking at the data directly.

  python3 scripts/build-sheet.py            -> experiments/all-runs.csv + a pivot
  python3 scripts/build-sheet.py --outputs  -> also writes experiments/all-outputs.md

One row per run across all four tasks. Columns are stated facts — cost, tokens,
scores, the human verdict where one exists — and nothing derived or interpreted.
Prices come from prices.json so the $/M columns are the dated list rates, not a
judgement.

`all-outputs.md` groups every task-4 answer under its model and effort, so the
actual lists can be read by cell instead of blind. Grading is finished, so the
blinding in ALL-ITEMS.md / SPOT-CHECK.md no longer needs to hold.
"""
import csv, json, pathlib, sys, collections

ROOT = pathlib.Path(__file__).parent.parent
EXP = ROOT / "experiments"

# task label -> (runs dir, does it have mechanical scores?)
SOURCES = [
    ("2-deck",        EXP / "task-2/runs"),
    ("2-deck-fix",    EXP / "task-2/followup-notes-fix/runs"),
    ("3-relnotes",    EXP / "task-3/runs"),
    ("4-actionitems", EXP / "task-4/runs"),
    ("4-effort",      EXP / "task-4/effort-sweep/runs"),
    ("4-local",       EXP / "task-4/local/runs"),
]

PRICE = {"opus": (5, 25), "sonnet": (2, 10), "kimi": (3, 15),
         "haiku": (1, 5), "mini": (.75, 4.5), "nano": (.2, 1.25),
         "opus-5": (5, 25), "kimi-k3": (3, 15),
         "glimmer": (0, 0)}   # local: $0 marginal, paid in wall-clock

COLS = ["task", "run_id", "harness", "model", "effort", "in_per_m", "out_per_m",
        "cost_usd", "round_trips", "tool_calls", "input_tokens", "output_tokens",
        "cache_read_tokens", "cache_write_tokens", "wall_clock_s",
        "recall", "listed", "surplus", "unassigned", "shippable", "perfect",
        "missed", "fell_for", "human_verdict", "human_note"]


def rows():
    for task, d in SOURCES:
        ex = d / "runs-extracted.csv"
        if not ex.exists():
            continue
        scores = {}
        if (d / "scores.csv").exists():
            scores = {r["run_id"]: r for r in csv.DictReader(open(d / "scores.csv"))}
        key = {}
        if (d / "key.csv").exists():
            key = {r["run_id"]: r for r in csv.DictReader(open(d / "key.csv"))}
        for r in csv.DictReader(open(ex)):
            rid = r["run_id"]
            k, s = key.get(rid, {}), scores.get(rid, {})
            # `model` from the session log is authoritative; strip the vendor prefix
            short = (r.get("model") or "").split("/")[-1].replace("claude-", "")
            short = {"opus-5": "opus", "sonnet-5": "sonnet", "kimi-k3": "kimi",
                     "haiku-4.5": "haiku", "gpt-5.4-mini": "mini",
                     "gpt-5.4-nano": "nano", "muse-glimmer:30b-mlx": "glimmer",
                     "muse-glimmer:30b": "glimmer"}.get(short, short)
            p = PRICE.get(short, ("", ""))
            yield {
                "task": task, "run_id": rid, "harness": r.get("harness", ""),
                "model": short, "effort": k.get("effort", "high" if s else ""),
                "in_per_m": p[0], "out_per_m": p[1],
                **{c: r.get(c, "") for c in ["cost_usd", "round_trips", "tool_calls",
                   "input_tokens", "output_tokens", "cache_read_tokens",
                   "cache_write_tokens", "wall_clock_s"]},
                **{c: s.get(c, "") for c in ["recall", "listed", "surplus",
                   "unassigned", "shippable", "perfect", "missed", "fell_for"]},
                "human_verdict": r.get("verdict", ""), "human_note": r.get("review_note", ""),
            }


def main():
    data = list(rows())
    out = EXP / "all-runs.csv"
    with out.open("w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLS)
        w.writeheader(); w.writerows(data)
    print(f"{len(data)} runs -> {out}\n")

    g = collections.defaultdict(list)
    for r in data:
        g[(r["task"], r["model"], r["effort"])].append(r)
    print(f"{'task':16}{'model':8}{'effort':7}{'n':>4}{'spend':>8}{'med cost':>10}"
          f"{'shippable':>11}{'human fav/acc/unus':>20}")
    for (t, m, e), v in sorted(g.items()):
        cost = sorted(float(x["cost_usd"] or 0) for x in v)
        sh = [x for x in v if x["shippable"]]
        shs = f"{sum(1 for x in sh if x['shippable']=='yes')}/{len(sh)}" if sh else "—"
        hv = collections.Counter(x["human_verdict"] for x in v if x["human_verdict"])
        hs = f"{hv['favorite']}/{hv['acceptable']}/{hv['unusable']}" if hv else "—"
        print(f"{t:16}{m:8}{e or '—':7}{len(v):>4}{sum(cost):>8.2f}"
              f"{cost[len(cost)//2]:>10.4f}{shs:>11}{hs:>20}")

    if "--outputs" in sys.argv:
        md = EXP / "all-outputs.md"
        with md.open("w") as fh:
            fh.write("# Every task-4 answer, grouped by model and effort\n\n"
                     "Unblinded — grading is finished. The fixture is "
                     "`task-4/fixture/call-notes.md`.\n")
            byc = collections.defaultdict(list)
            for r in data:
                if not r["recall"]:
                    continue
                byc[(r["model"], r["effort"])].append(r)
            for (m, e), v in sorted(byc.items()):
                fh.write(f"\n\n## {m} · {e} effort · {len(v)} runs\n")
                for r in sorted(v, key=lambda x: x["run_id"]):
                    d = next(p for t, p in SOURCES if t == r["task"])
                    body = (d / r["run_id"] / "action-items.md").read_text().strip()
                    fh.write(f"\n**{r['run_id']}** · recall {r['recall']}/5 · "
                             f"surplus {r['surplus']} · unassigned {r['unassigned']}"
                             f"{' · human: ' + r['human_verdict'] if r['human_verdict'] else ''}\n\n"
                             f"```\n{body}\n```\n")
        print(f"\nanswers -> {md}")


main()
