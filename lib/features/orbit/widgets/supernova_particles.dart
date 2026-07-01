import 'dart:math';

import 'package:flutter/material.dart';

class SupernovaParticlesPainter extends CustomPainter {
  SupernovaParticlesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 22; i++) {
      final double angle = (i / 22 * 2 * pi) + (progress * 2 * pi);
      final double distance = 86 + (sin(progress * 2 * pi + i) * 18);
      final Offset point =
          center + Offset(cos(angle) * distance, sin(angle) * distance);

      paint.color = i.isEven
          ? Colors.purple.withValues(alpha: 0.38)
          : Colors.greenAccent.withValues(alpha: 0.46);
      canvas.drawCircle(point, i.isEven ? 3.5 : 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SupernovaParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
