import 'dart:math';

import 'package:flutter/material.dart';

class CosmicMistPainter extends CustomPainter {
  CosmicMistPainter({required this.progress, required this.dispersed});

  final double progress;
  final bool dispersed;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double fade = dispersed ? 0.05 : 0.14;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 7; i++) {
      final double angle = (i / 9 * 2 * pi) + (progress * pi * 0.7);
      final double drift = dispersed ? 190 : 124;
      final Offset mistCenter =
          center +
          Offset(
            cos(angle) * (drift + (i.isEven ? 16 : -10)),
            sin(angle) * (drift * 0.42),
          );

      paint.shader =
          RadialGradient(
            colors: [
              const Color(0xFF24183D).withValues(alpha: fade),
              Colors.purpleAccent.withValues(alpha: fade * 0.22),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: mistCenter, radius: dispersed ? 66 : 86),
          );

      canvas.drawCircle(mistCenter, dispersed ? 66 : 86, paint);
    }

    final Paint dust = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 18; i++) {
      final double dx = (size.width * (i / 18)) + sin(progress * 0.2 + i) * 12;
      final double dy = size.height * 0.2 + cos(progress * 0.35 + i * 1.4) * 22;
      dust.color = Colors.white.withValues(alpha: dispersed ? 0.02 : 0.06);
      canvas.drawCircle(Offset(dx % size.width, dy + (i.isEven ? 0 : 14)), i.isEven ? 0.9 : 1.2, dust);
    }

    paint.shader = null;
  }

  @override
  bool shouldRepaint(covariant CosmicMistPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dispersed != dispersed;
  }
}
