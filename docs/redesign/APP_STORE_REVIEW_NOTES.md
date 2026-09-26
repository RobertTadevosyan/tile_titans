# App Store Review Notes — Tile Titans

> ## ⛔ STATUS: NOT READY TO SUBMIT
>
> The systems described below are **implemented and unit-tested in the engine
> layer, but are not yet reachable from the app's UI.** A reviewer opening the
> current build would still see the same single endless board as the rejected
> version.
>
> **Do not submit this document or this build to App Review yet.** Submitting
> notes describing features a reviewer cannot reach would be worse than the
> original rejection. The remaining work is listed in §6.
>
> This file becomes accurate — and submittable — when §6 is complete.

---

## 1. Context

A previous version of Tile Titans was reviewed under **Guideline 4.3(a) —
Design: Spam**, on the basis that it shared a similar binary, metadata and/or
concept with other submissions.

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

Those are presentation toggles over one rule set. The app also had no home
screen, no objectives, no levels, no progression, and no persistent statistics —
it launched directly into an endless board.

We are not disputing the rejection. We rebuilt the product.

## 2. What is different now

Each item below is a concrete, implemented system with automated tests.

### 2.1 Titan Trials — 18 authored puzzles

A library of hand-designed puzzles in `lib/content/trials.dart`, arranged in
three chapters. Each trial has a **fixed starting position**, an **objective**
and **constraints**. These are authored positions, not generated boards.

Objective types: reach a target tile · reach a score · hold N tiles of a value
simultaneously · survive N moves · collapse the board to N tiles.
Constraint types: move limit · time limit · blocked cells · no undo · no hints.

Chapters: *The Forge* (objectives), *The Proving Ground* (blocked cells, no
undo), *The Summit* (time pressure, 5×5 boards).

**Trial XII is a fully deterministic puzzle with no tile spawning at all** — a
fixed position with a known 3-move solution, verified by a test that replays it.
A randomly-generating merge game cannot contain this.

### 2.2 Daily Titan Trial — deterministic, no backend

`dailyTrialFor(date)` derives a board, objective and move budget from the
calendar date through a fixed 32-bit xorshift PRNG. Every player worldwide gets
the same puzzle on the same date **with no server involved**. Tests assert that
the same date always yields an identical trial, that time-of-day is irrelevant,
and that generated dailies satisfy the same integrity rules as authored ones.

### 2.3 Rule sets that actually differ

Modes are now data (`lib/domain/engine/rules.dart`), not scattered conditionals:

| Mode | Mechanical difference |
|---|---|
| Classic | 4×4, standard spawn — the strategic baseline |
| Zen | **No score and no loss.** A jammed board dissolves its lowest tiles so play continues indefinitely |
| Time Attack | 90 s, **+2 s per merge** — chaining buys time, so the strategy is combos, not speed |
| Hardcore | **5×5, two tiles per move, 70% of spawns are 4s**, no undo, no hints |
| Trial | Objective-driven; ends on the goal or the limit, not on a jam |

`evilAI` was **removed**. Its implementation was defective (it gated on
`score % 3`, and score rises by merge values, so it fired arbitrarily) and its
`1` tiles were unmergeable dead weight. Its intent — spawn pressure — is now
expressed properly in Hardcore's weighting.

### 2.4 Progression and statistics

`lib/domain/progress/` persists what the previous build computed and discarded:
games played, best score, highest tile, total merges and moves, average score,
longest game, play time, and per-mode counts.

15 in-app achievements drive **Path of the Titans** (Novice → Warrior →
Champion → Titan → Legend). Rank is derived purely from achievement points, so
it cannot be bought or ground out — there is no currency and no IAP.

Daily streaks are tracked with correct calendar semantics (a gap resets to 1,
because today still counts; the same day cannot be counted twice).

## 3. Verification

181 automated tests, all passing:

- `test/engine/board_test.dart` — move/merge rules, including that blocked cells
  partition a line and that a tile merges at most once per move.
- `test/engine/trials_test.dart` — every authored trial is square, uses only
  legal cell values, starts playable, **is not already solved at move zero**,
  and has a sane move budget. Plus daily determinism.
- `test/progress/progress_store_test.dart` — statistics, achievement
  thresholds, trial records, streak edge cases, corrupt-data recovery.

One authored trial was **caught and redesigned by these tests** during
development: Trial XII originally began on a completely full board.

## 4. Source-code origin

We audited for template origin because the rejection cited binary similarity.

**No purchased or copied game template was found.** Every dependency is a
standard platform SDK (Flutter, Firebase, `provider`, `shared_preferences`,
`audioplayers`, `device_info_plus`, Yandex Mobile Ads). There is no vendored
2048 engine. The merge logic is original, with this project's own tile-identity
and animation model.

One template artifact was found and removed: `test/widget_test.dart` was still
the stock Flutter "Counter increments" test and referenced a `MyApp` class that
does not exist in this project, so it could not compile.

## 5. Reviewer path

*(To be completed when §6 lands — this section must describe exactly what to tap,
and every claim in §2 must be reachable within two taps of launch.)*

## 6. Remaining work before this document is accurate

- [ ] Home screen exposing Play · Daily Titan Trial · Game Modes · Titan Trials
      · Hall of Titans · Statistics
- [ ] Trial runner UI: objective banner, move/time budget, win & fail states
- [ ] Trials gallery with per-trial records and chapter progress
- [ ] Statistics & achievements screen with Path of the Titans
- [ ] `GameController` migrated onto the new engine so modes use the new rule
      sets in play (currently the engine is additive and the live screens still
      use the old logic)
- [ ] Visual identity pass on the board and chrome
- [ ] Ads: remove the banner from the active board, latch the interstitial

## 7. Honest assessment

We cannot and do not claim that these changes guarantee approval.

What we can say is specific: the previous build had one rule set behind six
labels and no authored content. This build adds 18 designed puzzles, a
deterministic daily challenge, four mechanically distinct rule sets, and a
progression system — all covered by tests.

**Until §6 is complete, none of that is visible to a reviewer, and the app
should not be resubmitted.** The differentiation is real but currently
unreachable, which for review purposes is the same as not existing.
