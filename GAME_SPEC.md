# GAME SPEC

## Core Loop

StarPath turns relationship management into a space-navigation fantasy.

The intended loop is:

1. Enter Orbit
2. Observe the current route field
3. Select a friend ship
4. Read route state, distance, signal condition, and memory context
5. Choose a posture:
   - cruise
   - approach
   - lock
   - invisibility
   - wormhole
6. Move into Command Core to shape one deliberate action
7. Open Signal Deck if a message needs to be written
8. Use Profile Archive to pull curated identity and memory material when needed
9. Return to Orbit and continue navigation

## Main Systems

## 1. Orbit

The primary navigation surface.

Responsibilities:

- Main ship staging
- Friend ship selection
- Local Orbit and Wide Space view switching
- Route state presentation
- Wormhole travel
- Invisibility state
- Telemetry and route reading

## 2. Command Core

The ship interior and bridge chamber.

Responsibilities:

- Focus the next move
- Show route state in a quieter, more deliberate space
- Provide the cleanest path into Signal Deck

## 3. Signal Deck

The normal chat page.

Responsibilities:

- Read thread
- Draft one message
- Return to Command Core

## 4. Profile Archive

The premium identity and memory page.

Responsibilities:

- Show identity
- Curate memory fragments
- Expose an outward artifact
- Route selected context back toward Command Core

## 5. State And Travel Model

Relationship posture is expressed as travel state, not generic UI status.

Current product language:

- Cruise
- Approach
- Lock
- Invisibility
- Wormhole

Long-distance movement should feel like a real transition:

- lock
- ingress
- transit
- egress
- arrive in a new Local Orbit

## Design Principles

## 1. Scene first, information second

Each primary page must first read as a scene:

- Orbit as a live navigation field
- Command Core as a bridge interior
- Profile Archive as a premium identity destination

Only after that should the user read detailed information.

## 2. Never fall back into dashboard language

The product must not read like SaaS, admin, analytics, or settings software.

## 3. Keep the main stage sparse and cinematic

The user should focus on the central stage, not on side panels.

## 4. Every friend is a ship

This is a foundational metaphor and should be preserved.

## 5. Scale comes from layered views, not crowding

Use:

- Local Orbit for close interaction
- Wide Space for scale and distant presence

Do not try to solve scale by placing dozens of full-detail targets on one stage.

## 6. Chinese quality matters as much as English quality

Traditional Chinese is not a fallback locale. It needs dedicated layout and spacing tuning.

## Do Not Do

## Do not add major dependencies casually

Avoid:

- heavyweight HTML UI frameworks just to speed up styling
- big rendering libraries unless there is a clear product-level need
- backend dependencies before the core scene model is stable

## Do not treat Flutter UI as the current source of truth

Do not:

- rebuild the product from the older Flutter UI assumptions
- assume `lib/` reflects the latest accepted page hierarchy or visual language

## Do not casually refactor core state names across the prototype

Especially do not perform broad rename passes across `preview.html` unless there is a strong reason.

Examples:

- `archive` internals currently still back the product concept now shown as invisibility

## Do not change save or serialization contracts casually

Avoid unplanned changes to:

- repository interfaces
- serializer field mappings
- time physics persistence behavior

These are the most reusable parts of the Flutter skeleton and should stay stable unless there is a clear migration plan.

## Do not expand top-level navigation

Do not add more primary pages without explicit direction from Kai.

The intended structure is:

- Orbit
- Command Core
- Profile Archive

Signal Deck remains subordinate.
