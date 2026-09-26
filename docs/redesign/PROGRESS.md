# Tile Titans — Where we are

Checkpoint written 2026-09-26. Read `AUDIT.md` for the findings and `PLAN.md`
for the full design. This file is the short answer to "what were we doing and
how far did we get".

---

## The actual idea

Apple rejected Tile Titans twice under **Guideline 4.3(a) — Design: Spam**.
The audit concluded the rejection was substantively correct: six advertised game
modes were six presentations of **one rule set** (Zen was `score = 0`, Hardcore
was a hidden undo button), there was no home screen, no objectives, no
progression, and no persistent statistics. The app launched straight onto an
endless 2048 board.

So the goal is **not** a reskin. It is to add real, inspectable content and make
it reachable, then dress it in a Titan identity that never competes with the
board for attention.

Three systems were chosen over many small features:

1. **Titan Trials** — 18 hand-authored puzzles with fixed starting positions,
   objectives and constraints.
2. **Daily Titan Trial** — same puzzle worldwide per date, generated from a
   seeded PRNG, no backend.
3. **Rule sets that genuinely differ** — Zen never ends, Time Attack pays
   seconds for merges, Hardcore applies real spawn pressure.

---

## Done and verified

**217 tests passing · 0 analyzer errors**

| Area | State |
|---|---|
| Pure engine (`lib/domain/engine/`) | ✅ board, rules, objectives, trials, seeded PRNG — no Flutter imports |
| Trial library (`lib/content/trials.dart`) | ✅ 18 trials in 3 chapters, integrity-tested |
| Daily trial | ✅ deterministic, date-keyed, tested |
| Progress store (`lib/domain/progress/`) | ✅ stats, 15 achievements, Path of the Titans ranks, daily streaks |
| Titan Ranks + emblems | ✅ 14 vector sigils, icon-dominant tiles |
| Merge animation | ✅ colour A→B tween + forge bloom + milestone sparks |
| Movement animation | ✅ real paths (was: always exactly one cell) |
| Leaderboard overwrite bug | ✅ fixed with a guarded transaction |
| Contrast bug | ✅ numeral colour now derived from measured luminance |

### Bugs found and fixed along the way

1. **Leaderboard overwrote high scores with the current run.**
   `saveHighScoreToFirebase(int score)` ignored its parameter; the debounced
   callback read the controller's live `score` field instead. Three paths
   reached it, including app launch. Now captures the value at call time and
   publishes via a transaction that refuses to lower an existing entry.
2. **Tiles animated exactly one cell regardless of distance.**
   `_updateTileList()` recovered tile identity by matching position *after* the
   board had moved, so any travelling tile failed to match itself and was
   rebuilt with no origin. Movement is now tracked inside the engine during the
   collapse.
3. **Seeded PRNG could freeze.** The seed was masked to 32 bits *after* the
   zero check, so a seed like `0x100000000` produced state 0 — a fixed point of
   xorshift — and every "random" value would be 0 forever.
4. **A no-op swipe consumed an undo step.** History was pushed before testing
   whether the board actually changed.
5. **Merge sound stacked.** It fired once per merged pair inside the collapse
   loop, so a four-way cascade played four overlapping copies. Now one per move.
6. **Numeral contrast was guessed from tile value**, not measured, so it was
   wrong on the darker themes.
7. **The only test in the repo could not compile** — it was the stock Flutter
   counter template referencing a `MyApp` class that does not exist here.

### Design decisions made by looking at the result, not the code

- Emblems were first drawn **centred behind the numeral**. On device the digits
  covered the middle of every sigil and both read as clutter. Moved to a corner
  mark, then — at your direction — to **icon-dominant with the numeral as a
  small label beneath**.
- The axe emblem read as a *flag on a pole* because the blade was small and
  perched at the top of a full-height haft. Redrawn with a short haft and a
  large crescent blade.
- Trial XII originally started on a completely full board, and spawning tiles
  into a clear-the-board objective fought the goal. It is now the library's one
  **fully deterministic, no-spawn puzzle** with a known 3-move solution.

---

## Not done — this is what "not ready to submit" means

The systems above are **implemented and tested, but not reachable from the UI.**
A reviewer opening the current build still sees a single endless board. The
differentiation is real but invisible, which for App Review purposes is the same
as absent.

Remaining, in order:

- [ ] **Home screen** — Play · Daily Titan Trial · Game Modes · Titan Trials ·
      Hall of Titans · Statistics. This is the blocker: it is what makes every
      other item discoverable.
- [ ] **Trial runner UI** — objective banner, move/time budget, win & fail states
- [ ] **Trials gallery** — chapters, per-trial records, progress
- [ ] **Statistics & achievements screen** — Path of the Titans
- [ ] **Mode selection** wired to the new `RuleSet`s (the engine has them; the
      live game screen still uses the old `GameMode` branches)
- [ ] **Visual identity pass** on board chrome and app bar
- [ ] **Ads** — remove the banner from the active board; latch the interstitial
      (it can currently fire repeatedly on one game over)
- [ ] **iOS gate re-assessment** and honest resubmission verdict

## Known gaps in verification

- The leaderboard fix is **not unit-tested**: `GameController` builds Firebase
  instances in its field initialisers, so it cannot be constructed in a test.
  It becomes testable when the controller is migrated fully onto the engine.
- The merge bloom cannot be verified by screenshot — it lasts ~320 ms and
  `adb screencap` latency is longer than that. It is covered by widget tests
  that drive the animation clock directly instead.
- Trial difficulty is machine-checked for *legality* (playable, not pre-solved,
  sane budget) but no human has played them for fairness or fun.
