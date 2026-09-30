import 'package:flutter/material.dart';
import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_2048/presentation/widgets/merge_bloom.dart';
import 'package:flutter_2048/presentation/widgets/titan_emblem.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bloom lasts ~320 ms, which is shorter than the latency of a device
/// screenshot — so it cannot be verified by capturing the running app. These
/// tests drive the animation directly instead.
void main() {
  Widget host(Widget child, {bool disableAnimations = false}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          // Loose constraints: a tight SizedBox would force the child to fill
          // it and make size assertions meaningless.
          body: Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  group('MergeBloom', () {
    testWidgets('paints while running and stops once finished', (tester) async {
      await tester.pumpWidget(host(const MergeBloom(color: Colors.orange)));

      expect(find.byType(MergeBloom), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Part-way through the flash.
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull);

      // Past the end.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders nothing when reduce-motion is on', (tester) async {
      await tester.pumpWidget(
        host(const MergeBloom(color: Colors.orange, enabled: false)),
      );

      // Decoration is dropped entirely rather than shortened. Scoped to the
      // bloom's own subtree, since the Scaffold paints too.
      expect(
        find.descendant(
          of: find.byType(MergeBloom),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an emphatic bloom runs longer than a plain one', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const MergeBloom(color: Colors.orange, emphatic: true)),
      );
      await tester.pump(const Duration(milliseconds: 350));
      // Still animating at 350 ms; a plain bloom would already be done.
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a plain bloom completes inside its budget', (tester) async {
      await tester.pumpWidget(host(const MergeBloom(color: Colors.orange)));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.hasRunningAnimations,
        isFalse,
        reason: 'merge feedback must not outstay ~320ms',
      );
    });
  });

  group('TitanEmblem', () {
    testWidgets('every emblem in the ladder paints without error', (
      tester,
    ) async {
      for (final rank in titanRanks) {
        await tester.pumpWidget(
          host(TitanEmblem(emblem: rank.emblem, color: Colors.black, size: 48)),
        );
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${rank.name} (${rank.emblem}) failed to paint',
        );
      }
    });

    testWidgets('paints at tiny and large sizes alike', (tester) async {
      for (final size in [12.0, 24.0, 96.0, 240.0]) {
        await tester.pumpWidget(
          host(
            TitanEmblem(emblem: Emblem.crown, color: Colors.black, size: size),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'failed at $size px');
      }
    });

    testWidgets('respects the size it is given', (tester) async {
      await tester.pumpWidget(
        host(
          const TitanEmblem(emblem: Emblem.rune, color: Colors.black, size: 40),
        ),
      );
      final box = tester.getSize(find.byType(TitanEmblem));
      expect(box.width, 40);
      expect(box.height, 40);
    });
  });
}
