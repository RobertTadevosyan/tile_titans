import 'package:flutter/widgets.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trial names were shown verbatim from the data — "Trial IV" — in all ten
/// languages. "Trial" is an English word; only the numeral is universal.
void main() {
  group('trial names', () {
    test('every trial gets a name in the player\'s language', () async {
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));

      final first = allTrials.first;
      expect(ContentStrings.trialName(en, first), 'Trial I');
      expect(ContentStrings.trialName(ru, first), 'Испытание I');
    });

    test('the numeral counts through the whole set', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final names = [
        for (final trial in allTrials) ContentStrings.trialName(en, trial),
      ];
      expect(names.first, 'Trial I');
      expect(names[3], 'Trial IV');
      expect(names[8], 'Trial IX');
      expect(names.last, 'Trial XVIII');
      // Eighteen trials, eighteen distinct names.
      expect(names.toSet().length, allTrials.length);
    });

    test('the generated daily falls back to its own title', () async {
      final ru = await AppLocalizations.delegate.load(const Locale('ru'));
      final daily = dailyTrialFor(DateTime(2026, 9, 27));
      // It is not in the authored list, so it has no numeral to count to.
      expect(ContentStrings.trialName(ru, daily), isNot(contains('Trial')));
      expect(ContentStrings.trialName(ru, daily), contains('Ежедневное'));
    });
  });
}
