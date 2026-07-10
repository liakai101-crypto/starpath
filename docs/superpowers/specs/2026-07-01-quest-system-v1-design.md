# StarPath Quest System V1 Design

## Summary

StarPath's first quest system should turn each relationship into a small, readable progression loop. Version 1 will not introduce a full quest backend, reward inventory, or persistent quest history. Instead, it will derive 0 to 2 active quests from each `FriendPlanet`'s current state and expose them through `StarPathController` for the existing Flutter UI.

The goal is to make the "human relationship as cosmic exploration game" positioning legible in-product without destabilizing the current architecture.

## Product Goal

Build the first playable layer of relationship-specific progression:

- A relationship can surface a clear current objective.
- The objective updates immediately as the player interacts.
- The objective is grounded in real existing mechanics: `energy`, `unlocked`, `memoryCount`, and `mutualGravityAccepted`.
- The objective can be displayed in `Base` without introducing a new navigation mode.

## Non-Goals

Version 1 will not include:

- daily or weekly quests
- chapter maps or multi-step quest chains
- reward currencies or consumables
- persistent quest completion history
- backend quest storage
- quest editing tools

## Existing Constraints

The current project already has a strong control point:

- `StarPathController` owns cross-tab relationship state and action methods.
- `FriendPlanet` is the authoritative model for relationship status.
- `BasePage` already acts as the relationship workbench and is the best first home for quest UI.
- `EX-002` can be renamed to `Navigator Emma`, so quests cannot safely key off `name`.

## V1 Design

### Relationship Quest Model

Introduce a lightweight quest model that describes a single active objective for one relationship:

- stable quest id
- stable friend id
- quest type
- player-facing title
- short supporting description
- numeric progress
- completion boolean

This model should be pure data and contain no UI logic.

### Quest Types

V1 only needs three quest categories:

1. `reachEnergy`
Used when a relationship is below a target energy threshold.

2. `unlockConnection`
Used when the relationship is warm enough but still blocked by `mutualGravityAccepted == false` or `unlocked == false`.

3. `logSharedMemory`
Used after unlock when the next meaningful step is to archive the first shared memory.

These three types map directly onto the mechanics that already exist.

### Quest Generation Rules

Quest generation should be deterministic and derived from current state:

1. If `planet.unlocked == false` and `planet.energy < 0.70`, generate a primary `reachEnergy` quest with a target of `0.70`.
2. If `planet.unlocked == false` and `planet.energy >= 0.70`, generate a primary `unlockConnection` quest.
3. If `planet.unlocked == true` and `planet.memoryCount == 0`, generate a primary `logSharedMemory` quest.
4. If `planet.unlocked == true` and `planet.memoryCount > 0`, generate no active quest for V1.

Optional secondary quest support can be added later, but V1 should work with a single primary quest per relationship.

### Stable Identity

Add a stable `id` field to `FriendPlanet` and seed it in mock data. The controller and quest generator should use `id` rather than `name` for quest ownership.

This is required because display names are mutable in the current unlock flow.

### Controller Responsibilities

`StarPathController` should:

- expose `primaryQuestForPlanet(FriendPlanet planet)`
- expose `questsForPlanet(FriendPlanet planet)` if the UI benefits from a list
- reuse the generator rather than hard-coding quest rules inline
- trigger UI refresh through existing `notifyListeners()` flow after relationship mutations

Quest state should not be stored separately in V1. It should be recomputed on demand from current relationship state.

### UI Placement

The first quest UI should appear in `BasePage`, near the current selected relationship detail area. It should:

- show quest title
- show supporting copy
- show progress, such as `68% / 70%`
- show completion state if satisfied

`OrbitPage` should stay unchanged in V1 unless a tiny badge is needed later. The first goal is to prove the quest loop in the workbench, not spread it across surfaces.

## Data Flow

1. Repositories load mock `FriendPlanet` data.
2. `StarPathController` receives planets.
3. UI selects or focuses a relationship.
4. `StarPathController` asks `RelationshipQuestGenerator` for the current quest.
5. `BasePage` renders the quest card.
6. Player actions such as `pulse`, `sendSelectedSignal`, `archiveSelectedMemory`, and unlock progression mutate the planet.
7. Controller notifies listeners.
8. Quest is recomputed from the new relationship state.

## Error Handling

V1 only needs lightweight guardrails:

- if a quest cannot be generated, return `null` or an empty list
- if the UI has no selected relationship, render no quest card
- if mock data is missing an id, fail loudly in tests rather than silently generating unstable quest ownership

## Testing Strategy

Add focused tests for:

- quest generation from locked low-energy relationships
- quest generation from warm but still-locked relationships
- quest generation from unlocked relationships with no memories
- no quest for already-progressed relationships
- stable id handling in `FriendPlanet`
- controller quest exposure for the selected relationship path

Prefer isolated unit tests for the generator and small controller tests over broad widget tests in V1.

## File Responsibilities

### New files

- `lib/features/base/models/relationship_quest.dart`
  Pure quest data model and progress helper.

- `lib/features/base/models/relationship_quest_type.dart`
  Enum for V1 quest categories.

- `lib/features/base/relationship_quest_generator.dart`
  Deterministic quest generation rules from `FriendPlanet`.

- `test/relationship_quest_generator_test.dart`
  Unit tests for quest generation rules.

### Modified files

- `lib/features/orbit/models/friend_planet.dart`
  Add stable id field.

- `lib/services/starpath_mock_data.dart`
  Seed stable ids in mock planets.

- `lib/core/starpath_controller.dart`
  Surface quest lookup through controller methods.

- `lib/features/base/base_page.dart`
  Render the primary relationship quest in the selected relationship detail view.

## Scope Check

This is intentionally one subsystem: quest derivation plus first read-only UI exposure. It does not yet attempt rewards, persistence, or multi-screen quest orchestration.

## Decision

Proceed with a derived, relationship-specific quest layer first. This matches the current architecture, reinforces the game's positioning, and is small enough to ship as a verified slice.
