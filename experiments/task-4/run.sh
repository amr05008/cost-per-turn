#!/usr/bin/env bash
# Task 4 — action-item extraction from synthetic call notes.
# 3 arms x N reps, interleaved. All arms run on pi via OpenRouter, so the
# harness is held constant and only the model varies. No Anthropic key needed.
#
#   ./run.sh          60 runs (20 per arm)
#   ./run.sh 1        smoke test, one per arm — ALWAYS do this first
# Safe to re-run: completed runs are skipped.
#
# Run ./test-key.sh and see 0 failures before the first real run.
set -uo pipefail                 # NOT -e: one bad run must not kill the batch
cd "$(dirname "$0")"

# ── CONFIG ────────────────────────────────────────────────────────────────
REPS_DEFAULT=20                  # pre-committed. Topping up after seeing the
                                 # rate would be p-hacking on a binary metric.
ARTIFACT="action-items.md"
PROMPT_FILE="prompts/action-items.txt"
FIXTURE="fixture/call-notes.md"
# --thinking high on every arm, held constant with tasks 2 and 3. Reasoning
# effort is plausibly the biggest lever on over-listing and is UNTESTED — see
# the caveat in README.md. It is a variable for arm O, not for this task.
THINKING=high
ARMS=(
  "A:opus:anthropic/claude-opus-5"
  "B:sonnet:anthropic/claude-sonnet-5"
  "C:kimi:moonshotai/kimi-k3"
)
# ──────────────────────────────────────────────────────────────────────────

N=${1:-$REPS_DEFAULT}
PROMPT="$(cat "$PROMPT_FILE")"
mkdir -p runs
{ echo "date:         $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:           $(pi --version 2>&1 | head -1)"
  echo "reps_per_arm: $N"
  echo "thinking:     $THINKING"
  echo "prompt_sha:   $(shasum -a 256 "$PROMPT_FILE" | cut -c1-16)"
  echo "fixture_sha:  $(shasum -a 256 "$FIXTURE" | cut -c1-16)"
  echo "key_sha:      $(shasum -a 256 key.sh | cut -c1-16)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model" > runs/key.csv

ok=0; skip=0; fail=0; i=0
for rep in $(seq 1 "$N"); do
  for spec in "${ARMS[@]}"; do                    # interleaved, so drift hits all arms
    IFS=: read -r arm label model <<< "$spec"
    i=$((i+1)); id=$(printf "c%02d" $i); d="runs/$id"
    echo "$id,$arm,pi,$label" >> runs/key.csv
    if [ -s "$d/$ARTIFACT" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] already done, skipping"; skip=$((skip+1)); continue
    fi
    mkdir -p "$d"; cp "$FIXTURE" "$d/"
    printf "[%s] arm %s (rep %s) ... " "$id" "$arm" "$rep"
    ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
        --no-extensions --provider openrouter --model "$model" --thinking "$THINKING" \
        "$PROMPT" < /dev/null > run.jsonl 2> run.err )   # </dev/null or it stalls on stdin
    if [ -s "$d/$ARTIFACT" ]; then echo "ok"; ok=$((ok+1))
    else echo "NO ARTIFACT — see $d/run.err"; fail=$((fail+1)); fi
  done
done
echo; echo "$ok ok · $skip skipped · $fail missing $ARTIFACT"
echo "Costs:  python3 ../../scripts/extract-runs.py runs"
echo "Score:  ./score.sh"
