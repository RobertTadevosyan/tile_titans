@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/core/theme/themes.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/presentation/screens/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders the real home screen at phone and tablet sizes, in English and
/// Russian.
///
/// This was impossible until GameController stopped building Firebase
/// instances in its field initialisers: constructing it threw
/// "No Firebase App '[DEFAULT]' has been created", so no test could pump any
/// screen that reads it.
///
/// Run:    flutter test test/golden --tags golden
/// Update: flutter test test/golden --tags golden --update-goldens
Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required Locale locale,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final progress = ProgressStore();
  await progress.load();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameController>(create: (_) => GameController()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ProgressStore>.value(value: progress),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: appThemeData[kDefaultTheme],
        // Pinned: the daily trial card is generated from the date, so an
        // unpinned golden fails the next morning.
        home: HomeScreen(today: DateTime(2026, 9, 30)),
      ),
    ),
  );
  // The screen kicks off preference and Firebase work it never awaits; pump a
  // bounded number of frames rather than settling forever.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final cases = <String, Size>{
    'phone': const Size(390, 844),
    'tablet': const Size(834, 1112),
  };

  for (final entry in cases.entries) {
    for (final lang in ['en', 'ru']) {
      testWidgets('home ${entry.key} $lang renders', (tester) async {
        await _pump(tester, size: entry.value, locale: Locale(lang));

        // The reviewer path: the home screen must show what makes this app
        // different, in every language and at every size.
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(tester.takeException(), isNull);

        await expectLater(
          find.byType(HomeScreen),
          matchesGoldenFile('goldens/home_${entry.key}_$lang.png'),
        );
      });
    }
  }
}
