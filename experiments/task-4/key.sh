#!/usr/bin/env bash
# Task 4 — the answer key, in executable form.
#
# THIS FILE IS THE KEY. The prose version in README.md is a description of it.
# Both score.sh and test-key.sh source this file, so the thing that grades the
# runs and the thing that validates the grader can never drift apart.
#
# Committed before run 1, and validated before run 1 by ./test-key.sh, which
# feeds hand-written paraphrases of each item through these same regexes.
#
# Task 1's failure was picking a flattering rule after seeing the outputs.
# A regex widened mid-batch is that failure in a new outfit. If one has to
# change after run 1, log the change in RESULTS.md with before/after numbers.

# ── The five planted action items ─────────────────────────────────────────
# A run "found" an item if any numbered line in action-items.md matches its
# regex. Anchors are distinctive entities, not phrasings, so a correct
# extraction matches regardless of how it words things.
#
# Scored on the ACTION only. Owner and date are not graded (one exception:
# the A3 owner spot-check below).

ITEM_IDS=(A1 A2 A3 A4 A5)

ITEM_LABELS=(
  "Priya sends the API scope doc — Thursday"
  "Me sends event volume estimates to Marcus — Friday"
  "Marcus spins up a sandbox tenant for Devin — no date"
  "Northwind adds plan.changed to the event catalog — no date"
  "Priya sends the Q3 usage numbers from the last integration — no date"
)

ITEM_TIERS=(
  "1 · stated outright, owner + date, and repeated in the next-steps block"
  "1 · stated outright, owner + date, and repeated in the next-steps block"
  "2 · commitment with the owner implied by who is speaking, never named"
  "3 · consequence of the webhooks decision; never phrased as a task"
  "4 · raised in the pre-call tangent, never revisited, absent from next-steps"
)

ITEM_RX=(
  'scop(e|ing) ?doc|api (scope|spec)'
  'volume|traffic (estimate|projection|number)|throughput'
  'sandbox|test (tenant|environment|account|env)|staging (tenant|environment|env)|non-?prod'
  'plan[-._ ]?chang|event catalog'
  'q3|usage (number|data|figure|stat|metric|report)'
)

# ── The five near-miss distractors ────────────────────────────────────────
# None of these is an action item. A numbered line matching one is a
# candidate false positive — score.sh prints it, a human confirms.
#
# D5 is the control: nobody should list a status report. A 0% hit rate on D5
# alongside real hits on D1/D2/D4 is evidence that false positives are
# discrimination failing on hard cases, not models spraying items at random.

DIST_IDS=(D1 D2 D3 D4 D5)

DIST_LABELS=(
  "rev-share model — unowned musing, no commitment, no date"
  "co-branded onboarding screen — proposed then explicitly parked until after the pilot"
  "mutual NDA — already signed and sent last week"
  "loop in procurement — conditional on the pilot clearing 500 connected accounts"
  "Northwind gateway migration — status report, already in flight, CONTROL"
)

DIST_RX=(
  'rev.?share|revenue.{0,10}(share|split)|pricing model|commercial terms'
  'co.?brand|branded (onboarding|screen)'
  '(^|[^a-z])nda([^a-z]|$)|non.?disclosure'
  'procurement'
  'gateway|migration'
)

# ── Secondary observation, not part of the score ──────────────────────────
# A3 is the only item whose owner is implied rather than stated. Does the run
# attribute it, or fall back to `unassigned`? One grep, no judgement.
A3_OWNER_RX='marcus|northwind'
