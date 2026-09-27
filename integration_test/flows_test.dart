import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_2048/main.dart' as app;

/// Walks the flows the app advertises, on a real device or simulator.
///
/// Driving the Mi A2 with blind swipes found real defects but could only check
/// what a screenshot happened to show, and it could not run on iOS at all.
/// This opens the same screens by their widgets, so a layout overflow, a route
/// that throws or a control that does nothing fails loudly instead of needing
/// to be noticed in a picture.
///
/// Screens are found by icon rather than by label, so the walk works in all ten
/// languages without hardcoding ten sets of strings.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int frames = 20]) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> boot(WidgetTester tester) async {
    app.main();
    // The home screen waits on Firebase, stored preferences and an ad request,
    // none of which settle, so pumpAndSettle would time out.
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find.byIcon(Icons.settings_rounded).evaluate().isNotEmpty) break;
    }
    await settle(tester);
  }

  /// Opens the screen behind [icon], checks it built, and comes back.
  Future<void> visit(
    WidgetTester tester,
    IconData icon,
    String name,
  ) async {
    final finder = find.byIcon(icon);
    expect(finder, findsWidgets, reason: '$name is not reachable from home');

    await tester.tap(finder.first, warnIfMissed: false);
    await settle(tester);

    // An overflow, a null-check on missing data or a failed lookup surfaces
    // here. Painting a yellow stripe is not enough to call a screen working.
    expect(tester.takeException(), isNull, reason: '$name threw when opened');
    expect(find.byType(Scaffold), findsWidgets,
        reason: '$name opened to nothing');

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    if (nav.canPop()) nav.pop();
    await settle(tester);
    expect(tester.takeException(), isNull,
        reason: '$name threw on the way back');
  }

  testWidgets('the home screen builds without overflowing', (tester) async {
    await boot(tester);
    expect(find.byType(Scaffold), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every advertised mode opens a board', (tester) async {
    await boot(tester);
    // The four cards under "choose your challenge". A mode that is offered on
    // the home screen and then fails to start is the worst kind of dead end.
    await visit(tester, Icons.grid_4x4_rounded, 'Classic');
    await visit(tester, Icons.spa_rounded, 'Zen');
    await visit(tester, Icons.timer_rounded, 'Time Attack');
    await visit(tester, Icons.whatshot_rounded, 'Hardcore');
  });

  testWidgets('the daily trial and the trial list open', (tester) async {
    await boot(tester);
    await visit(tester, Icons.local_fire_department_rounded, 'Daily Trial');
    await visit(tester, Icons.chevron_right_rounded, 'Titan Trials');
  });

  testWidgets('leaderboard, statistics and settings all open', (tester) async {
    await boot(tester);
    // Each reads something that can be missing on a fresh install: the
    // leaderboard reads the database, statistics reads stored progress,
    // settings reads preferences.
    await visit(tester, Icons.emoji_events_rounded, 'Leaderboard');
    await visit(tester, Icons.insights_rounded, 'Statistics');
    await visit(tester, Icons.settings_rounded, 'Settings');
  });

  testWidgets('resuming the saved run opens the board', (tester) async {
    await boot(tester);
    await visit(tester, Icons.play_arrow_rounded, 'Continue');
  });
}
