import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts before the golden tests run.
///
/// Without this, a widget test draws every glyph as a filled box: the goldens
/// still catch layout and overflow, but not a truncated Russian button, which
/// is one of the things they exist to catch.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    var any = false;
    for (final p in paths) {
      final f = File(p);
      if (f.existsSync()) {
        loader.addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
        any = true;
      }
    }
    if (any) await loader.load();
  }

  // The app's own faces, plus the icon font, from the Flutter cache.
  final cache = File(Platform.resolvedExecutable).parent.path;
  final material = [
    '$cache/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '${Platform.environment['FLUTTER_ROOT'] ?? ''}'
        '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  final roboto = [
    '${Platform.environment['FLUTTER_ROOT'] ?? ''}'
        '/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  ];

  await load('OpenSans', ['assets/fonts/OpenSans-Regular.ttf']);
  await load('Orbitron', ['assets/fonts/Orbitron-Regular.ttf']);
  await load('PressStart2P', ['assets/fonts/PressStart2P-Regular.ttf']);
  await load('Roboto', roboto);
  await load('MaterialIcons', material);

  await testMain();
}
