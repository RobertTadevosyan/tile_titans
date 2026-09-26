/// A small deterministic PRNG.
///
/// The Daily Titan Trial has to produce the same board for every player on a
/// given date with no server involved, so it cannot use `dart:math`'s `Random`
/// (whose sequence is not guaranteed stable across platforms or SDK versions).
/// This is a 32-bit xorshift: tiny, stable, and good enough for board layout.
class SeededRandom {
  int _state;

  /// Mask *before* the zero check, not after: xorshift is a fixed point at 0,
  /// so a state of zero would return zero forever. A non-zero seed whose low 32
  /// bits happen to be zero (0x100000000, and every multiple) would otherwise
  /// slip through and produce a completely static "random" sequence.
  SeededRandom(int seed) : _state = _seedState(seed);

  static int _seedState(int seed) {
    final masked = seed & 0xFFFFFFFF;
    return masked == 0 ? 0x9E3779B9 : masked;
  }

  /// Derives a stable seed from a calendar date, so "today's trial" is the same
  /// everywhere without a network round-trip.
  factory SeededRandom.forDate(DateTime date) {
    final key = date.year * 10000 + date.month * 100 + date.day;
    // Knuth multiplicative hash, masked to 32 bits.
    return SeededRandom((key * 2654435761) & 0xFFFFFFFF);
  }

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  /// A value in [0, max).
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'must be positive');
    return _next() % max;
  }

  /// A value in [0.0, 1.0).
  double nextDouble() => _next() / 0x100000000;

  /// Picks one element. Throws on an empty list.
  T pick<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('cannot pick from an empty list');
    return items[nextInt(items.length)];
  }
}
