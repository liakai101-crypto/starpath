import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/friend_planet.dart';

class OrbitPlanet extends StatelessWidget {
  const OrbitPlanet({
    required this.controllerValue,
    required this.planet,
    required this.celebrating,
    required this.onTap,
    super.key,
  });

  final double controllerValue;
  final FriendPlanet planet;
  final bool celebrating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double pulse = (controllerValue + planet.offset / 6.28) % 1;
    final double celebrationScale = celebrating ? 1.08 + pulse * 0.08 : 1;
    final Size screen = MediaQuery.sizeOf(context);
    final Offset center = Offset(screen.width / 2, screen.height / 2);
    final double distance = planet.position == Offset.zero
        ? planet.radius
        : (planet.position - center).distance;
    final double maxDistance = sqrt(
          screen.width * screen.width + screen.height * screen.height,
        ) /
        2;
    final double depth =
        (1 - (distance / maxDistance).clamp(0.0, 1.0)).toDouble();
    final double perspectiveScale =
        lerpDouble(0.58, 0.94, depth)!.clamp(0.56, 0.96).toDouble();
    final Color spectralColor = planet.movingAway
        ? Color.lerp(
            const Color(0xFFFF8BA3),
            const Color(0xFFD84C72),
            0.28 + (1 - depth) * 0.18,
          )!
        : Color.lerp(
            const Color(0xFF2DE8FF),
            const Color(0xFFB9FBFF),
            0.18 + depth * 0.48,
          )!;
    final double shipBlur =
        lerpDouble(10, 20, depth)!.clamp(10, 20).toDouble();
    final double heading = atan2(planet.velocity.dy, planet.velocity.dx);
    final bool facingRight = planet.velocity.dx >= 0;
    final double pitch = heading.clamp(-0.65, 0.65) * 0.18;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: spectralColor),
      duration: const Duration(milliseconds: 420),
      builder: (context, animatedColor, child) {
        return AnimatedOpacity(
          opacity: planet.blocked ? 0 : 1,
          duration: const Duration(milliseconds: 360),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: Transform.translate(
              offset: planet.position - const Offset(62, 34),
              child: Transform.rotate(
                angle: pitch,
                child: Transform.scale(
                  scaleX: facingRight ? 1 : -1,
                  scaleY: 1,
                  child: Transform.scale(
                    scale: celebrationScale * perspectiveScale,
                    child: CustomPaint(
                      painter: HubbleEngineeringShipPainter(
                        color: animatedColor ?? spectralColor,
                        locked: !planet.unlocked,
                        pulse: pulse,
                        movingAway: planet.movingAway,
                        depth: depth,
                        blur: shipBlur,
                      ),
                      child: const SizedBox(
                        width: 124,
                        height: 68,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HubbleEngineeringShipPainter extends CustomPainter {
  HubbleEngineeringShipPainter({
    required this.color,
    required this.locked,
    required this.pulse,
    required this.movingAway,
    required this.depth,
    required this.blur,
  });

  final Color color;
  final bool locked;
  final double pulse;
  final bool movingAway;
  final double depth;
  final double blur;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double shipAlpha = locked ? 0.86 : 1.0;
    final double scale = 0.88 + depth * 0.16;
    final double length = 106 * scale;
    final double hullHeight = 24 * scale;
    final double podHeight = 26 * scale;

    final Rect glowRect = Rect.fromCenter(
      center: center,
      width: 138 * scale,
      height: 78 * scale,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..color = color.withValues(alpha: locked ? 0.10 : 0.18)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur + 6),
    );

    final Rect fieldRect = Rect.fromCenter(
      center: Offset(center.dx - length * 0.05, center.dy + 4),
      width: length * 1.12,
      height: hullHeight * 2.8,
    );
    canvas.drawOval(
      fieldRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05 * shipAlpha),
            Colors.transparent,
          ],
        ).createShader(fieldRect),
    );

    final Path mainHull = Path()
      ..moveTo(center.dx - length * 0.46, center.dy + 2)
      ..quadraticBezierTo(
        center.dx - length * 0.40,
        center.dy - hullHeight * 0.90,
        center.dx - length * 0.06,
        center.dy - hullHeight * 0.98,
      )
      ..quadraticBezierTo(
        center.dx + length * 0.20,
        center.dy - hullHeight * 0.86,
        center.dx + length * 0.28,
        center.dy - hullHeight * 0.36,
      )
      ..quadraticBezierTo(
        center.dx + length * 0.34,
        center.dy - hullHeight * 0.12,
        center.dx + length * 0.37,
        center.dy + 1,
      )
      ..quadraticBezierTo(
        center.dx + length * 0.34,
        center.dy + hullHeight * 0.16,
        center.dx + length * 0.27,
        center.dy + hullHeight * 0.44,
      )
      ..quadraticBezierTo(
        center.dx + length * 0.16,
        center.dy + hullHeight * 0.90,
        center.dx - length * 0.08,
        center.dy + hullHeight * 0.94,
      )
      ..quadraticBezierTo(
        center.dx - length * 0.38,
        center.dy + hullHeight * 0.88,
        center.dx - length * 0.46,
        center.dy + 2,
      )
      ..close();

    canvas.drawPath(
      mainHull.shift(const Offset(2, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.34)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final Rect hullBounds = Rect.fromCenter(
      center: center,
      width: length,
      height: hullHeight * 2.2,
    );
    canvas.drawPath(
      mainHull,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFD4DEE4).withValues(alpha: 0.96 * shipAlpha),
            const Color(0xFF83939E).withValues(alpha: 0.96 * shipAlpha),
            const Color(0xFF232D35).withValues(alpha: shipAlpha),
            const Color(0xFF12181D).withValues(alpha: shipAlpha),
          ],
          stops: const [0.0, 0.32, 0.68, 1.0],
        ).createShader(hullBounds),
    );
    canvas.drawPath(
      mainHull,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.22 * shipAlpha),
    );

    final Rect frontModule = Rect.fromCenter(
      center: Offset(center.dx - length * 0.18, center.dy),
      width: 44 * scale,
      height: 30 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frontModule, Radius.circular(12 * scale)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16 * shipAlpha),
            Colors.transparent,
          ],
        ).createShader(frontModule),
    );

    final Rect cockpit = Rect.fromCenter(
      center: Offset(center.dx - length * 0.27, center.dy - 2),
      width: 42 * scale,
      height: 20 * scale,
    );
    canvas.drawOval(
      cockpit,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.1),
          colors: [
            Colors.white.withValues(alpha: 0.86 * shipAlpha),
            color.withValues(alpha: 0.34 * shipAlpha),
            Colors.transparent,
          ],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(cockpit),
    );
    canvas.drawOval(
      cockpit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.26 * shipAlpha),
    );
    for (int i = 0; i < 3; i++) {
      final double windowX = cockpit.left + cockpit.width * (0.28 + i * 0.18);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(windowX, cockpit.center.dy),
            width: 5 * scale,
            height: 7 * scale,
          ),
          Radius.circular(2 * scale),
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.46),
      );
    }

    final Rect dome = Rect.fromCenter(
      center: Offset(center.dx + length * 0.05, center.dy - hullHeight * 0.84),
      width: 28 * scale,
      height: 22 * scale,
    );
    canvas.drawOval(
      dome,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.22),
            const Color(0xFF4B5C67).withValues(alpha: shipAlpha),
          ],
        ).createShader(dome),
    );

    Rect sidePodRect(double side) => Rect.fromCenter(
          center: Offset(center.dx + length * 0.10, center.dy + side * 20 * scale),
          width: 54 * scale,
          height: podHeight,
        );

    for (final double side in <double>[-1, 1]) {
      final Rect pod = sidePodRect(side);
      canvas.drawRRect(
        RRect.fromRectAndRadius(pod, Radius.circular(14 * scale)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFC1CCD2).withValues(alpha: 0.96 * shipAlpha),
              const Color(0xFF6B7983).withValues(alpha: shipAlpha),
              const Color(0xFF182027).withValues(alpha: shipAlpha),
            ],
            stops: const [0.0, 0.42, 1.0],
          ).createShader(pod),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(pod.deflate(1.4), Radius.circular(12 * scale)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white.withValues(alpha: 0.18 * shipAlpha),
      );

      final Rect podWindow = Rect.fromCenter(
        center: Offset(pod.left + 16 * scale, pod.center.dy),
        width: 18 * scale,
        height: 11 * scale,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(podWindow, Radius.circular(6 * scale)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.76 * shipAlpha),
              color.withValues(alpha: 0.26 * shipAlpha),
              const Color(0xFF0F151A).withValues(alpha: 0.92),
            ],
          ).createShader(podWindow),
      );

      final Paint seamPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.10 * shipAlpha);
      canvas.drawLine(
        Offset(pod.center.dx - 5 * scale, pod.top + 3 * scale),
        Offset(pod.center.dx - 5 * scale, pod.bottom - 3 * scale),
        seamPaint,
      );
      canvas.drawLine(
        Offset(pod.center.dx + 8 * scale, pod.top + 3 * scale),
        Offset(pod.center.dx + 8 * scale, pod.bottom - 3 * scale),
        seamPaint,
      );
    }

    final Paint bridgeRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: 0.16 * shipAlpha);
    canvas.drawLine(
      Offset(center.dx - length * 0.04, center.dy - hullHeight * 0.62),
      Offset(center.dx + length * 0.18, center.dy - hullHeight * 0.54),
      bridgeRim,
    );
    canvas.drawLine(
      Offset(center.dx - length * 0.02, center.dy + hullHeight * 0.58),
      Offset(center.dx + length * 0.17, center.dy + hullHeight * 0.46),
      bridgeRim,
    );

    final Paint undercarriage = Paint()
      ..color = const Color(0xFF202A31).withValues(alpha: shipAlpha);
    for (int i = 0; i < 4; i++) {
      final double x = center.dx - length * 0.08 + i * 13 * scale;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, center.dy + hullHeight * 1.08),
            width: 4 * scale,
            height: 10 * scale,
          ),
          Radius.circular(2 * scale),
        ),
        undercarriage,
      );
    }

    final Rect coreRect = Rect.fromCenter(
      center: Offset(center.dx + length * 0.18, center.dy),
      width: 20 * scale,
      height: 16 * scale,
    );
    canvas.drawOval(
      coreRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.98 * shipAlpha),
            color.withValues(alpha: 0.62 * shipAlpha),
            Colors.transparent,
          ],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(coreRect),
    );

    final Rect engineBlock = Rect.fromCenter(
      center: Offset(center.dx + length * 0.41, center.dy),
      width: 20 * scale,
      height: 32 * scale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(engineBlock, Radius.circular(10 * scale)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5A6874).withValues(alpha: shipAlpha),
            const Color(0xFF192028).withValues(alpha: shipAlpha),
          ],
        ).createShader(engineBlock),
    );

    final List<Offset> thrusters = <Offset>[
      Offset(center.dx + length * 0.49, center.dy),
      Offset(center.dx + length * 0.48, center.dy - 11 * scale),
      Offset(center.dx + length * 0.48, center.dy + 11 * scale),
    ];

    for (final Offset thruster in thrusters) {
      final Rect thrusterRect = Rect.fromCenter(
        center: thruster,
        width: 14 * scale,
        height: 10 * scale,
      );
      canvas.drawOval(
        thrusterRect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.70 * shipAlpha),
              color.withValues(alpha: 0.22 * shipAlpha),
              Colors.transparent,
            ],
          ).createShader(thrusterRect),
      );

      final Path flame = Path()
        ..moveTo(thruster.dx + 3 * scale, thruster.dy - 3.2 * scale)
        ..quadraticBezierTo(
          thruster.dx + 16 * scale + pulse * 8,
          thruster.dy - 1.4 * scale,
          thruster.dx + 25 * scale + pulse * 12,
          thruster.dy,
        )
        ..quadraticBezierTo(
          thruster.dx + 16 * scale + pulse * 8,
          thruster.dy + 1.4 * scale,
          thruster.dx + 3 * scale,
          thruster.dy + 3.2 * scale,
        )
        ..close();
      canvas.drawPath(
        flame,
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.96),
              movingAway
                  ? const Color(0xFFFF98A8)
                  : color.withValues(alpha: 0.82),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(thruster.dx, thruster.dy - 4, 32 * scale, 8 * scale),
          ),
      );
    }

    final Paint trailPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.26 * shipAlpha),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(center.dx + length * 0.42, center.dy - 8, 28, 16),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + length * 0.56, center.dy),
        width: 30 * scale,
        height: 12 * scale,
      ),
      trailPaint,
    );

    final Paint panelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.10 * shipAlpha);
    canvas.drawLine(
      Offset(center.dx - length * 0.34, center.dy - hullHeight * 0.22),
      Offset(center.dx + length * 0.24, center.dy - hullHeight * 0.10),
      panelPaint,
    );
    canvas.drawLine(
      Offset(center.dx - length * 0.30, center.dy + hullHeight * 0.20),
      Offset(center.dx + length * 0.22, center.dy + hullHeight * 0.12),
      panelPaint,
    );

    if (locked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx + length * 0.26, center.dy - hullHeight * 0.02),
            width: 18 * scale,
            height: 16 * scale,
          ),
          Radius.circular(5 * scale),
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.46),
      );
      canvas.drawPath(
        Path()
          ..moveTo(center.dx + length * 0.22, center.dy - hullHeight * 0.04)
          ..lineTo(center.dx + length * 0.22, center.dy + hullHeight * 0.08)
          ..quadraticBezierTo(
            center.dx + length * 0.26,
            center.dy + hullHeight * 0.16,
            center.dx + length * 0.30,
            center.dy + hullHeight * 0.08,
          )
          ..lineTo(center.dx + length * 0.30, center.dy - hullHeight * 0.04),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.70),
      );
    }
  }

  @override
  bool shouldRepaint(covariant HubbleEngineeringShipPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.locked != locked ||
        oldDelegate.pulse != pulse ||
        oldDelegate.movingAway != movingAway ||
        oldDelegate.depth != depth ||
        oldDelegate.blur != blur;
  }
}
