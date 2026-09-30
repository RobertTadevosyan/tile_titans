import 'package:flutter_2048/domain/engine/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeededRandom', () {
    test('is reproducible for a given seed', () {
      final a = SeededRandom(12345);
      final b = SeededRandom(12345);
      final left = List.generate(50, (_) => a.nextInt(1000));
      final right = List.generate(50, (_) => b.nextInt(1000));
      expect(left, right);
    });

    test('different seeds diverge', () {
      final a = List.generate(20, (_) => SeededRandom(1).nextInt(100));
      final b = SeededRandom(2);
      expect(List.generate(20, (_) => b.nextInt(100)), isNot(a));
    });

    test('never gets stuck when the low 32 bits of the seed are zero', () {
      // Regression: xorshift has a fixed point at state 0, so masking a seed
      // like 0x100000000 down to zero used to freeze the generator and return
      // 0 forever.
      for (final seed in [0, 0x100000000, 0x200000000, 1 << 40]) {
        final random = SeededRandom(seed);
        final values = List.generate(30, (_) => random.nextInt(1000));
        expect(
          values.toSet().length,
          greaterThan(1),
          reason: 'seed $seed produced a constant sequence',
        );
      }
    });

    test('stays within bounds', () {
      final random = SeededRandom(99);
      for (var i = 0; i < 500; i++) {
        final v = random.nextInt(7);
        expect(v, greaterThanOrEqualTo(0));
        expect(v, lessThan(7));
      }
    });

    test('nextDouble stays in [0, 1)', () {
      final random = SeededRandom(7);
      for (var i = 0; i < 500; i++) {
        final v = random.nextDouble();
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThan(1.0));
      }
    });

    test('rejects a non-positive bound', () {
      expect(() => SeededRandom(1).nextInt(0), throwsArgumentError);
    });

    test('pick refuses an empty list', () {
      expect(() => SeededRandom(1).pick<int>([]), throwsArgumentError);
    });

    test('spreads values across the range rather than clustering', () {
      final random = SeededRandom(2026);
      final counts = List<int>.filled(4, 0);
      for (var i = 0; i < 4000; i++) {
        counts[random.nextInt(4)]++;
      }
      // Not a statistical proof — just enough to catch a generator that has
      // collapsed onto one value or a narrow cycle.
      for (final c in counts) {
        expect(c, greaterThan(500), reason: 'distribution: $counts');
      }
    });

    test('forDate ignores the time of day', () {
      final a = SeededRandom.forDate(DateTime(2026, 9, 26, 1, 2, 3));
      final b = SeededRandom.forDate(DateTime(2026, 9, 26, 22, 58));
      expect(
        List.generate(10, (_) => a.nextInt(100)),
        List.generate(10, (_) => b.nextInt(100)),
      );
    });
  });
}
