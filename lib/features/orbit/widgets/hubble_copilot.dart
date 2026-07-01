import 'package:flutter/material.dart';

import '../../../core/starpath_style.dart';

class HubbleCopilot extends StatelessWidget {
  const HubbleCopilot({
    required this.name,
    required this.message,
    required this.encryptedLetterReady,
    required this.suitIndex,
    required this.sleeping,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final String name;
  final String message;
  final bool encryptedLetterReady;
  final int suitIndex;
  final bool sleeping;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = suitIndex == 1
        ? StarPathStyle.accent
        : suitIndex == 2
        ? StarPathStyle.accentSoft
        : const Color(0xFF7CE7B2);
    final double cardWidth = compact ? 248 : 280;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        key: const ValueKey('hubble-copilot'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: compact ? 78 : 88,
              height: compact ? 78 : 88,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -5,
                    child: Container(
                      width: compact ? 64 : 72,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: StarPathStyle.backgroundDeep.withValues(
                          alpha: 0.42,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.08),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.28),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          StarPathStyle.backgroundDeep.withValues(alpha: 0.16),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.12),
                          blurRadius: 18,
                          spreadRadius: 0,
                        ),
                        const BoxShadow(
                          color: Colors.black54,
                          blurRadius: 12,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              sleeping
                                  ? Colors.black.withValues(alpha: 0.08)
                                  : Colors.transparent,
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              'assets/hubble/hubble_reference.png',
                              width: compact ? 78 : 84,
                              height: compact ? 78 : 84,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return CustomPaint(
                                  size: const Size(84, 84),
                                  painter: _FallbackHubblePainter(
                                    accent: accent,
                                    sleeping: sleeping,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.20),
                                    Colors.transparent,
                                    accent.withValues(
                                      alpha: sleeping ? 0.03 : 0.10,
                                    ),
                                  ],
                                  stops: const [0.0, 0.35, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 7,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.10),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.16),
                              Colors.transparent,
                              accent.withValues(alpha: sleeping ? 0.03 : 0.08),
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (encryptedLetterReady)
                    Positioned(
                      right: -5,
                      bottom: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: StarPathStyle.backgroundDeep,
                          shape: BoxShape.circle,
                          border: Border.all(color: StarPathStyle.accent),
                          boxShadow: [
                            BoxShadow(
                              color: StarPathStyle.accent.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mark_email_unread,
                          color: StarPathStyle.accent,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: StarPathStyle.surfaceMuted.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: StarPathStyle.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        maxLines: compact ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: StarPathStyle.textSecondary,
                          fontSize: 11.8,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackHubblePainter extends CustomPainter {
  const _FallbackHubblePainter({required this.accent, required this.sleeping});

  final Color accent;
  final bool sleeping;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Paint backGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: sleeping ? 0.22 : 0.34),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2.4, backGlow);

    final Paint body = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white,
              accent.withValues(alpha: sleeping ? 0.45 : 0.8),
            ],
            stops: const [0.15, 1],
          ).createShader(
            Rect.fromCircle(center: center + const Offset(0, 8), radius: 28),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 8),
        width: 42,
        height: 30,
      ),
      body,
    );

    final Paint helmet = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center + const Offset(0, -1), 23, helmet);

    final Paint face = Paint()..color = const Color(0xFFF6D2A8);
    final Paint ear = Paint()..color = const Color(0xFFC97A3D);
    final Paint muzzle = Paint()..color = Colors.white;
    final Paint nose = Paint()..color = const Color(0xFF1D1D1D);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 4),
          width: 28,
          height: 24,
        ),
        const Radius.circular(12),
      ),
      face,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(0, 6),
          width: 22,
          height: 18,
        ),
        const Radius.circular(10),
      ),
      muzzle,
    );

    final Path leftEar = Path()
      ..moveTo(center.dx - 8, center.dy - 12)
      ..quadraticBezierTo(
        center.dx - 20,
        center.dy - 30,
        center.dx - 3,
        center.dy - 24,
      )
      ..quadraticBezierTo(
        center.dx - 3,
        center.dy - 16,
        center.dx - 8,
        center.dy - 12,
      );
    final Path rightEar = Path()
      ..moveTo(center.dx + 8, center.dy - 12)
      ..quadraticBezierTo(
        center.dx + 20,
        center.dy - 30,
        center.dx + 3,
        center.dy - 24,
      )
      ..quadraticBezierTo(
        center.dx + 3,
        center.dy - 16,
        center.dx + 8,
        center.dy - 12,
      );
    canvas.drawPath(leftEar, ear);
    canvas.drawPath(rightEar, ear);

    canvas.drawCircle(center + const Offset(-5, -1), 2.2, nose);
    canvas.drawCircle(center + const Offset(5, -1), 2.2, nose);
    canvas.drawCircle(center + const Offset(0, 4), 3.8, nose);
  }

  @override
  bool shouldRepaint(covariant _FallbackHubblePainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.sleeping != sleeping;
  }
}
