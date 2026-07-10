import 'relationship_quest_type.dart';

class RelationshipQuest {
  const RelationshipQuest({
    required this.id,
    required this.friendId,
    required this.title,
    required this.description,
    required this.type,
    required this.currentValue,
    required this.targetValue,
    required this.completed,
  });

  final String id;
  final String friendId;
  final String title;
  final String description;
  final RelationshipQuestType type;
  final double currentValue;
  final double targetValue;
  final bool completed;

  double get progress {
    if (targetValue <= 0) {
      return 0;
    }
    return (currentValue / targetValue).clamp(0, 1).toDouble();
  }
}
