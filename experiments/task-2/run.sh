#!/usr/bin/env bash
# Task 2 — 3 arms x N reps, run start to finish with no babysitting.
# Each run is a headless agent session in its own directory with its own copy
# of the source, so no run can see another's output.
#
#   ./run.sh          15 runs (5 per arm), ~20 min
#   ./run.sh 1        1 per arm — the smoke test, do this first
#
# Safe to re-run: completed runs are skipped, so if one dies you just run it
# again and it picks up the stragglers.
set -uo pipefail          # deliberately NOT -e: one bad run shouldn't kill the batch
cd "$(dirname "$0")"
N=${1:-5}
PROMPT="$(cat prompts/build-deck.txt)"
mkdir -p runs

# These numbers age. Record what produced them.
{ echo "date:         $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "claude:       $(claude --version 2>&1 | head -1)"
  echo "pi:           $(pi --version 2>&1 | head -1)"
  echo "reps_per_arm: $N"
  echo "source_sha:   $(shasum -a 256 fixture/talk-source.md | cut -c1-16)"
} > runs/meta.txt
cat runs/meta.txt; echo

echo "run_id,arm,harness,model" > runs/key.csv
ok=0; skip=0; fail=0; i=0

for rep in $(seq 1 "$N"); do
  for arm in A B C; do
    i=$((i+1)); id=$(printf "r%02d" $i); d="runs/$id"

    case $arm in
      A) echo "$id,A,claude-code,opus-5" ;;
      B) echo "$id,B,pi,opus-5"          ;;
      C) echo "$id,C,pi,kimi-k3"         ;;
    esac >> runs/key.csv

    # Already finished? Leave it alone.
    if [ -s "$d/deck.html" ] && [ -s "$d/run.jsonl" ]; then
      echo "[$id] arm $arm — already done, skipping"; skip=$((skip+1)); continue
    fi

    mkdir -p "$d"; cp fixture/talk-source.md "$d/"
    printf "[%s] arm %s (rep %s) ... " "$id" "$arm" "$rep"

    case $arm in
      A) ( cd "$d" && claude --bare -p --model opus --effort high \
             --output-format stream-json --verbose --dangerously-skip-permissions \
             "$PROMPT" < /dev/null > run.jsonl 2> run.err ) ;;
      B) ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
             --no-extensions --provider openrouter --model anthropic/claude-opus-5 \
             --thinking high "$PROMPT" < /dev/null > run.jsonl 2> run.err ) ;;
      C) ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
             --no-extensions --provider openrouter --model moonshotai/kimi-k3 \
             --thinking high "$PROMPT" < /dev/null > run.jsonl 2> run.err ) ;;
    esac

    if [ -s "$d/deck.html" ]; then
      echo "ok"; ok=$((ok+1))
    else
      echo "NO DECK — see $d/run.err"; fail=$((fail+1))
    fi
  done
done

echo
echo "$ok ok · $skip skipped · $fail with no deck.html"
[ "$fail" -gt 0 ] && echo "Re-run ./run.sh $N to retry just the failures."
echo
echo "Costs:  python3 ../../scripts/extract-runs.py runs --debug"
echo "Grade:  open each runs/r*/deck.html with wifi off. Don't read key.csv yet."
