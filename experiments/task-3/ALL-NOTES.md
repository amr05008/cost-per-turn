# Task 3 — all 20 release notes, for grading

20 runs, presented in scrambled order. Arm is **not** shown — it's in
`runs/key.csv`, which stays closed until you've filled in the table below.

## Verdicts — fill this in

Copy into `runs/grades.csv` when done (header included).

```csv
run_id,verdict,note
n01,,
n04,,
n03,,
n05,,
n02,,
n08,,
n16,,
n17,,
n15,,
n19,,
n09,,
n07,,
n18,,
n12,,
n10,,
n11,,
n20,,
n13,,
n14,,
n06,,
```

`verdict` is one of `favorite` / `acceptable` / `unusable`.

**The question:** would you paste this into App Store Connect?

Things to watch, from the answer key:

- Should be there: flashlight + retry, barcode finds more products, clear offline handling
- Should not: the AI model change, the new scan measurements, any process/doc noise
- 250-word cap

---

## 1. `n01` — 248 words

### What's New — Version 1.4.0

**A flashlight for hard-to-read labels**
Ingredient lists are tiny, and store aisles are dim. There's now a flashlight
button on the camera screen, and if a label can't be read you'll see a "Turn on
flashlight & retry" option that switches the light on for you — better light is
the most common fix for a failed scan.

**More barcodes recognized**
We added another product database, so many items that used to come back as "not
found" now return a real answer. For lots of grocery products we can now read
the manufacturer's full ingredient list instead of going by the product name
alone. When that info may be out of date, we say so and keep the confidence
level cautious — we'd rather flag uncertainty than get it wrong.

**Smarter ingredient analysis**
We moved to a newer, more capable AI model. In our testing it reads long
ingredient lists and restaurant menus more carefully, and is stricter about
borderline items like oats that aren't certified gluten-free.

**Clearer behavior on a bad connection**
If your phone is offline, the app tells you right away instead of spinning for
up to a minute. Connection problems are now described as connection problems,
so a weak signal no longer looks like the app is broken.

**Privacy**
Unchanged: we keep no record of what you scan. Diagnostic logs no longer
include scanned barcodes or results at all.

Found a scan we got wrong? Let us know.

---

## 2. `n04` — 241 words

### What's New in GlutenOrNot 1.4.0

**Scan in dim light with the flashlight**

There's now a flashlight button right on the camera screen, so you can light up dark ingredient labels. And if a label scan comes back as "Couldn't read that," the retry button offers to turn the flashlight on for you — dim light is the most common reason a scan fails, and this usually fixes it.

**More barcodes recognized**

We added another product database behind the scenes, so barcodes that used to come back as "not found" (about 1 in 7 scans) are much more likely to find your product now — often with the full ingredient list, not just the name.

**Faster, clearer messages when your connection is weak**

If you're offline or on a spotty connection, the app now tells you right away instead of spinning for up to a minute. Error messages also make it clear when the problem is your connection, so you know to try again somewhere with better signal.

**More accurate answers**

We upgraded the technology that reads and analyzes your scans. Verdicts are now more careful and consistent — especially for tricky cases like menu items and borderline ingredients.

**Bug fixes**

Fixed an issue where the flashlight sometimes wouldn't actually turn on when retrying a failed scan.

As always, GlutenOrNot keeps no record of what you scan. Thanks for using the app — and if something looks off, let us know!

---

## 3. `n03` — 246 words

### What's New in GlutenOrNot 1.4.0

**Better label scans in bad lighting**

Dim light is the most common reason a label scan fails, so we added a flashlight
you can turn on yourself.

- A new flashlight button on the camera screen. It stays on between shots, so you
  don't have to keep switching it back on.
- If we can't read a label, the "Couldn't read that" screen now offers **Turn on
  flashlight & retry** — one tap turns on the light and takes you back to the
  camera.
- Fixed a bug where the flashlight button lit up but the light didn't come on.

**Clearer messages when your connection is spotty**

- The app now checks your connection before starting a scan, so you get an
  instant, plain answer instead of waiting a minute for a scan that couldn't
  work.
- Network and timeout messages now point at your connection rather than looking
  like the app is broken — including the confusing case where a scan finished but
  the answer never reached your phone.

**More barcodes recognized, better answers**

- We added another product database, so fewer scans come back as "product not
  found." For many grocery items we can now read the full ingredient list and
  give you a real verdict instead of a general caution.
- The ingredient analysis is smarter about things like barley malt and oats that
  aren't certified gluten-free.

As always: we keep no record of what you scan.

---

## 4. `n05` — 239 words

### What's New — Version 1.4.0

**Flashlight for tricky labels**
Small print in a dim aisle is the top reason a label scan fails. There's now a flashlight button on the camera screen, and if a scan can't be read, "Turn on flashlight & retry" is one tap away. The light stays on while you keep scanning.

**More barcodes recognized**
We added another product database behind the scenes, so barcodes that used to come back as "not found" now have a much better chance of matching. For many grocery items we can also read the manufacturer's full ingredient list instead of just the product name — which means a real gluten check rather than a generic "we're not sure."

**Sharper ingredient analysis**
We upgraded the AI model that reviews ingredients. It's more careful about what matters on a celiac or gluten-free diet — barley malt, oats that aren't certified gluten-free, and restaurant dishes built on bread or pasta. Where product info comes from an older retail listing, we now flag that it may be out of date rather than calling it safe. A thorough answer can take a moment longer; we think that's the right trade.

**Clearer messages on a bad connection**
If you're offline, the app tells you straight away instead of leaving you waiting. Timeout and network messages now say it's your connection, not a broken app.

As always, we keep no record of what you scan.

---

## 5. `n02` — 245 words

### What's New in 1.4.0

Better scans in dim light, fewer "not found" dead ends, and clearer messages when your connection drops.

**Flashlight for label photos**
There's a new flashlight button right on the camera screen. And when a label photo doesn't read clearly, tap "Turn on flashlight & retry" — it lights the label for you automatically. Poor lighting is the most common fixable reason a scan fails.

**Fewer "product not found" dead ends**
We added a backup barcode database. Around 1 in 7 barcode scans used to come up empty; far more products are now found, often with the full ingredient list ready for a proper analysis instead of a name-only guess.

**Clearer connection messages**
The app now checks whether you're online before sending a scan, so you're not left waiting a minute only to fail. If the problem is your connection, we say so — in plain words.

**More careful verdicts**
The engine behind our ingredient analysis got an upgrade. It's now stricter about risky foods: menu items like bread and pasta dishes are flagged more reliably, and oats that aren't certified gluten-free get called out as a caution.

**Privacy, kept tight**
Still no record of what you scan. We closed the few spots where diagnostic data could have hinted at a specific product, and the photo-quality measurements we now collect are counts only — never your photo or its text.

Thanks for scanning with GlutenOrNot. If something misbehaves, let us know.

---

## 6. `n08` — 252 words  ⚠ over cap

### What's New in GlutenOrNot 1.4.0

This update makes scanning more reliable — especially in dim grocery aisles and on shaky connections.

**Flashlight for label photos**
- A new flashlight button on the camera screen lights up hard-to-read ingredient labels before you snap.
- If a label scan fails, "Couldn't read that" now offers **"Turn on flashlight & retry"** — dim light is the most common reason a photo can't be read.

**More barcodes found**
- Barcode scans that used to come back "product not found" now check an extra product database, so more scans return a result.
- For many grocery items we can now read the manufacturer's actual ingredient list — not just the product name — for a more confident verdict.

**Clearer messages on bad connections**
- Offline or on a weak connection? The app now tells you right away instead of spinning for up to a minute.
- Errors now say when the problem is your connection, so a momentary blip no longer looks like the app is broken.

**Smarter, safer analysis**
- We've upgraded the engine that reads ingredient lists and menus. Verdicts are just as accurate, and borderline cases (like bread or pasta dishes on menus) are flagged more cautiously — erring on the side of your safety.

**Under the hood**
- Reliability fixes for the flashlight, camera, and scan retry flow.
- As always: we never keep a record of what you scan.

Thanks for using GlutenOrNot — your reports shape what we fix next!

---

## 7. `n16` — 244 words

### What's New in GlutenOrNot 1.4.0

**A flashlight for dark labels**

Scanning ingredients in a dim pantry or poorly lit aisle? There's now a flashlight button on the camera screen. And if a label photo can't be read, the retry screen offers **"Turn on flashlight & retry"** — one tap, and the light is already on for your next shot. Dim light is the most common reason scans fail, so this should save you a lot of retakes.

**More barcodes find a product**

About 1 in 7 barcode scans used to dead-end with "product not found." We added a new product database as a backup, so many of those scans now return a real answer — often with the full ingredient list analyzed, not just a guess from the name.

**Clearer messages when your connection is the problem**

The app now checks whether you're online *before* scanning, so instead of hanging for a minute and then showing a vague "Network error," you get an instant message that points at your connection — not the app.

**Smarter, more careful answers**

Label and menu analysis now runs on a newer, more capable AI model. Verdicts are just as safe as before, and stricter where they should be — for example, flagging likely-gluten menu dishes that used to slip through.

**Plus:** fixed a bug where the flashlight button lit up but the actual LED stayed off, and made small reliability improvements throughout. Thanks for scanning with GlutenOrNot!

---

## 8. `n17` — 248 words

### What's New in GlutenOrNot 1.4.0

**Better label scans in dim light**

There's now a flashlight button right on the camera screen, so you can light up an ingredient label in a dark pantry or a dim restaurant. If a label can't be read, we'll offer to turn the flashlight on and try again — low light is the most common reason a scan fails. The flashlight stays on between retakes, and we fixed a bug where the button lit up without the light coming on.

**More barcodes found**

We added another product database, so barcodes that used to come back as "not found" now have a much better chance of matching. For many grocery items we can also pull the manufacturer's ingredient list, which means a real gluten analysis instead of a generic "be careful" result. When ingredient info comes from an older retail listing, we tell you that and keep the confidence lower — we'd rather be cautious than wrong.

**Smarter, more careful answers**

Scan results now come from a more capable AI model. In our testing it's noticeably stricter about restaurant and menu items, and better at catching things like oats that aren't certified gluten-free.

**Clearer messages on a bad connection**

If your phone is offline, you'll know right away instead of waiting for a scan that can't go through. Connection problems now say so plainly, rather than looking like the app is broken.

As always, we don't keep a record of what you scan.

---

## 9. `n15` — 250 words

### What's New in Version 1.4.0

Scanning labels in poor light just got a lot easier, and more barcodes now return an answer.

**Flashlight for label scans**
There's now a flashlight button on the camera screen, so you can light up an ingredient label in a dim restaurant or a dark grocery aisle. It stays on while you retake shots, and if a scan can't be read, we'll offer to turn the flashlight on and try again — low light is the most common fixable reason a label doesn't come through.

**More barcodes recognized**
We added another product database, so barcodes that used to come back as "not found" have a much better chance of turning up a result. For many packaged foods we can now read the full ingredient list instead of just the product name, which means a real gluten assessment rather than a generic "be cautious." When ingredient info comes from a less reliable source, we say so and keep the confidence rating lower.

**Better answers, especially for menus**
The AI behind your results has been upgraded. Verdicts on ingredient labels are as accurate as before, and restaurant menu items are now assessed more strictly.

**Clearer messages when your connection drops**
If you're offline, the app tells you right away instead of spinning for up to a minute. Connection problems now say so plainly, so a weak signal no longer looks like the app is broken.

As always, we don't keep a record of what you scan.

---

## 10. `n19` — 247 words

### What's New in Version 1.4.0

**Better scanning in dim light**

Reading a tiny label in a dark restaurant is now much easier. There's a new flashlight button on the camera screen, and it stays on between shots so you're not switching it back on for every retake. If a label can't be read, the app now offers to turn on the flashlight and try again — low light is the most common fixable reason a scan fails.

**More barcodes recognized**

We added another product database, so many barcodes that used to come back as "not found" now return a result. For lots of grocery items we can also pull the manufacturer's full ingredient list, which means a real gluten check instead of a general caution based only on the product name. Where the ingredient info comes from a retail listing that might be out of date, we say so and keep the confidence lower — we'd rather be careful.

**More careful gluten verdicts**

We upgraded the AI model behind the analysis. It's better at catching things like barley malt and oats that aren't certified gluten-free, and it's noticeably stricter about restaurant and menu items.

**Clearer messages on a bad connection**

If your phone is offline, the app tells you right away instead of spinning for half a minute. Connection problems now say so plainly, so a dropped signal doesn't look like the app is broken.

As always, we don't keep a record of what you scan.

---

## 11. `n09` — 243 words

### What's New — Version 1.4.0

**A flashlight for hard-to-read labels**

Dim light is the most common reason a label scan fails, so there's now a flashlight button on the camera screen. If a scan comes back "Couldn't read that," tap "Turn on flashlight & retry" to try again with more light. It stays on across retakes until you switch it off. We also fixed a bug where the button looked on but the light didn't come on.

**More barcodes recognized**

We added another product database, so barcodes that used to come back "not found" now have a much better chance of a real answer. When a listing includes the manufacturer's full ingredient statement, you get a complete analysis instead of a name-only "be cautious." Those listings can be out of date, so we deliberately cap how confident such a result can be, and the result tells you why.

**Clearer answers on a weak connection**

If your phone is offline, the app now says so right away instead of waiting up to a minute and then showing an error that looks like the app is broken. Network and timeout messages now point to your connection, not a mystery failure.

**Sharper ingredient analysis**

We upgraded the AI model behind the scenes. It's more cautious in borderline cases — for example, flagging oats that aren't certified gluten-free, and being stricter about dishes on restaurant menus.

As always, we keep no record of what you scan.

---

## 12. `n07` — 240 words

### What's New — Version 1.4.0

**Flashlight for label scans**
Dim lighting is the number one reason a label won't read. You can now tap the flashlight button right on the camera screen, and it stays on while you retake photos and check results. If a scan fails, the first thing we offer is "Turn on flashlight & retry" — one tap turns the light on and puts you back in the camera. We also fixed a bug where the light could look on without actually coming on.

**More barcodes found**
We added another product database, so many barcodes that used to come back as "not found" now return a result. For lots of packaged groceries we can now read the full ingredient list instead of just the product name, which means a real gluten check rather than a general caution. When ingredient info comes from an older listing, we say so and keep the confidence lower.

**Clearer, more careful answers**
We upgraded the analysis behind every scan. It's more thorough on things like non-certified oats, and stricter about restaurant and menu items where gluten is likely.

**Fewer confusing errors on a weak connection**
The app now checks your connection before scanning, so if you're offline you're told right away instead of waiting through a long timeout. Connection problems now say so, instead of looking like the app is broken.

As always, we keep no record of what you scan.

---

## 13. `n18` — 231 words

### What's New in GlutenOrNot 1.4.0

**More products found by barcode.** About 1 in 7 barcode scans used to come back as "product not found." We added a new product database as a backup, so many more barcodes now find a match — and for lots of grocery items we can pull the full ingredient list for a complete analysis instead of a best guess.

**Flashlight help for label photos.** Dim lighting is one of the most common reasons a label photo can't be read. There's now a flashlight toggle on the camera screen, and when a scan fails, the "Couldn't read that" screen offers one-tap "Turn on flashlight & retry."

**Clearer messages when your connection is the problem.** If you're offline or on a weak connection, the app now tells you right away, in plain words, instead of spinning for a minute and showing an error that made it look like the app was broken.

**Smarter, more careful analysis.** We upgraded the AI that reads your labels and menus. Verdicts are more accurate, and it's now better at catching hidden gluten risks — like bread or pasta in restaurant dishes — that used to slip through.

**Privacy, as always.** We still keep no record of what you scan — our diagnostics only ever count photo size and letters read, never the photo or text itself.

Thanks for scanning with us!

---

## 14. `n12` — 247 words

### What's New in GlutenOrNot 1.4.0

This release makes scanning more reliable, especially in dim light and on spotty connections.

**Flashlight while you scan**
There's now a flashlight toggle on the camera screen, so you can light up dark ingredient labels in pantries, restaurants, and grocery aisles. And if a scan comes back unreadable, one tap turns the flashlight on and tries again — poor lighting is the most common reason a label photo fails.

**Better results on weak connections**
- If you're offline, the app tells you right away instead of spinning for up to a minute and then failing.
- When a scan fails because of your connection, the message now says so clearly, instead of looking like the app broke.

**More barcodes recognized**
We added another product database, so many barcodes that used to come back "not found" now get a real answer — often with a full ingredient analysis.

**Smarter analysis**
We upgraded the model that reads your labels and menus. Verdicts are more careful where it matters — menu items like bread and pasta dishes are flagged more reliably.

**Your privacy, as always**
- Nothing you scan is recorded. Our analytics only ever count things (like whether a scan succeeded), never what you scanned — and we tightened the app so scan details can't leak into diagnostic logs either.

Thanks for using GlutenOrNot — and if a scan ever fails, try the flashlight first. It makes a bigger difference than you'd think.

---

## 15. `n10` — 217 words

### What's New in GlutenOrNot 1.4.0

**More products found by barcode.** We added a new product database, so barcodes that used to come back "not found" are much more likely to get a result — often with the full ingredient list, not just the product name.

**Flashlight for label photos.** Dim light is a common reason a label photo can't be read. There's now a flashlight button on the camera screen, and if a scan fails you'll get a "Turn on flashlight & retry" option for your next shot.

**Clearer messages when your connection is the problem.** The app now checks you're online before scanning, so instead of hanging and then showing a vague error, it tells you right away when your connection is the issue.

**Smarter answers.** We upgraded the AI that reads your labels. It's better at tricky cases and stricter about flagging things like bread and pasta dishes, so you're less likely to get a misleading "looks safe."

**Even stronger privacy.** Barcode numbers and scan details no longer appear in our logs or analytics at all — the app keeps no record of what you scan.

**Behind the scenes.** Anonymous, counts-only failure reporting (never what you scanned) helps us find and fix the cases where the app falls short.

Thanks for scanning with GlutenOrNot!

---

## 16. `n11` — 250 words

### What's New — Version 1.4.0

**Better scans in dim light**

There's now a flashlight button on the camera screen, and it stays on between shots while you're scanning. If we can't read a label, the first thing we offer is "Turn on flashlight & retry" — poor lighting is the most common reason a photo won't read, and the easiest to fix. We also fixed a bug where the button could light up without the light coming on.

**More barcodes recognized**

We added another product database to our lookups, so barcodes that used to come back as "not found" now have a much better chance of returning a result. For many grocery items we can pull the full ingredient list too, giving you a real gluten assessment instead of a cautious "we only know the product name."

**More careful answers**

Ingredient analysis now runs on a newer, stronger AI model. In testing it gave the same answers on packaged labels, caught more risky menu items like bread and pasta, and flagged oats that aren't certified gluten-free. When ingredient info comes from a store listing that may be out of date, we limit how confident we'll be — better a "check the package" than a wrong "safe."

**Clearer messages on a bad connection**

If you're offline, we tell you right away instead of leaving you waiting. Connection problems now say so plainly, instead of looking like the app is broken.

As always, we keep no record of what you scan.

---

## 17. `n20` — 248 words

### What's New in GlutenOrNot 1.4.0

**More barcodes recognized.** We added a new product database, so scans that used to come back "not found" are much more likely to identify your product — often with a full ingredient analysis instead of just a name.

**Flashlight help for tricky labels.** Dim lighting is one of the biggest reasons a label photo fails to read. There's now a flashlight toggle right on the camera screen, and if a scan can't read your label, you'll get a one-tap "Turn on flashlight & retry" option. We also fixed a bug where the flashlight sometimes wouldn't actually turn on.

**Clearer messages when your connection is the problem.** The app now checks whether you're online before starting a scan, so instead of hanging and then showing a confusing error, it tells you right away when the issue is your connection — not the app.

**More accurate results.** We upgraded the AI that analyzes ingredients, improving the quality and consistency of gluten-free verdicts — especially for borderline cases like oat ingredients and restaurant-style menus.

**Better reliability behind the scenes.** When a scan fails because of a timeout or network problem, the app now quietly lets us know so we can find and fix issues faster. As always, we never record what you scanned — no barcode values, no photos, no product names.

Thanks for using GlutenOrNot! If something isn't working right, reach out from the app — your reports directly shape what we fix next.

---

## 18. `n13` — 249 words

### What's New

#### Version 1.4.0

**A flashlight for hard-to-read labels**

Dim light is the most common reason a label scan fails, so there's now a
flashlight button on the camera screen. Leave it on and it stays on while
you retake shots or check another product. And if a scan comes back with
"Couldn't read that," the fix is one tap away: "Turn on flashlight & retry."

**More barcodes recognized**

We added another product database, so barcodes that used to come up empty
now have a much better chance of being found. Even better: for a lot of
grocery items we can now pull the full ingredient list and give you a real
gluten verdict, instead of only recognizing the product name and asking
you to check the label yourself.

**Sharper ingredient analysis**

We upgraded the AI model behind every verdict. It reads ingredient lists
and restaurant menus more carefully — it's stricter about dishes that are
likely to contain gluten, and it now flags oats that aren't certified
gluten-free. When ingredient info comes from a retail listing rather than
the manufacturer, we lower the confidence we show you, because that
listing may be out of date.

**Clearer messages on a weak connection**

The app now checks your connection before scanning, so if you're offline
it tells you immediately instead of leaving you waiting. Network and
timeout messages now say plainly that it's the connection, not the app.

As always, we keep no record of what you scan.

---

## 19. `n14` — 248 words

### What's New in GlutenOrNot 1.4.0

**Scan in dim light with the new flashlight**

Dark, blurry label photos are the top reason scans fail. There's now a flashlight button on the camera screen, and if a photo can't be read, you can turn it on and retry in one tap. Your setting sticks between scans.

**Clearer answers when your connection is the problem**

Offline or on a weak connection? The app now tells you right away instead of spinning for a minute before a vague error — and it says when it's your connection, not the app, so you know to find better signal and retry.

**More barcodes found**

We added another product database, so barcodes that used to come back "not found" are much more likely to get an answer — often with the real ingredient list and a full analysis instead of a cautious guess. These listings can be out of date, so they're marked lower confidence; when in doubt, photograph the label on the package.

**More careful verdicts**

The analysis behind every scan is upgraded: better at catching hidden gluten, like flagging bread and pasta dishes on menus. We also fixed a rare case where a long answer got cut off mid-scan.

**Behind the scenes**

Scans that fail from a timeout or network problem now quietly report that a failure happened — never what you scanned; we keep no record of that. It helps us fix what makes scans fail.

Thanks for scanning with GlutenOrNot!

---

## 20. `n06` — 246 words

### What's New in GlutenOrNot 1.4.0

This update makes scanning easier and more reliable — especially in dim lighting or on a weak connection.

**Flashlight for dark labels**
There's now a flashlight button on the camera screen for dim kitchens, restaurants, or grocery aisles. If a scan fails, the app will offer to turn on the flashlight and retry — one tap and you're scanning again with the light already on.

**More barcodes find a match**
About 1 in 7 barcode scans used to come back "product not found." We added a new product database, so many more items are recognized — and for lots of grocery products we can now read the actual ingredient list instead of just the product name, giving you a fuller answer.

**Better answers overall**
The analysis behind every scan got an upgrade. It's better at catching things that matter for celiac safety — like flagging non-certified oats and gluten-containing dishes that previously slipped through.

**Friendlier on bad connections**
If your connection drops or is too weak, the app now tells you right away instead of spinning for a minute and failing — and it says so, so you know to find better signal and try again.

**Privacy, as always**
What you scan stays private. This release tightens things further — the app no longer keeps any internal record of barcode values or scan contents, even in diagnostic logs.

Thanks for using GlutenOrNot! If something doesn't look right, let us know.

---

