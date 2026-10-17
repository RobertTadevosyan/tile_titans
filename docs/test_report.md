# Tile Titans — pre-release test report

**Version** 4.2.0+3011 · **Date** 6 October 2026
(supersedes the 4.1.0+3010 report of 30 September; that draft was never rolled out)
**Package** `lets.play.game` · **Target** Google Play

---

## Verdict

**NO-GO**

No defect was found that would block a release. The verdict reflects **coverage
that could not be obtained**, not known breakage — four rows of the required
device matrix, a human play-test of the shipped content, and a review of eight
machine-translated languages. Details in *Not verified* below.

The 4.1.0 build is already staged on Play as a **draft** release; nothing is
rolled out, so this report costs nothing to act on.

---

## 1. Static and unit — PASS

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** (was 30) |
| `dart format --set-exit-if-changed` | clean (47 files reformatted) |
| `flutter test` | **415 passing**, 23 test files |
| Core logic: moves, scoring, save/load, undo, restart | pass |
| Solvability: all 18 trials + 30 generated dailies | pass (solver, 5 seeds each) |
| Ad policy: free sessions, cadence, cooldown, persistence | pass (10 tests) |
| Localisation parity: 10 languages | pass (29 tests) |
| Goldens: home at phone + tablet, EN + RU | pass (4 goldens, real fonts) |

### Fixed during this pass

- **`use_build_context_synchronously` ×3.** Two were inside `updateHistory`,
  which nothing calls — deleted. The third was live: the game-over dialog's
  restart action awaits a save and then pops a route that may be gone. Guarded.
- **Seven warnings**, all introduced by recent work: imports orphaned when
  `kDefaultTheme` moved and `GameMode` shrank, `final theme = Theme.of(context)`
  left unused when buttons moved to `titanButtonFill`, and a `GlobalKey` the old
  scroll-to-user maths used.
- **The home goldens were date-dependent** (found 1 Oct, during cleanup). The
  Daily Titan Trial card is generated from the calendar day, and `HomeScreen`
  read `DateTime.now()`, so all four goldens recorded on 30 Sep failed the next
  morning with a 0.35% diff — a test that breaks every midnight is worse than
  no test. `HomeScreen` now takes an optional `today`; production leaves it
  null, the goldens pin 2026-09-30. Re-recording with the pin reproduced the
  committed PNGs byte for byte, which is the proof that the date was the only
  variable.
- **Deprecations**: `withOpacity` → `withValues` (9), `WidgetsBinding.window` →
  `MediaQuery.orientationOf` / `platformDispatcher.implicitView` (2).
- **`GameController` was untestable.** It built three Firebase objects in field
  initialisers, so constructing one threw `No Firebase App '[DEFAULT]'`. That is
  why the project had never had a widget or golden test of a real screen. Two of
  those fields (`db`, `userId`) were never read at all; `analytics` is now
  resolved on use. Home goldens exist as a result.

### Suppressed with reasons, not "fixed"

- `constant_identifier_names` on `AppTheme`: those names are **persisted**.
  `ThemeProvider` writes `theme.name` and matches on it at launch, so renaming
  them to lowerCamelCase would silently reset every existing player's theme.
- `avoid_web_libraries_in_flutter` on the web device-info shim: selected only by
  `if (dart.library.html)`, never compiled into the Android or iOS app.

---

## 2. Device matrix

| Form factor | Device | Result |
|---|---|---|
| Large phone (Android, real) | Samsung SM-S928B, 1440×3120 | **PASS** — release build, all flows, 0 crashes |
| Small-ish phone (Android, real) | Xiaomi Mi A2, 1080×2160, Android 12 | **PASS** — release build, all flows, 0 crashes |
| Large phone (Android, emu) | Pixel 9 Pro XL, API 36 | **PASS** — release, monkey seeds 1 & 7 |
| Small phone (iOS) | iPhone SE simulator | **PASS** — flow walk 5/5 |
| Large phone (iOS) | iPhone 16 Pro Max, 18 Pro Max (iOS 27) | **PASS** — flow walk 5/5 each |
| Tablet (iOS) | iPad Pro 13", iPad Air 11" M3 | **PASS** — flow walk 5/5 |
| Android tablet | Pixel Tablet AVD | **NOT RUN** — emulator unavailable |
| Foldable (book) | Pixel 9 Pro Fold AVD | **NOT RUN** — emulator unavailable |
| Flip | Flip API 36 AVD | **NOT RUN** — emulator unavailable |
| Oldest Android | Small API 24 AVD | **NOT RUN** — emulator unavailable |
| iOS release on hardware | iPhone 11 | **NOT RUN** — deploy cut off; simulators cannot run release |

The Android emulator became unusable partway through this pass, and the four
rows above are recorded as not run rather than passed. It is an environment
fault on this machine, not a signal about the app. What was ruled out, in order:

- Died twice mid-monkey, then stopped booting at all, hanging with every guest
  CPU thread *and* the main loop unresponsive
  (`detected a hanging thread 'QEMU2 CPU0..3 thread'`, `'QEMU2 main loop'`).
- Not stale processes: the hang reproduces with zero `qemu-system` processes
  left, load average 1.7 and memory free.
- Not corrupt AVD state: reproduces after `-wipe-data -no-snapshot-load`.
- Not the graphics backend: reproduces on `-gpu swiftshader_indirect` with
  `-feature -Vulkan`, so the `VulkanVirtualQueue` warning in the log is not the
  cause.
- Not acceleration config: `emulator -accel-check` returns 0 and reports
  Hypervisor.Framework 27.0 healthy, and this same emulator binary ran a Pixel
  9 Pro XL API 36 image successfully earlier in this same session.

Everything the emulator can be configured out of has been tried; what is left
is host hypervisor state, which clears on a reboot of the Mac. That is the
first step in *To reach GO*.

---

## 3. Automated flows and stress

| Check | Result |
|---|---|
| `integration_test` flow walk (5 cases) | **PASS** on 4 iOS targets |
| Monkey, seed 1, 3000 events | **PASS** — 0 FATAL, 0 ANR, 0 `E/flutter` |
| Monkey, seed 7, 3000 events | **PASS** — 0 FATAL, 0 ANR, 0 `E/flutter` |
| Monkey, seed 42 | **INCONCLUSIVE** — emulator died mid-run, twice |
| Cold start timing | **NOT MEASURED** — emulator unavailable |

The flow walk opens every advertised screen by icon rather than label, so it runs
unchanged in all ten languages, and fails on a layout overflow or a route that
throws rather than requiring someone to notice it.

---

## 4. Release preflight — PASS

| Check | Result |
|---|---|
| Keys or secrets committed | none (`git ls-files` clean) |
| Purchase SDKs (must be absent) | none |
| Test AdMob app id | none — the app uses Yandex |
| `targetSdk` | 36 (Play's floor from 31 Aug 2026) |
| Permissions | `INTERNET` only |
| Privacy policy reachable | HTTP 200 |
| `app-ads.txt` reachable | HTTP 200 |
| Release AAB | builds, 62.9 MB |
| Release IPA | builds, 40.9 MB, App Store format |

---

## 5. Ads — PASS by test, PARTIAL by hand

Policy constants: 2 ad-free sessions, an interstitial every 3rd win, 3-minute
cooldown. All covered by `test/config/ad_policy_test.dart`.

Verified by hand: banner absent on a capture build, present on a normal build,
never under the board's swipe area; no interstitial on launch or mid-move. The
interstitial that used to fire on the leaderboard's "find me" — a full-screen ad
on a navigation tap, bypassing the cooldown entirely — was removed earlier this
week.

Not verified by hand: UMP/EEA consent form, ATT prompt, `ads_enabled=false`
remote kill.

---

## 6. Not verified — what NO-GO rests on

1. **Four device-matrix rows** (Android tablet, foldable, flip, API 24) and
   **iOS release on hardware**. The foldable rows matter most: fold/unfold
   mid-game is a state transition nothing else in the matrix exercises.
2. **No human has played the 18 Titan Trials.** A solver proves each is winnable
   on five seeded runs. Winnable is not fair, not fun, and not correctly ordered
   by difficulty — and for an app rejected twice under Guideline 4.3(a), whether
   the content is *good* is the entire argument.
3. **Eight of ten languages are machine-translated and unreviewed.** Parity and
   placeholders are now machine-checked, so nothing will throw or fall back to
   English; whether the Japanese reads well is unknown.
4. **Monkey seed 42** never completed on a live emulator.

None of these is a known defect. Each is a claim the release bar makes that I
cannot currently support with evidence.

---

## 7. To reach GO

- Run the four missing matrix rows once the emulator is healthy (reboot the Mac
  first; the hang survived process kills).
- Play the 18 trials, in order, and judge difficulty curve and fairness.
- Have a native speaker read at least ru, de, es — the three largest audiences
  after English.
- Deploy the release IPA to the iPhone 11 over cable and run the main journey.


---

## 8. Added in 4.2.0 — ads on every screen, landscape, More games

### What changed

- **A banner on all seven screens.** The four hand-rolled implementations are
  gone; every screen now uses one `ScreenBanner` as its
  `Scaffold.bottomNavigationBar`, so the Scaffold insets the body and an ad can
  no longer cover content on any screen or orientation. Gameplay screens pass a
  12dp gap so a swipe that overshoots the board cannot land on the ad.
- **Two networks, by region.** Yandex in RU/BY/KZ/UZ/KG/TJ/AM/AZ/GE/MD/TM,
  AdMob everywhere else. The country comes from the clock's IANA zone first
  (a VPN and the Region setting cannot change it) and the locale second; an
  unknown country falls to AdMob, which serves in more of the world. Only the
  chosen SDK is initialised.
- **One banner unit per network** instead of three Yandex units, so there is a
  single eCPM to read and one place to pause the banner.
- **UMP consent** before the first AdMob request, failing open to
  non-personalised ads on timeout.
- **Landscape** is now one two-column layout for phones and tablets alike:
  controls left, board right. The board sizes itself from the space actually
  left over rather than a fixed `shortestSide - 80`, and the control column
  scrolls when a short phone runs out of height.
- **More games**, a cross-promotion screen reading the shared `apps.json`
  catalogue, cached, with a built-in copy for the first run and offline.

### Verified

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **440 passing** (was 415; +25) |
| Region routing, 11 Yandex countries + 7 AdMob markets | pass (unit) |
| Time zone beats locale; unknown falls to AdMob | pass (unit) |
| Catalogue parsing: malformed JSON, non-HTTPS links, duplicates | pass (unit) |
| Offline icon fallback | pass (widget) |
| Release build (R8, real ad ids), Pixel 9 API 36 | **PASS** — launch + 4-screen walk, 0 crashes, 0 ANR, 0 overflow |
| Yandex routing on a `Europe/Moscow` device | **PASS** — Yandex SDK selected |
| AdMob routing (`--dart-define=AD_NETWORK=admob`) | **PASS** — UMP consent ran, no crash |
| Landscape game screen, phone | **PASS** — board fully visible, 0 overflow |
| More games, offline | **PASS** — built-in catalogue, 5 apps, self excluded |

### Found and fixed during this pass

- **`ScreenBanner` gated on `isMobile()` rather than `adsEnabled()`**, so a
  `STORE_CAPTURE` build would still have shown banners in store footage.
- **Catalogue icons were blank offline.** `Image.network`'s `loadingBuilder`
  only fires on download *progress* events, so a request that never gets a
  response at all — the offline case — drew nothing and left an empty square
  beside every name. Now uses `frameBuilder`, which reports whether a frame has
  painted whatever the reason. Covered by a widget test.
- **The landscape board was a fixed size** (`shortestSide - 80`, with
  `minSize == maxSize`), which ignored the space the new banner takes and would
  have overflowed. It now fits what is left.
- **Settings capped its width only on tablets**, so a phone in landscape — about
  850dp wide and not a "tablet" — stretched its rows the whole way across.

### Verified on a networked emulator (6 Oct, second pass)

The first pass ran on an emulator whose DNS was dead, which made every network
feature look broken. Relaunching the AVD with `-dns-server 8.8.8.8` fixed it
(the earlier `ping` failures were qemu's user-mode NAT dropping ICMP, not an
absence of connectivity). With a working network:

| Check | Result |
|---|---|
| Catalogue icons load from `apps.json` | **PASS** — all six real store icons render |
| Catalogue fetched from GitHub Pages | **PASS** — live list, not the built-in copy |
| Yandex banner, real inventory | **PASS** — live ad rendered below the content, no overlap |
| Yandex chosen on a `Europe/Moscow` device | **PASS** |

The emoji tiles seen in the first pass were the offline fallback behaving
correctly, not a defect: the code requested the real icons all along.

### Not verified in 4.2.0

1. **AdMob has never rendered a banner.** Every request returns
   `Ad failed to load : 3` (NO_FILL) — including against Google's own *test*
   unit (`…3940256099942544/6300978111`), which is supposed to fill
   unconditionally. The egress is NL, a normal AdMob market, so region does not
   explain it. The SDK also logs `Not retrying to fetch app settings`, which is
   what it does when it cannot resolve settings for the configured app id.

   The most likely explanation is the one flagged when the id was supplied: the
   AdMob app id in the manifest, `ca-app-pub-7455708815499849~7738003760`, is
   also present in the **New2048** project. If that AdMob app entry is
   registered against New2048's package rather than `lets.play.game`, AdMob
   will refuse to serve to this package — which would mean no AdMob revenue
   anywhere outside the Yandex region after rollout, and no error a player
   would ever see.

   **This should be checked in the AdMob console before rolling out**: the app
   entry that owns ad unit `…/5544994731` must be the one whose package is
   `lets.play.game`. Until then the AdMob half of this release is unproven.

2. **The four device-matrix rows** from §2 — Android tablet, foldable, flip,
   API 24 — remain unrun. Landscape was verified on one emulator only, and the
   tablet branch of the new layout has therefore never been seen.
3. **AdMob in production has never served a single impression from this app.**
   The app id is the one the user confirmed (`~7738003760`, "Tile Titans: Merge
   Puzzle"), but it is also present in the New2048 project's manifest. If those
   two apps are the same AdMob entry, fine; if not, impressions will be
   attributed to the wrong app. Worth one look in the AdMob console.

---

NO-GO
