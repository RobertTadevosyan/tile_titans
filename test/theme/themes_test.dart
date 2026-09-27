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

    test('prominent cards avoid the muddy mid-luminance band', () {
      // Dark text on a mid-tone accent scores well on paper and still looks
      // washed out. Every prominent surface must land clearly dark or clearly
      // light so its text reads as deliberate.
      for (final theme in AppTheme.values) {
        final surface = titanProminentSurface(appThemeData[theme]!.primaryColor);
        final l = surface.computeLuminance();
        final settled = l <= 0.24 || l >= 0.70;
        expect(settled, isTrue,
            reason: '${theme.name} prominent surface sits at '
                '${l.toStringAsFixed(2)}, in the muddy middle');
      }
    });

    test('prominent cards clear AA for body text in every theme', () {
      // Retro's brown sat at 4.3:1 with white — readable-ish, under the floor.
      for (final theme in AppTheme.values) {
        final surface = titanProminentSurface(appThemeData[theme]!.primaryColor);
        final ratio = titanContrastRatio(surface, titanForegroundOn(surface));
        expect(ratio, greaterThanOrEqualTo(kMinBodyContrast),
            reason: '${theme.name} prominent card is only '
                '${ratio.toStringAsFixed(1)}:1');
      }
    });

    test('filled buttons are readable in every theme', () {
      // primaryColor and colorScheme.onPrimary were set independently, so the
      // pair produced Settings' restart button at 2.01:1 on Classic and
      // 1.22:1 on Dark — a dark purple label on a near-black fill.
      for (final theme in AppTheme.values) {
        final fill = titanProminentSurface(appThemeData[theme]!.primaryColor);
        final ratio = titanContrastRatio(fill, titanForegroundOn(fill));
        expect(ratio, greaterThanOrEqualTo(kMinBodyContrast),
            reason: '${theme.name} button label is only '
                '${ratio.toStringAsFixed(2)}:1');
      }
    });

    test('the app bar title is readable in every theme', () {
      // Each theme hardcoded its bar foreground and two of them picked one
      // that loses against their own fill: Classic's white on #66BB6A was
      // 2.36:1 and Ocean's 3.32:1 — on the title at the top of every screen.
      for (final theme in AppTheme.values) {
        final bar = appThemeData[theme]!.appBarTheme;
        final ratio =
            titanContrastRatio(bar.backgroundColor!, bar.foregroundColor!);
        expect(ratio, greaterThanOrEqualTo(kMinBodyContrast),
            reason: '${theme.name} app bar title is only '
                '${ratio.toStringAsFixed(2)}:1');
      }
    });

    test('end-of-game dialogs are readable in every theme', () {
      // These dialogs fill with the app bar colour. On Classic that was
      // #66BB6A with the title white and the body text left to inherit a
      // near-black onSurface — two answers in one dialog, the second unreadable.
      for (final theme in AppTheme.values) {
        final base = appThemeData[theme]!.appBarTheme.backgroundColor;
        expect(base, isNotNull, reason: '${theme.name} has no app bar colour');
        final surface = titanProminentSurface(base!);
        final ratio = titanContrastRatio(surface, titanForegroundOn(surface));
        expect(ratio, greaterThanOrEqualTo(kMinBodyContrast),
            reason: '${theme.name} dialog text is only '
                '${ratio.toStringAsFixed(1)}:1');
      }
    });

    test('secondary text on a prominent card still clears AA', () {
      // The subtitle under CONTINUE was 3.54:1: a flat 65% alpha applied to a
      // foreground that had already been chosen for a dark fill.
      for (final theme in AppTheme.values) {
        final surface = titanProminentSurface(appThemeData[theme]!.primaryColor);
        final muted = titanMutedOn(surface, titanForegroundOn(surface));
        final ratio = titanContrastRatio(surface, muted);
        expect(ratio, greaterThanOrEqualTo(kMinBodyContrast),
            reason: '${theme.name} muted text is only '
                '${ratio.toStringAsFixed(2)}:1');
      }
    });

    test('accent-filled cards get a readable foreground in every theme', () {
      // A prominent TitanCard is filled with the theme's primary colour. The
      // win overlay, rank card and Continue button all use one, and on Forge
      // the page's near-white onSurface was invisible against ember.
      for (final theme in AppTheme.values) {
        final accent = titanProminentSurface(appThemeData[theme]!.primaryColor);
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
        final accent = titanProminentSurface(appThemeData[theme]!.primaryColor);
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
