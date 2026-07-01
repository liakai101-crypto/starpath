import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/starpath_copy.dart';
import '../models/friend_planet.dart';

class OrbitConsole extends StatelessWidget {
  const OrbitConsole({
    required this.planets,
    required this.onPulse,
    required this.launchPulseLabel,
    required this.coolingLabel,
    required this.pulseCoolingDown,
    required this.onShipTap,
    required this.copy,
    this.compact = false,
    super.key,
  });

  final List<FriendPlanet> planets;
  final VoidCallback? onPulse;
  final String launchPulseLabel;
  final String coolingLabel;
  final bool pulseCoolingDown;
  final ValueChanged<FriendPlanet> onShipTap;
  final StarPathCopy copy;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.032),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.05),
                blurRadius: 14,
              ),
              BoxShadow(
                color: Colors.purpleAccent.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 5 : 11),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final FriendPlanet planet in planets)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onShipTap(planet),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 5),
                      child: Row(
                        children: [
                          Container(
                            width: compact ? 10 : 12,
                            height: compact ? 10 : 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: planet.color,
                              boxShadow: [
                                BoxShadow(
                                  color: planet.color.withValues(alpha: 0.4),
                                  blurRadius: compact ? 8 : 12,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: compact ? 8 : 10),
                          Expanded(
                            child: compact
                                ? Text(
                                    '${planet.name} / ${copy.formation(planet.formation)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        planet.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        planet.relationshipLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.72),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        copy.formation(planet.formation),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.66),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          Icon(
                            planet.mutualGravityAccepted
                                ? Icons.link
                                : Icons.shield_outlined,
                            size: compact ? 18 : 20,
                            color: planet.mutualGravityAccepted
                                ? Colors.greenAccent
                                : Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: compact ? 6 : 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: Size.fromHeight(compact ? 34 : 48),
                    ),
                    onPressed: onPulse,
                    key: const ValueKey('launch-pulse-button'),
                    icon: Icon(
                      pulseCoolingDown ? Icons.thermostat : Icons.bolt,
                      size: compact ? 16 : 18,
                    ),
                    label: Text(
                      pulseCoolingDown ? coolingLabel : launchPulseLabel,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
