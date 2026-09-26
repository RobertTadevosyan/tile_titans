# Tile Titans — Redesign Plan

Companion to `AUDIT.md`. Parity contract: **`AUDIT.md` §3** — every row must still
work when this is done.

---

## Goal

Turn Tile Titans from an endless 2048 board with six cosmetic mode toggles into a
merge puzzle with **authored content**: a library of hand-designed objective-based
trials, a deterministic daily challenge, genuinely distinct rule sets, and visible
progression — presented with a Titan identity that never competes with the board
for attention. The test of success is not "does it look different" but *"can a
reviewer open the app, tap twice, and play something that plainly is not 2048."*

## Research basis

Working from established guidance rather than a fresh survey, given the
implementation-first instruction: Material 3 (tonal surfaces, state layers, 48 dp
targets), Apple HIG (safe areas, Dynamic Type outside the board, reduce-motion),
and the structural conventions of content-driven casual puzzlers — a mode/level
gallery as the launch surface, one prominent primary action, short objective
statements over instruction walls, and per-level best-result records.

---

## The differentiation decision

The brief says prefer 1–3 strong systems over many weak ones. I am building
**three**, in this order, because each is a prerequisite for the next being
credible:

### 1. Titan Trials — authored objective puzzles (the core differentiator)

A library of hand-designed trials, each with a **preset starting board**, an
**objective**, and **constraints**. Not procedural noise — authored content that
belongs to this game and can be inspected in seconds.

Objective types: reach a target tile · reach a score · create N tiles of a value ·
survive N moves · clear blockers.
Constraint types: move limit · time limit · blocked (immovable) cells · no undo ·
no hints · locked direction.

This is the thing that makes the app not-2048: a 2048 clone has no authored levels.

### 2. Daily Titan Trial — deterministic, no backend

Generated from the date via a seeded PRNG, so every player on 2026-09-26 gets the
same board, objective and constraints with **zero server infrastructure**. Records
personal best per day. Gives a reason to return and is immediately visible on the
home screen.

### 3. Real rule sets for the existing modes

Replace the one-line variations with mechanics that change how you *play*:

| Mode | New rule set |
|---|---|
| Classic | Unchanged — the strategic baseline |
| Zen | No score, no game-over; full board auto-clears the lowest tiles so a session never ends |
| Time Attack | Score attack on a clock; merges add time, so chaining buys seconds |
| Hardcore | 5×5 spawn pressure: higher-value spawns, no undo, no hints |
| Trials | Objective mode (system 1) |
| Daily | Deterministic mode (system 2) |

`evilAI` is **removed as a mode** and its concept folded into Hardcore's spawn
pressure. Its current implementation is broken (`score % 3`) and its `1`-tiles are
unmergeable dead weight. Removing a broken mode is not a feature loss.

**Not building:** relics, currencies, wildcards, multiplier tiles. They add
explanation cost and monetisation smell without strengthening the 4.3 case.

---

## Architectural prerequisite

`AUDIT.md` §7: rules currently live inside `GameController` next to `showDialog`
and Firebase calls. New rule sets cannot be layered onto that safely or testably.

**PR 1 extracts a pure engine first**, per the skill's own boundary rule:

```
lib/domain/engine/
  board.dart        immutable board + move/merge — pure, no Flutter
  rules.dart        RuleSet: spawn policy, win/lose, undo/hints allowed
  objective.dart    Objective + Constraint types and evaluation
  trial.dart        Trial definition
  seeded_random.dart deterministic PRNG for daily
lib/content/
  trials.dart       the authored trial library
```

Pure Dart, no `BuildContext`, fully unit-testable. `GameController` becomes a thin
presentation adapter over it. **This is a refactor, not a rewrite** — the move/merge
algorithm is lifted as-is because it works.

---

## Design system

One theme source; screens compose from components and never style themselves.

- **Palette:** cold iron, stone and ember. Dark-first (Titan identity reads as
  forged metal, not fantasy parchment). The classic-2048 cream `0xFFFAF3DD` Retro
  theme is retired.
- **Type:** display/heading in a strong condensed face for identity; **board
  numerals stay in a clean high-legibility face** — identity never touches the
  numbers.
- **Spacing** 4/8/12/16/24/32 · **radius** 8/12/20 · **motion** 120/200/280 ms.
- **Tile hierarchy:** milestone tiles (256/512/1024/2048/4096+) get progressively
  stronger treatment — metal→ember→molten, with a forge-flash on first reach.

The board keeps the full visual budget. Identity lives in chrome, typography,
iconography, copy and transitions — never behind the numerals.

## Information architecture

```
HomeScreen  ← new launch surface
 ├── CONTINUE / PLAY          (resumes saved run)
 ├── DAILY TITAN TRIAL        (today's objective + your best)
 ├── GAME MODES               (Classic · Zen · Time Attack · Hardcore)
 ├── TITAN TRIALS             (authored library + progress)
 ├── HALL OF TITANS           (leaderboard)
 ├── STATISTICS               (+ achievements, Path of the Titans)
 └── SETTINGS                 (themes, language, sound, board size)
```

Everything a reviewer should evaluate is one tap from launch. Nothing that
differentiates the game sits behind Settings.

## Ads changes (behaviour changes — deliberate, per `AUDIT.md` §6)

1. **Remove the banner from the active game screen.** Board is high-attention.
   Banners stay on Home, Leaderboard, Settings.
2. **Latch the interstitial** — fixes the repeat-fire bug (§6).
3. **Cap interstitials**: not before session 3, min 3 minutes apart, never
   mid-trial.
4. **Add rewarded as opt-in only**: continue-after-loss, extra undo, extra hint.
   Never forced, always declinable.

## Test plan

- Unit: engine move/merge parity vs current behaviour, objective evaluation,
  constraint enforcement, daily determinism (same date ⇒ same board).
- Content: every authored trial is solvable and its objective is reachable.
- Widget/golden: Home, Board, Trials, Stats at phone/tablet.
- Stress: 9-digit scores, 40-char names, longest locale strings.
- Delete the broken stock `widget_test.dart`.
- Parity contract walked row by row on the device.

## PR sequence

| PR | Contents | Ships? |
|---|---|---|
| 1 | Pure engine extraction + unit tests | ✅ no UI change |
| 2 | Trials + Daily + rule sets + content library | ✅ reachable via existing mode picker |
| 3 | Design system + board identity | ✅ |
| 4 | Home screen + navigation | ✅ |
| 5 | Statistics, achievements, progression | ✅ |
| 6 | Ads policy + rewarded | ✅ |
| 7 | Tests, metadata, review notes | ✅ |

## iOS release gate

I will not recommend resubmission on the strength of this plan. After
implementation I will assess against `AUDIT.md` §9 and report previous-vs-new with
the specific screens a reviewer can check — and say so plainly if the differences
are still mainly cosmetic.
