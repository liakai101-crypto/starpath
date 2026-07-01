import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/starpath_copy.dart';
import '../../core/starpath_style.dart';
import 'models/friend_planet.dart';
import 'widgets/cosmic_mist.dart';
import 'widgets/hubble_core.dart';
import 'widgets/hubble_copilot.dart';
import 'widgets/orbit_effects.dart';
import 'widgets/orbit_console.dart';
import 'widgets/orbit_planet.dart';
import 'widgets/supernova_particles.dart';

class OrbitPage extends StatelessWidget {
  const OrbitPage({
    required this.controller,
    required this.planets,
    required this.supernova,
    required this.onPulse,
    required this.formations,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.copy,
    required this.onLanguageToggle,
    required this.hubbleMessage,
    required this.encryptedLetterReady,
    required this.onHubbleTap,
    required this.onShipTap,
    required this.pulseCoolingDown,
    required this.resonanceActive,
    required this.lensActive,
    required this.quantumActive,
    required this.isHibernating,
    required this.wakeEffectActive,
    required this.singularityActive,
    required this.pixelNoiseActive,
    required this.bigBangActive,
    required this.ceoSignalVisible,
    required this.hubbleSuitIndex,
    required this.onQuantumTap,
    required this.onHibernationToggle,
    required this.onSingularityTap,
    required this.onAcceptSingularity,
    required this.solarPhotonReadout,
    required this.entropyLostPercent,
    required this.hibernationCoolingDown,
    required this.quantumTransitProgress,
    required this.quantumTargetPosition,
    required this.selectedPlanet,
    required this.latestSignalTitle,
    required this.latestMemoryTitle,
    required this.onClearSelectedPlanet,
    required this.onSendSelectedSignal,
    required this.onArchiveSelectedMemory,
    required this.onOpenBase,
    required this.onOpenCapsule,
    super.key,
  });

  final AnimationController controller;
  final List<FriendPlanet> planets;
  final bool supernova;
  final VoidCallback onPulse;
  final List<String> formations;
  final String selectedFormation;
  final ValueChanged<String> onFormationChanged;
  final StarPathCopy copy;
  final VoidCallback onLanguageToggle;
  final String hubbleMessage;
  final bool encryptedLetterReady;
  final VoidCallback onHubbleTap;
  final ValueChanged<FriendPlanet> onShipTap;
  final bool pulseCoolingDown;
  final bool resonanceActive;
  final bool lensActive;
  final bool quantumActive;
  final bool isHibernating;
  final bool wakeEffectActive;
  final bool singularityActive;
  final bool pixelNoiseActive;
  final bool bigBangActive;
  final bool ceoSignalVisible;
  final int hubbleSuitIndex;
  final VoidCallback onQuantumTap;
  final VoidCallback onHibernationToggle;
  final VoidCallback onSingularityTap;
  final VoidCallback onAcceptSingularity;
  final String solarPhotonReadout;
  final double entropyLostPercent;
  final bool hibernationCoolingDown;
  final double quantumTransitProgress;
  final Offset? quantumTargetPosition;
  final FriendPlanet? selectedPlanet;
  final String? latestSignalTitle;
  final String? latestMemoryTitle;
  final VoidCallback onClearSelectedPlanet;
  final VoidCallback onSendSelectedSignal;
  final VoidCallback onArchiveSelectedMemory;
  final VoidCallback onOpenBase;
  final VoidCallback onOpenCapsule;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool compact = constraints.maxWidth < 1100;
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (!isHibernating) {
              _DriftPhysics.advance(planets: planets, size: size);
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                ColoredBox(
                  color: isHibernating
                      ? const Color(0xFF04101E)
                      : const Color(0xFF02050B),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: _DeepSpaceBackdropPainter(
                    progress: controller.value,
                    hibernating: isHibernating,
                  ),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: _StarDustPainter(progress: controller.value),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: _OrbitalFieldPainter(
                    progress: controller.value,
                    hibernating: isHibernating,
                  ),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: CosmicMistPainter(
                    progress: controller.value,
                    dispersed: supernova,
                  ),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: _ForegroundMistPainter(
                    progress: controller.value,
                    hibernating: isHibernating,
                  ),
                ),
                if (supernova)
                  CustomPaint(
                    size: Size.infinite,
                    painter: SupernovaParticlesPainter(
                      progress: controller.value,
                    ),
                  ),
                if (resonanceActive && selectedPlanet != null)
                  CustomPaint(
                    size: Size.infinite,
                    painter: ResonanceStreamPainter(
                      progress: controller.value,
                      target: selectedPlanet!,
                    ),
                  ),
                if (lensActive)
                  CustomPaint(
                    size: Size.infinite,
                    painter: GravityLensPainter(progress: controller.value),
                  ),
                if (quantumActive)
                  CustomPaint(
                    size: Size.infinite,
                    painter: _QuantumWormholePainter(
                      progress: controller.value,
                      transitProgress: quantumTransitProgress,
                      targetPosition: quantumTargetPosition,
                    ),
                  ),
                if (wakeEffectActive || bigBangActive)
                  CustomPaint(
                    size: Size.infinite,
                    painter: ExpandingHaloPainter(progress: controller.value),
                  ),
                if (pixelNoiseActive)
                  CustomPaint(
                    size: Size.infinite,
                    painter: PixelNoisePainter(progress: controller.value),
                  ),
                HubbleCore(
                  label: copy.command,
                  progress: controller.value,
                  isHibernating: isHibernating,
                  quantumTransitProgress: quantumTransitProgress,
                  quantumTargetPosition: quantumTargetPosition,
                ),
                for (final FriendPlanet planet in planets)
                  RepaintBoundary(
                    child: OrbitPlanet(
                      key: ValueKey('ship-${planet.name}'),
                      controllerValue: controller.value,
                      planet: planet,
                      celebrating: supernova && planet.name == 'Navigator Emma',
                      onTap: () => onShipTap(planet),
                    ),
                  ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: RepaintBoundary(
                    child: _GlassShell(
                      child: _LanguageButton(
                        label: copy.languageButton,
                        onPressed: onLanguageToggle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  left: 18,
                  child: RepaintBoundary(
                    child: _GlassShell(
                      child: _PhysicsHud(
                        copy: copy,
                        solarPhotonReadout: solarPhotonReadout,
                        entropyLostPercent: entropyLostPercent,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: RepaintBoundary(
                    child: _GlassShell(
                      child: _FormationFilterButton(
                        formations: formations,
                        selectedFormation: selectedFormation,
                        onChanged: onFormationChanged,
                        copy: copy,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 128,
                  child: RepaintBoundary(
                    child: _GlassShell(
                      padding: const EdgeInsets.all(10),
                      child: _SystemButtons(
                        copy: copy,
                        isHibernating: isHibernating,
                        hibernationCoolingDown: hibernationCoolingDown,
                        onQuantumTap: onQuantumTap,
                        onHibernationToggle: onHibernationToggle,
                        onSingularityTap: onSingularityTap,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: compact ? 52 : 120,
                  child: RepaintBoundary(
                    child: _OrbitConsoleDock(
                      planets: planets,
                      onPulse: pulseCoolingDown || isHibernating
                          ? null
                          : onPulse,
                      launchPulseLabel: copy.launchPulse,
                      coolingLabel: copy.cooling,
                      pulseCoolingDown: pulseCoolingDown,
                      onShipTap: onShipTap,
                      copy: copy,
                      initiallyExpanded: !compact,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: compact ? 170 : 240,
                  child: RepaintBoundary(
                    child: HubbleCopilot(
                      name: copy.hubbleName,
                      message: hubbleMessage,
                      encryptedLetterReady: encryptedLetterReady,
                      suitIndex: hubbleSuitIndex,
                      sleeping: isHibernating,
                      onTap: onHubbleTap,
                      compact: compact,
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: compact ? 168 : 118,
                  child: RepaintBoundary(
                    child: _GlassShell(
                      padding: const EdgeInsets.all(10),
                      child: _OrbitContactPanel(
                        copy: copy,
                        selectedPlanet: selectedPlanet,
                        latestSignalTitle: latestSignalTitle,
                        latestMemoryTitle: latestMemoryTitle,
                        onClear: onClearSelectedPlanet,
                        onSendSignal: isHibernating
                            ? null
                            : onSendSelectedSignal,
                        onLogMemory: isHibernating
                            ? null
                            : onArchiveSelectedMemory,
                        onOpenBase: onOpenBase,
                        onOpenCapsule: onOpenCapsule,
                        compact: compact,
                      ),
                    ),
                  ),
                ),
                if (singularityActive) const _SingularityCollapseOverlay(),
                if (ceoSignalVisible)
                  _CeoSignalDialog(
                    message: copy.ceoSignal,
                    copy: copy,
                    onAccept: onAcceptSingularity,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DriftPhysics {
  const _DriftPhysics._();

  static void advance({
    required List<FriendPlanet> planets,
    required Size size,
  }) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final bounds = Rect.fromLTWH(32, 72, size.width - 64, size.height - 184);

    for (final planet in planets) {
      if (planet.position == Offset.zero) {
        planet.position =
            center + Offset(planet.radius * 0.55, planet.radius * 0.22);
      }

      final currentDistance = (planet.position - center).distance;
      var next = planet.position + planet.velocity;
      var velocity = planet.velocity;

      if (next.dx < bounds.left || next.dx > bounds.right) {
        velocity = Offset(-velocity.dx, velocity.dy);
        next = planet.position + velocity;
      }

      if (next.dy < bounds.top || next.dy > bounds.bottom) {
        velocity = Offset(velocity.dx, -velocity.dy);
        next = planet.position + velocity;
      }

      final nextDistance = (next - center).distance;
      if (!planet.mutualGravityAccepted && nextDistance < 110) {
        final direction = (next - center);
        final normalized = direction.distance == 0
            ? const Offset(1, 0)
            : direction / direction.distance;
        next = center + normalized * 110;
        velocity = -velocity;
      }

      planet.movingAway = nextDistance > currentDistance;
      planet.velocity = velocity;
      planet.position = next;
    }
  }
}

class _PhysicsHud extends StatelessWidget {
  const _PhysicsHud({
    required this.copy,
    required this.solarPhotonReadout,
    required this.entropyLostPercent,
  });

  final StarPathCopy copy;
  final String solarPhotonReadout;
  final double entropyLostPercent;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.isZh
                ? '\u592a\u967d\u80fd $solarPhotonReadout'
                : 'Solar $solarPhotonReadout',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (entropyLostPercent > 0)
            Text(
              copy.isZh
                  ? '\u71b5\u503c -${entropyLostPercent.toStringAsFixed(0)}%'
                  : 'Entropy -${entropyLostPercent.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _OrbitContactPanel extends StatelessWidget {
  const _OrbitContactPanel({
    required this.copy,
    required this.selectedPlanet,
    required this.latestSignalTitle,
    required this.latestMemoryTitle,
    required this.onClear,
    required this.onSendSignal,
    required this.onLogMemory,
    required this.onOpenBase,
    required this.onOpenCapsule,
    required this.compact,
  });
  final StarPathCopy copy;
  final FriendPlanet? selectedPlanet;
  final String? latestSignalTitle;
  final String? latestMemoryTitle;
  final VoidCallback onClear;
  final VoidCallback? onSendSignal;
  final VoidCallback? onLogMemory;
  final VoidCallback onOpenBase;
  final VoidCallback onOpenCapsule;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final FriendPlanet? planet = selectedPlanet;
    final String recentUpdate =
        latestMemoryTitle ??
        latestSignalTitle ??
        (planet?.lastContactLabel ?? '');
    return SizedBox(
      width: compact ? 256 : 308,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  copy.orbitContactLayer,
                  style: const TextStyle(
                    color: StarPathStyle.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (planet != null)
                IconButton(
                  tooltip: copy.cancel,
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Colors.white70,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (planet == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.noFriendSelected,
                  style: const TextStyle(
                    color: StarPathStyle.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  copy.selectShipHint,
                  style: TextStyle(
                    color: StarPathStyle.textSecondary.withValues(alpha: 0.88),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: planet.color,
                    boxShadow: [
                      BoxShadow(
                        color: planet.color.withValues(alpha: 0.50),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    planet.name,
                    style: const TextStyle(
                      color: StarPathStyle.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _InfoPill(
                  label: '${(planet.energy * 100).round()}%',
                  color: planet.color,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!compact) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(
                    label: copy.formation(planet.formation),
                    color: StarPathStyle.accent,
                  ),
                  _InfoPill(
                    label: planet.unlocked ? copy.unlocked : copy.locked,
                    color: planet.unlocked
                        ? const Color(0xFF7CE7B2)
                        : StarPathStyle.textSecondary,
                  ),
                  _InfoPill(
                    label: planet.mutualGravityAccepted
                        ? copy.linkStatus
                        : copy.energyLocked,
                    color: planet.mutualGravityAccepted
                        ? const Color(0xFF7CE7B2)
                        : StarPathStyle.accentSoft,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _OrbitPanelRow(title: copy.nextAction, body: planet.nextAction),
              const SizedBox(height: 8),
              _OrbitPanelRow(
                title: copy.recentUpdate,
                body: recentUpdate.isEmpty
                    ? planet.lastContactLabel
                    : recentUpdate,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSendSignal,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: Text(copy.sendSoftPing),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onLogMemory,
                      icon: const Icon(Icons.auto_stories_rounded, size: 16),
                      label: Text(copy.logSharedMoment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onOpenBase,
                      icon: const Icon(Icons.hub_outlined, size: 16),
                      label: Text(copy.openBaseWorkbench),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onOpenCapsule,
                      icon: const Icon(Icons.photo_outlined, size: 16),
                      label: Text(copy.openCapsuleArchive),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  _InfoPill(
                    label: copy.formation(planet.formation),
                    color: StarPathStyle.accent,
                  ),
                  const SizedBox(width: 8),
                  _InfoPill(
                    label: planet.unlocked ? copy.unlocked : copy.locked,
                    color: planet.unlocked
                        ? const Color(0xFF7CE7B2)
                        : StarPathStyle.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _OrbitPanelRow(
                title: copy.recentUpdate,
                body: recentUpdate.isEmpty
                    ? planet.lastContactLabel
                    : recentUpdate,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrbitPanelRow extends StatelessWidget {
  const _OrbitPanelRow({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: StarPathStyle.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          body,
          style: const TextStyle(
            color: StarPathStyle.textPrimary,
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SystemButtons extends StatelessWidget {
  const _SystemButtons({
    required this.copy,
    required this.isHibernating,
    required this.hibernationCoolingDown,
    required this.onQuantumTap,
    required this.onHibernationToggle,
    required this.onSingularityTap,
  });

  final StarPathCopy copy;
  final bool isHibernating;
  final bool hibernationCoolingDown;
  final VoidCallback onQuantumTap;
  final VoidCallback onHibernationToggle;
  final VoidCallback onSingularityTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _MiniAction(
          keyLabel: 'quantum',
          icon: Icons.auto_awesome,
          label: copy.quantum,
          onPressed: onQuantumTap,
        ),
        const SizedBox(height: 10),
        _MiniAction(
          keyLabel: 'hibernate',
          icon: isHibernating
              ? Icons.wb_sunny_outlined
              : hibernationCoolingDown
              ? Icons.hourglass_bottom
              : Icons.bedtime,
          label: isHibernating
              ? copy.wake
              : hibernationCoolingDown
              ? copy.cooling
              : copy.hibernate,
          onPressed: hibernationCoolingDown && !isHibernating
              ? null
              : onHibernationToggle,
        ),
        const SizedBox(height: 10),
        _MiniAction(
          keyLabel: 'singularity',
          icon: Icons.brightness_1,
          label: copy.singularity,
          onPressed: onSingularityTap,
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.keyLabel,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String keyLabel;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: FilledButton(
        key: ValueKey('action-$keyLabel'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.all(8),
          backgroundColor: onPressed == null
              ? Colors.white.withValues(alpha: 0.035)
              : Colors.white.withValues(alpha: 0.055),
          foregroundColor: onPressed == null
              ? Colors.white38
              : Colors.cyanAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _CeoSignalDialog extends StatelessWidget {
  const _CeoSignalDialog({
    required this.message,
    required this.copy,
    required this.onAccept,
  });

  final String message;
  final StarPathCopy copy;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: StarPathStyle.backgroundDeep.withValues(alpha: 0.72),
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: StarPathStyle.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: StarPathStyle.accent.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.42),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.greenAccent,
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: StarPathStyle.textPrimary,
                    height: 1.35,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onAccept,
                  child: Text(copy.isZh ? '\u555f\u52d5' : 'Engage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SingularityCollapseOverlay extends StatelessWidget {
  const _SingularityCollapseOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1, end: 0),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.28),
                    blurRadius: 80,
                    spreadRadius: 120,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuantumWormholePainter extends CustomPainter {
  _QuantumWormholePainter({
    required this.progress,
    required this.transitProgress,
    required this.targetPosition,
  });

  final double progress;
  final double transitProgress;
  final Offset? targetPosition;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Offset rightExit =
        targetPosition ?? Offset(size.width * 0.72, size.height * 0.45);
    final double p = transitProgress;
    final bool midTransit = p >= 0.28 && p <= 0.72;

    final Paint tunnel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.cyanAccent.withValues(alpha: 0.9),
          Colors.greenAccent.withValues(alpha: 0.9),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(center, rightExit));

    final Path arc = Path()
      ..moveTo(center.dx, center.dy - 6)
      ..quadraticBezierTo(
        center.dx + 86,
        center.dy - 110,
        rightExit.dx,
        rightExit.dy - 8,
      );
    canvas.drawPath(arc, tunnel);

    final Paint portal = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.purpleAccent.withValues(alpha: 0.38);
    canvas.drawCircle(center, 28 + sin(progress * pi * 2) * 3, portal);
    canvas.drawCircle(rightExit, 18 + cos(progress * pi * 2) * 2, portal);

    final Paint particlePaint = Paint()..style = PaintingStyle.fill;
    final int count = midTransit ? 14 : 8;
    for (int i = 0; i < count; i++) {
      final double seed = (progress * 8 + i / count) % 1;
      final double t = midTransit ? (p + i / count) % 1 : seed;
      final Offset point =
          Offset.lerp(center, rightExit, t)! +
          Offset(
            sin((t * 10) + progress * 12) * 16,
            cos((t * 8) + progress * 10) * 10,
          );
      particlePaint.color = (i.isEven ? Colors.cyanAccent : Colors.greenAccent)
          .withValues(alpha: midTransit ? 0.9 - (i / count) * 0.7 : 0.35);
      canvas.drawCircle(point, midTransit ? 2.4 : 1.6, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuantumWormholePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.transitProgress != transitProgress ||
        oldDelegate.targetPosition != targetPosition;
  }
}

class _FormationFilterButton extends StatelessWidget {
  const _FormationFilterButton({
    required this.formations,
    required this.selectedFormation,
    required this.onChanged,
    required this.copy,
  });

  final List<String> formations;
  final String selectedFormation;
  final ValueChanged<String> onChanged;
  final StarPathCopy copy;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selectedFormation,
      color: StarPathStyle.surface,
      icon: const Icon(Icons.tune_rounded, color: StarPathStyle.accent),
      tooltip: copy.fleetFilter,
      onSelected: onChanged,
      itemBuilder: (context) {
        return [
          for (final formation in formations)
            PopupMenuItem<String>(
              value: formation,
              child: Text(
                formation == 'All' ? copy.allBands : copy.formation(formation),
                style: TextStyle(
                  color: formation == selectedFormation
                      ? StarPathStyle.accent
                      : StarPathStyle.textPrimary,
                  fontSize: 13,
                  fontWeight: formation == selectedFormation
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
        ];
      },
    );
  }
}

class _OrbitConsoleDock extends StatefulWidget {
  const _OrbitConsoleDock({
    required this.planets,
    required this.onPulse,
    required this.launchPulseLabel,
    required this.coolingLabel,
    required this.pulseCoolingDown,
    required this.onShipTap,
    required this.copy,
    required this.initiallyExpanded,
  });

  final List<FriendPlanet> planets;
  final VoidCallback? onPulse;
  final String launchPulseLabel;
  final String coolingLabel;
  final bool pulseCoolingDown;
  final ValueChanged<FriendPlanet> onShipTap;
  final StarPathCopy copy;
  final bool initiallyExpanded;

  @override
  State<_OrbitConsoleDock> createState() => _OrbitConsoleDockState();
}

class _OrbitConsoleDockState extends State<_OrbitConsoleDock> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant _OrbitConsoleDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: _expanded ? 286 : 112,
      constraints: BoxConstraints(
        minHeight: _expanded ? 186 : 44,
        maxHeight: _expanded ? 186 : 44,
      ),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: _GlassShell(
          padding: EdgeInsets.all(_expanded ? 8 : 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _expanded
                ? Column(
                    key: const ValueKey('expanded-console'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.copy.signalCabin,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: widget.copy.isZh
                                ? '\u6536\u5408'
                                : 'Collapse',
                            icon: const Icon(Icons.expand_more, size: 18),
                            color: Colors.white70,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            onPressed: () => setState(() => _expanded = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 104,
                        child: SingleChildScrollView(
                          child: OrbitConsole(
                            planets: widget.planets,
                            onPulse: widget.onPulse,
                            launchPulseLabel: widget.launchPulseLabel,
                            coolingLabel: widget.coolingLabel,
                            pulseCoolingDown: widget.pulseCoolingDown,
                            onShipTap: widget.onShipTap,
                            copy: widget.copy,
                            compact: true,
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    key: const ValueKey('collapsed-console'),
                    height: 40,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyanAccent.withValues(alpha: 0.10),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.layers_outlined,
                            size: 15,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.copy.signalCabin,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.expand_less,
                          size: 18,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: StarPathStyle.accent,
        backgroundColor: StarPathStyle.surfaceMuted.withValues(alpha: 0.76),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _GlassShell extends StatelessWidget {
  const _GlassShell({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: StarPathStyle.glassPanel(
            radius: 24,
            tint: StarPathStyle.surfaceMuted,
            opacity: 0.80,
            borderOpacity: 0.09,
            blur: 18,
            shadowOffset: const Offset(0, 12),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          StarPathStyle.accent.withValues(alpha: 0.06),
                          Colors.transparent,
                          StarPathStyle.accentSoft.withValues(alpha: 0.05),
                        ],
                        stops: const [0, 0.46, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding ?? const EdgeInsets.all(4),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeepSpaceBackdropPainter extends CustomPainter {
  const _DeepSpaceBackdropPainter({
    required this.progress,
    required this.hibernating,
  });

  final double progress;
  final bool hibernating;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.42);
    final Rect atmosphere = Rect.fromCenter(
      center: center,
      width: size.width * 1.22,
      height: size.height * 0.76,
    );
    final Color coreTint = hibernating
        ? const Color(0xFF1F4B73)
        : const Color(0xFF44185F);

    final Paint vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.16),
          Colors.black.withValues(alpha: 0.84),
        ],
        stops: const [0.48, 0.80, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);

    final Paint bloom = Paint()
      ..shader = RadialGradient(
        colors: [
          coreTint.withValues(alpha: hibernating ? 0.12 : 0.16),
          coreTint.withValues(alpha: hibernating ? 0.05 : 0.08),
          Colors.transparent,
        ],
      ).createShader(atmosphere);
    canvas.drawOval(atmosphere, bloom);

    final Paint secondaryBloom = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: hibernating ? 0.02 : 0.035),
              Colors.transparent,
            ],
            stops: const [0.18, 1],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.52, size.height * 0.34),
              width: size.width * 0.44,
              height: size.height * 0.18,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.34),
        width: size.width * 0.44,
        height: size.height * 0.18,
      ),
      secondaryBloom,
    );

    final Paint lane = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: hibernating ? 0.025 : 0.045),
          Colors.transparent,
        ],
        stops: const [0.10, 0.5, 0.90],
      ).createShader(Rect.fromLTWH(0, size.height * 0.52, size.width, 40));
    final Path flow = Path()
      ..moveTo(size.width * 0.05, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.33,
        size.height * 0.49 + sin(progress * pi * 0.6) * 8,
        size.width * 0.94,
        size.height * 0.58,
      );
    canvas.drawPath(flow, lane);

    final Paint underGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: hibernating ? 0.025 : 0.04),
              coreTint.withValues(alpha: 0.015),
              Colors.transparent,
            ],
            stops: const [0, 0.5, 1],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height * 0.67),
              width: size.width * 0.84,
              height: size.height * 0.20,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.67),
        width: size.width * 0.84,
        height: size.height * 0.20,
      ),
      underGlow,
    );

    final Paint clusterPaint = Paint()..style = PaintingStyle.fill;
    final List<Offset> clusters = [
      Offset(size.width * 0.14, size.height * 0.16),
      Offset(size.width * 0.84, size.height * 0.18),
      Offset(size.width * 0.72, size.height * 0.72),
    ];
    for (int i = 0; i < clusters.length; i++) {
      final Offset base =
          clusters[i] +
          Offset(sin(progress * 0.24 + i) * 5, cos(progress * 0.18 + i) * 3);
      final List<Offset> dust = [
        const Offset(0, 0),
        const Offset(16, -10),
        const Offset(-14, 12),
        const Offset(24, 8),
        const Offset(-20, -8),
      ];
      for (final Offset offset in dust) {
        clusterPaint.color =
            (i.isEven ? Colors.cyanAccent : Colors.purpleAccent).withValues(
              alpha: hibernating ? 0.018 : 0.028,
            );
        canvas.drawCircle(base + offset, 1.3, clusterPaint);
      }
    }

    final Paint halo = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.transparent,
              coreTint.withValues(alpha: hibernating ? 0.06 : 0.08),
              Colors.transparent,
            ],
            stops: const [0.28, 0.55, 1],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height * 0.39),
              width: size.width * 0.58,
              height: size.height * 0.18,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.39),
        width: size.width * 0.58,
        height: size.height * 0.18,
      ),
      halo,
    );

    final Paint nebulaBand = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              const Color(
                0xFF5A2A7A,
              ).withValues(alpha: hibernating ? 0.04 : 0.07),
              const Color(
                0xFF173A53,
              ).withValues(alpha: hibernating ? 0.03 : 0.06),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.55, size.height * 0.30),
              width: size.width * 0.86,
              height: size.height * 0.18,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.30),
        width: size.width * 0.86,
        height: size.height * 0.18,
      ),
      nebulaBand,
    );
  }

  @override
  bool shouldRepaint(covariant _DeepSpaceBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hibernating != hibernating;
  }
}

class _StarDustPainter extends CustomPainter {
  const _StarDustPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint star = Paint()..style = PaintingStyle.fill;
    final List<_StarLayer> layers = [
      _StarLayer(
        count: 24,
        opacity: 0.065,
        size: 0.72,
        drift: 0.06,
        color: Colors.white,
      ),
      _StarLayer(
        count: 18,
        opacity: 0.048,
        size: 1.0,
        drift: 0.045,
        color: Colors.cyanAccent,
      ),
      _StarLayer(
        count: 10,
        opacity: 0.034,
        size: 1.35,
        drift: 0.032,
        color: Colors.purpleAccent,
      ),
    ];

    for (int layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      final layer = layers[layerIndex];
      for (int i = 0; i < layer.count; i++) {
        final double seed = (i + 1) / (layer.count + 1);
        final double x =
            (seed * size.width * 0.98) +
            sin((progress * layer.drift) + i * 1.1 + layerIndex) * 6;
        final double y =
            (seed * size.height * 0.92) +
            cos((progress * (layer.drift + 0.03)) + i * 1.5 + layerIndex) * 4;
        final Offset p = Offset(
          (x + (layerIndex * 57)) % size.width,
          (y + (layerIndex * 43)) % size.height,
        );
        star.color = layer.color.withValues(
          alpha: layer.opacity + (sin(progress * 2 + i) * 0.006),
        );
        canvas.drawCircle(p, layer.size, star);
      }
    }

    final Paint microDust = Paint()..style = PaintingStyle.fill;
    final Random random = Random(17);
    for (int i = 0; i < 90; i++) {
      microDust.color = (i.isEven ? Colors.white : Colors.cyanAccent)
          .withValues(alpha: 0.012 + (i % 5) * 0.003);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.45 + (i % 3) * 0.10,
        microDust,
      );
    }

    final Paint twinkle = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final Offset p = Offset(
        ((i * 173.0) + sin(progress * 2 * pi + i) * 6) % size.width,
        ((i * 97.0) + cos(progress * pi * 1.4 + i) * 4) % size.height,
      );
      twinkle.color = Colors.white.withValues(
        alpha: 0.06 + ((sin(progress * pi * 6 + i) + 1) * 0.03),
      );
      canvas.drawCircle(p, 1.2, twinkle);
    }
  }

  @override
  bool shouldRepaint(covariant _StarDustPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StarLayer {
  const _StarLayer({
    required this.count,
    required this.opacity,
    required this.size,
    required this.drift,
    required this.color,
  });

  final int count;
  final double opacity;
  final double size;
  final double drift;
  final Color color;
}

class _OrbitalFieldPainter extends CustomPainter {
  const _OrbitalFieldPainter({
    required this.progress,
    required this.hibernating,
  });

  final double progress;
  final bool hibernating;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect fieldRect = Rect.fromCenter(
      center: center,
      width: size.width * 1.08,
      height: size.height * 0.34,
    );

    final Paint band = Paint()
      ..shader = RadialGradient(
        colors: [
          (hibernating ? const Color(0xFF23436A) : const Color(0xFF4A1D66))
              .withValues(alpha: 0.09),
          (hibernating ? const Color(0xFF08111F) : const Color(0xFF241030))
              .withValues(alpha: 0.038),
          Colors.transparent,
        ],
        stops: const [0.04, 0.52, 1],
      ).createShader(fieldRect);
    canvas.drawOval(fieldRect, band);

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.cyanAccent.withValues(
        alpha: hibernating ? 0.025 : 0.045,
      );
    final Path path = Path()
      ..moveTo(size.width * 0.07, size.height * 0.60)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.54 + sin(progress * pi * 2) * 4,
        size.width * 0.93,
        size.height * 0.61,
      );
    canvas.drawPath(path, arc);

    final Paint line = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: hibernating ? 0.022 : 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.58, size.width, 20));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.57, size.width, 2), line);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.purpleAccent.withValues(
        alpha: hibernating ? 0.022 : 0.04,
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.37),
        width: size.width * 0.68,
        height: size.height * 0.14,
      ),
      ring,
    );

    final Paint guide = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.transparent,
              Colors.cyanAccent.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height * 0.48),
              width: size.width * 0.52,
              height: 18,
            ),
          );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.48),
        width: size.width * 0.52,
        height: 10,
      ),
      guide,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitalFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hibernating != hibernating;
  }
}

class _ForegroundMistPainter extends CustomPainter {
  const _ForegroundMistPainter({
    required this.progress,
    required this.hibernating,
  });

  final double progress;
  final bool hibernating;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Color base = hibernating
        ? const Color(0xFF3C5A8E)
        : Colors.purpleAccent;
    final List<Offset> blobs = [
      Offset(size.width * 0.12, size.height * 0.18),
      Offset(size.width * 0.82, size.height * 0.22),
      Offset(size.width * 0.16, size.height * 0.78),
      Offset(size.width * 0.84, size.height * 0.74),
    ];
    for (int i = 0; i < blobs.length; i++) {
      final Offset center =
          blobs[i] +
          Offset(
            sin(progress * pi * 0.22 + i) * 3,
            cos(progress * pi * 0.18 + i) * 2,
          );
      paint.shader = RadialGradient(
        colors: [
          base.withValues(alpha: 0.032),
          base.withValues(alpha: 0.012),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 140));
      canvas.drawCircle(center, 140, paint);
    }

    final Paint veil = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: hibernating ? 0.12 : 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width / 2, size.height * 0.55),
              width: size.width,
              height: size.height * 0.42,
            ),
          );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.55),
        width: size.width,
        height: size.height * 0.42,
      ),
      veil,
    );
  }

  @override
  bool shouldRepaint(covariant _ForegroundMistPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hibernating != hibernating;
  }
}
