import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/more_games/catalogue.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/widgets/more_games_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A row whose icon URL will never resolve, which is what every row looks
/// like offline — the state the screen is in the first time most players
/// open it.
const _app = CatalogueApp(
  id: 'am.game.colorsortx',
  name: 'Hue Lab',
  taglines: {'en': 'Pour, mix, relax.'},
  play: 'https://play.google.com/store/apps/details?id=am.game.colorsortx',
  icon: 'https://example.invalid/missing.png',
  color: 0xFF5B3DF5,
  emoji: '🧪',
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a row shows the name and tagline', (tester) async {
    await _pump(tester, CatalogueRow(app: _app, language: 'en', onTap: () {}));
    expect(find.text('Hue Lab'), findsOneWidget);
    expect(find.text('Pour, mix, relax.'), findsOneWidget);
  });

  testWidgets('an icon that cannot load still draws the emoji tile', (
    tester,
  ) async {
    // Offline, Image.network never resolves. Without a placeholder the row
    // shows an empty square where the icon belongs, which is what the first
    // build did on a device with no network.
    await _pump(tester, CatalogueIcon(app: _app, size: 56));
    expect(find.text('🧪'), findsOneWidget);

    // The tile that actually holds the emoji, not whichever ColoredBox the
    // surrounding clip happens to build first.
    final box = tester.widget<ColoredBox>(
      find
          .ancestor(of: find.text('🧪'), matching: find.byType(ColoredBox))
          .first,
    );
    expect(box.color, const Color(0xFF5B3DF5));
  });

  testWidgets('the tile is square at the requested size', (tester) async {
    await _pump(tester, CatalogueIcon(app: _app, size: 56));
    final size = tester.getSize(find.byType(CatalogueIcon));
    expect(size, const Size(56, 56));
  });

  testWidgets('tapping a row reports it once', (tester) async {
    var taps = 0;
    await _pump(
      tester,
      CatalogueRow(app: _app, language: 'en', onTap: () => taps++),
    );
    await tester.tap(find.byType(ListTile));
    expect(taps, 1);
  });
}
