import '../orbit/models/friend_planet.dart';
import 'models/relationship_quest.dart';
import 'models/relationship_quest_type.dart';

class RelationshipQuestGenerator {
  const RelationshipQuestGenerator();

  List<RelationshipQuest> questsForPlanet(FriendPlanet planet) {
    final RelationshipQuest? quest = primaryQuestForPlanet(planet);
    if (quest == null) {
      return const [];
    }
    return [quest];
  }

  RelationshipQuest? primaryQuestForPlanet(FriendPlanet planet) {
    if (!planet.unlocked && planet.energy < 0.70) {
      return RelationshipQuest(
        id: '${planet.id}-reach-energy',
        friendId: planet.id,
        title: 'Warm ${planet.name} to 70%',
        description: 'Raise this orbit enough to open the unlock window.',
        type: RelationshipQuestType.reachEnergy,
        currentValue: planet.energy,
        targetValue: 0.70,
        completed: planet.energy >= 0.70,
      );
    }

    if (!planet.unlocked && planet.energy >= 0.70) {
      return RelationshipQuest(
        id: '${planet.id}-unlock-connection',
        friendId: planet.id,
        title: 'Stabilize mutual gravity',
        description: 'This orbit is warm enough. Push it into a real unlock.',
        type: RelationshipQuestType.unlockConnection,
        currentValue: planet.unlocked ? 1 : 0,
        targetValue: 1,
        completed: planet.unlocked,
      );
    }

    if (planet.unlocked && planet.memoryCount == 0) {
      return RelationshipQuest(
        id: '${planet.id}-log-memory',
        friendId: planet.id,
        title: 'Archive the first shared memory',
        description: 'Turn the fresh unlock into something worth keeping.',
        type: RelationshipQuestType.logSharedMemory,
        currentValue: planet.memoryCount.toDouble(),
        targetValue: 1,
        completed: planet.memoryCount > 0,
      );
    }

    return null;
  }
}
