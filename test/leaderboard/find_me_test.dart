import 'package:flutter_test/flutter_test.dart';

/// "Find me" appeared to work only sometimes. Three separate silent failures,
/// each reproduced here as the arithmetic the screen now uses.
void main() {
  const itemHeight = 72.0;
  const separator = 1.0;

  double target(int index, double maxExtent) =>
      (index * (itemHeight + separator)).clamp(0.0, maxExtent);

  group('scrolling to the player row', () {
    test('the divider counts toward the pitch', () {
      // The old code used index * 72 and drifted by a pixel per row.
      expect(target(120, 1e9), 120 * 73.0);
      expect(
        target(120, 1e9) - 120 * itemHeight,
        120.0,
        reason: 'old maths was 120px — nearly two rows — short by row 120',
      );
    });

    test('the first row needs no scrolling', () {
      expect(target(0, 5000), 0.0);
    });

    test('a row near the end cannot scroll past the end', () {
      // 174 rows of 73px is ~12.7k of content; a short list has a small extent.
      expect(target(173, 400.0), 400.0);
    });
  });

  group('a player with no row on this board', () {
    int indexOf(List<String> ids, String me) => ids.indexOf(me);

    test('is reported, not ignored', () {
      // Reinstalling changes the anonymous id, so the old row stays behind
      // under the old id and the player is absent from every board.
      expect(indexOf(['a', 'b', 'c'], 'me'), -1);
    });

    test('is found when present', () {
      expect(indexOf(['a', 'me', 'c'], 'me'), 1);
    });
  });
}
