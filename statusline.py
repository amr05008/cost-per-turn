#!/usr/bin/env python3
import json
import os
import sys

def color(text, code):
    return f"\033[{code}m{text}\033[0m"

BLUE   = "34"
CYAN   = "36"
GREEN  = "32"
YELLOW = "33"
RED    = "31"
DIM    = "2"

data = json.load(sys.stdin)

# Directory
cwd = data.get("workspace", {}).get("current_dir") or data.get("cwd", "")
dirname = os.path.basename(cwd) if cwd else "?"

# Duration
duration_ms = (data.get("cost") or {}).get("total_duration_ms") or 0
mins = int(duration_ms // 60000)
secs = int((duration_ms % 60000) // 1000)
duration_str = f"{mins}m {secs:02d}s"

# Context window
ctx = data.get("context_window") or {}
pct = int(ctx.get("used_percentage") or 0)
ctx_size = ctx.get("context_window_size") or 200000
current = ctx.get("current_usage") or {}
used_tokens = (
    (current.get("input_tokens") or 0)
    + (current.get("cache_creation_input_tokens") or 0)
    + (current.get("cache_read_input_tokens") or 0)
)
used_k  = f"{used_tokens // 1000}k" if used_tokens >= 1000 else str(used_tokens)
total_k = f"{ctx_size // 1000}k"

bar_width = 8
filled = int(pct * bar_width / 100)
bar = "▓" * filled + "░" * (bar_width - filled)

ctx_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN

# Cost
cost_usd = (data.get("cost") or {}).get("total_cost_usd") or 0
cost_color = RED if cost_usd > 5 else YELLOW if cost_usd >= 1 else GREEN

# Model
model = (data.get("model") or {}).get("display_name") or "?"

# Rate limits
def rate_limit_segment(window, label):
    pct = int(((data.get("rate_limits") or {}).get(window) or {}).get("used_percentage") or 0)
    seg_color = RED if pct >= 90 else YELLOW if pct >= 70 else GREEN
    filled = int(pct * bar_width / 100)
    seg_bar = "▓" * filled + "░" * (bar_width - filled)
    return color(f"{label} {seg_bar} {pct}%", seg_color)

segments = [
    color(f"📁 {dirname}", BLUE),
    color(f"⏱ {duration_str}", CYAN),
    color(f"◔ {used_k}/{total_k} {bar} {pct}%", ctx_color),
    color(f"${cost_usd:.2f}", cost_color),
    rate_limit_segment("five_hour", "5h"),
    rate_limit_segment("seven_day", "7d"),
    color(f"◆ {model}", DIM),
]

print("  " + color(" │ ", DIM).join(segments))
