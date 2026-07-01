import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../features/base/models/signal_record.dart';
import '../features/capsule/models/capsule_memory.dart';
import '../features/orbit/models/friend_planet.dart';
import '../services/repositories.dart';
import '../services/time_physics_storage.dart';
import '../shared/ai/ai_signal_service.dart';
import 'starpath_copy.dart';

class StarPathController extends ChangeNotifier {
  StarPathController({
    required FriendRepository friendRepository,
    required SignalRepository signalRepository,
    required CapsuleRepository capsuleRepository,
    required this.aiSignalService,
    this.timePhysicsStorage = const TimePhysicsStorage(),
  }) : planets = List<FriendPlanet>.from(friendRepository.loadPlanets()),
       signals = List<SignalRecord>.from(signalRepository.loadSignals()),
       _baseMemories =
           List<CapsuleMemory>.from(capsuleRepository.loadMemories());

  final AiSignalService aiSignalService;
  final TimePhysicsStorage timePhysicsStorage;
  final List<CapsuleMemory> _baseMemories;

  final List<FriendPlanet> planets;
  final List<SignalRecord> signals;

  bool supernova = false;
  String selectedFormation = 'All';
  StarPathLanguage language = StarPathLanguage.english;
  String hubbleMessage = const StarPathCopy(
    StarPathLanguage.english,
  ).hubbleIdle;
  bool encryptedLetterReady = false;
  int pulseCount = 0;
  DateTime? pulseCooldownUntil;
  DateTime? lensCooldownUntil;
  bool resonanceActive = false;
  bool lensActive = false;
  bool quantumActive = false;
  String? quantumTargetName;
  bool isHibernating = false;
  bool wakeEffectActive = false;
  bool singularityActive = false;
  bool pixelNoiseActive = false;
  bool bigBangActive = false;
  bool ceoSignalVisible = false;
  bool singularityMedalUnlocked = false;
  bool hibernationCoolingDown = false;
  int hubbleSuitIndex = 0;
  String? selectedPlanetName;
  String? latestSignalTitle;
  String? latestMemoryTitle;
  DateTime? hibernateStartTime;
  DateTime? hibernateCooldownUntil;
  DateTime? lastInteractionAt;
  DateTime? quantumStartTime;
  int solarPhotonWatts = 0;
  double entropyLostPercent = 0;
  bool physicsLoaded = false;
  Timer? _resonanceTimer;
  Timer? _lensTimer;
  Timer? _quantumTimer;
  Timer? _hibernateCooldownTimer;
  Timer? _wakeEffectTimer;
  Timer? _pixelNoiseTimer;
  Timer? _singularityCollapseTimer;
  Timer? _bigBangTimer;
  final List<String> _customFormations = [];

  StarPathCopy get copy => StarPathCopy(language);

  bool get pulseCoolingDown {
    final DateTime? until = pulseCooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  bool get lensCoolingDown {
    final DateTime? until = lensCooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  String get solarPhotonReadout {
    return '${solarPhotonWatts}W';
  }

  double get quantumTransitProgress {
    final DateTime? start = quantumStartTime;
    if (!quantumActive || start == null) {
      return 0;
    }

    return (DateTime.now().difference(start).inMilliseconds / 2600)
        .clamp(0, 1)
        .toDouble();
  }

  Future<void> initializePhysics() async {
    final snapshot = await timePhysicsStorage.load();
    pulseCooldownUntil = snapshot.pulseCooldownUntil;
    hibernateStartTime = snapshot.hibernateStartTime;
    lastInteractionAt = snapshot.lastInteractionAt;
    solarPhotonWatts = snapshot.solarPhotonWatts;
    isHibernating = snapshot.isHibernating;

    for (
      int i = 0;
      i < planets.length && i < snapshot.planetEnergies.length;
      i++
    ) {
      planets[i].energy = snapshot.planetEnergies[i];
      planets[i].radius = _radiusForEnergy(planets[i].energy);
    }

    if (isHibernating) {
      hubbleMessage = copy.hubbleSleep;
    } else {
      _applyEntropyDecay(DateTime.now());
    }

    physicsLoaded = true;
    await _persistPhysics();
    notifyListeners();
  }

  List<String> get formations {
    final seen = <String>{};
    for (final planet in planets) {
      seen.add(planet.formation);
    }
    return ['All', ...seen, ..._customFormations];
  }

  List<FriendPlanet> get relationshipFeed {
    final List<FriendPlanet> feed = planets.where((planet) => !planet.blocked).toList();
    feed.sort((a, b) => b.energy.compareTo(a.energy));
    return feed;
  }

  List<FriendPlanet> get visiblePlanets {
    return planets.where((planet) {
      if (planet.blocked) {
        return false;
      }

      return selectedFormation == 'All' ||
          planet.formation == selectedFormation;
    }).toList();
  }

  FriendPlanet? get selectedPlanet {
    final String? name = selectedPlanetName;
    if (name == null) {
      return null;
    }
    for (final FriendPlanet planet in planets) {
      if (planet.name == name) {
        return planet;
      }
    }
    return null;
  }

  String get aiSuggestion {
    return aiSignalService.suggestionFor(planets, signals);
  }

  List<CapsuleMemory> get memories {
    final bool emmaUnlocked = planets.any(
      (planet) => planet.name == 'Navigator Emma' && planet.unlocked,
    );

    return _baseMemories.map((memory) {
      if (memory.friendName != 'Navigator Emma') {
        return memory;
      }

      return CapsuleMemory(
        friendName: memory.friendName,
        title: memory.title,
        caption: memory.caption,
        color: memory.color,
        unlocked: emmaUnlocked,
      );
    }).toList();
  }

  void pulse() {
    if (isHibernating || pulseCoolingDown) {
      hubbleMessage = copy.hubbleCooling;
      notifyListeners();
      return;
    }

    final FriendPlanet target = selectedPlanet ?? planets[1];
    if (!target.mutualGravityAccepted && target.energy >= 0.30) {
      notifyListeners();
      return;
    }

    _applyContactBoost(
      target,
      delta: 0.15,
      title: 'Pulse resonance',
      summary: 'A direct pulse narrowed the distance and lit the route.',
      nextActionWhenWarm: 'Open the shared capsule',
      nextActionWhenCool: 'Keep the next message low-pressure',
    );
    pulseCount += 1;
    resonanceActive = true;
    _resonanceTimer?.cancel();
    _resonanceTimer = Timer(const Duration(milliseconds: 900), () {
      resonanceActive = false;
      notifyListeners();
    });
    lastInteractionAt = DateTime.now();

    if (pulseCount >= 3) {
      pulseCooldownUntil = DateTime.now().add(const Duration(minutes: 30));
      hubbleMessage = copy.hubbleCooling;
    }

    _checkSingularity();
    unawaited(_persistPhysics());
    notifyListeners();
  }

  void selectFormation(String formation) {
    selectedFormation = formation;
    notifyListeners();
  }

  void addFormation(String formation) {
    final String trimmed = formation.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final bool exists =
        _customFormations.contains(trimmed) || formations.contains(trimmed);
    if (!exists) {
      _customFormations.add(trimmed);
    }
    selectedFormation = trimmed;
    notifyListeners();
  }

  void toggleLanguage() {
    language = language == StarPathLanguage.english
        ? StarPathLanguage.traditionalChinese
        : StarPathLanguage.english;
    hubbleMessage = encryptedLetterReady
        ? copy.hubbleEncrypted
        : copy.hubbleIdle;
    notifyListeners();
  }

  void selectPlanet(FriendPlanet planet) {
    selectedPlanetName = planet.name;
    if (!planet.unlocked && !lensCoolingDown) {
      inspectShip(planet);
      return;
    }
    notifyListeners();
  }

  void clearSelectedPlanet() {
    selectedPlanetName = null;
    notifyListeners();
  }

  void inspectShip(FriendPlanet planet) {
    selectedPlanetName = planet.name;
    if (planet.unlocked || lensCoolingDown) {
      notifyListeners();
      return;
    }

    lensActive = true;
    _lensTimer?.cancel();
    _lensTimer = Timer(const Duration(milliseconds: 1600), () {
      lensActive = false;
      notifyListeners();
    });
    lensCooldownUntil = DateTime.now().add(const Duration(hours: 4));
    lastInteractionAt = DateTime.now();
    encryptedLetterReady = true;
    hubbleMessage = copy.hubbleEncrypted;
    unawaited(_persistPhysics());
    notifyListeners();
  }

  void sendSelectedSignal() {
    final FriendPlanet? target = selectedPlanet;
    if (target == null || isHibernating) {
      return;
    }
    _applyContactBoost(
      target,
      delta: target.unlocked ? 0.07 : 0.10,
      title: target.unlocked ? 'Shared lane reopened' : 'Soft orbit ping',
      summary: target.unlocked
          ? 'A gentle follow-up keeps the stable lane active without pressure.'
          : 'A low-pressure ping reopened the channel and raised the response window.',
      nextActionWhenWarm: 'Open the shared capsule',
      nextActionWhenCool: 'Let the next message stay light',
    );
    latestSignalTitle = signals.first.title;
    hubbleMessage = copy.signalSent;
    lastInteractionAt = DateTime.now();
    _checkSingularity();
    unawaited(_persistPhysics());
    notifyListeners();
  }

  void archiveSelectedMemory() {
    final FriendPlanet? target = selectedPlanet;
    if (target == null) {
      return;
    }

    final bool unlockMemory = target.unlocked || target.energy >= 0.60;
    final CapsuleMemory memory = CapsuleMemory(
      friendName: target.name,
      title: unlockMemory
          ? '${target.name} Archive'
          : '${target.name} Pending Archive',
      caption: unlockMemory
          ? 'A new shared trace was filed after the latest orbit contact.'
          : 'A partial trace was filed. Raise the orbit energy to reveal the full page.',
      color: target.color,
      unlocked: unlockMemory,
    );

    final int existingIndex = _baseMemories.indexWhere(
      (item) => item.friendName == target.name,
    );
    if (existingIndex >= 0) {
      _baseMemories[existingIndex] = memory;
    } else {
      _baseMemories.insert(0, memory);
    }

    target.memoryCount += 1;
    target.nextAction = unlockMemory
        ? 'Open the shared capsule'
        : 'Keep building the route';
    latestMemoryTitle = memory.title;
    hubbleMessage = copy.memoryLogged;
    lastInteractionAt = DateTime.now();
    unawaited(_persistPhysics());
    notifyListeners();
  }

  void tapHubble() {
    if (encryptedLetterReady) {
      encryptedLetterReady = false;
      hubbleMessage = copy.hubbleDecrypted;
      notifyListeners();
      return;
    }

    hubbleSuitIndex = (hubbleSuitIndex + 1) % 3;
    hubbleMessage = copy.hubbleIdle;
    notifyListeners();
  }

  void triggerQuantumTunneling() {
    if (planets.isEmpty) {
      return;
    }

    triggerQuantumWormhole(planets.first);
  }

  void triggerQuantumWormhole(FriendPlanet target) {
    if (isHibernating) {
      return;
    }

    _resetTransientEffects(keepQuantum: true);
    quantumTargetName = target.name;
    quantumActive = true;
    quantumStartTime = DateTime.now();
    _quantumTimer?.cancel();
    _quantumTimer = Timer(const Duration(milliseconds: 2600), () {
      quantumActive = false;
      quantumStartTime = null;
      notifyListeners();
    });
    final bool exists = planets.any(
      (planet) => planet.name == 'Unknown QT-009',
    );
    if (!exists) {
      planets.add(
        FriendPlanet(
          name: 'Unknown QT-009',
          energy: 0.60,
          unlocked: false,
          color: Colors.purpleAccent,
          radius: 140,
          offset: 5.2,
          formation: 'Cross-field',
          relationshipLabel: 'Wormhole visitor',
          lastContactLabel: 'Just arrived',
          memoryCount: 1,
          nextAction: 'Inspect the new route',
          position: const Offset(80, 320),
          velocity: const Offset(0.82, -0.26),
        ),
      );
    }

    selectedFormation = 'All';
    selectedPlanetName = target.name;
    notifyListeners();
  }

  void toggleHibernation() {
    if (!isHibernating && hibernationCoolingDown) {
      return;
    }

    isHibernating = !isHibernating;
    if (isHibernating) {
      _resetTransientEffects();
      hibernateStartTime = DateTime.now();
      hibernateCooldownUntil = DateTime.now().add(const Duration(seconds: 10));
      hibernationCoolingDown = true;
      _hibernateCooldownTimer?.cancel();
      _hibernateCooldownTimer = Timer(const Duration(seconds: 10), () {
        hibernationCoolingDown = false;
        notifyListeners();
      });
      hubbleMessage = copy.hubbleSleep;
      unawaited(_persistPhysics());
      notifyListeners();
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime? start = hibernateStartTime;
    if (start != null && now.isAfter(start)) {
      solarPhotonWatts += now.difference(start).inSeconds * 12;
    }
    hibernateStartTime = null;
    lastInteractionAt = now;
    wakeEffectActive = true;
    _wakeEffectTimer?.cancel();
    _wakeEffectTimer = Timer(const Duration(seconds: 2), () {
      wakeEffectActive = false;
      notifyListeners();
    });
    hubbleMessage = copy.hubbleWake;
    unawaited(_persistPhysics());
    notifyListeners();
  }

  void triggerSingularity() {
    _resetTransientEffects();
    ceoSignalVisible = true;
    pixelNoiseActive = true;
    singularityActive = false;
    _pixelNoiseTimer?.cancel();
    _pixelNoiseTimer = Timer(const Duration(milliseconds: 1200), () {
      pixelNoiseActive = false;
      notifyListeners();
    });
    notifyListeners();
  }

  void acceptSingularitySignal() {
    _resetTransientEffects();
    ceoSignalVisible = false;
    pixelNoiseActive = false;
    singularityActive = true;
    bigBangActive = false;
    singularityMedalUnlocked = true;
    lastInteractionAt = DateTime.now();
    _singularityCollapseTimer?.cancel();
    _singularityCollapseTimer = Timer(const Duration(milliseconds: 1500), () {
      singularityActive = false;
      bigBangActive = true;
      _bigBangTimer?.cancel();
      _bigBangTimer = Timer(const Duration(seconds: 2), () {
        bigBangActive = false;
        notifyListeners();
      });
      notifyListeners();
    });
    unawaited(_persistPhysics());
    notifyListeners();
  }

  double _radiusForEnergy(double energy) {
    if (energy >= 0.70) {
      return 90;
    }

    if (energy >= 0.45) {
      return 140;
    }

    return 190;
  }

  void _checkSingularity() {
    final bool allDefaultUnlocked = planets
        .where((planet) => !planet.name.startsWith('Unknown QT'))
        .every((planet) => planet.energy >= 0.70 || planet.unlocked);
    if (allDefaultUnlocked && !singularityMedalUnlocked && !ceoSignalVisible) {
      triggerSingularity();
    }
  }

  void _applyContactBoost(
    FriendPlanet target, {
    required double delta,
    required String title,
    required String summary,
    required String nextActionWhenWarm,
    required String nextActionWhenCool,
  }) {
    target.energy = min(1, target.energy + delta);
    target.radius = _radiusForEnergy(target.energy);
    target.lastContactLabel = 'Updated just now';
    target.nextAction =
        target.energy >= 0.70 ? nextActionWhenWarm : nextActionWhenCool;
    _unlockIfEligible(target);
    signals.insert(
      0,
      SignalRecord(
        friendName: target.name,
        title: title,
        summary: summary,
        energyDelta: delta,
        color: target.color,
      ),
    );
    if (signals.length > 8) {
      signals.removeLast();
    }
  }

  void _unlockIfEligible(FriendPlanet target) {
    if (target.energy >= 0.70 &&
        target.mutualGravityAccepted &&
        !target.unlocked) {
      target.unlocked = true;
      if (target.name == 'EX-002') {
        target.name = 'Navigator Emma';
      }
      target.color = Colors.greenAccent;
      target.relationshipLabel = 'Unlocked connection';
      target.lastContactLabel = 'Mutual gravity stabilized';
      target.nextAction = 'Open the shared capsule';
      selectedPlanetName = target.name;
      supernova = true;
    }
  }

  void _applyEntropyDecay(DateTime now) {
    final DateTime? last = lastInteractionAt;
    if (last == null || isHibernating) {
      return;
    }

    final int idleDays = now.difference(last).inDays;
    if (idleDays <= 14) {
      entropyLostPercent = 0;
      return;
    }

    final int decayDays = idleDays - 14;
    final double decay = decayDays * 0.01;
    entropyLostPercent = decay * 100;

    for (final planet in planets) {
      planet.energy = max(0.30, planet.energy - decay);
      planet.radius = _radiusForEnergy(planet.energy);
    }
  }

  Future<void> _persistPhysics() {
    return timePhysicsStorage.save(
      pulseCooldownUntil: pulseCooldownUntil,
      hibernateStartTime: hibernateStartTime,
      lastInteractionAt: lastInteractionAt,
      solarPhotonWatts: solarPhotonWatts,
      planetEnergies: planets.map((planet) => planet.energy).toList(),
      isHibernating: isHibernating,
    );
  }

  void _resetTransientEffects({
    bool keepQuantum = false,
  }) {
    _resonanceTimer?.cancel();
    _lensTimer?.cancel();
    _quantumTimer?.cancel();
    _wakeEffectTimer?.cancel();
    _pixelNoiseTimer?.cancel();
    _singularityCollapseTimer?.cancel();
    _bigBangTimer?.cancel();
    resonanceActive = false;
    lensActive = false;
    quantumActive = keepQuantum ? quantumActive : false;
    if (!keepQuantum) {
      quantumTargetName = null;
      quantumStartTime = null;
    }
    wakeEffectActive = false;
    pixelNoiseActive = false;
    singularityActive = false;
    bigBangActive = false;
  }

  @override
  void dispose() {
    _resonanceTimer?.cancel();
    _lensTimer?.cancel();
    _quantumTimer?.cancel();
    _hibernateCooldownTimer?.cancel();
    _wakeEffectTimer?.cancel();
    _pixelNoiseTimer?.cancel();
    _singularityCollapseTimer?.cancel();
    _bigBangTimer?.cancel();
    super.dispose();
  }
}
