#!/usr/bin/env bash
# Generic experiment runner. Copy this directory, edit the CONFIG block, done.
#
#   ./run.sh 1     smoke test — one run per arm. ALWAYS do this first.
#   ./run.sh       full batch
# Safe to re-run: completed runs are skipped, so a failure costs one run.
set -uo pipefail                 # NOT -e: one bad run must not kill the batch
cd "$(dirname "$0")"

# ── CONFIG ────────────────────────────────────────────────────────────────
REPS_DEFAULT=10                  # per arm. 10+ for cheap tasks; 5 resolves ~nothing
ARTIFACT="output.md"             # the file each run must produce
PROMPT_FILE="prompts/task.txt"
FIXTURE="fixture/input.md"       # copied into every run dir
# arm_id : label : pi model  — add or remove lines freely
ARMS=(
  "A:opus:anthropic/claude-opus-5"
  "B:kimi:moonshotai/kimi-k3"
)
# ──────────────────────────────────────────────────────────────────────────

N=${1:-$REPS_DEFAULT}
PROMPT="$(cat "$PROMPT_FILE")"
mkdir -p runs
{ echo "date:         $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:           $(pi --version 2>&1 | head -1)"
  echo "reps_per_arm: $N"
  echo "prompt_sha:   $(shasum -a 256 "$PROMPT_FILE" | cut -c1-16)"
  echo "fixture_sha:  $(shasum -a 256 "$FIXTURE" | cut -c1-16)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model" > runs/key.csv

ok=0; skip=0; fail=0; i=0
for rep in $(seq 1 "$N"); do
  for spec in "${ARMS[@]}"; do                    # interleaved, so drift hits all arms
    IFS=: read -r arm label model <<< "$spec"
    i=$((i+1)); id=$(printf "r%02d" $i); d="runs/$id"
    echo "$id,$arm,pi,$label" >> runs/key.csv
    if [ -s "$d/$ARTIFACT" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] already done, skipping"; skip=$((skip+1)); continue
    fi
    mkdir -p "$d"; cp "$FIXTURE" "$d/"
    printf "[%s] arm %s (rep %s) ... " "$id" "$arm" "$rep"
    ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
        --no-extensions --provider openrouter --model "$model" --thinking high \
        "$PROMPT" < /dev/null > run.jsonl 2> run.err )   # </dev/null or it stalls on stdin
    if [ -s "$d/$ARTIFACT" ]; then echo "ok"; ok=$((ok+1))
    else echo "NO ARTIFACT — see $d/run.err"; fail=$((fail+1)); fi
  done
done
echo; echo "$ok ok · $skip skipped · $fail missing $ARTIFACT"
echo "Costs:  python3 ../../scripts/extract-runs.py runs"
