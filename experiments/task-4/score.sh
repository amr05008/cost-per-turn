#!/usr/bin/env bash
# Task 4 — mechanical scoring. This is the whole point of the task: unlike
# tasks 1-3, "was this right" is a diff, not a taste call.
#
#   ./score.sh            score every run, print per-run detail
#   ./score.sh --quiet    summary + scores.csv only
#
# Writes runs/scores.csv. Reads key.sh, which is also what test-key.sh
# validates — the grader and its test cannot drift.
#
# WHAT IS AND ISN'T MECHANICAL HERE:
#   recall     fully mechanical — distinctive anchors, no judgement
#   listed     fully mechanical — count of numbered lines
#   surplus    listed - recall, i.e. every line that did not earn a point.
#              Mechanical SURFACING of false-positive candidates; the lines are
#              printed for a human to confirm, per FINDINGS #6: write checkers
#              that over-flag and hand a person the call.
#
# Lines are assigned to items GREEDILY, first match wins, one line per item.
# That matters: a fabricated line that happens to contain an anchor ("review
# the auth model once the scope doc lands") would otherwise be absorbed into
# an already-found item and vanish from the false-positive count. Claiming
# makes it show up as surplus instead, which is the over-flagging direction.
#
# `perfect` below is therefore provisional until the surplus lines are read.
# If an unmatched line turns out to be a legitimate rephrasing of a planted
# item, that is a REGEX MISS — log it in RESULTS.md with before/after numbers,
# per the rule at the top of key.sh.
set -uo pipefail
cd "$(dirname "$0")"
source ./key.sh
QUIET=${1:-}

NUMBERED='^[[:space:]]*[0-9]+[.)]'
out=runs/scores.csv
echo "run_id,listed,recall,surplus,unassigned,found,missed,fell_for,a3_owner,perfect,shippable" > "$out"

# ── TWO VERDICT COLUMNS, ON PURPOSE ───────────────────────────────────────
# `perfect`   the PRE-REGISTERED rule: recall 5/5 and zero surplus. Kept
#             unchanged so the original metric stays auditable.
# `shippable` the REPAIRED rule: recall 5/5 and at most one `unassigned` owner.
#
# The repair is post-hoc and driven by human ground truth, not by tuning. The
# effort sweep's blind spot-check rejected two runs that scored 5/5 with zero
# surplus; both had dropped owners ("unassigned — send event volume estimates"
# is the note-taker's own commitment). An action item with no owner is a note.
#
# Validated on 32 human judgements from two independent grading sessions:
# explains all 6 recall-5/5 verdicts in the spot check, and still agrees 20/20
# with task 4's original human pass. It makes several arms look WORSE
# (opus-low 20/20 -> 15/20, haiku-high 4/20 -> 1/20), which is the opposite of
# a flattering rule.
#
# THE ANSWER KEY WAS NOT TOUCHED. What changed is how the key is aggregated
# into a verdict, logged here with before/after numbers per key.sh's rule.
tot=0; perfect_n=0; ship_n=0
for f in runs/*/action-items.md; do
  [ -s "$f" ] || continue
  id=$(basename "$(dirname "$f")"); tot=$((tot+1))

  # Items = numbered lines. If the model ignored the format, fall back to
  # non-blank lines and say so, rather than silently reporting listed=0.
  lines=$(grep -E "$NUMBERED" "$f")
  fmt=""
  if [ -z "$lines" ]; then
    lines=$(grep -E '[^[:space:]]' "$f" | grep -Ev '^[[:space:]]*#')
    fmt=" ⚠unnumbered"
  fi
  listed=$(printf '%s\n' "$lines" | grep -Ec '[^[:space:]]')

  # Greedy assignment: walk the lines in order, and let each line claim the
  # first planted item it matches that is still unclaimed. One line per item.
  # Anything that claims nothing is surplus. No pipe here — a subshell would
  # discard the claim state.
  claimed=""; surplus=""; a3line=""
  while IFS= read -r l; do
    printf '%s\n' "$l" | grep -Eq '[^[:space:]]' || continue
    got=""
    for j in "${!ITEM_RX[@]}"; do
      case " $claimed " in *" ${ITEM_IDS[$j]} "*) continue ;; esac
      if printf '%s\n' "$l" | grep -Eqi "${ITEM_RX[$j]}"; then
        got=${ITEM_IDS[$j]}; claimed="$claimed $got"
        [ "$got" = A3 ] && a3line=$l
        break
      fi
    done
    [ -n "$got" ] || surplus="$surplus$l"$'\n'
  done <<< "$lines"

  found=""; missed=""; recall=0
  for j in "${!ITEM_IDS[@]}"; do
    case " $claimed " in
      *" ${ITEM_IDS[$j]} "*) found="$found${found:+ }${ITEM_IDS[$j]}"; recall=$((recall+1)) ;;
      *)                     found="$found${found:+ }__"; missed="$missed${missed:+ }${ITEM_IDS[$j]}" ;;
    esac
  done
  sur=$(printf '%s' "$surplus" | grep -Ec '[^[:space:]]')

  # Which of the five named near-misses did it fall for?
  fps=""
  for j in "${!DIST_RX[@]}"; do
    printf '%s' "$surplus" | grep -Eqi "${DIST_RX[$j]}" && fps="$fps${fps:+ }${DIST_IDS[$j]}"
  done

  # Secondary observation only, never part of the score: A3's owner is implied
  # by who is speaking and never stated. Does the run attribute it?
  if [ -z "$a3line" ]; then a3="n/a"
  elif printf '%s\n' "$a3line" | grep -Eqi "$A3_OWNER_RX"; then a3=named
  else a3=unassigned; fi

  # Owner attribution. Every one of the five items has an owner recoverable
  # from the notes, so `unassigned` is always a miss, not a valid reading.
  una=$(printf '%s\n' "$lines" | grep -Eci 'unassigned')

  perfect=no
  [ "$recall" = 5 ] && [ "$sur" = 0 ] && { perfect=yes; perfect_n=$((perfect_n+1)); }
  shippable=no
  [ "$recall" = 5 ] && [ "$una" -le 1 ] && { shippable=yes; ship_n=$((ship_n+1)); }

  echo "$id,$listed,$recall,$sur,$una,\"$found\",\"$missed\",\"$fps\",$a3,$perfect,$shippable" >> "$out"

  [ "$QUIET" = "--quiet" ] && continue
  printf '── %s · listed=%-3s recall %s/5 [%s] · surplus=%s · unassigned=%s%s%s%s\n' \
    "$id" "$listed" "$recall" "$found" "$sur" "$una" \
    "${fps:+ · fell for: $fps}" "$fmt" \
    "$([ "$shippable" = no ] && [ "$recall" = 5 ] && echo ' · ⚠ 5/5 but owners dropped')"
  if [ "$sur" -gt 0 ]; then
    printf '%s' "$surplus" | grep -E '[^[:space:]]' | cut -c1-104 | sed 's/^[[:space:]]*/     ▸ /'
  fi
done

echo
echo "$tot runs scored · $perfect_n perfect (pre-registered: 5/5, 0 surplus)"
echo "$(printf '%*s' ${#tot} '')            $ship_n shippable (repaired: 5/5, <=1 unassigned) · wrote $out"
echo
echo "NEXT: read the ▸ lines above. Each is a false-positive CANDIDATE, not a"
echo "confirmed one. A line that is really a rephrasing of a planted item means"
echo "the regex missed — log that in RESULTS.md, do not quietly widen it."
