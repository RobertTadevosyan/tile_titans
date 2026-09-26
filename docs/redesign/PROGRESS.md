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
| Design system (`titan_design.dart`) | ✅ spacing, radius, motion, text roles, cards, metrics |
| Home screen | ✅ every feature one tap from launch |
| Localisation | ✅ 39 new strings across en/ru/es/hy (non-English needs native review) |

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

## Reachability — resolved

The differentiating content is now reachable within two taps of launch. See
`APP_STORE_REVIEW_NOTES.md` §3 for the reviewer path.

Delivered since the first checkpoint: home screen, trial runner, trials gallery,
statistics with per-mode records, mode wiring onto the new rule sets, per-mode
leaderboards, the ads rework, and the visual identity pass (Titan sigils,
scoreboard tiles, flat chrome, the Forge theme, and retirement of the 2048
cream palette).

## Remaining

- [x] **Home screen** — built and shipping. Rank masthead, prominent Continue,
      today's Daily Trial with its generated objective, a 2x2 mode gallery
      stating each rule difference, chapter progress for the 18 trials, and
      Hall of Titans / Statistics / Settings. Launch now opens here.
- [x] **Trial runner UI** — objective banner, live budget, win & fail states
- [x] **Trials gallery** — chapters, per-trial records, constraints shown
- [x] **Statistics & achievements** — per-mode records, Path of the Titans
- [x] **Mode selection** wired to the new `RuleSet`s
- [x] **Visual identity pass** — sigils, scoreboard tiles, flat chrome, Forge
- [x] **Ads** — banner off the board, moved to Home; interstitial latched;
      first two sessions ad-free
- [x] **iOS build** — was impossible against current Xcode; now runs on the
      simulator
- [ ] **Native review of ru / es / hy** — 45 new strings are machine-translated
- [ ] **Full parity-contract walk on device** — core play, trials, modes,
      statistics, themes and ads verified; state restoration and the complete
      settings matrix not yet
- [ ] **Settings still exposes the old Game Mode and AI Difficulty pickers**,
      which now duplicate (and can contradict) the home screen's mode cards

## Known gaps in verification

- The leaderboard fix is **not unit-tested**: `GameController` builds Firebase
  instances in its field initialisers, so it cannot be constructed in a test.
  It becomes testable when the controller is migrated fully onto the engine.
- The merge bloom cannot be verified by screenshot — it lasts ~320 ms and
  `adb screencap` latency is longer than that. It is covered by widget tests
  that drive the animation clock directly instead.
- Trial difficulty is machine-checked for *legality* (playable, not pre-solved,
  sane budget) but no human has played them for fairness or fun.
