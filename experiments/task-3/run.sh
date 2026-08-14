#!/usr/bin/env bash
# Task 3 — release notes from a real commit log.
# 2 arms x N reps, interleaved. Both arms run on pi via OpenRouter, so the
# harness is held constant and only the model varies. No Anthropic key needed.
#
#   ./run.sh          20 runs (10 per arm)
#   ./run.sh 1        smoke test, one per arm
# Safe to re-run: completed runs are skipped.
set -uo pipefail
cd "$(dirname "$0")"
N=${1:-10}
PROMPT="$(cat prompts/release-notes.txt)"
mkdir -p runs
{ echo "date:        $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:          $(pi --version 2>&1 | head -1)"
  echo "reps_per_arm: $N"
  echo "source_sha:  $(shasum -a 256 fixture/changelog.txt | cut -c1-16)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model" > runs/key.csv

ok=0; skip=0; fail=0; i=0
for rep in $(seq 1 "$N"); do
  for arm in A B; do
    i=$((i+1)); id=$(printf "n%02d" $i); d="runs/$id"
    case $arm in
      A) MODEL=anthropic/claude-opus-5; echo "$id,A,pi,opus-5" ;;
      B) MODEL=moonshotai/kimi-k3;      echo "$id,B,pi,kimi-k3" ;;
    esac >> runs/key.csv
    if [ -s "$d/release-notes.md" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] already done, skipping"; skip=$((skip+1)); continue
    fi
    mkdir -p "$d"; cp fixture/changelog.txt "$d/"
    printf "[%s] arm %s (rep %s) ... " "$id" "$arm" "$rep"
    ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
        --no-extensions --provider openrouter --model "$MODEL" --thinking high \
        "$PROMPT" < /dev/null > run.jsonl 2> run.err )
    if [ -s "$d/release-notes.md" ]; then echo "ok"; ok=$((ok+1))
    else echo "NO NOTES — see $d/run.err"; fail=$((fail+1)); fi
  done
done
echo; echo "$ok ok · $skip skipped · $fail with no release-notes.md"
echo "Costs:  python3 ../../scripts/extract-runs.py runs"
echo "Leaks:  ./check-leaks.sh"
