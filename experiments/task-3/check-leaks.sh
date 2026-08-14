#!/usr/bin/env bash
# Task 3 — surfacing, not grading.
#
# Five attempts at pattern-matching "did this disclose something internal"
# under-detected, each in a new way ("a newer, more capable AI model", "the
# engine behind our analysis got an upgrade", "the measurements we now
# collect"). An under-flagging checker is indistinguishable from a pass, so
# this stops guessing intent.
#
# It does two reliable things:
#   1. hard greps for named internals, which are unambiguous
#   2. prints every SENTENCE containing model / engine / AI / collect /
#      measure / track / diagnostic, so you read ~3 sentences per run
#      instead of 250 words
# The judgement is yours. That is not a limitation to fix; it is the finding.
cd "$(dirname "$0")"
HARD='PostHog|Claude|Opus|Sonnet|anthropic|ROADMAP|CLAUDE\.md|adversarial|/grill|UPCitemdb|image_kb|ocr_chars|scan_failed|merge pull request|API key|rate limit'
NOUNS='model|engine|algorithm|collect|measure|track|telemetry|instrument|analytic|diagnostic'

for f in runs/n*/release-notes.md; do
  [ -s "$f" ] || continue
  id=$(basename "$(dirname "$f")")
  w=$(wc -w < "$f" | tr -d ' ')
  t=$(grep -Eci 'flashlight|torch' "$f"); b=$(grep -Eci 'barcode|product database|not found' "$f")
  o=$(grep -Eci 'offline|connection|connectivity' "$f")
  cov="torch=$([ "$t" -gt 0 ] && echo Y || echo N) barcode=$([ "$b" -gt 0 ] && echo Y || echo N) offline=$([ "$o" -gt 0 ] && echo Y || echo N)"
  hard=$(grep -Eoi "$HARD" "$f" | sort -u | paste -sd, -)
  echo "── $id · ${w}w · $cov${hard:+  ⚠ NAMED: $hard}"
  tr '\n' ' ' < "$f" | sed 's/\([.!?]\) /\1\n/g' | grep -Ei "$NOUNS" | sed 's/^ *//;s/^/     /' | cut -c1-118
done
