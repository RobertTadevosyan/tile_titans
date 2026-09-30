import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every language must carry every string, with the same placeholders.
///
/// A missing key does not fail the build: gen_l10n falls back to the template,
/// so the app silently shows English to a Russian player. A placeholder that
/// differs between languages is worse — it throws at runtime, in that language
/// only, on the screen that uses it.
void main() {
  final dir = Directory('lib/l10n');
  final template = json.decode(
    File('${dir.path}/app_en.arb').readAsStringSync(),
  ) as Map<String, dynamic>;

  final keys = template.keys.where((k) => !k.startsWith('@')).toList();

  final others = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))
      .toList();

  test('there is more than one language to check', () {
    expect(others, isNotEmpty);
    expect(keys.length, greaterThan(100));
  });

  for (final file in others) {
    final lang = file.path.split('app_').last.replaceAll('.arb', '');
    final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;

    test('$lang has every string', () {
      final missing = [for (final k in keys) if (!map.containsKey(k)) k];
      expect(missing, isEmpty, reason: '$lang is missing: ${missing.join(", ")}');
    });

    test('$lang has no empty strings', () {
      final empty = [
        for (final k in keys)
          if (map.containsKey(k) && (map[k] as String).trim().isEmpty) k,
      ];
      expect(empty, isEmpty, reason: '$lang is empty at: ${empty.join(", ")}');
    });

    test('$lang uses the same placeholders as English', () {
      final pattern = RegExp(r'\{(\w+)');
      final wrong = <String>[];
      for (final k in keys) {
        if (!map.containsKey(k)) continue;
        Set<String> holes(String s) =>
            pattern.allMatches(s).map((m) => m.group(1)!).toSet()
              // ICU syntax is not a placeholder: the plural categories, and the
              // literal in an `=1{1 game}` arm, which otherwise reads as a hole
              // named "1" that exists in English and in no other language.
              ..removeWhere((h) =>
                  const {'plural', 'select', 'one', 'few', 'many', 'other',
                         'zero', 'two'}.contains(h) ||
                  int.tryParse(h) != null);
        final a = holes(template[k] as String);
        final b = holes(map[k] as String);
        if (a.difference(b).isNotEmpty || b.difference(a).isNotEmpty) {
          wrong.add('$k (en: $a, $lang: $b)');
        }
      }
      expect(wrong, isEmpty,
          reason: '$lang placeholder mismatch — these throw at runtime:\n'
              '${wrong.join("\n")}');
    });
  }

  test('no language has strings English does not', () {
    for (final file in others) {
      final lang = file.path.split('app_').last.replaceAll('.arb', '');
      final map = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final extra = map.keys
          .where((k) => !k.startsWith('@') && !template.containsKey(k))
          .toList();
      expect(extra, isEmpty, reason: '$lang has orphan keys: $extra');
    }
  });
}
