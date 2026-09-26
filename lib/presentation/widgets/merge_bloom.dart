import 'package:flutter/material.dart';

/// The flash that fires when two tiles fuse.
///
/// A merge is the only moment in the game where something is *created*, and
/// before this it was invisible: the doubled tile simply appeared at its new
/// colour. This gives that moment a shape — a ring that punches outward and
/// fades, brighter for milestone ranks.
///
/// Deliberately short (≈320 ms) and non-blocking: it plays over the board
/// without gating input, because a puzzle game must stay responsive while it
/// celebrates.
class MergeBloom extends StatelessWidget {
  final Color color;

  /// Milestone merges (256+) get a wider, brighter bloom.
  final bool emphatic;

  /// Respects the platform's reduce-motion setting; when true the bloom is
  /// skipped entirely rather than shortened.
  final bool enabled;

  const MergeBloom({
    super.key,
    required this.color,
    this.emphatic = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: emphatic ? 420 : 320),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          return CustomPaint(
            painter: _BloomPainter(
              progress: t,
              color: color,
              emphatic: emphatic,
            ),
          );
        },
      ),
    );
  }
}

class _BloomPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool emphatic;

  _BloomPainter({
    required this.progress,
    required this.color,
    required this.emphatic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;

    final centre = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * (emphatic ? 0.78 : 0.62);

    // Ring: starts tight and hot, expands and thins as it fades.
    final radius = maxRadius * Curves.easeOutQuart.transform(progress);
    final fade = (1 - progress);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * (emphatic ? 0.075 : 0.055) * fade
      ..color = color.withOpacity((emphatic ? 0.85 : 0.6) * fade);
    canvas.drawCircle(centre, radius, ring);

    // Core flash, only in the first third — the "heat" of the strike.
    if (progress < 0.34) {
      final coreFade = 1 - (progress / 0.34);
      final core = Paint()
        ..color = color.withOpacity(0.5 * coreFade)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centre, size.shortestSide * 0.3 * coreFade, core);
    }

    // Milestone merges throw sparks along the diagonals.
    if (emphatic && progress < 0.8) {
      final sparkFade = 1 - (progress / 0.8);
      final spark = Paint()
        ..color = color.withOpacity(0.7 * sparkFade)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.045 * sparkFade
        ..style = PaintingStyle.stroke;
      const diagonals = [
        Offset(0.7, 0.7),
        Offset(-0.7, 0.7),
        Offset(0.7, -0.7),
        Offset(-0.7, -0.7),
      ];
      for (final d in diagonals) {
        final inner = centre + d * radius * 0.55;
        final outer = centre + d * radius * 0.95;
        canvas.drawLine(inner, outer, spark);
      }
    }
  }

  @override
  bool shouldRepaint(_BloomPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.emphatic != emphatic;
}
