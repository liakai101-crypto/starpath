import 'dart:math';

import 'package:flutter/material.dart';

class HubbleCore extends StatelessWidget {
  const HubbleCore({
    required this.label,
    required this.progress,
    required this.isHibernating,
    required this.quantumTransitProgress,
    required this.quantumTargetPosition,
    super.key,
  });

  final String label;
  final double progress;
  final bool isHibernating;
  final double quantumTransitProgress;
  final Offset? quantumTargetPosition;

  @override
  Widget build(BuildContext context) {
    final double drift = isHibernating ? 0.22 : 1;
    final double surge = sin(progress * 2 * pi) * 7 * drift;
    final double lift = cos(progress * 2 * pi) * 5 * drift;
    final double rotate = sin(progress * 2 * pi) * 0.05 * drift;
    final bool inTransit = quantumTransitProgress > 0;
    final double p = quantumTransitProgress;
    final Offset transitOffset =
        _wormholeOffset(context, p, quantumTargetPosition);
    final double transitScale = inTransit ? _wormholeScale(p) : 1;
    final double transitRotation = inTransit ? sin(p * pi) * 0.38 : 0;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.translate(
            offset: Offset(0 + surge, -16 + lift) + transitOffset,
            child: Transform.rotate(
              angle: rotate + transitRotation,
              child: Transform.scale(
                scale: transitScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(
                      size: const Size(340, 240),
                      painter: _CommandShipPainter(
                        progress: progress,
                        hibernating: isHibernating,
                        quantumTransitProgress: quantumTransitProgress,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _wormholeOffset(
    BuildContext context,
    double progress,
    Offset? targetPosition,
  ) {
    final size = MediaQuery.sizeOf(context);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset target = targetPosition ?? Offset(size.width * 0.72, size.height * 0.45);
    final Offset delta = target - center;
    final double travel = progress < 0.28
        ? Curves.easeIn.transform(progress / 0.28)
        : progress < 0.72
            ? 1
            : 1;
    final double strength = targetPosition == null
        ? 0.84 * travel
        : (progress == 0
            ? 0.84
            : (progress < 0.28 ? 0.84 * travel : 0.84));
    final double yJitter = sin(progress * pi * 2) * 16;
    final double vanish = progress < 0.28
        ? 0
        : progress < 0.72
            ? -36
            : 0;
    return Offset(delta.dx * strength, delta.dy * strength + yJitter + vanish);
  }

  double _wormholeScale(double progress) {
    if (progress < 0.28) {
      return 1 - Curves.easeIn.transform(progress / 0.28) * 0.36;
    }
    if (progress < 0.72) {
      return 0.64;
    }
    return 0.64 + Curves.easeOut.transform((progress - 0.72) / 0.28) * 0.36;
  }
}

class _CommandShipPainter extends CustomPainter {
  const _CommandShipPainter({
    required this.progress,
    required this.hibernating,
    required this.quantumTransitProgress,
  });

  final double progress;
  final bool hibernating;
  final double quantumTransitProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double pulse = 0.5 + sin(progress * 2 * pi) * 0.5;
    final double breathing = 0.5 + cos(progress * 2 * pi * 0.5) * 0.5;
    final Color glowColor = hibernating ? const Color(0xFF54708C) : Colors.cyanAccent;
    final Color engineColor = hibernating
        ? Colors.purpleAccent.withValues(alpha: 0.55)
        : Colors.greenAccent;
    final bool locked = hibernating;
    final Color color = glowColor;

    final bool inTransit = quantumTransitProgress > 0;
    final bool movingAway = sin(progress * 2 * pi) > 0;
    final double shipAlpha = inTransit && quantumTransitProgress < 0.28
        ? 1 - quantumTransitProgress / 0.28
        : inTransit && quantumTransitProgress > 0.72
            ? (quantumTransitProgress - 0.72) / 0.28
            : inTransit
                ? 0.18
                : 1;

    final Rect glowRect = Rect.fromCenter(
      center: Offset(center.dx + 8, center.dy + 18),
      width: 272,
      height: 144,
    );
    final Paint aura = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: (hibernating ? 0.1 : 0.2) * shipAlpha),
          glowColor.withValues(alpha: (hibernating ? 0.04 : 0.1) * shipAlpha),
          Colors.transparent,
        ],
        stops: const [0.04, 0.54, 1],
      ).createShader(glowRect);
    canvas.drawOval(glowRect, aura);

    final Paint shadowPool = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.42 * shipAlpha),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx + 12, center.dy + 34),
        width: 220,
        height: 92,
      ))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 12, center.dy + 34),
        width: 220,
        height: 92,
      ),
      shadowPool,
    );

    final Paint bloom = Paint()
      ..color = Colors.white.withValues(alpha: (hibernating ? 0.02 : 0.04) * shipAlpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 26 + pulse * 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 10, center.dy + 10),
        width: 214 + breathing * 20,
        height: 116 + breathing * 10,
      ),
      bloom,
    );

    final double hullLength = 190;
    final double hullHeight = 90;

    final Path hull = Path()
      ..moveTo(center.dx - 88, center.dy + 3)
      ..quadraticBezierTo(center.dx - 72, center.dy - 34, center.dx - 12, center.dy - 40)
      ..quadraticBezierTo(center.dx + 54, center.dy - 45, center.dx + 98, center.dy - 7)
      ..quadraticBezierTo(center.dx + 112, center.dy + 4, center.dx + 98, center.dy + 14)
      ..quadraticBezierTo(center.dx + 48, center.dy + 50, center.dx - 10, center.dy + 44)
      ..quadraticBezierTo(center.dx - 72, center.dy + 38, center.dx - 88, center.dy + 3)
      ..close();
    final Paint hullShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(hull.shift(const Offset(2.2, 3.5)), hullShadow);

    final Paint hullFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFFD7E2E6), const Color(0xFF96A7B3), hibernating ? 0.65 : 0.25)!
              .withValues(alpha: 0.96 * shipAlpha),
          Color.lerp(const Color(0xFF677680), const Color(0xFF24303A), hibernating ? 0.5 : 0.32)!
              .withValues(alpha: shipAlpha),
          const Color(0xFF11171D).withValues(alpha: 1),
        ],
        stops: const [0, 0.52, 1],
      ).createShader(Rect.fromCenter(center: center, width: hullLength, height: hullHeight));
    canvas.drawPath(hull, hullFill);

    final Paint hullEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = Colors.white.withValues(alpha: 0.16 * shipAlpha);
    canvas.drawPath(hull, hullEdge);

    final Path hullHighlight = Path()
      ..moveTo(center.dx - 72, center.dy - 17)
      ..quadraticBezierTo(center.dx - 8, center.dy - 34, center.dx + 68, center.dy - 6)
      ..quadraticBezierTo(center.dx + 30, center.dy - 14, center.dx - 72, center.dy - 17)
      ..close();
    canvas.drawPath(
      hullHighlight,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.20 * shipAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCenter(center: center, width: 164, height: 34)),
    );

    final Path dorsal = Path()
      ..moveTo(center.dx - 20, center.dy - 41)
      ..quadraticBezierTo(center.dx + 14, center.dy - 64, center.dx + 32, center.dy - 20)
      ..quadraticBezierTo(center.dx + 10, center.dy - 16, center.dx - 20, center.dy - 41)
      ..close();
    canvas.drawPath(
      dorsal,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.34 * shipAlpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCenter(center: center, width: 54, height: 28)),
    );

    final Rect frontGlass = Rect.fromCenter(center: Offset(center.dx - 72, center.dy - 2), width: 70, height: 46);
    final Paint frontGlassFill = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.92 * shipAlpha),
          Colors.cyanAccent.withValues(alpha: 0.38 * shipAlpha),
          Colors.transparent,
        ],
        stops: const [0, 0.48, 1],
      ).createShader(frontGlass);
    canvas.drawOval(frontGlass, frontGlassFill);
    canvas.drawOval(
      frontGlass.deflate(1.1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.3 * shipAlpha),
    );
    canvas.drawLine(
      Offset(center.dx - 84, center.dy - 2),
      Offset(center.dx - 52, center.dy - 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.18 * shipAlpha),
    );

    final Rect bridgeShell = Rect.fromCenter(center: Offset(center.dx - 8, center.dy - 2), width: 112, height: 62);
    final Paint bridgeFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF495662).withValues(alpha: shipAlpha),
          const Color(0xFF1A222A).withValues(alpha: 1),
        ],
      ).createShader(bridgeShell);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeShell, const Radius.circular(28)),
      bridgeFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeShell.deflate(2.2), const Radius.circular(24)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withValues(alpha: 0.14 * shipAlpha),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx - 6, center.dy - 10), width: 78, height: 34),
        const Radius.circular(20),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12 * shipAlpha),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCenter(center: Offset(center.dx - 6, center.dy - 10), width: 78, height: 34),
        ),
    );

    final Rect bridgeGlass = Rect.fromCenter(center: Offset(center.dx - 12, center.dy - 5), width: 56, height: 32);
    final Paint bridgeGlassFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.32 * shipAlpha),
          glowColor.withValues(alpha: 0.42 * shipAlpha),
          const Color(0xFF0D1319).withValues(alpha: 0.95),
        ],
      ).createShader(bridgeGlass);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeGlass, const Radius.circular(20)),
      bridgeGlassFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bridgeGlass.deflate(1.2), const Radius.circular(18)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.22 * shipAlpha),
    );

    final Path sideWingTop = Path()
      ..moveTo(center.dx - 28, center.dy - 10)
      ..quadraticBezierTo(center.dx - 62, center.dy - 38, center.dx - 86, center.dy - 26)
      ..quadraticBezierTo(center.dx - 58, center.dy - 8, center.dx - 28, center.dy - 10)
      ..close();
    final Path sideWingBottom = Path()
      ..moveTo(center.dx - 28, center.dy + 10)
      ..quadraticBezierTo(center.dx - 62, center.dy + 38, center.dx - 86, center.dy + 26)
      ..quadraticBezierTo(center.dx - 58, center.dy + 8, center.dx - 28, center.dy + 10)
      ..close();
    final Paint wingFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: locked ? 0.3 : 0.56),
          const Color(0xFF26343E).withValues(alpha: 1),
        ],
      ).createShader(Rect.fromCenter(center: center, width: 98, height: 56));
    canvas.drawPath(sideWingTop, wingFill);
    canvas.drawPath(sideWingBottom, wingFill);
    final Paint wingEdge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.12 * shipAlpha);
    canvas.drawPath(sideWingTop, wingEdge);
    canvas.drawPath(sideWingBottom, wingEdge);

    final Rect centralCore = Rect.fromCenter(center: Offset(center.dx + 15, center.dy), width: 24, height: 22);
    final Paint coreGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.98 * shipAlpha),
          engineColor.withValues(alpha: 0.6 * shipAlpha),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(centralCore);
    canvas.drawOval(centralCore, coreGlow);

    final Rect engineShell = Rect.fromCenter(center: Offset(center.dx + 86, center.dy), width: 42, height: 54);
    final Paint engineBody = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A5864).withValues(alpha: shipAlpha),
          const Color(0xFF161D24).withValues(alpha: 1),
        ],
      ).createShader(engineShell);
    canvas.drawRRect(
      RRect.fromRectAndRadius(engineShell, const Radius.circular(16)),
      engineBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(engineShell.deflate(2), const Radius.circular(14)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.12 * shipAlpha),
    );

    final Paint thrusterGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          engineColor.withValues(alpha: locked ? 0.24 : 0.5),
          engineColor.withValues(alpha: locked ? 0.08 : 0.24),
          Colors.transparent,
        ],
        stops: const [0, 0.38, 1],
      ).createShader(Rect.fromCenter(center: Offset(center.dx + 126, center.dy), width: 58, height: 32))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 124, center.dy), width: 42, height: 18), thrusterGlow);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 124, center.dy - 14), width: 34, height: 12), thrusterGlow);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx + 124, center.dy + 14), width: 34, height: 12), thrusterGlow);

    final Path flame = Path()
      ..moveTo(center.dx + 102, center.dy - 7)
      ..quadraticBezierTo(center.dx + 128 + pulse * 8, center.dy - 3, center.dx + 144 + pulse * 12, center.dy)
      ..quadraticBezierTo(center.dx + 128 + pulse * 8, center.dy + 3, center.dx + 102, center.dy + 7)
      ..close();
    canvas.drawPath(
      flame,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.96),
            movingAway ? const Color(0xFFFF8A92) : engineColor.withValues(alpha: 0.84),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(center.dx + 98, center.dy - 8, 48, 16)),
    );

    final Rect underside = Rect.fromCenter(center: Offset(center.dx + 4, center.dy + 20), width: 98, height: 18);
    final Paint undersideFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.08 * shipAlpha),
          Colors.transparent,
        ],
      ).createShader(underside);
    canvas.drawRRect(
      RRect.fromRectAndRadius(underside, const Radius.circular(10)),
      undersideFill,
    );

    final Paint atmosphere = Paint()
      ..color = Colors.white.withValues(alpha: locked ? 0.05 : 0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center + const Offset(4, 0), width: 182, height: 82),
        const Radius.circular(36),
      ),
      atmosphere,
    );
  }
  @override
  bool shouldRepaint(covariant _CommandShipPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hibernating != hibernating ||
        oldDelegate.quantumTransitProgress != quantumTransitProgress;
  }
}
