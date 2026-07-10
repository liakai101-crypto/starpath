# HANDOFF

## Project In One Line

StarPath is a space-fiction relationship navigation game prototype where friends are represented as ships, routes, signals, memories, and bridge actions instead of contact cards.

## Current Completion Estimate

- Product direction: about 79 percent locked
- Visual prototype quality: strong on Orbit, partial on Command Core and Profile Archive
- Flutter app architecture: solid skeleton, not the current UI mainline

## What Is Finished

### Product structure

- Three main product pages are locked:
  - Orbit
  - Command Core
  - Profile Archive
- One secondary page is locked:
  - Signal Deck, a normal chat page entered from Command Core

### Orbit prototype in `preview.html`

- Local Orbit and Wide Space view modes exist
- Core route states exist:
  - cruise
  - approach
  - lock
  - invisibility
  - wormhole
- Main ship exists and is used in both Local and Wide views
- Left and right rails exist and can collapse
- Route ledger, target HUD, telemetry, zoom controls, language toggle, and mobile preview shell exist
- Distant targets no longer auto-switch the view into Wide Space
- Invisibility flow exists:
  - enter invisibility
  - list hidden routes
  - cancel invisibility

### Command Core prototype

- Dedicated page exists
- It is no longer just a small overlay on Orbit
- It already has bridge-oriented copy, a reactor concept, and a path into Signal Deck

### Profile Archive prototype

- Dedicated page exists
- Hero identity block, memory ribbon, artifact area, and return rail exist

### Flutter app skeleton

- App shell exists in [`lib/core/starpath_shell.dart`](/C:/starpath/lib/core/starpath_shell.dart)
- Central state exists in [`lib/core/starpath_controller.dart`](/C:/starpath/lib/core/starpath_controller.dart)
- Repository interfaces and mock repositories exist
- AI service seams exist
- Quest generator exists
- Time physics persistence exists
- Basic Flutter tests exist for controller-adjacent logic

## What Is In Progress

### Command Core

- The page is being pushed from dashboard-like layout toward a real bridge scene
- The current blocker is visual readability:
  - the scene still reads too much like panels placed over a background
  - the center object still lacks clear meaning

### Profile Archive

- The page is being pushed from widget collection toward a curated identity destination
- The current blocker is hierarchy:
  - identity is still not dominant enough
  - memory modules still read too much like standard cards

### Bilingual layout tuning

- English is more stable than Traditional Chinese
- Traditional Chinese still needs explicit spacing, width, and wrapping tuning

## What Has Not Started Or Is Not Finished Enough

- Final-grade Command Core environment rendering
- Final-grade Profile Archive hierarchy and curation feel
- Deep-space scale that truly feels infinite
- Fully polished wormhole travel sequence with stronger transit staging
- Real mobile QA across all major page states
- Integration of the visual prototype back into Flutter UI
- Real backend integration
- Real AI signal generation

## Critical Hidden Assumptions And Traps

- The active product mainline is [`preview.html`](/C:/starpath/preview.html), not the Flutter UI.
- The Flutter app is important, but currently it is the architecture skeleton, not the highest-fidelity product surface.
- Do not turn the product back into a dashboard. This has been a repeated anti-goal.
- There must remain only three primary pages. Signal Deck is not a fourth primary page.
- Every friend must remain a ship. Not every friend must be fully rendered at once.
- Local Orbit is intentionally a close, high-quality stage with only one to two visible friend ships.
- Wide Space is intentionally an observation layer, not a direct click-on-every-ship tactical map.
- "Archive" was renamed at the product layer to "Invisibility", but many internal variable names still use `archive`.
- The HTML prototype is large and stateful. A careless refactor can break multiple scenes at once.
- The preview structure test is shallow string verification, not full behavior verification.

## The Next Three Things To Do

### 1. Finish Command Core as a real bridge scene

Why this is first:

- It is the biggest gap versus the target product quality
- It currently lowers the whole perceived quality of the product
- Until this reads as a ship interior, the product cannot honestly claim high-end UI completion

### 2. Rebuild Profile Archive into a premium identity page

Why this is second:

- It still reads too much like a third dashboard
- It needs stronger identity, memory curation, and artifact hierarchy
- Once this is fixed, all three main pages can start reading like one coherent product

### 3. Do explicit Traditional Chinese layout tuning

Why this is third:

- The user cares about the Chinese interface, not just the English one
- The current Chinese layout still breaks spacing, wrapping, and proportion in multiple places
- This is a product-quality blocker, not just localization cleanup
