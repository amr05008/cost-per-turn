#!/usr/bin/env python3
"""Turn raw run logs into one CSV row per run.

Reads the JSONL that `claude -p --output-format stream-json --verbose` and
`pi -p --mode json` write, and emits the experiment record. Both harnesses are
reduced to the SAME derived metrics so they're comparable:

  round_trips  — model API calls (assistant messages). This is the honest
                 cross-harness "turns" number. Do NOT use Claude Code's
                 `num_turns` for comparison; pi counts turns differently.
  tool_calls   — tool_use blocks issued across the run.

Usage:
    python3 extract-runs.py <run_dir> [--debug]

Expects files named <run_id>.jsonl, e.g. r001.jsonl. Writes runs-extracted.csv
into <run_dir>. --debug prints the distinct content-block types it saw, so you
can confirm tool-call counting on run 1 before trusting the other 30.
"""
import csv
import json
import pathlib
import sys
from datetime import datetime, timezone

DEBUG = "--debug" in sys.argv
BLOCK_TYPES = set()


def _mmss(seconds):
    """Seconds -> "11m 27s". Spreadsheets are read by people."""
    if seconds in ("", None):
        return ""
    s = int(round(float(seconds)))
    return f"{s // 60}m {s % 60:02d}s"


def _blocks(content):
    return [b for b in content if isinstance(b, dict)] if isinstance(content, list) else []


def _is_tool_call(block_type: str) -> bool:
    # pi and Claude Code name these differently; match either without matching
    # tool *results*, which are model input, not model output.
    t = block_type.lower()
    return "tool" in t and "result" not in t


def parse_claude(path):
    """Claude Code: stream-json JSONL, terminated by a `result` event."""
    rt = tools = 0
    final = ""
    res = None
    models = set()
    for line in path.read_text(errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("type") == "assistant":
            rt += 1
            if d.get("message", {}).get("model"):
                models.add(d["message"]["model"])
            for b in _blocks(d.get("message", {}).get("content")):
                BLOCK_TYPES.add(b.get("type", "?"))
                if _is_tool_call(b.get("type", "")):
                    tools += 1
                elif b.get("type") == "text":
                    final = b.get("text", final)
        elif d.get("type") == "result":
            res = d
    if res is None:
        raise ValueError(f"{path.name}: no result event — run may have been interrupted")
    u = res.get("usage", {}) or {}
    return {
        "harness": "claude-code",
        # Read from the log, not from the run label — this catches a silent
        # model fallback that key.csv would happily lie about.
        "model": "+".join(sorted(models)) or "?",
        "cost_usd": round(res.get("total_cost_usd") or 0, 4),
        "input_tokens": u.get("input_tokens", 0),
        "output_tokens": u.get("output_tokens", 0),
        "cache_read_tokens": u.get("cache_read_input_tokens", 0),
        "cache_write_tokens": u.get("cache_creation_input_tokens", 0),
        "wall_clock_s": round((res.get("duration_ms") or 0) / 1000, 1),
        "round_trips": rt,
        "tool_calls": tools,
        "native_turn_count": res.get("num_turns"),
        # Did the HARNESS report a failed session (API error, aborted run)?
        # Says nothing about whether the output is any good.
        "session_error": "yes" if res.get("is_error") else "no",
        "session_id": res.get("session_id", ""),
        "final_text": final,
    }


def parse_pi(path):
    """pi: --mode json JSONL, per-message usage with its own cost breakdown."""
    rt = tools = 0
    cost = tin = tout = tcr = tcw = 0
    final = ""
    stamps = []
    models = set()
    for line in path.read_text(errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            d = json.loads(line)
        except json.JSONDecodeError:
            continue
        if d.get("type") != "message_end":
            continue
        msg = d.get("message", {})
        if msg.get("timestamp"):
            stamps.append(msg["timestamp"])
        if msg.get("role") != "assistant":
            continue
        rt += 1
        if msg.get("model"):
            models.add(msg["model"])
        u = msg.get("usage") or {}
        tin += u.get("input", 0)
        tout += u.get("output", 0)
        tcr += u.get("cacheRead", 0)
        tcw += u.get("cacheWrite", 0)
        cost += ((u.get("cost") or {}).get("total") or 0)
        for b in _blocks(msg.get("content")):
            BLOCK_TYPES.add(b.get("type", "?"))
            if _is_tool_call(b.get("type", "")):
                tools += 1
            elif b.get("type") == "text" and b.get("text", "").strip():
                final = b["text"]
    if rt == 0:
        raise ValueError(f"{path.name}: no assistant messages — run may have failed")
    wall = round((max(stamps) - min(stamps)) / 1000, 1) if len(stamps) > 1 else ""
    return {
        "harness": "pi",
        "model": "+".join(sorted(models)) or "?",
        "cost_usd": round(cost, 4),
        "input_tokens": tin,
        "output_tokens": tout,
        "cache_read_tokens": tcr,
        "cache_write_tokens": tcw,
        "wall_clock_s": wall,
        "round_trips": rt,
        "tool_calls": tools,
        "native_turn_count": "",
        "session_error": "not reported by pi",
        "session_id": "",
        "final_text": final,
    }


# Column order is for reading left-to-right: what ran, what it cost, how long,
# how much work, then the raw token detail. See experiments/COLUMNS.md.
FIELDS = [
    "run_id", "harness", "model", "cost_usd", "wall_clock", "wall_clock_s",
    "round_trips", "tool_calls", "input_tokens", "output_tokens",
    "cache_read_tokens", "cache_write_tokens", "session_error",
    "native_turn_count", "session_id",
]


def main():
    run_dir = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("-") else ".")
    out_rows, answers = [], run_dir / "answers"
    answers.mkdir(exist_ok=True)

    # Accept either layout: <dir>/<run_id>.jsonl, or <dir>/<run_id>/run.jsonl
    paths = sorted(run_dir.glob("*.jsonl")) or sorted(run_dir.glob("*/run.jsonl"))
    for path in paths:
        run_id = path.stem if path.stem != "run" else path.parent.name
        head = path.read_text(errors="replace")[:400]
        try:
            row = parse_pi(path) if '"type":"session"' in head or '"agent_start"' in head else parse_claude(path)
        except ValueError as e:
            print(f"  !! {e}", file=sys.stderr)
            continue
        # Blind grading: the answer file is named by run_id only, no config in it.
        (answers / f"{run_id}.md").write_text(row.pop("final_text") or "")  # chat reply
        row["run_id"] = run_id
        row["wall_clock"] = _mmss(row.get("wall_clock_s"))
        out_rows.append({k: row.get(k, "") for k in FIELDS})
        print(f"  {run_id}: {row['harness']:<11} {row['model']:<28} ${row['cost_usd']:<7} "
              f"{row['round_trips']:>3} round-trips  {row['tool_calls']:>3} tool calls  "
              f"{row['wall_clock_s']}s")

    out = run_dir / "runs-extracted.csv"
    with out.open("w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=FIELDS)
        w.writeheader()
        w.writerows(out_rows)

    print(f"\n{len(out_rows)} runs -> {out}")
    print(f"Outputs for blind grading -> {answers}/")
    if DEBUG:
        print(f"\nContent block types seen: {sorted(BLOCK_TYPES)}")
        print("Confirm the tool-call blocks are being counted before trusting tool_calls.")


if __name__ == "__main__":
    main()
