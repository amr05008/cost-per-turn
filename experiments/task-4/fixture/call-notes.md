# Northwind <> Kestrel — API partnership sync

Tue 14:00–14:22, Meet
Me (PM, Kestrel) · Devin (eng, Kestrel) · Sam (design, Kestrel) · Priya (PM, Northwind) · Marcus (staff eng, Northwind)

my notes, typed live, not cleaned up

~13:58 — waiting on Marcus to join
  Priya asking abt the London office. we signed the lease, 6 desks, first two eng start in Sept
  she's hiring in EMEA too, 2 PMs, says the market is brutal right now.
  P: "oh god — I still owe you the Q3 usage numbers from the last integration. that's been sitting in my drafts for a month, let me dig those up"
  me: no rush, but yes please, our exec review keeps asking for it

~14:01 — Marcus in, Priya frames why they're doing this at all
  their retention story is basically "how many tools is this account wired into." accounts w/ 2+ integrations churn at roughly a third the rate of accounts w/ zero
  so partner surface is a north star for them this year, not a side quest
  good context — means we're not asking for a favor, they want the volume
  NDA is already signed, P sent it over last week, so we can get into specifics today

~14:03 — our ask, Sam walked it
  today a Kestrel user lands and gets the same generic setup checklist regardless of what they're paying Northwind for. someone on Northwind Enterprise gets told to do 4 things that don't apply to them, and 2 things they already did
  Sam: "the first screen is the only screen where we get to look like we know who they are, and right now we look like we've never met"
  our metric is time-to-first-value, north star for the half. median is 11 days, we want single digits

~14:06 — Marcus, what exists today
  REST read endpoints — /accounts, /subscriptions, /entitlements. all fine, all pull
  no events to speak of. "there's an event catalog but it's four things and they're all billing failures"
  M: "if we go webhooks we'd have to add plan.changed to the event catalog. that's not in there today"
  also flagged: their platform team is mid-migration onto the new gateway, lands in ~6 wks. doesn't block us but any new endpoint work lands on the far side of it

~14:09 — polling vs webhooks
  P floated polling first, said it's zero new surface on their side and we could start tomorrow
  Devin pushed back hard: "at our volume we'd be hammering you for a change that happens maybe twice a month per account. 40k accounts, every 15 minutes, for two events a month. you'd rate limit us inside a day and you'd be right to"
  M didn't disagree. said the pull endpoints were never sized for that
  D also noted we already have the receiver from the Stripe integration, same payload shape — so there's nothing for us to build on our side either way

~14:11 — rate limits
  currently 60 rpm per partner key, org-level not per-account
  M reckons that's fine for pilot volume and would rather not touch it until we're past the pilot, but wants our numbers on file either way
  me: I'll send our event volume estimates Friday. Devin already has them out of the Segment pipe

~14:13 — test access
  D: can't build against prod, obviously. asked what non-prod looks like
  M: "yeah, we can get a sandbox tenant spun up for you, that's not a big lift, it's mostly a flag"
  D asked abt seeded data, M said every sandbox comes w/ a demo org already populated

~14:15 — scope
  P: "let me put the whole thing in writing. I'll have the API scope doc in your inbox Thursday — endpoints, auth model, what we'll commit to for the pilot"
  that's the artifact our eng leads will actually read, so good

~14:16 — Sam, the dead state
  Sam is worried abt what the connect flow looks like in the gap between "user authorises" and "we know what plan they're on"
  w/ polling that gap is up to 15 min of a screen that can't say anything useful
  "if there's a spinner on the first screen we've lost the entire point of doing this"

~14:17 — decision
  ok, webhooks. P agreed, M didn't object, Devin happy
  this is the one that unblocks Sam, so worth the back and forth

~14:18 — co-branded onboarding screen
  P raised doing a co-branded version of that first screen, their logo alongside ours
  Sam interested — said it'd help w/ the "who are you" problem directly
  P walked it back herself: "actually no. park that until after the pilot. it's a brand review on our side and I'm not opening that door for a six week test"

~14:19
  P, half joking: "someone should really take a hard look at the rev-share model at some point, the current one predates all of this"
  Sam asked how many partners are on the current API. M said eleven, almost all read-only reporting tools, we'd be the first writing into the onboarding path

~14:20 — what happens if it works
  P: if the pilot clears 500 connected accounts we'd want to loop in procurement abt a real contract instead of the pilot agreement
  agreed that's a bridge for later, nobody wants to open it now

~14:21 — wrap, P has a hard stop at :22
  M said his team lives in the shared doc rather than email, so that's where the scope doc will land

next steps
- Priya -> API scope doc, Thursday
- me -> event volume estimates to Marcus, Friday
-

(rest of this is a mess, will clean up later)
