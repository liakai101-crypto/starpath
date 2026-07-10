import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/core/starpath_controller.dart';
import 'package:starpath/features/base/models/relationship_quest.dart';
import 'package:starpath/features/base/models/relationship_quest_type.dart';
import 'package:starpath/features/base/relationship_quest_generator.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';
import 'package:starpath/services/mock_repositories.dart';
import 'package:starpath/shared/ai/mock_ai_signal_service.dart';

void main() {
  group('FriendPlanet identity', () {
    test('friend planet requires a stable id', () {
      final planet = FriendPlanet(
        id: 'emma',
        name: 'EX-002',
        energy: 0.68,
        unlocked: false,
        color: Colors.cyanAccent,
        radius: 140,
        offset: 2,
        formation: 'Sport',
      );

      expect(planet.id, 'emma');
    });
  });

  group('RelationshipQuest', () {
    test('calculates progress as clamped ratio', () {
      const quest = RelationshipQuest(
        id: 'emma-reach-70',
        friendId: 'emma',
        title: 'Warm EX-002 to 70%',
        description: 'Raise this orbit enough to open the unlock window.',
        type: RelationshipQuestType.reachEnergy,
        currentValue: 0.68,
        targetValue: 0.70,
        completed: false,
      );

      expect(quest.progress, closeTo(0.9714, 0.0001));
    });
  });

  group('RelationshipQuestGenerator', () {
    const generator = RelationshipQuestGenerator();

    test('locked low-energy planet gets reach-energy quest', () {
      final planet = FriendPlanet(
        id: 'emma',
        name: 'EX-002',
        energy: 0.68,
        unlocked: false,
        color: Colors.cyanAccent,
        radius: 140,
        offset: 2,
        formation: 'Sport',
      );

      final quest = generator.primaryQuestForPlanet(planet);

      expect(quest, isNotNull);
      expect(quest!.type, RelationshipQuestType.reachEnergy);
      expect(quest.targetValue, 0.70);
    });

    test('warm locked planet gets unlock quest', () {
      final planet = FriendPlanet(
        id: 'emma',
        name: 'EX-002',
        energy: 0.75,
        unlocked: false,
        color: Colors.cyanAccent,
        radius: 140,
        offset: 2,
        formation: 'Sport',
        mutualGravityAccepted: false,
      );

      final quest = generator.primaryQuestForPlanet(planet);

      expect(quest, isNotNull);
      expect(quest!.type, RelationshipQuestType.unlockConnection);
    });

    test('unlocked planet with no memories gets memory quest', () {
      final planet = FriendPlanet(
        id: 'emma',
        name: 'Navigator Emma',
        energy: 0.80,
        unlocked: true,
        color: Colors.greenAccent,
        radius: 90,
        offset: 2,
        formation: 'Sport',
        memoryCount: 0,
      );

      final quest = generator.primaryQuestForPlanet(planet);

      expect(quest, isNotNull);
      expect(quest!.type, RelationshipQuestType.logSharedMemory);
    });

    test('progressed unlocked planet gets no quest', () {
      final planet = FriendPlanet(
        id: 'alex',
        name: 'Cpt. Alex',
        energy: 0.85,
        unlocked: true,
        color: Colors.greenAccent,
        radius: 90,
        offset: 4,
        formation: 'Research',
        memoryCount: 2,
      );

      expect(generator.primaryQuestForPlanet(planet), isNull);
    });
  });

  group('StarPathController quest lookup', () {
    test('controller exposes primary quest for a relationship', () {
      final controller = StarPathController(
        friendRepository: const MockFriendRepository(),
        signalRepository: const MockSignalRepository(),
        capsuleRepository: const MockCapsuleRepository(),
        aiSignalService: const MockAiSignalService(),
      );

      final emma = controller.planets.firstWhere((planet) => planet.name == 'EX-002');
      final quest = controller.primaryQuestForPlanet(emma);

      expect(quest, isNotNull);
      expect(quest!.friendId, 'emma');
    });
  });
}
