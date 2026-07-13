# DECISIONS

This file exists to stop future agents from treating deliberate decisions as arbitrary choices.

## 1. The active product UI mainline is `preview.html`

- Selected:
  - `preview.html` is the active product UI and interaction mainline
- Rejected alternatives:
  - Treat Flutter UI as the primary surface
  - Split effort equally between Flutter UI and HTML prototype
- Why:
  - The latest accepted Orbit work, Wide Space, wormhole, invisibility, page hierarchy, and visual tuning all live in `preview.html`
  - The Flutter app is still behind in fidelity

## 2. Keep exactly three primary pages

- Selected:
  - Orbit
  - Command Core
  - Profile Archive
- Rejected alternatives:
  - Add more top-level pages
  - Promote Signal Deck to a fourth main page
- Why:
  - The product needs stronger focus, not more navigation
  - Signal Deck is intentionally a subordinate chat layer entered from Command Core

## 3. Keep Signal Deck as a normal chat page

- Selected:
  - Signal Deck is a straightforward conversation surface
- Rejected alternatives:
  - Make it a dashboard-like communication control center
  - Keep it as a dominant overlay that competes with the bridge scene
- Why:
  - The user explicitly wants Signal Deck to be ordinary and readable
  - The bridge must stay the primary Command Core experience

## 4. Every friend is represented as a ship

- Selected:
  - Every friend maps to a ship identity
- Rejected alternatives:
  - Some friends are cards, some are ships
  - Friends become abstract nodes without ship embodiment
- Why:
  - The entire relationship navigation metaphor depends on ship embodiment
  - This is a core design rule, not a cosmetic choice

## 5. Local Orbit and Wide Space are different view layers, not different pages

- Selected:
  - Orbit contains:
    - Local Orbit
    - Wide Space
- Rejected alternatives:
  - Wide Space as a separate page
  - A standard zoomable tactical map
- Why:
  - Orbit should feel like one navigation system with two scales
  - Local Orbit is for interaction, Wide Space is for observation and direction

## 6. Local Orbit must stay sparse

- Selected:
  - Main ship plus one to two visible friend ships
- Rejected alternatives:
  - Show all friends at once
  - Turn Orbit into a dense overview board
- Why:
  - The user wants a cinematic stage, not a contact wall
  - Scale must come from view transitions and indexing, not crowding the stage

## 7. Wide Space is observation-only

- Selected:
  - Wide Space shows scale, direction, and distant presence
- Rejected alternatives:
  - Clicking every distant ship directly in the space layer
  - Showing detailed names and cards on all distant ships
- Why:
  - The user wants an infinite-universe feel, not a tactical clutter layer
  - Selection should happen through the left index and then route into travel

## 8. Distant targets no longer auto-force Wide Space

- Selected:
  - Clicking Morgan or Ethan does not auto-switch from Local Orbit to Wide Space
- Rejected alternatives:
  - Auto-switch on distant target selection
- Why:
  - The user explicitly rejected the forced jump
  - View change should come from zoom controls or explicit travel actions, not ordinary selection

## 9. "Archive" was renamed to "Invisibility" at the product layer

- Selected:
  - User-facing language says:
    - Invisibility
    - Invisible routes
    - Cancel invisibility
- Rejected alternatives:
  - Keep "archive" as the visible product term
- Why:
  - The user preferred the more cinematic stealth interpretation
  - The mechanic is closer to partial concealment than storage

## 10. Internal `archive` variable names may remain temporarily

- Selected:
  - Keep some internal `archive` state names for now
- Rejected alternatives:
  - Full internal rename immediately
- Why:
  - The current priority is product progress, not broad variable churn
  - A full rename should happen only after the page structures stabilize

## 11. Command Core must be read as a ship interior first

- Selected:
  - The first read of Command Core must be "bridge / interior / command chamber"
- Rejected alternatives:
  - "information page with a nice background"
  - "panel-heavy dashboard"
- Why:
  - This is one of the clearest user expectations
  - It is currently the biggest quality gap relative to the target

## 12. Profile Archive must be read as a premium identity destination

- Selected:
  - The first read of Profile Archive must be identity, memory, curation, and artifact
- Rejected alternatives:
  - General settings page
  - Third control dashboard
  - Pure admin dossier without warmth
- Why:
  - The user explicitly rejected a cold dashboard reading
  - The page needs a more personal and curated tone

## 13. Do not optimize for more features before page quality

- Selected:
  - Finish the three main page experiences before expanding scope
- Rejected alternatives:
  - Add many secondary features while the main scenes remain weak
- Why:
  - Product quality is currently blocked by scene and hierarchy issues, not missing feature count

## 14. Keep Flutter as the domain and integration skeleton for now

- Selected:
  - Flutter keeps controller, repositories, mock data, AI seams, persistence, and tests
- Rejected alternatives:
  - Delete Flutter work because the prototype is HTML
  - Prematurely port every HTML improvement into Flutter
- Why:
  - The Flutter layer still contains useful architecture
  - The HTML layer is ahead visually, but the Flutter layer is ahead structurally

## 15. Prefer no heavy dependency expansion during the prototype phase

- Selected:
  - Keep the prototype mostly self-contained
- Rejected alternatives:
  - Pull in heavy UI frameworks or major rendering stacks for the HTML prototype
- Why:
  - The current bottleneck is product clarity and scene execution
  - Dependency growth would increase migration cost before the design is stable

## 16. WebGL for the stage is scoped, not started

- Selected:
  - Write down a considered plan ([`docs/WEBGL_STAGE.md`](/C:/starpath/docs/WEBGL_STAGE.md))
    for replacing only the spatial "stage" content (ship, starfield,
    wormhole, reactor holo) with WebGL/Three.js, keeping every UI surface
    HTML/CSS — but do not begin implementing it
- Rejected alternatives:
  - Start building it now because the plan exists
  - Reject the idea outright and not document it
- Why:
  - No current product requirement needs true perspective/camera
    mechanics; Local Orbit and Wide Space are two fixed view layers
    (DECISIONS #5), not a continuous camera, and CSS already meets that
  - Consistent with #15: a rendering-stack addition needs a clear
    product-level need, which does not exist yet
  - Writing the plan down now (while the scene model is fresh) is cheaper
    than re-deriving it later if the need does appear
  - Starting Phase 0 of that plan is a decision only Kai makes
