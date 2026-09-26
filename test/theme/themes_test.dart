import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/core/theme/themes.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_test/flutter_test.dart';

/// Themes are a shipped feature, so every one of them must stay complete and
/// readable. Contrast is checked rather than eyeballed: the numeral colour on a
/// tile is chosen from measured luminance, and these assert the palettes that
/// feed it are sane.
void main() {
  group('theme completeness', () {
    test('every theme has ThemeData and a tile palette', () {
      for (final theme in AppTheme.values) {
        expect(appThemeData[theme], isNotNull,
            reason: '${theme.name} has no ThemeData');
        expect(tileColors[theme], isNotNull,
            reason: '${theme.name} has no tile palette');
      }
    });

    test('every palette covers the whole playable ladder', () {
      for (final theme in AppTheme.values) {
        final palette = tileColors[theme]!;
        for (var value = 2; value <= 2048; value *= 2) {
          expect(palette[value], isNotNull,
              reason: '${theme.name} is missing a colour for $value');
        }
      }
    });

    test('app bars are flat, not the Material default slab', () {
      for (final theme in AppTheme.values) {
        final elevation = appThemeData[theme]!.appBarTheme.elevation;
        expect(elevation, 0,
            reason: '${theme.name} still has a raised app bar');
      }
    });
  });

  group('tile readability', () {
    /// Mirrors the rule in AnimatedTile: the numeral is black on light tiles
    /// and white on dark ones, chosen from measured luminance.
    // Mirrors the derived crossover used by AnimatedTile.
    const crossover = 0.179;
    Color numeralFor(Color tile) => tile.computeLuminance() > crossover
        ? const Color(0xFF14181C)
        : Colors.white;

    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final lighter = la > lb ? la : lb;
      final darker = la > lb ? lb : la;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('every tile keeps its numeral legible', () {
      for (final theme in AppTheme.values) {
        final palette = tileColors[theme]!;
        for (final entry in palette.entries) {
          final ratio = contrast(entry.value, numeralFor(entry.value));
          // 4.5:1 is the WCAG AA threshold for normal text; tile numerals are
          // large and bold, so 3.5 is a fair floor and still well clear of the
          // "grey on grey" failures the audit found.
          expect(ratio, greaterThan(3.5),
              reason: '${theme.name} tile ${entry.key} has contrast '
                  '${ratio.toStringAsFixed(2)}');
        }
      }
    });
  });

  group('prominent surfaces stay readable', () {
    double contrastOf(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final lighter = la > lb ? la : lb;
      final darker = la > lb ? lb : la;
      return (lighter + 0.05) / (darker + 0.05);
    }

    test('accent-filled cards get a readable foreground in every theme', () {
      // A prominent TitanCard is filled with the theme's primary colour. The
      // win overlay, rank card and Continue button all use one, and on Forge
      // the page's near-white onSurface was invisible against ember.
      for (final theme in AppTheme.values) {
        final accent = appThemeData[theme]!.primaryColor;
        final foreground = titanForegroundOn(accent);
        final ratio = contrastOf(accent, foreground);
        expect(ratio, greaterThan(3.5),
            reason: '${theme.name} accent card contrast is '
                '${ratio.toStringAsFixed(2)}');
      }
    });

    test('a filled button on that foreground is readable too', () {
      // The overlay's primary button inverts: it is filled with the card's
      // foreground colour, so its own label must contrast with that.
      for (final theme in AppTheme.values) {
        final accent = appThemeData[theme]!.primaryColor;
        final onCard = titanForegroundOn(accent);
        final onButton = titanForegroundOn(onCard);
        expect(contrastOf(onCard, onButton), greaterThan(3.5),
            reason: '${theme.name} button label is unreadable');
      }
    });
  });

  group('identity', () {
    test('no theme uses the classic 2048 cream background', () {
      // 0xFFFAF3DD with a tan board is the most recognisable marker of a clone,
      // and the brief calls it out explicitly.
      const clone = Color(0xFFFAF3DD);
      for (final theme in AppTheme.values) {
        expect(appThemeData[theme]!.scaffoldBackgroundColor, isNot(clone),
            reason: '${theme.name} still uses the 2048 cream');
      }
    });

    test('Forge climbs from cold metal to molten', () {
      final palette = tileColors[AppTheme.Forge]!;
      final low = palette[4]!.computeLuminance();
      final milestone = palette[2048]!;

      // The 2048 tile should read as hot: strongly weighted to red and green
      // over blue.
      expect(milestone.b, lessThan(milestone.r));
      expect(low, lessThan(0.3), reason: 'low tiles should be cold iron');
    });
  });
}
