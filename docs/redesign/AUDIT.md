# Tile Titans — Audit

Date: 2026-09-26 · Auditor: engineering + product pass ahead of redesign
Context: Apple rejected a prior submission twice under **Guideline 4.3(a) — Design: Spam**.
This audit is written to answer one question honestly: *is this game today
meaningfully different from a 2048 clone?*

---

## 1. Identity

| | |
|---|---|
| Name | Tile Titans: Merge Puzzle |
| Android id | `lets.play.game` |
| Namespace | `com.rob.tiles.flutter_2048` |
| Flutter package | `flutter_2048` |
| Version | 4.0.3+3008 (Android), iOS previously 1.0.x |
| Framework | Flutter 3.41.6 / Dart SDK ^3.7.2 |
| Platforms | Android (live), iOS (rejected), Web (Firebase Hosting) |
| Languages | English, Russian, Spanish, Armenian (43 strings each) |
| Backend | Firebase (Auth anon, Realtime DB, Analytics, Crashlytics) |
| Ads | Yandex Mobile Ads (banner ×3 placements, interstitial ×1) |
| Size | ~4,950 lines of Dart across 34 files |

**Type:** game (casual puzzle). This decides the research targets and the ads
pattern — a puzzle board is a *high-attention* surface, which matters below.

### Template-origin finding

The brief asked me to state explicitly whether this came from a purchased or
template codebase. **I found no evidence of a purchased or copied game
template.** Specifically:

- Every dependency is a legitimate platform SDK (`provider`, `audioplayers`,
  `shared_preferences`, `firebase_*`, `yandex_mobileads`, `device_info_plus`,
  `intl`). There is no 2048 engine package and no vendored third-party game code.
- The merge/move logic in `game_controller.dart` is hand-written, with this
  project's own quirks (a `Tile` id-tracking scheme, `lastMoveOffset`-based
  animation, Firebase score sync). It does not match the widely-copied
  open-source Flutter 2048 samples.
- The identifiers, comments (several in the author's voice), and commit history
  are consistent with original authorship.

**One genuine template artifact remains:** `test/widget_test.dart` is the stock
Flutter "Counter increments smoke test". It references `MyApp`, a class that does
not exist in this project (the app class is `GameApp`), so **the only test in the
repo cannot compile.** That is the single clearest "generated from a template and
never revisited" signal in the codebase, and it is also the sort of thing a
reviewer skimming a binary would never see — so it is a hygiene problem, not a 4.3
problem. It should be deleted and replaced with real tests.

So: the 4.3 rejection is **not** explained by copied code. It is explained by
product shape, which is the rest of this document.

---

## 2. Navigation map

```
GameScreen (launch — there is no home screen)
 ├── AppBar ⚡ icon  → autoplay / AI toggle
 ├── AppBar 📊 icon  → LeaderboardScreen
 └── AppBar ⚙ icon   → SettingsScreen
                        ├── theme picker
                        ├── language selector
                        ├── board size
                        ├── sound toggle
                        └── game mode picker
```

Three screens total. **The app launches directly into a playable board.**
There is no menu, no mode gallery, no statistics screen, no achievements, no
onboarding, and no way to see what the game contains without opening Settings.

---

## 3. Feature-parity contract

Every row below must still work identically after the redesign.

| Screen | Action | Calls | Expected result |
|---|---|---|---|
| Game | Swipe L/R/U/D | `moveLeft/Right/Up/Down` | Tiles shift, merge, score rises |
| Game | Undo button | `undo()` | Restores board/tiles/score one step; no-op in Hardcore |
| Game | Restart button | `resetGame()` | Fresh board, score 0 |
| Game | Hint (💡) | `getHint()` | Returns best direction per `aiDifficulty` |
| Game | Auto Play toggle | `toggleAutoPlay()` | 500 ms timer plays `getHint()` moves |
| Game | Game over | `_showGameOverDialog` + interstitial | Dialog; score to Firebase |
| Game | Timer (timed mode) | `_startTimer` | 60 s countdown, ends game |
| Game | → Leaderboard | `Navigator.push` | Leaderboard screen |
| Game | → Settings | `Navigator.push` | Settings screen |
| Leaderboard | Load scores | Firebase RTDB read | Ranked list |
| Settings | Theme select | `ThemeProvider.setTheme` + `prefs` key `theme` | Theme applies, persists |
| Settings | Language select | `LocaleManager` | Locale applies, persists |
| Settings | Board size | `prefs` key `board_size` | Grid size changes |
| Settings | Sound toggle | `prefs` key `sound_enabled` | Merge/game-over SFX on/off |
| Settings | Game mode | `setGameMode` | Mode rules apply |
| Persistence | Save/restore | keys `saved_score`, `saved_grid_size`, `saved_board`, `high_score` | Board restores on relaunch |

**Storage keys must not change** (`high_score`, `sound_enabled`, `board_size`,
`saved_score`, `saved_grid_size`, `saved_board`, `theme`). Any new state gets new keys.

---

## 4. The 4.3 problem: modes are one-line variations

This is the core finding, and it matches Apple's stated objection precisely.
Six modes are advertised. Here is what each one *actually does*, from
`_applyModeRules()` in `game_controller.dart:325`:

| Mode | Entire implementation | Honest description |
|---|---|---|
| Normal | — | Standard 2048 |
| Timed | `_startTimer()` | Standard 2048 + 60 s clock |
| Challenge | `_lockRandomTile()` | Standard 2048 + one random immovable cell |
| Evil AI | `_addEvilTile()` | Standard 2048 + stray `1` tiles |
| Hardcore | *comment only* — `undo()` early-returns | Standard 2048 with the undo button hidden |
| Zen | `score = 0` | Standard 2048 with the score forced to zero |

Zen is not a relaxation mode; it is the normal game with the scoreboard zeroed
on every update. Hardcore is not a difficulty; it is a hidden button. These are
**presentation toggles, not rule sets**. A reviewer playing three of them would
correctly conclude they are the same game, which is very likely what happened.

Supporting defects found in the same code:

- `_addEvilTile()` gates on `if (score % 3 == 0)` — the comment says
  *"every 3 moves?"*. Score increases by merge values (4, 8, 16…), not by one,
  so this fires on an essentially arbitrary subset of moves. It is not the
  intended rule.
- The `1` tiles it spawns are not powers of two and cannot participate in the
  normal merge ladder, so they act as permanent obstructions rather than a
  designed mechanic.
- `challenge` mode shares its name with the trials concept but implements none
  of it — it locks a single random tile.

There is **no objective-based content anywhere in the app**: no targets, no move
limits, no puzzle definitions, no daily content, no progression, no achievements.
Every session is an identical endless board. That is the definition of the
category Apple flagged.

---

## 5. Pain list

**Product / structure**
1. No home screen — the app opens onto a board, so nothing communicates that the
   game has modes, competition or depth. A reviewer sees 2048 within one second.
2. Modes are buried in Settings, presented as a plain picker, with no explanation
   of what each rule change means.
3. No statistics despite the controller already tracking `totalMoves`,
   `totalMerges`, `totalCreatedTiles`, `totalMergeValue` — **these are computed
   every game and then thrown away.** Nothing persists them.
4. No achievements, no progression, no reason to return tomorrow.
5. No onboarding.

**Visual identity**
6. The name promises Titans; the UI delivers a pastel green Material default.
   There is no Viking/Titan identity in type, colour, iconography or copy.
7. The `Retro` theme is the literal classic-2048 palette (`0xFFFAF3DD` cream
   background, brown board) — the exact look the brief asks to avoid.
8. Themes are `ThemeData` with one colour and one font each; they restyle the app
   bar and background but the board hierarchy is unchanged.
9. Milestone tiles (256 / 512 / 1024 / 2048) get no special treatment — reaching
   2048 looks like reaching 8.
10. Three fonts are bundled (`OpenSans`, `Orbitron`, `PressStart2P`) and used as
    per-theme novelty rather than as a type hierarchy.

**Code quality**
11. `game_controller.dart` (904 lines) mixes game rules, Firebase writes, audio,
    analytics, **and builds `showDialog`/UI** — it takes `BuildContext` and
    `AppLocalizations` into the domain layer. This blocks presentation-only
    changes and makes the rules untestable.
12. Two dead commented-out copies of `getHint()` (~50 lines).
13. `GameSettings.scroe` typo; `_showIntestitialAd` typo; `ai_difficultt.dart`
    filename typo; `deviceInfo.dart` breaks the project's own snake_case convention.
14. The only test cannot compile (see §1).

**Accessibility**
15. Tile text colour is chosen by `tile.value <= 4 ? black : white` regardless of
    theme, so contrast is not guaranteed across the five palettes.
16. No semantic labels on the board or icon-only buttons.
17. Mode/state is conveyed by colour alone in several places.

---

## 6. Ads today — two real problems

| Placement | Where | Assessment |
|---|---|---|
| Banner | Bottom of **the active game screen** | ❌ Board is the highest-attention surface in the app |
| Banner | Leaderboard | ✅ Acceptable — low-attention page |
| Banner | Settings | ✅ Acceptable |
| Interstitial | Every game over | ❌ No cap, no cooldown, no first-session grace |
| Rewarded | *none* | ⚠️ Missed: undo / continue / hint are natural opt-in exchanges |

**Bug (real, user-visible):** the interstitial is triggered from inside a
`ValueListenableBuilder` builder via `addPostFrameCallback`
(`game_screen.dart:236-240`). That builder re-runs on every rebuild while
`isOver` stays true, so the callback can fire repeatedly and request/show the
interstitial more than once for a single game over. It needs a latch.

There is also **no ad-free first session**, which is the single most damaging
setting for retention and for a reviewer's first impression.

---

## 7. Code shape — can this be a presentation-only redesign?

**Partly, and that is the key planning constraint.**

| Area | Presentation-only change possible? |
|---|---|
| Leaderboard screen | ✅ Yes |
| Settings screen | ✅ Yes |
| Board rendering / tiles | ✅ Yes — `animated_tile.dart`, `game_board.dart` are clean |
| Game screen chrome | ⚠️ Mostly — 887 lines with four near-duplicate layout builders |
| Game modes / rules | ❌ **No** — rules live inside the controller alongside UI calls |
| Statistics | ❌ No — nothing is persisted; needs a new store |
| Trials / daily / progression | ❌ No — does not exist |

Per the skill's own boundary rule: *"If the audit shows the code cannot support a
presentation-only change, extract the logic first in its own PR with tests, then
redesign."* That applies here. The controller must be split so game rules are pure
and testable **before** new modes are layered on, otherwise the new content will
be as untestable as the current modes.

---

## 8. What to keep

Genuinely good and should survive untouched:

- The **tile identity/animation model** (`Tile` with stable ids, `previousX/Y`,
  `justMerged`) — this is better than most clones and drives smooth movement.
- The **AI hint engine** with three difficulty heuristics. This is real,
  working, differentiating logic that is currently almost invisible to the user.
- **Autoplay** — genuinely unusual; a reviewer-visible feature today.
- Four-language localisation with no missing keys.
- Firebase leaderboard plumbing (anon auth + RTDB) — works, no need to touch.
- Responsive tablet/landscape/web layout branches.

---

## 9. Verdict for the App Review question

**Would today's build read as a 2048 clone?** Yes, and I think the rejection was
substantively correct rather than a mistake. Opening the app shows a 4×4 numeric
merge board on a pastel background with score/best above it. The differentiating
features that do exist (AI hints, autoplay, themes) are either hidden behind a
Settings menu or indistinguishable from the base game during play. The six modes,
which are the headline claim, are six presentations of one rule set.

**Cosmetic work will not fix this.** Repainting the board Viking-dark and renaming
the leaderboard "Hall of Titans" would leave the same game underneath. The
redesign has to add real, inspectable, objective-based content — and it has to be
reachable from the first screen.

Plan follows in `PLAN.md`.
