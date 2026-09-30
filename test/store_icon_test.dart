@Tags(['store'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_2048/presentation/widgets/titan_emblem.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the launcher icon from the game's own emblem art.
///
/// The icon is drawn rather than designed elsewhere so it cannot drift from
/// the app: the sigil is the same `TitanEmblem` the tiles use, and the colours
/// are the Forge palette the app opens in. The icon it replaces showed a
/// 2/4/8/16 grid and the wordmark — the board of the game it was rejected for
/// resembling, plus text no one can read at 60px.
///
/// Run: flutter test test/store_icon_test.dart --tags store
const _iron = Color(0xFF15181C); // scaffold
const _ember = Color(0xFFE2703A); // primary
const _steel = Color(0xFF2A3038);

/// One candidate icon: a sigil on a forged plate.
Widget _icon(Emblem emblem, {required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 1.15,
        colors: [Color(0xFF2B2018), _iron],
        stops: [0.0, 0.72],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // A forged plate: the shape of a game tile, so the icon still reads as
        // a tile game without ever showing a numeral.
        Container(
          width: size * 0.70,
          height: size * 0.70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.155),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF39424C), _steel],
            ),
            border: Border.all(color: _ember, width: size * 0.022),
            boxShadow: [
              BoxShadow(
                color: _ember.withValues(alpha: 0.30),
                blurRadius: size * 0.09,
                spreadRadius: size * 0.005,
              ),
            ],
          ),
        ),
        TitanEmblem(
          emblem: emblem,
          color: _ember,
          size: size * 0.44,
          weight: 0.105,
        ),
      ],
    ),
  );
}

Future<void> _write(
  WidgetTester tester,
  Widget child,
  String path,
  double logical,
  double scale,
) async {
  final key = GlobalKey();
  tester.view.physicalSize = Size(logical * scale, logical * scale);
  tester.view.devicePixelRatio = scale;
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(key: key, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: scale);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// A brighter forging: the plate catches more light and the ember rim is hotter,
/// so the icon still carries on Play's white listing background, where a nearly
/// black square reads as a hole next to its neighbours.
Widget _iconHot(Emblem emblem, {required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.2,
        colors: [Color(0xFF4A2A16), Color(0xFF1B1F24)],
        stops: [0.0, 0.78],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size * 0.62,
          height: size * 0.62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFE2703A).withValues(alpha: 0.42),
                const Color(0xFFE2703A).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Container(
          width: size * 0.72,
          height: size * 0.72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4C5764), Color(0xFF2C333C)],
            ),
            border: Border.all(
              color: const Color(0xFFFF8A4C),
              width: size * 0.028,
            ),
          ),
        ),
        TitanEmblem(
          emblem: emblem,
          color: const Color(0xFFFFA061),
          size: size * 0.46,
          weight: 0.115,
        ),
      ],
    ),
  );
}

void main() {
  const out = 'build/store/icon';

  testWidgets('render icon candidates', (tester) async {
    for (final e in [
      Emblem.crossedAxes,
      Emblem.helm,
      Emblem.hammer,
      Emblem.rune,
    ]) {
      await _write(
        tester,
        _icon(e, size: 512),
        '$out/candidate_${e.name}.png',
        512,
        2.0,
      );
    }
    await _write(
      tester,
      _iconHot(Emblem.crossedAxes, size: 512),
      '$out/candidate_hot.png',
      512,
      2.0,
    );
  });

  testWidgets('render the shipping icon', (tester) async {
    // The master the launcher-icon generator slices from.
    await _write(
      tester,
      _iconHot(Emblem.crossedAxes, size: 512),
      'assets/icons/app_icon.png',
      512,
      2.0,
    );

    // Play's listing icon.
    await _write(
      tester,
      _iconHot(Emblem.crossedAxes, size: 512),
      '$out/icon_512.png',
      512,
      1.0,
    );

    // Adaptive foreground: Android masks the outer third, so the plate sits
    // inside the inner safe zone on transparency and the background colour is
    // supplied separately.
    await _write(
      tester,
      SizedBox(
        width: 512,
        height: 512,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 512 * 0.44,
                height: 512 * 0.44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(512 * 0.10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4C5764), Color(0xFF2C333C)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFF8A4C),
                    width: 512 * 0.017,
                  ),
                ),
              ),
              const TitanEmblem(
                emblem: Emblem.crossedAxes,
                color: Color(0xFFFFA061),
                size: 512 * 0.28,
                weight: 0.115,
              ),
            ],
          ),
        ),
      ),
      'assets/icons/app_icon_foreground.png',
      512,
      2.0,
    );
  });
}
