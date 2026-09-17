import 'package:flutter/material.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final Path path = Path();
    final double a = w / 2;
    final double b = h / 2;

    path.moveTo(a, 0);
    path.lineTo(w, b * 0.5);
    path.lineTo(w, b * 1.5);
    path.lineTo(a, h);
    path.lineTo(0, b * 1.5);
    path.lineTo(0, b * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}