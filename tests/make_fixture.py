#!/usr/bin/env python3
"""Regenerate the synthetic fixture transcripts.

The fixture exists so the repo is runnable by someone who has never run a
Claude Code session — and so the parser's edge cases stay covered without
shipping any of Aaron's real transcripts.

It deliberately reproduces every shape that made the real data tricky:

  * one JSONL line per *content block*, all repeating the same message.usage
    (a naive per-line sum over-counts this fixture by design)
  * cache_creation split across ephemeral_1h and ephemeral_5m in the same
    session, because they are priced differently
  * a model switch mid-session
  * a subagent transcript nested at <session-id>/subagents/, carrying the
    parent session id
  * a '<synthetic>' assistant line with an all-zero usage block
  * user / system / file-history-snapshot lines that carry no usage at all
  * a growing cache_read, so the cost-per-turn curve actually curves

Deterministic: no clock, no randomness. Run it, commit the output.

    python3 tests/make_fixture.py
"""

from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).parent / "fixtures" / "projects"
T0 = datetime(2026, 7, 15, 9, 0, 0, tzinfo=timezone.utc)

SHOP_SESSION = "11111111-aaaa-4bbb-8ccc-000000000001"
NOTES_SESSION = "22222222-bbbb-4ccc-8ddd-000000000002"


def usage(inp: int, out: int, read: int, w1h: int, w5m: int) -> dict:
    return {
        "input_tokens": inp,
        "cache_creation_input_tokens": w1h + w5m,
        "cache_read_input_tokens": read,
        "output_tokens": out,
        "server_tool_use": {"web_search_requests": 0, "web_fetch_requests": 0},
        "service_tier": "standard",
        "cache_creation": {
            "ephemeral_1h_input_tokens": w1h,
            "ephemeral_5m_input_tokens": w5m,
        },
        "inference_geo": "not_available",
        "speed": "standard",
    }


def assistant(session: str, cwd: str, mid: str, model: str, ts: datetime,
              blocks: list[dict], use: dict, sidechain: bool = False,
              agent_id: str | None = None) -> list[dict]:
    """One line per content block — every line repeats the same usage."""
    lines = []
    for block in blocks:
        line = {
            "type": "assistant",
            "uuid": f"{mid}-{block['type']}-{len(lines)}",
            "sessionId": session,
            "timestamp": ts.isoformat().replace("+00:00", "Z"),
            "cwd": cwd,
            "gitBranch": "main",
            "version": "2.1.220",
            "isSidechain": sidechain,
            "requestId": mid.replace("msg_", "req_"),
            "message": {
                "id": mid,
                "type": "message",
                "role": "assistant",
                "model": model,
                "content": [block],
                "stop_reason": "tool_use" if block["type"] == "tool_use" else "end_turn",
                "usage": use,
            },
        }
        if agent_id:
            line["agentId"] = agent_id
        lines.append(line)
    return lines


def noise(session: str, cwd: str, ts: datetime, kind: str) -> dict:
    """A line with no message.usage. Must never be counted as a turn."""
    if kind == "user":
        return {
            "type": "user",
            "uuid": f"u-{ts.timestamp()}",
            "sessionId": session,
            "cwd": cwd,
            "timestamp": ts.isoformat().replace("+00:00", "Z"),
            "message": {"role": "user", "content": [{"type": "text", "text": "keep going"}]},
        }
    return {
        "type": kind,
        "uuid": f"{kind}-{ts.timestamp()}",
        "sessionId": session,
        "cwd": cwd,
        "timestamp": ts.isoformat().replace("+00:00", "Z"),
    }


def build_shop() -> tuple[list[dict], list[dict]]:
    """A long session whose context — and therefore cost — grows every turn."""
    cwd = "/Users/demo/repos/widget-shop"
    lines: list[dict] = []
    read = 0
    for i in range(1, 41):
        ts = T0 + timedelta(minutes=3 * i)
        # Model switches partway through, so pricing must follow the model
        # that actually served each turn rather than a per-session guess.
        model = "claude-opus-5" if i <= 24 else "claude-sonnet-5"
        # Cache writes alternate TTL; both appear in one session.
        w1h, w5m = (9000, 0) if i % 3 else (0, 4200)
        blocks = [{"type": "thinking", "thinking": ""}, {"type": "text", "text": f"step {i}"}]
        if i % 2 == 0:
            blocks.append(
                {"type": "tool_use", "id": f"toolu_{i}", "name": "Read", "input": {"n": i}}
            )
        lines.append(noise(SHOP_SESSION, cwd, ts - timedelta(seconds=20), "user"))
        lines.extend(
            assistant(
                SHOP_SESSION, cwd, f"msg_shop_{i:03d}", model, ts,
                blocks, usage(3, 400 + 12 * i, read, w1h, w5m),
            )
        )
        read += 9000 if i % 3 else 4200

    # A locally-generated line: real model string, all-zero usage.
    lines.extend(
        assistant(
            SHOP_SESSION, cwd, "msg_shop_syn", "<synthetic>",
            T0 + timedelta(minutes=125),
            [{"type": "text", "text": "(interrupted)"}],
            usage(0, 0, 0, 0, 0),
        )
    )
    lines.append(noise(SHOP_SESSION, cwd, T0 + timedelta(minutes=126), "file-history-snapshot"))

    # Subagent transcript: nested on disk, but sessionId is the PARENT's.
    sub: list[dict] = []
    for i in range(1, 6):
        sub.extend(
            assistant(
                SHOP_SESSION, cwd, f"msg_shop_sub_{i}", "claude-haiku-4-5-20251001",
                T0 + timedelta(minutes=60, seconds=30 * i),
                [{"type": "text", "text": f"sub {i}"}],
                usage(14000, 180, 0 if i == 1 else 15000, 0, 15000 if i == 1 else 0),
                sidechain=True, agent_id="agent-a1b2c3d4e5f60718",
            )
        )
    return lines, sub


def build_notes() -> list[dict]:
    """A short session in a second repo, on a different model."""
    cwd = "/Users/demo/repos/note-taker"
    lines: list[dict] = []
    read = 0
    for i in range(1, 7):
        ts = T0 + timedelta(days=1, minutes=5 * i)
        lines.append(noise(NOTES_SESSION, cwd, ts - timedelta(seconds=10), "user"))
        lines.extend(
            assistant(
                NOTES_SESSION, cwd, f"msg_note_{i:03d}", "claude-fable-5", ts,
                [{"type": "text", "text": f"note {i}"}],
                usage(2, 300, read, 0, 6000),
            )
        )
        read += 6000
    return lines


def write(path: Path, lines: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as fh:
        for line in lines:
            fh.write(json.dumps(line) + "\n")
    print(f"wrote {path.relative_to(Path(__file__).parent)}  ({len(lines)} lines)")


def main() -> None:
    shop, sub = build_shop()
    shop_dir = ROOT / "-Users-demo-repos-widget-shop"
    write(shop_dir / f"{SHOP_SESSION}.jsonl", shop)
    write(shop_dir / SHOP_SESSION / "subagents" / "agent-a1b2c3d4e5f60718.jsonl", sub)
    write(ROOT / "-Users-demo-repos-note-taker" / f"{NOTES_SESSION}.jsonl", build_notes())


if __name__ == "__main__":
    main()
