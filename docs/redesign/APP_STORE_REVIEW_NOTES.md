# App Store Review Notes — Tile Titans

> ## Status: differentiating content is now reachable; submission still gated
>
> The ⛔ blocker on this file has been lifted. Every system described below is
> implemented, tested, and **reachable within two taps of launch** — the earlier
> warning was that none of it was visible to a reviewer, and that is no longer
> true.
>
> Two things still gate an actual submission, and they are listed in §7. Neither
> is about the game's content.

---

## 1. Context

A previous version of Tile Titans was reviewed under **Guideline 4.3(a) —
Design: Spam**, for sharing a similar binary, metadata and/or concept with other
submissions.

Our own audit agreed with the substance of that assessment. At the time of
rejection the app offered six named game modes whose entire mechanical
difference was:

| Mode | What it actually did |
|---|---|
| Timed | Started a 60-second timer |
| Challenge | Made one random cell immovable |
| Evil AI | Occasionally inserted an unmergeable `1` tile |
| Hardcore | Hid the undo button |
| Zen | Set the score to zero |

Those are presentation toggles over one rule set. The app had no home screen, no
objectives, no levels, no progression and no persistent statistics — it launched
directly into an endless board.

We are not disputing the rejection. We rebuilt the product.

## 2. What is different now

Each item is a concrete, implemented system with automated tests.

### 2.1 Titan Trials — 18 authored puzzles

A library of hand-designed puzzles in `lib/content/trials.dart`, in three
chapters. Each has a **fixed starting position**, an **objective** and
**constraints**. These are authored positions, not generated boards.

Objectives: reach a target tile · reach a score · hold N tiles of a value at
once · survive N moves · collapse the board to N tiles.
Constraints: move limit · time limit · blocked cells · no undo · no hints.

Chapters: *The Forge* (objectives), *The Proving Ground* (blocked cells, no
undo), *The Summit* (time pressure, 5×5 boards).

**Trial XII spawns no tiles at all** — a fixed position with a known three-move
solution, verified by a test that replays it. A randomly-generating merge game
cannot contain this.

### 2.2 Daily Titan Trial — deterministic, no backend

`dailyTrialFor(date)` derives a board, objective and move budget from the
calendar date through a fixed 32-bit xorshift PRNG. Every player worldwide gets
the same puzzle on the same date **with no server involved**. Tests assert the
same date always yields an identical trial, that time of day is irrelevant, and
that generated dailies meet the same integrity rules as authored ones.

### 2.3 Rule sets that actually differ

Modes are data (`lib/domain/engine/rules.dart`), not scattered conditionals:

| Mode | Mechanical difference |
|---|---|
| Classic | 4×4, standard spawn — the strategic baseline |
| Zen | **No score and no loss.** A jammed board dissolves its lowest tiles so play continues indefinitely |
| Time Attack | 90 s, **+2 s per merge** — chaining buys time, so the strategy is combos, not speed |
| Hardcore | **5×5, two tiles per move, 70% of spawns are 4s**, no undo, no hints |
| Trial | Objective-driven; ends on the goal or the limit, not on a jam |

`evilAI` was **removed**. Its implementation was defective — it gated on
`score % 3`, and score rises by merge values, so it fired arbitrarily — and its
`1` tiles were unmergeable dead weight. Its intent, spawn pressure, is now
expressed properly in Hardcore's weighting.

`test/engine/rules_test.dart` asserts **no two rule sets share a
configuration**, so the rejected condition cannot silently return.

### 2.4 Progression and statistics, separated per mode

`lib/domain/progress/` persists what the previous build computed and discarded.
Records are kept **per mode**, because the modes are not comparable: a Hardcore
score comes off a 5×5 board flooded with 4s, a Time Attack score comes from
ninety seconds, and Zen keeps no score at all.

Leaderboards are likewise split per mode (`leaderboard/<mode>/<uid>`).

15 in-app achievements drive **Path of the Titans** (Novice → Warrior →
Champion → Titan → Legend). Rank derives purely from achievement points, so it
cannot be bought or ground out — there is no currency and no IAP.

### 2.5 Visual identity

The board is no longer a cream/tan 2048 grid. Tiles carry **Titan rank sigils**
drawn as vector paths (14 original emblems, no imported artwork), the numeral
sits beneath as a label, and merges animate the tile's colour from the pair's
colour to its own with a forge bloom. A test forbids any theme from using the
classic 2048 cream `0xFFFAF3DD`.

## 3. Reviewer path

Launch the app. The home screen shows, top to bottom:

1. **CONTINUE** — resumes the current run.
2. **DAILY TITAN TRIAL** — today's objective and constraints. *Tap it* to play a
   deterministic dated puzzle; the board is the authored position, including
   blocked cells drawn as solid ✕ cells.
3. **CHOOSE YOUR CHALLENGE** — Classic / Zen / Time Attack / Hardcore, each
   card stating its rule difference. *Tap Hardcore* for the clearest contrast: a
   5×5 board, two spawns per move, undo and hints disabled.
4. **TITAN TRIALS** — *tap* for the 18 authored puzzles across three chapters,
   each showing its board size, budget and restrictions.
5. **HALL OF TITANS** — per-mode leaderboards.
6. **STATISTICS** — per-mode records, achievements, Path of the Titans.

Nothing is gated behind progress. Every trial is playable from a fresh install.

## 4. Verification

254 automated tests, all passing:

- `test/engine/board_test.dart` — move/merge rules, including that blocked cells
  partition a line and a tile merges at most once per move.
- `test/engine/tile_movement_test.dart` — movement paths.
- `test/engine/rules_test.dart` — rule sets are mechanically distinct.
- `test/engine/trials_test.dart` — every authored trial is square, legal,
  playable, **not already solved at move zero**, and sanely budgeted; plus daily
  determinism.
- `test/progress/progress_store_test.dart` — per-mode statistics, achievement
  thresholds, trial records, streak edge cases, corrupt-data recovery, and
  migration of pre-existing pooled data.
- `test/theme/themes_test.dart` — every tile of every theme clears 3.5:1
  contrast; no theme may use the 2048 cream.

## 5. Source-code origin

We audited for template origin because the rejection cited binary similarity.

**No purchased or copied game template was found.** Every dependency is a
standard platform SDK (Flutter, Firebase, `provider`, `shared_preferences`,
`audioplayers`, `device_info_plus`, Yandex Mobile Ads). There is no vendored
2048 engine. The merge logic is original, with this project's own tile-identity
and animation model.

One template artifact was found and removed: `test/widget_test.dart` was still
the stock Flutter "Counter increments" test, referencing a `MyApp` class that
does not exist here, so it could not compile.

## 6. Defects found and fixed during this work

Listed because several were user-visible and would have affected a reviewer:

1. The leaderboard overwrote a player's high score with their **current run**.
2. Tiles animated exactly one cell regardless of distance travelled.
3. Opening a trial during a cold start silently discarded its authored board.
4. `isGameOver()` treated two adjacent blocked cells as a mergeable pair, so a
   board containing them could never end.
5. The seeded PRNG could freeze at zero, making the Daily Trial degenerate.
6. Tile numerals used a guessed contrast threshold; mid-tone tiles sat at 2.36:1.
7. The board requested a banner ad it never displayed.
8. iOS could not build at all against current Xcode.

## 7. What still gates submission

Neither item is about game content:

- [ ] **Non-English translations are machine-produced.** 45 new strings were
      added across Russian, Spanish and Armenian without native review. Tests
      assert they are present and short enough not to truncate, but not that
      they read naturally.
- [ ] **The parity contract has not been walked end to end on a device** for
      every row of `AUDIT.md` §3. Core play, trials, modes, statistics, themes
      and ads have been verified on a Samsung device, a Pixel emulator and the
      iOS simulator; state restoration and the full settings matrix have not.

## 8. Honest assessment

We cannot and do not claim these changes guarantee approval.

What we can state specifically: the previous build had one rule set behind six
labels and no authored content. This build adds 18 designed puzzles, a
deterministic daily challenge, four mechanically distinct rule sets, per-mode
progression and leaderboards, and an original visual system — all covered by
tests, and all reachable within two taps of launch.

Whether that clears 4.3(a) is Apple's judgement. The difference is no longer
cosmetic, which is the bar we set ourselves after the audit.
