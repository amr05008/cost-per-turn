#!/usr/bin/env bash
# Task 4 — validate the answer key BEFORE run 1.
#
# The regexes in key.sh are what actually grade the runs. If they only get
# exercised against real outputs, the first time one under-matches is after
# the batch — and widening it then is picking a flattering rule after seeing
# the data. That is exactly how task 1 went wrong.
#
# So: three hand-written paraphrases per item and per distractor, written
# before any run, asserting four things at once —
#
#   1. every paraphrase of an item matches ITS OWN item regex        (recall works)
#   2. no paraphrase of an item matches ANY OTHER item regex         (no double-counting)
#   3. no paraphrase of an item matches ANY distractor regex         (no spurious FP flags)
#   4. no paraphrase of a distractor matches ANY item regex          (the one that matters most:
#                                                                     a near-miss must never score
#                                                                     as a found action item)
#
# Run this and see 0 failures before ./run.sh 1.
set -uo pipefail
cd "$(dirname "$0")"
source ./key.sh

# ── Hand-written paraphrases. Three per item, three per distractor. ───────
# Written before any run, from the fixture only. These are plausible ways a
# correct (or a fooled) extraction might phrase each line.
CASES=(
"A1|Priya — send the API scope doc — Thursday"
"A1|Priya (Northwind) — deliver the scoping document covering endpoints, auth model and pilot commitments — by Thursday"
"A1|Northwind — share API scope documentation with Kestrel — Thu"

"A2|me — send event volume estimates to Marcus — Friday"
"A2|Kestrel — provide expected traffic projections so Northwind can size the rate limit — by end of week"
"A2|Aaron — share the throughput numbers from the Segment pipe — Fri"

"A3|Marcus — spin up a sandbox tenant for Devin — no date"
"A3|Northwind — provision a test environment so Kestrel eng can build against non-prod — no date"
"A3|Northwind engineering — set up sandbox access — before build starts"

"A4|Northwind — add plan.changed to the event catalog — no date"
"A4|Marcus — implement the plan-changed webhook event, it doesn't exist today — no date"
"A4|Northwind eng — extend the event catalogue to cover plan changes — unassigned date"

"A5|Priya — send the Q3 usage numbers from the last integration — no date"
"A5|Priya — dig up and share the Q3 usage data she still owes us — no date"
"A5|Northwind — provide usage figures from the previous integration — no date"

"D1|unassigned — take a hard look at the rev-share model — no date"
"D1|Northwind — revisit the revenue share arrangement — no date"
"D1|unassigned — review the current pricing model — someday"

"D2|Sam — design the co-branded onboarding screen — after the pilot"
"D2|Kestrel design — build a cobranded first screen with Northwind's logo — TBD"
"D2|unassigned — revisit the co-brand treatment post-pilot — no date"

"D3|Priya — send the mutual NDA — done last week"
"D3|Northwind — execute the NDA — complete"
"D3|unassigned — confirm the non-disclosure agreement is signed — no date"

"D4|unassigned — loop in procurement about a real contract — if the pilot clears 500 accounts"
"D4|Priya — engage procurement for a full contract — post-pilot"
"D4|Northwind — start procurement process — conditional"

"D5|Northwind platform team — complete the gateway migration — ~6 weeks"
"D5|unassigned — wait for the new gateway migration to land — 6 wks"
"D5|Marcus — confirm timing of the platform migration — no date"
)

idx_of() {  # idx_of <id> <array-name-of-ids...>  → prints index or -1
  local want=$1; shift; local i=0
  for x in "$@"; do [ "$x" = "$want" ] && { echo $i; return; }; i=$((i+1)); done
  echo -1
}

matches() { printf '%s\n' "$2" | grep -Eqi "$1"; }

pass=0; fail=0
report() { if [ "$1" = ok ]; then pass=$((pass+1)); else fail=$((fail+1)); printf '  ✗ %s\n     %s\n' "$2" "$3"; fi; }

for case in "${CASES[@]}"; do
  id=${case%%|*}; text=${case#*|}
  ii=$(idx_of "$id" "${ITEM_IDS[@]}")
  di=$(idx_of "$id" "${DIST_IDS[@]}")

  if [ "$ii" -ge 0 ]; then
    # 1. matches its own item regex
    matches "${ITEM_RX[$ii]}" "$text" \
      && report ok || report no "$id should match its own regex" "$text"
    # 2. matches no OTHER item regex
    for j in "${!ITEM_RX[@]}"; do
      [ "$j" = "$ii" ] && continue
      matches "${ITEM_RX[$j]}" "$text" \
        && report no "$id also matches ${ITEM_IDS[$j]} — recall would double-count" "$text" \
        || report ok
    done
    # 3. matches no distractor regex
    for j in "${!DIST_RX[@]}"; do
      matches "${DIST_RX[$j]}" "$text" \
        && report no "$id also matches ${DIST_IDS[$j]} — would raise a false FP flag" "$text" \
        || report ok
    done
  else
    # 1. matches its own distractor regex
    matches "${DIST_RX[$di]}" "$text" \
      && report ok || report no "$id should match its own regex" "$text"
    # 4. matches NO item regex — a near-miss must never score as a found item
    for j in "${!ITEM_RX[@]}"; do
      matches "${ITEM_RX[$j]}" "$text" \
        && report no "$id matches ${ITEM_IDS[$j]} — a distractor would score as a found item" "$text" \
        || report ok
    done
  fi
done

echo
echo "$((pass+fail)) assertions · $pass pass · $fail fail"
[ "$fail" -eq 0 ] || { echo "FIX key.sh BEFORE RUNNING THE BATCH."; exit 1; }
echo "Key validated. Safe to run ./run.sh 1"
