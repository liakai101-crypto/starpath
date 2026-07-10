# Quest System V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a first playable relationship-specific quest layer that derives one active quest from each relationship's current state and displays it in Base.

**Architecture:** Keep quest logic derived and stateless in V1. Add a focused quest model and generator, expose quest lookup through `StarPathController`, and render the active quest in `BasePage`'s selected-relationship area. Avoid storage or backend work until the loop proves valuable.

**Tech Stack:** Flutter, Dart, `flutter_test`

---

## File Map

- Create: `lib/features/base/models/relationship_quest_type.dart`
  Holds the V1 quest enum.

- Create: `lib/features/base/models/relationship_quest.dart`
  Holds quest data and progress helper.

- Create: `lib/features/base/relationship_quest_generator.dart`
  Converts `FriendPlanet` state into one active quest.

- Create: `test/relationship_quest_generator_test.dart`
  Covers quest generation rules.

- Modify: `lib/features/orbit/models/friend_planet.dart`
  Add stable `id`.

- Modify: `lib/services/starpath_mock_data.dart`
  Seed stable ids for mock relationships.

- Modify: `lib/core/starpath_controller.dart`
  Add generator dependency and controller quest accessors.

- Modify: `lib/features/base/base_page.dart`
  Render active quest in the relationship detail UI.

### Task 1: Add stable friend identity

**Files:**
- Modify: `lib/features/orbit/models/friend_planet.dart`
- Modify: `lib/services/starpath_mock_data.dart`
- Test: `test/relationship_quest_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';

void main() {
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: FAIL with a constructor error because `FriendPlanet` does not accept `id`.

- [ ] **Step 3: Write minimal implementation**

```dart
class FriendPlanet {
  final String id;
  String name;
  double energy;
  bool unlocked;
  Color color;
  double radius;
  double offset;
  String formation;
  String relationshipLabel;
  String lastContactLabel;
  int memoryCount;
  String nextAction;
  bool mutualGravityAccepted;
  bool blocked;
  Offset position;
  Offset velocity;
  bool movingAway;

  FriendPlanet({
    required this.id,
    required this.name,
    required this.energy,
    required this.unlocked,
    required this.color,
    required this.radius,
    required this.offset,
    required this.formation,
    this.relationshipLabel = 'Connection',
    this.lastContactLabel = '',
    this.memoryCount = 0,
    this.nextAction = '',
    this.mutualGravityAccepted = true,
    this.blocked = false,
    this.position = Offset.zero,
    this.velocity = const Offset(0.7, 0.4),
    this.movingAway = false,
  });
}
```

```dart
static List<FriendPlanet> planets() {
  return [
    FriendPlanet(
      id: 'ex001',
      name: 'Unknown EX-001',
      energy: 0.30,
      unlocked: false,
      color: Colors.purple,
      radius: 190,
      offset: 0,
      formation: 'Research',
    ),
    FriendPlanet(
      id: 'emma',
      name: 'EX-002',
      energy: 0.68,
      unlocked: false,
      color: Colors.cyanAccent,
      radius: 140,
      offset: 2,
      formation: 'Sport',
    ),
    FriendPlanet(
      id: 'alex',
      name: 'Cpt. Alex',
      energy: 0.85,
      unlocked: true,
      color: Colors.greenAccent,
      radius: 90,
      offset: 4,
      formation: 'Research',
    ),
  ];
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: PASS with 1 test passed.

- [ ] **Step 5: Commit**

```bash
git add lib/features/orbit/models/friend_planet.dart lib/services/starpath_mock_data.dart test/relationship_quest_generator_test.dart
git commit -m "feat: add stable friend ids for quests"
```

### Task 2: Add the quest model layer

**Files:**
- Create: `lib/features/base/models/relationship_quest_type.dart`
- Create: `lib/features/base/models/relationship_quest.dart`
- Test: `test/relationship_quest_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/features/base/models/relationship_quest.dart';
import 'package:starpath/features/base/models/relationship_quest_type.dart';

void main() {
  test('relationship quest calculates progress as clamped ratio', () {
    const quest = RelationshipQuest(
      id: 'emma-reach-70',
      friendId: 'emma',
      title: 'Warm Emma to 70%',
      description: 'Raise Emma enough to open the unlock window.',
      type: RelationshipQuestType.reachEnergy,
      currentValue: 0.68,
      targetValue: 0.70,
      completed: false,
    );

    expect(quest.progress, closeTo(0.9714, 0.0001));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: FAIL with import or type-not-found errors for `RelationshipQuest`.

- [ ] **Step 3: Write minimal implementation**

```dart
enum RelationshipQuestType {
  reachEnergy,
  unlockConnection,
  logSharedMemory,
}
```

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: PASS and report 2 tests passed.

- [ ] **Step 5: Commit**

```bash
git add lib/features/base/models/relationship_quest_type.dart lib/features/base/models/relationship_quest.dart test/relationship_quest_generator_test.dart
git commit -m "feat: add relationship quest models"
```

### Task 3: Implement deterministic quest generation

**Files:**
- Create: `lib/features/base/relationship_quest_generator.dart`
- Test: `test/relationship_quest_generator_test.dart`

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/features/base/models/relationship_quest_type.dart';
import 'package:starpath/features/base/relationship_quest_generator.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';

void main() {
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
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: FAIL with import or missing method errors for `RelationshipQuestGenerator`.

- [ ] **Step 3: Write minimal implementation**

```dart
import '../orbit/models/friend_planet.dart';
import 'models/relationship_quest.dart';
import 'models/relationship_quest_type.dart';

class RelationshipQuestGenerator {
  const RelationshipQuestGenerator();

  List<RelationshipQuest> questsForPlanet(FriendPlanet planet) {
    final quest = primaryQuestForPlanet(planet);
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: PASS and report the generator tests passing.

- [ ] **Step 5: Commit**

```bash
git add lib/features/base/relationship_quest_generator.dart test/relationship_quest_generator_test.dart
git commit -m "feat: generate relationship quests from planet state"
```

### Task 4: Expose quests through the controller

**Files:**
- Modify: `lib/core/starpath_controller.dart`
- Test: `test/relationship_quest_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/core/starpath_controller.dart';
import 'package:starpath/services/mock_repositories.dart';
import 'package:starpath/shared/ai/mock_ai_signal_service.dart';

void main() {
  test('controller exposes primary quest for a relationship', () {
    final controller = StarPathController(
      friendRepository: const MockFriendRepository(),
      signalRepository: const MockSignalRepository(),
      capsuleRepository: const MockCapsuleRepository(),
      aiSignalService: const MockAiSignalService(),
    );

    final emma = controller.planets.firstWhere((planet) => planet.id == 'emma');
    final quest = controller.primaryQuestForPlanet(emma);

    expect(quest, isNotNull);
    expect(quest!.friendId, 'emma');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: FAIL because `StarPathController` has no `primaryQuestForPlanet`.

- [ ] **Step 3: Write minimal implementation**

```dart
import '../features/base/models/relationship_quest.dart';
import '../features/base/relationship_quest_generator.dart';
```

```dart
class StarPathController extends ChangeNotifier {
  StarPathController({
    required FriendRepository friendRepository,
    required SignalRepository signalRepository,
    required CapsuleRepository capsuleRepository,
    required this.aiSignalService,
    this.timePhysicsStorage = const TimePhysicsStorage(),
    this.questGenerator = const RelationshipQuestGenerator(),
  }) : planets = List<FriendPlanet>.from(friendRepository.loadPlanets()),
       signals = List<SignalRecord>.from(signalRepository.loadSignals()),
       _baseMemories =
           List<CapsuleMemory>.from(capsuleRepository.loadMemories());

  final RelationshipQuestGenerator questGenerator;
```

```dart
List<RelationshipQuest> questsForPlanet(FriendPlanet planet) {
  return questGenerator.questsForPlanet(planet);
}

RelationshipQuest? primaryQuestForPlanet(FriendPlanet planet) {
  return questGenerator.primaryQuestForPlanet(planet);
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart -r compact`
Expected: PASS with controller quest test green.

- [ ] **Step 5: Commit**

```bash
git add lib/core/starpath_controller.dart test/relationship_quest_generator_test.dart
git commit -m "feat: expose relationship quests from controller"
```

### Task 5: Render the quest in Base

**Files:**
- Modify: `lib/features/base/base_page.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starpath/core/starpath_copy.dart';
import 'package:starpath/core/starpath_style.dart';
import 'package:starpath/features/base/base_page.dart';
import 'package:starpath/features/base/models/relationship_quest.dart';
import 'package:starpath/features/base/models/relationship_quest_type.dart';
import 'package:starpath/features/base/models/signal_record.dart';
import 'package:starpath/features/orbit/models/friend_planet.dart';

void main() {
  testWidgets('base page shows active relationship quest', (tester) async {
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

    await tester.pumpWidget(
      MaterialApp(
        theme: StarPathStyle.theme(),
        home: BasePage(
          planets: [planet],
          signals: const [
            SignalRecord(
              friendName: 'EX-002',
              title: 'Late-night orbit ping',
              summary: 'Recent replies cluster at night.',
              energyDelta: 0.15,
              color: Colors.cyanAccent,
            ),
          ],
          aiSuggestion: 'Start with a low-pressure check-in.',
          copy: const StarPathCopy(StarPathLanguage.english),
          formations: const ['All', 'Sport'],
          selectedFormation: 'All',
          onFormationChanged: (_) {},
          onAddFormation: () {},
          primaryQuestBuilder: (_) => const RelationshipQuest(
            id: 'emma-reach-energy',
            friendId: 'emma',
            title: 'Warm Emma to 70%',
            description: 'Raise this orbit enough to open the unlock window.',
            type: RelationshipQuestType.reachEnergy,
            currentValue: 0.68,
            targetValue: 0.70,
            completed: false,
          ),
        ),
      ),
    );

    expect(find.text('Warm Emma to 70%'), findsOneWidget);
    expect(find.textContaining('0.68'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/widget_test.dart -r compact`
Expected: FAIL because `BasePage` has no quest input or quest card.

- [ ] **Step 3: Write minimal implementation**

```dart
import 'models/relationship_quest.dart';
```

```dart
class BasePage extends StatefulWidget {
  const BasePage({
    required this.planets,
    required this.signals,
    required this.aiSuggestion,
    required this.copy,
    required this.formations,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.onAddFormation,
    this.primaryQuestBuilder,
    super.key,
  });

  final RelationshipQuest? Function(FriendPlanet planet)? primaryQuestBuilder;
```

```dart
final RelationshipQuest? activeQuest = selectedPlanet == null
    ? null
    : widget.primaryQuestBuilder?.call(selectedPlanet);
```

```dart
if (activeQuest != null) ...[
  const SizedBox(height: 12),
  _DetailBlock(
    title: 'Active quest',
    body:
        '${activeQuest.title}\n${activeQuest.description}\n${activeQuest.currentValue.toStringAsFixed(2)} / ${activeQuest.targetValue.toStringAsFixed(2)}',
  ),
],
```

Update the shell wiring:

```dart
BasePage(
  planets: _starPathController.planets,
  signals: _starPathController.signals,
  aiSuggestion: _starPathController.aiSuggestion,
  copy: _starPathController.copy,
  formations: _starPathController.formations,
  selectedFormation: _starPathController.selectedFormation,
  onFormationChanged: _starPathController.selectFormation,
  onAddFormation: _showFormationDialog,
  primaryQuestBuilder: _starPathController.primaryQuestForPlanet,
),
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/widget_test.dart -r compact`
Expected: PASS with the active quest card visible.

- [ ] **Step 5: Commit**

```bash
git add lib/core/starpath_shell.dart lib/features/base/base_page.dart test/widget_test.dart
git commit -m "feat: show active relationship quests in base"
```

### Task 6: Full verification pass

**Files:**
- Test: `test/relationship_quest_generator_test.dart`
- Test: `test/widget_test.dart`
- Test: `test/ai_signal_service_test.dart`
- Test: `test/starpath_serializers_test.dart`

- [ ] **Step 1: Run focused quest tests**

Run: `C:\src\flutter\bin\flutter.bat test test/relationship_quest_generator_test.dart test/widget_test.dart -r compact`
Expected: PASS with quest logic and Base quest UI green.

- [ ] **Step 2: Run broader regression tests**

Run: `C:\src\flutter\bin\flutter.bat test test/ai_signal_service_test.dart test/starpath_serializers_test.dart -r compact`
Expected: PASS with no regressions in AI or serializer coverage.

- [ ] **Step 3: Run analyzer**

Run: `C:\src\flutter\bin\flutter.bat analyze`
Expected: `No issues found!`

- [ ] **Step 4: Commit verification-clean state**

```bash
git add lib test
git commit -m "test: verify quest system v1 integration"
```

## Self-Review

- Spec coverage check:
  - stable friend id: Task 1
  - quest model and enum: Task 2
  - deterministic generation: Task 3
  - controller exposure: Task 4
  - Base UI exposure: Task 5
  - verification: Task 6

- Placeholder scan:
  - no `TODO` or `TBD` markers remain
  - each task includes exact files, commands, and code

- Type consistency:
  - `RelationshipQuest`
  - `RelationshipQuestType`
  - `RelationshipQuestGenerator`
  - `primaryQuestForPlanet`
  - `questsForPlanet`

