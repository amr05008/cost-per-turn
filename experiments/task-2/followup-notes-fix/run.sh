#!/usr/bin/env bash
# Follow-up: does one sentence fix Kimi's only failure mode?
# Arm D = arm C (pi · Kimi K3) with build-deck-v2.txt. Nothing else differs.
#
#   ./run.sh          5 runs, ~20 min, ~$0.70
# Safe to re-run: completed runs are skipped.
set -uo pipefail
cd "$(dirname "$0")"
N=${1:-5}
PROMPT="$(cat prompts/build-deck-v2.txt)"
mkdir -p runs
{ echo "date:        $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "pi:          $(pi --version 2>&1 | head -1)"
  echo "prompt_sha:  $(shasum -a 256 prompts/build-deck-v2.txt | cut -c1-16)"
  echo "source_sha:  $(shasum -a 256 ../fixture/talk-source.md | cut -c1-16)"
} > runs/meta.txt
cat runs/meta.txt; echo
echo "run_id,arm,harness,model" > runs/key.csv

ok=0; skip=0; fail=0
for i in $(seq 1 "$N"); do
  id=$(printf "d%02d" $i); d="runs/$id"
  echo "$id,D,pi,kimi-k3" >> runs/key.csv
  if [ -s "$d/deck.html" ] && [ -s "$d/run.jsonl" ]; then
    echo "[$id] already done, skipping"; skip=$((skip+1)); continue
  fi
  mkdir -p "$d"; cp ../fixture/talk-source.md "$d/"
  printf "[%s] arm D (rep %s) ... " "$id" "$i"
  ( cd "$d" && pi -p --mode json --no-session --no-context-files --no-skills \
      --no-extensions --provider openrouter --model moonshotai/kimi-k3 \
      --thinking high "$PROMPT" < /dev/null > run.jsonl 2> run.err )
  if [ -s "$d/deck.html" ]; then echo "ok"; ok=$((ok+1))
  else echo "NO DECK — see $d/run.err"; fail=$((fail+1)); fi
done
echo; echo "$ok ok · $skip skipped · $fail with no deck.html"
echo "Costs:  python3 ../../../scripts/extract-runs.py runs"
