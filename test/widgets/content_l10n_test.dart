import 'package:flutter/material.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Authored content is stored as data with English identifiers. These tests
/// assert the player never sees those identifiers: every trial objective,
/// chapter and rank must render in the active language.
void main() {
  Future<AppLocalizations> localise(WidgetTester tester, Locale locale) async {
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
    return l10n;
  }

  testWidgets('the app ships ten languages', (tester) async {
    expect(AppLocalizations.supportedLocales.length, 10);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    final code = locale.languageCode;

    testWidgets('$code renders every trial objective', (tester) async {
      final l10n = await localise(tester, locale);

      for (final trial in allTrials) {
        final text = ContentStrings.objective(l10n, trial.objective);
        expect(
          text.trim(),
          isNotEmpty,
          reason: '${trial.id} has no objective text in $code',
        );
        expect(
          text,
          isNot(contains('{')),
          reason: '${trial.id} left a placeholder unfilled in $code',
        );
      }
    });

    testWidgets('$code renders the daily objective', (tester) async {
      final l10n = await localise(tester, locale);
      for (var day = 1; day <= 28; day++) {
        final trial = dailyTrialFor(DateTime(2026, 4, day));
        final text = ContentStrings.objective(l10n, trial.objective);
        expect(text.trim(), isNotEmpty);
        expect(text, isNot(contains('{')));
      }
    });

    testWidgets('$code renders chapters and ranks', (tester) async {
      final l10n = await localise(tester, locale);

      for (final chapter in trialChapters) {
        expect(ContentStrings.chapter(l10n, chapter.id).trim(), isNotEmpty);
        expect(
          ContentStrings.chapterTheme(l10n, chapter.id).trim(),
          isNotEmpty,
        );
      }
      for (final rank in ranks) {
        expect(ContentStrings.rank(l10n, rank).trim(), isNotEmpty);
      }
    });

    testWidgets('$code does not fall back to raw identifiers', (tester) async {
      final l10n = await localise(tester, locale);
      if (code == 'en') return; // English is the identifier language

      // At least one rank and one chapter must differ from the English source,
      // which would catch a locale that silently fell through to the default.
      final translatedRanks =
          ranks.where((r) => ContentStrings.rank(l10n, r) != r.name).length;
      expect(
        translatedRanks,
        greaterThan(0),
        reason: '$code ranks all fell back to English',
      );

      final translatedChapters =
          trialChapters
              .where((c) => ContentStrings.chapter(l10n, c.id) != c.name)
              .length;
      expect(
        translatedChapters,
        greaterThan(0),
        reason: '$code chapters all fell back to English',
      );
    });
  }
}
