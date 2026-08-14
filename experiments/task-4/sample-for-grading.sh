#!/usr/bin/env bash
# Task 4 — the small human pass, and the only judgement in this task.
#
# Mechanical scoring answers "was it right." It does not answer "would you
# paste this list into the follow-up email." Prediction 5 is that those two
# disagree, and this is the first task in the repo where both numbers exist.
#
# It is a STRATIFIED SAMPLE, not the whole batch: every run that scored
# perfect, plus 10 others. ~20 judgements instead of 60, same answer, and it
# keeps task 4 the mechanical one instead of quietly becoming another taste task.
#
#   ./sample-for-grading.sh          build ALL-ITEMS.md + runs/sample-map.csv
#   ./sample-for-grading.sh --join   after grading: sample-grades.csv → grades.csv
#
# BLINDING — this matters more here than in tasks 2 and 3. Arms are interleaved
# strictly across THREE arms, so `run_index mod 3` IS the arm: c07 is always
# arm A. Scrambling the order is not enough; the run id itself leaks the arm.
# So ALL-ITEMS.md carries anonymous labels (#01, #02, ...) and the label→run_id
# map lives in runs/sample-map.csv, which stays closed until grading is done.
set -uo pipefail
cd "$(dirname "$0")"
N_OTHERS=10

if [ "${1:-}" = "--join" ]; then
  # sample-grades.csv is `label,verdict,note` — join it back to run ids.
  [ -s runs/sample-grades.csv ] || { echo "write runs/sample-grades.csv first (label,verdict,note)"; exit 1; }
  echo "run_id,verdict,note" > runs/grades.csv
  tail -n +2 runs/sample-grades.csv | while IFS=, read -r label rest; do
    rid=$(awk -F, -v l="$label" '$1==l{print $2}' runs/sample-map.csv)
    [ -n "$rid" ] && echo "$rid,$rest" >> runs/grades.csv
  done
  echo "wrote runs/grades.csv ($(($(wc -l < runs/grades.csv)-1)) rows) — extract-runs.py will fold it in"
  exit 0
fi

[ -s runs/scores.csv ] || { echo "run ./score.sh first"; exit 1; }

# Deterministic shuffle: sort by a hash of the run id. Reproducible, and
# uncorrelated with arm.
h() { printf '%s' "$1" | shasum -a 256 | cut -c1-12; }

perfect=$(awk -F, 'NR>1 && $NF=="yes"{print $1}' runs/scores.csv)
others=$(awk -F, 'NR>1 && $NF!="yes"{print $1}' runs/scores.csv \
         | while read -r r; do echo "$(h "$r") $r"; done | sort | head -"$N_OTHERS" | cut -d' ' -f2)

sel=$(printf '%s\n%s\n' "$perfect" "$others" | grep -E '[^[:space:]]' \
      | while read -r r; do echo "$(h "$r")-x $r"; done | sort | cut -d' ' -f2)

echo "label,run_id" > runs/sample-map.csv
{ echo "# Task 4 — action-item lists for the human pass"
  echo
  echo "Would you send this list as the follow-up from that call, unedited?"
  echo '`favorite` / `acceptable` / `unusable`. Record in `runs/sample-grades.csv`'
  echo 'as `label,verdict,note`, then run `./sample-for-grading.sh --join`.'
  echo
  echo "Do not open \`runs/sample-map.csv\` or \`runs/key.csv\` until that file is written."
  echo
} > ALL-ITEMS.md

i=0
for r in $sel; do
  i=$((i+1)); label=$(printf '#%02d' $i)
  echo "$label,$r" >> runs/sample-map.csv
  { echo "---"; echo; echo "## $label"; echo; cat "runs/$r/action-items.md"; echo; } >> ALL-ITEMS.md
done

echo "wrote ALL-ITEMS.md — $i lists ($(printf '%s\n' "$perfect" | grep -Ec '[^[:space:]]') perfect + others)"
echo "map is runs/sample-map.csv — KEEP IT CLOSED until runs/sample-grades.csv is written"
