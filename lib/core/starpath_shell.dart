import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../features/base/base_page.dart';
import '../features/capsule/capsule_page.dart';
import '../features/orbit/models/friend_planet.dart';
import '../features/orbit/orbit_page.dart';
import '../services/mock_repositories.dart';
import '../shared/ai/mock_ai_signal_service.dart';
import 'starpath_controller.dart';
import 'starpath_style.dart';

class StarPathShell extends StatefulWidget {
  const StarPathShell({super.key});

  @override
  State<StarPathShell> createState() => _StarPathShellState();
}

class _StarPathShellState extends State<StarPathShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final StarPathController _starPathController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _starPathController = StarPathController(
      friendRepository: const MockFriendRepository(),
      signalRepository: const MockSignalRepository(),
      capsuleRepository: const MockCapsuleRepository(),
      aiSignalService: const MockAiSignalService(),
    );
    unawaited(_starPathController.initializePhysics());
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _starPathController.dispose();
    super.dispose();
  }

  Future<void> _showFormationDialog() async {
    final TextEditingController controller = TextEditingController();
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StarPathStyle.surface,
          title: Text(
            _starPathController.copy.addFormation,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: StarPathStyle.textPrimary),
            decoration: InputDecoration(
              hintText: _starPathController.copy.formationHint,
              hintStyle: const TextStyle(color: StarPathStyle.textTertiary),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_starPathController.copy.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(_starPathController.copy.addFormation),
            ),
          ],
        );
      },
    );

    final String formation = (result ?? '').trim();
    if (formation.isNotEmpty) {
      _starPathController.addFormation(formation);
    }
  }

  Future<void> _openWormholeDialog(BuildContext context) async {
    final List<FriendPlanet> planets = _starPathController.visiblePlanets
        .where((planet) => !planet.blocked)
        .toList();
    if (planets.isEmpty) {
      return;
    }

    final FriendPlanet? target = await showDialog<FriendPlanet>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: StarPathStyle.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: StarPathStyle.accent.withValues(alpha: 0.24),
            ),
          ),
          title: Text(
            _starPathController.copy.chooseFriendShip,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SizedBox(
            width: 360,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: planets.length,
                separatorBuilder: (_, _) =>
                    Divider(color: Colors.white.withValues(alpha: 0.08)),
                itemBuilder: (context, index) {
                  final FriendPlanet planet = planets[index];
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      key: ValueKey('wormhole-target-${planet.name}'),
                      contentPadding: EdgeInsets.zero,
                      onTap: () => Navigator.of(context).pop(planet),
                      leading: CircleAvatar(
                        radius: 10,
                        backgroundColor: planet.color,
                      ),
                      title: Text(
                        planet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        _starPathController.copy.formation(planet.formation),
                        style: TextStyle(
                          color: StarPathStyle.textSecondary.withValues(
                            alpha: 0.82,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: StarPathStyle.accent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_starPathController.copy.cancel),
            ),
          ],
        );
      },
    );

    if (target != null) {
      _starPathController.triggerQuantumWormhole(target);
    }
  }

  FriendPlanet? _selectedQuantumTarget() {
    final String? targetName = _starPathController.quantumTargetName;
    if (targetName == null) {
      return null;
    }

    for (final FriendPlanet planet in _starPathController.visiblePlanets) {
      if (planet.name == targetName) {
        return planet;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _starPathController,
      builder: (context, child) {
        final FriendPlanet? quantumTarget = _selectedQuantumTarget();

        return Scaffold(
          backgroundColor: StarPathStyle.backgroundDeep,
          extendBody: true,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  StarPathStyle.backgroundGlow,
                  StarPathStyle.background,
                  StarPathStyle.backgroundDeep,
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -0.75),
                          radius: 1.1,
                          colors: [
                            StarPathStyle.accent.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                IndexedStack(
                  index: _tabIndex,
                  children: [
                    OrbitPage(
                      controller: _orbitController,
                      planets: _starPathController.visiblePlanets,
                      supernova: _starPathController.supernova,
                      onPulse: _starPathController.pulse,
                      formations: _starPathController.formations,
                      selectedFormation: _starPathController.selectedFormation,
                      onFormationChanged: _starPathController.selectFormation,
                      copy: _starPathController.copy,
                      onLanguageToggle: _starPathController.toggleLanguage,
                      hubbleMessage: _starPathController.hubbleMessage,
                      encryptedLetterReady:
                          _starPathController.encryptedLetterReady,
                      onHubbleTap: _starPathController.tapHubble,
                      onShipTap: _starPathController.selectPlanet,
                      pulseCoolingDown: _starPathController.pulseCoolingDown,
                      resonanceActive: _starPathController.resonanceActive,
                      lensActive: _starPathController.lensActive,
                      quantumActive: _starPathController.quantumActive,
                      isHibernating: _starPathController.isHibernating,
                      wakeEffectActive: _starPathController.wakeEffectActive,
                      singularityActive: _starPathController.singularityActive,
                      pixelNoiseActive: _starPathController.pixelNoiseActive,
                      bigBangActive: _starPathController.bigBangActive,
                      ceoSignalVisible: _starPathController.ceoSignalVisible,
                      hubbleSuitIndex: _starPathController.hubbleSuitIndex,
                      onQuantumTap: () => _openWormholeDialog(context),
                      onHibernationToggle:
                          _starPathController.toggleHibernation,
                      onSingularityTap: _starPathController.triggerSingularity,
                      onAcceptSingularity:
                          _starPathController.acceptSingularitySignal,
                      solarPhotonReadout:
                          _starPathController.solarPhotonReadout,
                      entropyLostPercent:
                          _starPathController.entropyLostPercent,
                      hibernationCoolingDown:
                          _starPathController.hibernationCoolingDown,
                      quantumTransitProgress:
                          _starPathController.quantumTransitProgress,
                      quantumTargetPosition: quantumTarget?.position,
                      selectedPlanet: _starPathController.selectedPlanet,
                      latestSignalTitle: _starPathController.latestSignalTitle,
                      latestMemoryTitle: _starPathController.latestMemoryTitle,
                      onClearSelectedPlanet:
                          _starPathController.clearSelectedPlanet,
                      onSendSelectedSignal:
                          _starPathController.sendSelectedSignal,
                      onArchiveSelectedMemory:
                          _starPathController.archiveSelectedMemory,
                      onOpenBase: () {
                        setState(() {
                          _tabIndex = 1;
                        });
                      },
                      onOpenCapsule: () {
                        setState(() {
                          _tabIndex = 2;
                        });
                      },
                    ),
                    BasePage(
                      planets: _starPathController.planets,
                      signals: _starPathController.signals,
                      aiSuggestion: _starPathController.aiSuggestion,
                      copy: _starPathController.copy,
                      formations: _starPathController.formations,
                      selectedFormation: _starPathController.selectedFormation,
                      onFormationChanged: _starPathController.selectFormation,
                      onAddFormation: _showFormationDialog,
                    ),
                    CapsulePage(
                      memories: _starPathController.memories,
                      planets: _starPathController.relationshipFeed,
                      copy: _starPathController.copy,
                      singularityMedalUnlocked:
                          _starPathController.singularityMedalUnlocked,
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DecoratedBox(
                  decoration: StarPathStyle.dockDecoration(radius: 32),
                  child: NavigationBar(
                    height: 72,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    selectedIndex: _tabIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        _tabIndex = value;
                      });
                    },
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.public_outlined),
                        selectedIcon: const Icon(Icons.public),
                        label: _starPathController.copy.orbit,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.hub_outlined),
                        selectedIcon: const Icon(Icons.hub),
                        label: _starPathController.copy.base,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.photo_outlined),
                        selectedIcon: const Icon(Icons.photo),
                        label: _starPathController.copy.capsule,
                      ),
                    ],
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
