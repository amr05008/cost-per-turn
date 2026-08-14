# Task 4 — action items out of call notes

**The question:** every task in this repo so far was graded on taste, and model
tier tied every single time — 3/5, 3/5, 3/5 on task 2, 3/10, 3/10 on task 3.
That makes FINDINGS #1 hard to trust in either direction, because "usable" was
one person's judgement.

**So: when correctness is objective, does tier finally matter?**

This is the experiment FINDINGS §A ranks first. The output has a right answer,
the grading is a `diff`, and there is no human in the loop for the headline
number — so n can go high cheaply and the result doesn't depend on anyone's
mood.

The failure modes are symmetric and both are real. A run that lists **twenty**
action items scores 5/5 on recall trivially and is useless. A run that lists
**one** is equally useless. What's being measured is discrimination, not
diligence.

## The setup

- **Source:** `fixture/call-notes.md` — ~1,000 words of running-log notes from a
  20-minute partnership call, typed live by the PM taking them. **Synthetic and
  fully fictional**, hand-authored for this task. Ships in the repo, so it can
  never change underneath a re-run (FINDINGS #8).
- **The call:** Northwind is opening API access; Kestrel wants to build
  plan-aware onboarding on top of it. Both sides have to commit roadmap work.
  Five people — two PMs, two engineers, a designer.
- **Job:** extract the action items to `action-items.md`, one per numbered line,
  `owner — action — when`. One prompt: `prompts/action-items.txt`. The prompt
  says **nothing about how many items exist** and leans neither toward "find
  them all" nor "only the obvious ones."
- **Arms — three tiers, n=20 each, 60 runs:**

| arm | harness | model |
| --- | --- | --- |
| A | pi | Opus 5 |
| B | pi | Sonnet 5 |
| C | pi | Kimi K3 |

All on pi via OpenRouter at `--thinking high`, so the harness is held constant
and **only the model varies**. Task 2 measured the harness effect and found none
worth paying for. **No Anthropic key needed.** Measured at smoke test: **~$0.05/run, so ~$3 for the batch.**

n=20 is **pre-committed**, not a starting point. Running 15 and topping up after
seeing the rate would be p-hacking on a binary metric, and the reps are cheap
enough that there's no reason to leave the temptation lying around.

## The answer key — written before any run

The executable version is [`key.sh`](key.sh), which is what actually grades the
runs. This section describes it; **`key.sh` is the authority**.

### The five planted action items

| # | tier | the item | why it's hard |
| --- | --- | --- | --- |
| **A1** | 1 | Priya sends the API scope doc, Thursday | free — stated outright and repeated in the next-steps block |
| **A2** | 1 | I send event volume estimates to Marcus, Friday | free — same |
| **A3** | 2 | Marcus spins up a sandbox tenant for Devin | *"yeah, we can get a sandbox tenant spun up"* — the owner is whoever is speaking, and is never named |
| **A4** | 3 | Northwind adds `plan.changed` to the event catalog | at ~14:06 Marcus says *"if we go webhooks we'd have to add plan.changed to the event catalog, that's not in there today."* At ~14:17 the call decides **webhooks**. Nobody ever says "add plan.changed." Getting it means linking two moments eleven minutes apart. |
| **A5** | 4 | Priya sends the Q3 usage numbers she still owes | said at ~13:58 while waiting for Marcus to join, during small talk about an office lease. Never revisited. Absent from the next-steps block. |

### The five near-miss distractors

None of these is an action item. Listing one is a precision error, and that is
the axis that separates careful from eager.

| # | trap | in the notes |
| --- | --- | --- |
| **D1** | unowned musing | *"someone should really take a hard look at the rev-share model at some point"* — no owner, no date, nobody picks it up |
| **D2** | **retracted** | a co-branded onboarding screen is proposed, discussed, then killed by the person who raised it: *"actually no. park that until after the pilot"* |
| **D3** | already done | *"NDA is already signed, P sent it over last week"* |
| **D4** | conditional | *"if the pilot clears 500 connected accounts we'd want to loop in procurement"* — contingent on a future event |
| **D5** | status, not action | Northwind's platform team is mid-migration onto a new gateway — already in flight, not a commitment made on this call |

**D2 is the sharpest.** It *was* an action item for about ninety seconds before
it was retracted, so catching it requires reading to the end rather than
pattern-matching on proposal language.

**D5 is the control.** Nobody should list a status report. If D5 draws a 0% hit
rate while D1/D2/D4 draw real hits, that's evidence the false positives are
discrimination failing on hard cases rather than models spraying items at
random. A distractor nobody falls for still earns its place.

### Reconciliation, before the key was frozen

The synthetic-fixture risk is that the author calibrates difficulty by feel and
plants something that isn't really there. So the key was reconciled against an
independent read of the notes before anything ran: Aaron listed what he'd count,
without reading this section.

**Result: identical. All five, no sixth, no distractor listed.** He also
attributed the sandbox to Marcus unprompted, which is the A3 owner question
working — the notes never state that owner.

**What this does and doesn't establish.** It establishes that the five items are
genuinely in the text, that no sixth is hiding, and that none of the five is a
stretch. It says **nothing about difficulty**: the reader had co-designed the
experiment and knew there were five, knew the tier structure, and knew roughly
what the distractors looked like. A 5/5 from a primed reader is not evidence the
task is easy, and shouldn't be reported as if it were.

**A fourth was found by the smoke test, and the fixture changed because of it.**
The rate-limits block originally read *"I'll send our event volume estimates
Friday **so they can size it properly**"* — which states outright that Northwind
will size the limit, making it a real sixth action item. Neither reader caught
it; Opus listed it on the first run. The line now has Marcus explicitly
declining to touch the limit until after the pilot, so A2 keeps its motivation
and nobody commits to sizing anything.

**The key was not touched, and the smoke runs were discarded.** This is the
distinction the protocol turns on: fixing *unintended ambiguity in the fixture*
is repairing the instrument; adjusting the *key* to accommodate an output is the
task-1 failure. Cost of finding it: $0.15 and three runs. Everything below this
line ran against fixture `sha 757338e7f994a209` or later.

Three further near-misses were removed from the fixture during authoring because each
created a defensible sixth item: Marcus committing to seed plan data in the
sandbox, Priya committing to pull the self-serve/sales-assisted split, and
Kestrel's implied webhook-receiver work — the last killed by a line establishing
they already have a receiver from the Stripe integration.

### The partial next-steps block

The notes end with a half-typed `next steps` list containing **only A1 and A2**,
and a trailing empty bullet. This is what a real note-taker leaves behind, and
it manufactures the low-recall failure mode: a run that trusts the summary and
stops scores **2/5 recall with perfect precision**. Without it, essentially
every failure would be over-listing and only half the question gets measured.

## Grading

**The headline is mechanical.** `./score.sh` reads each `action-items.md` and
emits one line per run:

```
── c07 · listed=9   recall 4/5 [A1 A2 A3 __ A5] · surplus=5 · fell for: D1 D2 D4
     ▸ 5. unassigned — take a hard look at the rev-share model — no date
     ▸ 6. Sam — design the co-branded onboarding screen — after the pilot
     ▸ 7. unassigned — loop in procurement about a real contract — post-pilot
     ▸ 8. Devin — review the auth model once the scope doc lands — no date
     ▸ 9. Sam — resolve the connect flow dead state — no date
```

| number | how it's derived | judgement? |
| --- | --- | --- |
| `recall` /5 | grep for each item's distinctive anchor (`plan.changed`, `sandbox`, `Q3`) | none |
| `listed` | count of numbered lines | none |
| `surplus` | `listed − recall` — every line that didn't earn a point, i.e. the **false-positive candidates** | printed for a human to confirm |
| `perfect` | `recall == 5 && surplus == 0` | provisional until the ▸ lines are read |

**Lines are assigned to items greedily, first match wins, one line per item.**
That detail is load-bearing. Line 8 in the sample above — *"review the auth
model once the scope doc lands"* — is fabricated but contains A1's anchor. Without
claiming it would be absorbed into an already-found item and vanish from the
false-positive count, silently flattering the run. Claiming pushes it into
surplus instead, which is the over-flagging direction.

**Headline metric: cost per perfect extraction.**

The `listed` distribution is the chart that carries this: *same prompt, same
document, 60 runs, answers ranging from N to M.* No judgement anywhere in it.

Scored on the **action only** — owner and date are not graded. The one
exception is a free secondary observation on A3, the only item whose owner is
implied rather than stated: does the run name Marcus/Northwind, or fall back to
`unassigned`?

### Why `surplus` is surfaced rather than scored

FINDINGS #6, ten failed attempts: write checkers that over-flag and hand a
person the call. A line that turns out to be a legitimate rephrasing of a
planted item is a **regex miss**, and it gets logged in RESULTS.md with
before/after numbers — never quietly widened. That rule is at the top of
`key.sh`.

### The one human pass

`./sample-for-grading.sh` builds a **stratified sample** — every perfect run
plus 10 others, ~20 lists — for a single question: *would you send this as the
follow-up from that call, unedited?* That answers prediction 5 without turning
task 4 into another taste task.

**Blinding needs more care here than in tasks 2 and 3.** Three arms interleaved
strictly means `run_index mod 3` **is** the arm — c07 is always arm A. Scrambling
order isn't enough, because the run id itself leaks it. So `ALL-ITEMS.md` carries
anonymous labels and the map lives in `runs/sample-map.csv`, closed until
`runs/sample-grades.csv` is written.

## Running it

```bash
./test-key.sh            # validate the key BEFORE anything runs — expect 0 failures
./run.sh 1               # smoke test, one per arm
./score.sh               # check it scores sensibly on 3 runs
./run.sh                 # 60 runs
python3 ../../scripts/extract-runs.py runs
./score.sh
./sample-for-grading.sh  # then grade ALL-ITEMS.md, then --join
```

## Predictions, written before running

1. **A1 and A2 hit ~100% in every arm.** The discriminators are **A4** (the
   decision that obligates work) and **A5** (the buried tangent).
2. **Precision, not recall, is where tier shows up — if it shows up at all.**
   Recall is a reading-comprehension task; knowing that a parked item is no
   longer an action item is closer to judgement.
3. **`listed` varies more *within* an arm than *between* arms.** Third
   confirmation of FINDINGS #4 if it holds, and the most quotable chart here.
4. **D2, the retracted item, is the most common false positive**, ahead of D1
   and D4. D5 draws close to zero.
5. **Mechanical `perfect` and the human "would you send this" verdict disagree
   on ≥20% of the sampled runs.** First task where both numbers exist.

## Caveats

- **The fixture is synthetic, authored by someone who knew the answer.** Task 3
  used a real changelog, where difficulty was whatever it happened to be; here
  difficulty is a design choice, and a badly calibrated ladder produces either
  all 5/5 or all 2/5. Mitigation: the key is reconciled against an independent
  cold read of the notes before it is frozen, and `./test-key.sh` validates the
  regexes against hand-written paraphrases before run 1.
- **`--thinking high` is held constant, and that is a real limitation.**
  Reasoning effort is plausibly the single biggest lever on over-listing — more
  deliberation, more candidate items — and it is untested. That's arm O's
  question. This fixture would be a good home for it, and the result here should
  be read as *at high effort*, not in general.
- **One fixture, one call, five items.** A different call with a different mix
  of explicit and implied commitments could move all of this.
- **Recall is measured by anchor, not by meaning.** A run that names
  `plan.changed` in a garbled item still scores the point. The `▸` dump is the
  check on that, and it is a human one.
- **If a run reveals genuine ambiguity in the fixture text**, the fix is to the
  *fixture*, and the batch restarts. The key is never amended mid-batch — that
  is the task-1 failure this whole protocol is built around.

## Designed-in follow-up (not run here)

**Task 4b — the same rig, a second fixture containing only two real action
items.** If models still report ~5, that is eagerness nailed to the wall, and it
separates "reads carefully" from "produces the expected shape of an answer."
One extra fixture, identical machinery, doubles the batch.
