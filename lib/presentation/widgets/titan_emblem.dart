import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_2048/content/titan_ranks.dart';

/// Draws a Titan rank sigil as vector geometry.
///
/// These are authored as paths rather than imported artwork on purpose: they
/// are original to this game, they recolour with the theme, they stay crisp at
/// any density, and they add nothing to the bundle size.
///
/// Every emblem is designed inside a unit square and scaled at paint time, so
/// one definition serves a 24 px tile watermark and a 96 px achievement badge.
class TitanEmblem extends StatelessWidget {
  final Emblem emblem;
  final Color color;
  final double size;

  /// Stroke weight relative to [size]. Heavier reads better when the emblem is
  /// a bold focal mark; lighter suits a watermark behind a numeral.
  final double weight;

  const TitanEmblem({
    super.key,
    required this.emblem,
    required this.color,
    this.size = 24,
    this.weight = 0.085,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmblemPainter(
          emblem: emblem,
          color: color,
          weight: weight,
        ),
        // The numeral carries the meaning; the sigil is decoration, so it is
        // hidden from assistive technology rather than read out as a shape.
        isComplex: false,
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  final Emblem emblem;
  final Color color;
  final double weight;

  _EmblemPainter({
    required this.emblem,
    required this.color,
    required this.weight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * weight
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Normalised helper: p(0.5, 0.5) is the centre of the emblem.
    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (emblem) {
      case Emblem.spark:
        _drawSpark(canvas, s, fill, p);
      case Emblem.chevron:
        _drawChevron(canvas, stroke, p);
      case Emblem.arrow:
        _drawArrow(canvas, stroke, p);
      case Emblem.axe:
        _drawAxe(canvas, stroke, fill, p);
      case Emblem.shield:
        _drawShield(canvas, stroke, p);
      case Emblem.crossedAxes:
        _drawCrossedAxes(canvas, stroke, fill, p);
      case Emblem.fang:
        _drawFang(canvas, fill, p);
      case Emblem.helm:
        _drawHelm(canvas, stroke, p);
      case Emblem.crown:
        _drawCrown(canvas, stroke, p);
      case Emblem.hammer:
        _drawHammer(canvas, stroke, p);
      case Emblem.rune:
        _drawRune(canvas, stroke, p);
      case Emblem.sun:
        _drawSun(canvas, s, stroke, p);
      case Emblem.bolt:
        _drawBolt(canvas, fill, p);
      case Emblem.spiral:
        _drawSpiral(canvas, s, stroke);
    }
  }

  /// 2 — Whelp. A four-pointed spark: the smallest possible mark.
  void _drawSpark(Canvas canvas, double s, Paint fill, _P p) {
    final path = Path()
      ..moveTo(p(0.5, 0.12).dx, p(0.5, 0.12).dy)
      ..quadraticBezierTo(
          p(0.56, 0.44).dx, p(0.56, 0.44).dy, p(0.88, 0.5).dx, p(0.88, 0.5).dy)
      ..quadraticBezierTo(
          p(0.56, 0.56).dx, p(0.56, 0.56).dy, p(0.5, 0.88).dx, p(0.5, 0.88).dy)
      ..quadraticBezierTo(
          p(0.44, 0.56).dx, p(0.44, 0.56).dy, p(0.12, 0.5).dx, p(0.12, 0.5).dy)
      ..quadraticBezierTo(
          p(0.44, 0.44).dx, p(0.44, 0.44).dy, p(0.5, 0.12).dx, p(0.5, 0.12).dy)
      ..close();
    canvas.drawPath(path, fill);
  }

  /// 4 — Thrall. A single chevron.
  void _drawChevron(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.18, 0.64).dx, p(0.18, 0.64).dy)
        ..lineTo(p(0.5, 0.3).dx, p(0.5, 0.3).dy)
        ..lineTo(p(0.82, 0.64).dx, p(0.82, 0.64).dy),
      stroke,
    );
  }

  /// 8 — Scout. An arrow: the chevron, now with direction.
  void _drawArrow(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.5, 0.85).dx, p(0.5, 0.85).dy)
        ..lineTo(p(0.5, 0.18).dx, p(0.5, 0.18).dy)
        ..moveTo(p(0.24, 0.42).dx, p(0.24, 0.42).dy)
        ..lineTo(p(0.5, 0.15).dx, p(0.5, 0.15).dy)
        ..lineTo(p(0.76, 0.42).dx, p(0.76, 0.42).dy),
      stroke,
    );
  }

  /// 16 — Raider. A bearded axe: straight haft, flared cutting edge, and the
  /// hooked "beard" beneath it that makes the silhouette read as an axe rather
  /// than a banner.
  void _drawAxe(Canvas canvas, Paint stroke, Paint fill, _P p) {
    // Short haft, big blade. An earlier version used a full-height haft with a
    // small head and read unmistakably as a flag on a pole — at this size the
    // blade has to dominate for the shape to say "axe".
    canvas.drawPath(
      Path()
        ..moveTo(p(0.3, 0.1).dx, p(0.3, 0.1).dy)
        ..lineTo(p(0.3, 0.93).dx, p(0.3, 0.93).dy),
      stroke,
    );
    final blade = Path()
      ..moveTo(p(0.3, 0.12).dx, p(0.3, 0.12).dy)
      ..lineTo(p(0.6, 0.07).dx, p(0.6, 0.07).dy)
      ..quadraticBezierTo(
          p(0.99, 0.36).dx, p(0.99, 0.36).dy, p(0.6, 0.66).dx, p(0.6, 0.66).dy)
      ..lineTo(p(0.3, 0.6).dx, p(0.3, 0.6).dy)
      ..close();
    canvas.drawPath(blade, fill);
  }

  /// 32 — Shieldman. A round-topped shield.
  void _drawShield(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.5, 0.12).dx, p(0.5, 0.12).dy)
        ..lineTo(p(0.85, 0.28).dx, p(0.85, 0.28).dy)
        ..quadraticBezierTo(
            p(0.85, 0.7).dx, p(0.85, 0.7).dy, p(0.5, 0.9).dx, p(0.5, 0.9).dy)
        ..quadraticBezierTo(
            p(0.15, 0.7).dx, p(0.15, 0.7).dy, p(0.15, 0.28).dx, p(0.15, 0.28).dy)
        ..close(),
      stroke,
    );
  }

  /// 64 — Warrior. Two crossed axes: solid blade wedges on crossed hafts, so
  /// the shape reads as weapons rather than as an X with hooks on it.
  void _drawCrossedAxes(Canvas canvas, Paint stroke, Paint fill, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.26, 0.9).dx, p(0.26, 0.9).dy)
        ..lineTo(p(0.7, 0.22).dx, p(0.7, 0.22).dy)
        ..moveTo(p(0.74, 0.9).dx, p(0.74, 0.9).dy)
        ..lineTo(p(0.3, 0.22).dx, p(0.3, 0.22).dy),
      stroke,
    );
    // Right-hand blade.
    canvas.drawPath(
      Path()
        ..moveTo(p(0.66, 0.28).dx, p(0.66, 0.28).dy)
        ..lineTo(p(0.62, 0.08).dx, p(0.62, 0.08).dy)
        ..quadraticBezierTo(
            p(0.92, 0.1).dx, p(0.92, 0.1).dy, p(0.88, 0.34).dx, p(0.88, 0.34).dy)
        ..close(),
      fill,
    );
    // Left-hand blade, mirrored.
    canvas.drawPath(
      Path()
        ..moveTo(p(0.34, 0.28).dx, p(0.34, 0.28).dy)
        ..lineTo(p(0.38, 0.08).dx, p(0.38, 0.08).dy)
        ..quadraticBezierTo(
            p(0.08, 0.1).dx, p(0.08, 0.1).dy, p(0.12, 0.34).dx, p(0.12, 0.34).dy)
        ..close(),
      fill,
    );
  }

  /// 128 — Berserker. Three fangs.
  void _drawFang(Canvas canvas, Paint fill, _P p) {
    for (final x in [0.24, 0.5, 0.76]) {
      final w = 0.11;
      canvas.drawPath(
        Path()
          ..moveTo(p(x - w, 0.24).dx, p(x - w, 0.24).dy)
          ..lineTo(p(x + w, 0.24).dx, p(x + w, 0.24).dy)
          ..lineTo(p(x, 0.78).dx, p(x, 0.78).dy)
          ..close(),
        fill,
      );
    }
  }

  /// 256 — Huscarl. A helm with a nose guard: the first milestone, so the
  /// silhouette steps up in complexity.
  void _drawHelm(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.16, 0.72).dx, p(0.16, 0.72).dy)
        ..lineTo(p(0.16, 0.46).dx, p(0.16, 0.46).dy)
        ..quadraticBezierTo(
            p(0.5, 0.1).dx, p(0.5, 0.1).dy, p(0.84, 0.46).dx, p(0.84, 0.46).dy)
        ..lineTo(p(0.84, 0.72).dx, p(0.84, 0.72).dy)
        ..moveTo(p(0.16, 0.5).dx, p(0.16, 0.5).dy)
        ..lineTo(p(0.84, 0.5).dx, p(0.84, 0.5).dy)
        // Nose guard.
        ..moveTo(p(0.5, 0.5).dx, p(0.5, 0.5).dy)
        ..lineTo(p(0.5, 0.84).dx, p(0.5, 0.84).dy),
      stroke,
    );
  }

  /// 512 — Jarl. A three-peaked circlet.
  void _drawCrown(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.14, 0.76).dx, p(0.14, 0.76).dy)
        ..lineTo(p(0.14, 0.3).dx, p(0.14, 0.3).dy)
        ..lineTo(p(0.32, 0.5).dx, p(0.32, 0.5).dy)
        ..lineTo(p(0.5, 0.2).dx, p(0.5, 0.2).dy)
        ..lineTo(p(0.68, 0.5).dx, p(0.68, 0.5).dy)
        ..lineTo(p(0.86, 0.3).dx, p(0.86, 0.3).dy)
        ..lineTo(p(0.86, 0.76).dx, p(0.86, 0.76).dy)
        ..close(),
      stroke,
    );
  }

  /// 1024 — Warlord. Mjölnir.
  void _drawHammer(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromPoints(p(0.16, 0.16), p(0.84, 0.46)),
          Radius.circular(p(0.06, 0).dx),
        ))
        ..moveTo(p(0.5, 0.46).dx, p(0.5, 0.46).dy)
        ..lineTo(p(0.5, 0.88).dx, p(0.5, 0.88).dy)
        ..moveTo(p(0.38, 0.88).dx, p(0.38, 0.88).dy)
        ..lineTo(p(0.62, 0.88).dx, p(0.62, 0.88).dy),
      stroke,
    );
  }

  /// 2048 — Titan. A bind-rune: angular, deliberately unlike the softer ranks
  /// below it, so the 2048 tile reads as a different class of thing.
  void _drawRune(Canvas canvas, Paint stroke, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.5, 0.08).dx, p(0.5, 0.08).dy)
        ..lineTo(p(0.5, 0.92).dx, p(0.5, 0.92).dy)
        ..moveTo(p(0.5, 0.2).dx, p(0.5, 0.2).dy)
        ..lineTo(p(0.86, 0.38).dx, p(0.86, 0.38).dy)
        ..moveTo(p(0.5, 0.2).dx, p(0.5, 0.2).dy)
        ..lineTo(p(0.14, 0.38).dx, p(0.14, 0.38).dy)
        ..moveTo(p(0.5, 0.56).dx, p(0.5, 0.56).dy)
        ..lineTo(p(0.84, 0.74).dx, p(0.84, 0.74).dy)
        ..moveTo(p(0.5, 0.56).dx, p(0.5, 0.56).dy)
        ..lineTo(p(0.16, 0.74).dx, p(0.16, 0.74).dy),
      stroke,
    );
  }

  /// 4096 — World-Breaker. A rayed sun.
  void _drawSun(Canvas canvas, double s, Paint stroke, _P p) {
    canvas.drawCircle(p(0.5, 0.5), s * 0.22, stroke);
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final inner = Offset(
        p(0.5, 0.5).dx + math.cos(angle) * s * 0.32,
        p(0.5, 0.5).dy + math.sin(angle) * s * 0.32,
      );
      final outer = Offset(
        p(0.5, 0.5).dx + math.cos(angle) * s * 0.45,
        p(0.5, 0.5).dy + math.sin(angle) * s * 0.45,
      );
      canvas.drawLine(inner, outer, stroke);
    }
  }

  /// 8192 — Godslayer. A lightning bolt.
  void _drawBolt(Canvas canvas, Paint fill, _P p) {
    canvas.drawPath(
      Path()
        ..moveTo(p(0.58, 0.06).dx, p(0.58, 0.06).dy)
        ..lineTo(p(0.24, 0.54).dx, p(0.24, 0.54).dy)
        ..lineTo(p(0.46, 0.54).dx, p(0.46, 0.54).dy)
        ..lineTo(p(0.4, 0.94).dx, p(0.4, 0.94).dy)
        ..lineTo(p(0.76, 0.44).dx, p(0.76, 0.44).dy)
        ..lineTo(p(0.54, 0.44).dx, p(0.54, 0.44).dy)
        ..close(),
      fill,
    );
  }

  /// 16384+ — Eternal. An unbroken spiral.
  void _drawSpiral(Canvas canvas, double s, Paint stroke) {
    final centre = Offset(s * 0.5, s * 0.5);
    final path = Path();
    const turns = 2.6;
    const steps = 90;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final angle = t * math.pi * 2 * turns;
      final radius = s * 0.44 * t;
      final point = Offset(
        centre.dx + math.cos(angle) * radius,
        centre.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_EmblemPainter old) =>
      old.emblem != emblem || old.color != color || old.weight != weight;
}

typedef _P = Offset Function(double x, double y);
