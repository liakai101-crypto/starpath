import 'dart:math';

import 'package:flutter/material.dart';

import '../models/friend_planet.dart';

class ResonanceStreamPainter extends CustomPainter {
  ResonanceStreamPainter({required this.progress, required this.target});

  final double progress;
  final FriendPlanet target;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final end = target.position == Offset.zero ? center : target.position;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyanAccent.withValues(alpha: 0.1),
          Colors.greenAccent.withValues(alpha: 0.85),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(center, end))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, end, paint);

    for (int i = 0; i < 8; i++) {
      final t = ((progress * 2) + i / 8) % 1;
      final point = Offset.lerp(center, end, t)!;
      canvas.drawCircle(
        point,
        2.5,
        Paint()..color = Colors.cyanAccent.withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ResonanceStreamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.target != target;
  }
}

class GravityLensPainter extends CustomPainter {
  GravityLensPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 4; i++) {
      final radius = 92 + (i * 32) + sin(progress * 2 * pi) * 8;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.purpleAccent.withValues(alpha: 0.32 - i * 0.05);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GravityLensPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class QuantumBeamPainter extends CustomPainter {
  QuantumBeamPainter({
    required this.progress,
    required this.transitProgress,
  });

  final double progress;
  final double transitProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * (0.35 + sin(progress * 2 * pi) * 0.04);
    final center = Offset(size.width / 2, size.height / 2);
    final exit = Offset(size.width * 0.72, size.height * 0.45);
    final progressLine = transitProgress.clamp(0, 1);

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.purpleAccent.withValues(alpha: 0.15),
          Colors.cyanAccent.withValues(alpha: 0.9),
          Colors.greenAccent.withValues(alpha: 0.7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(center, exit))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final double travel = progressLine < 0.28
        ? progressLine / 0.28
        : progressLine < 0.72
        ? 1
        : 1 - ((progressLine - 0.72) / 0.28);
    final Offset current = Offset.lerp(center, exit, travel)!;
    final Path path = Path()
      ..moveTo(center.dx, y)
      ..quadraticBezierTo(
        center.dx + 84,
        y - 96,
        exit.dx,
        exit.dy,
      );
    canvas.drawPath(path, paint);
    canvas.drawCircle(current, 16, Paint()..color = Colors.cyanAccent.withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant QuantumBeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.transitProgress != transitProgress;
  }
}

class ExpandingHaloPainter extends CustomPainter {
  ExpandingHaloPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 4; i++) {
      final t = (progress + i * 0.18) % 1;
      final radius = t * max(size.width, size.height);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = Colors.cyanAccent.withValues(alpha: (1 - t) * 0.28);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ExpandingHaloPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PixelNoisePainter extends CustomPainter {
  PixelNoisePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((progress * 1000).round());
    final paint = Paint();
    for (int i = 0; i < 80; i++) {
      paint.color = (i.isEven ? Colors.cyanAccent : Colors.purpleAccent)
          .withValues(alpha: 0.14 + random.nextDouble() * 0.22);
      canvas.drawRect(
        Rect.fromLTWH(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
          8 + random.nextDouble() * 26,
          2 + random.nextDouble() * 8,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PixelNoisePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
