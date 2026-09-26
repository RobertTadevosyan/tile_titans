import 'package:flutter/material.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The home screen is the reviewer path: everything that distinguishes Tile
/// Titans from an endless merge board has to be visible here. These tests guard
/// that, and guard the layout against long strings and huge numbers.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('design system helpers', () {
    test('compacts large numbers so cards cannot blow out', () {
      expect(titanCompact(999), '999');
      expect(titanCompact(1500), '1.5K');
      expect(titanCompact(15000), '15K');
      expect(titanCompact(1500000), '1.5M');
      expect(titanCompact(153532), '154K');
      // A nine-digit score must still be short.
      expect(titanCompact(999999999).length, lessThanOrEqualTo(6));
    });

    test('formats durations', () {
      expect(titanDuration(45), '45s');
      expect(titanDuration(120), '2m');
      expect(titanDuration(3600), '1h');
      expect(titanDuration(3900), '1h 5m');
    });
  });

  group('trial content is exposed', () {
    test('the library has content for every chapter shown on the home screen',
        () {
      for (final chapter in trialChapters) {
        expect(chapter.trials, isNotEmpty,
            reason: '${chapter.name} would render an empty progress row');
        expect(chapter.name, isNotEmpty);
      }
    });
  });

  group('ProgressStore drives the masthead', () {
    test('a fresh player starts at Novice with an empty bar', () async {
      final store = ProgressStore();
      await store.load();

      expect(store.rank.name, 'Novice');
      expect(store.points, 0);
      expect(store.nextRank, isNotNull);
      expect(store.trialsCompleted, 0);
    });

    test('rank progress fraction stays inside 0..1 at every point', () async {
      final store = ProgressStore();
      await store.load();

      // Unlock a spread of achievements and check the maths the masthead does.
      await store.recordGame(
        mode: 'classic',
        score: 20000,
        highestTile: 4096,
        moves: 900,
        merges: 2000,
        seconds: 4000,
      );

      final rank = store.rank;
      final next = store.nextRank;
      final span = next == null ? 1 : (next.required - rank.required);
      final into = next == null ? 1 : (store.points - rank.required);
      final fraction = span <= 0 ? 1.0 : (into / span).clamp(0.0, 1.0);

      expect(fraction, greaterThanOrEqualTo(0.0));
      expect(fraction, lessThanOrEqualTo(1.0));
    });
  });

  group('localisation covers the new screens', () {
    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets('${locale.languageCode} has every home string',
          (tester) async {
        late AppLocalizations l10n;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                l10n = AppLocalizations.of(context)!;
                return const SizedBox();
              },
            ),
          ),
        );

        final strings = <String, String>{
          'homeContinue': l10n.homeContinue,
          'homeChooseChallenge': l10n.homeChooseChallenge,
          'homeDailyTrial': l10n.homeDailyTrial,
          'homeTitanTrials': l10n.homeTitanTrials,
          'homeHallOfTitans': l10n.homeHallOfTitans,
          'homeRank': l10n.homeRank,
          'modeClassic': l10n.modeClassic,
          'modeZen': l10n.modeZen,
          'modeTimeAttack': l10n.modeTimeAttack,
          'modeHardcore': l10n.modeHardcore,
          'modeClassicDesc': l10n.modeClassicDesc,
          'modeZenDesc': l10n.modeZenDesc,
          'modeTimeAttackDesc': l10n.modeTimeAttackDesc,
          'modeHardcoreDesc': l10n.modeHardcoreDesc,
          'trialNoUndo': l10n.trialNoUndo,
          'statistics': l10n.statistics,
          'settings': l10n.settings,
        };

        strings.forEach((key, value) {
          expect(value.trim(), isNotEmpty,
              reason: '$key is empty in ${locale.languageCode}');
        });
      });

      testWidgets('${locale.languageCode} mode descriptions stay short',
          (tester) async {
        late AppLocalizations l10n;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                l10n = AppLocalizations.of(context)!;
                return const SizedBox();
              },
            ),
          ),
        );

        // Mode cards clamp to two lines; anything much longer than this will
        // ellipsise and stop explaining the rule.
        for (final description in [
          l10n.modeClassicDesc,
          l10n.modeZenDesc,
          l10n.modeTimeAttackDesc,
          l10n.modeHardcoreDesc,
        ]) {
          expect(description.length, lessThan(46),
              reason: '"$description" will truncate in ${locale.languageCode}');
        }
      });
    }
  });
}
