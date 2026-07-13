# WEBGL_STAGE

Scoping for a possible future split: the spatial "stage" content (ship,
starfield, wormhole, reactor holo) moves to WebGL/Three.js; every UI surface
(rails, HUD, dock, forms, Signal Deck) stays HTML/CSS exactly as it is today.
Written July 2026, in response to a direct question about whether Three.js
is needed anywhere in the product.

## Honest status

**Not started. This is a plan, not a track in progress.** No WebGL code
exists anywhere in the repo. Every "3D-ish" effect currently in
`preview.html` — the ship, the reactor's holographic projection, the
wormhole tunnel, the three-speed starfield parallax — is CSS transform /
gradient / mask, zero canvas, zero WebGL. That CSS-only approach is
working and should not be assumed obsolete; this doc exists so that *if*
the product direction changes toward true camera/perspective mechanics
(see Phase 3 note below), there is a considered plan to follow instead of
an ad hoc rewrite.

Per [DECISIONS #15](/C:/starpath/docs/DECISIONS.md), pulling in a rendering
stack requires a clear product-level need. Starting Phase 0 is a decision
only Kai makes, not something a future agent should do unprompted because
this file exists.

## Why only the stage, not the whole UI

WebGL and DOM are good at opposite things:

- **Stage wins on WebGL**: true perspective (depth-based scale/occlusion,
  not art-directed), real camera movement, dynamic lighting. This is
  exactly what CSS transforms fake today with layered gradients and
  hand-picked depth-blur.
- **UI wins on DOM**: text density, keyboard navigation, screen readers,
  text selection, `word-break`/`overflow-wrap` i18n handling (the whole
  premise of this session's Traditional Chinese fixes), focus-visible
  rings, native form controls. Three.js text rendering is strictly worse
  than the browser's own text engine on every one of these axes.

The two are not in tension: the split follows the same boundary the
product already draws between "scene" and "information" (GAME_SPEC
Design Principle 1).

## Scope boundary

| Stays / moves to WebGL (the stage) | Stays HTML/CSS (the UI) |
|---|---|
| Orbit main ship + ship parts | Left/right rails, target HUD, quick actions, route ledger |
| Deep-space starfield / nebula / galactic band | Top toolbar, brand masthead, footer dock |
| Distant/local friend markers (`.orbit-object`, `.wide-marker`) | Signal Deck (entirely — zero spatial content) |
| Flight-lane / route-path curves | Profile Archive text cards (identity, memory grid, timeline) |
| Wormhole tunnel (spokes + rings + rift) | Empty-state panel, toasts, icons, buttons |
| Bridge reactor's holographic projection | Command Core side docks, chip rows |
| (optional, lowest priority) bridge backdrop, Profile Archive planet | Anything text-dense, selectable, or requiring a11y |

## Architecture

1. **One canvas, layered under the DOM.** `position:absolute`, z-index
   below the UI layer, sized to the active scene's stage container.
   Not one canvas per scene — one renderer, three swappable scene modules
   (`OrbitStage` / `BridgeStage` / `ArchiveStage`) mounted per `data-scene`.
2. **A sync layer, not a second state machine.** The WebGL scenes read the
   *same* variables that currently drive CSS custom properties
   (`selectedSignal`, `orbitViewMode`, `currentSystemMode`/phase-tint,
   friend distance tier, wormhole state). One source of truth; the
   renderer is a second consumer, not a parallel system.
3. **DOM-projected labels for anything that must track a moving 3D
   object**, not `CSS3DRenderer`. Project the 3D world position to screen
   coordinates each frame (`camera.project` or Three's `CSS2DRenderer`)
   and position a normal HTML label there. `CSS3DRenderer` would pull the
   *whole UI* into 3D space, which is the one thing this plan explicitly
   avoids.
4. **Hit-testing stays DOM**, not raycasting. Ship/marker click targets
   remain invisible `<button>` elements positioned via the same
   projection, on top of the canvas. This session did real work landing
   44px touch targets, `:focus-visible` rings, and `aria-label`s on every
   interactive element (see `DESIGN.md` §7); raycasting would throw all of
   that away and require rebuilding keyboard/screen-reader access from
   scratch.
5. **Self-hosted, not a CDN import.** Same reasoning as the Rajdhani font
   this sprint: download the Three.js module into `assets/` and import it
   locally, so the prototype keeps working offline and isn't exposed to a
   live third-party dependency. No bundler — this is a static single-file
   prototype and should stay one, per DECISIONS #15.

## Phasing

Do not attempt this as one rewrite. The interlocking, state-driven CSS
this session spent most of its time debugging is exactly the failure mode
a big-bang WebGL migration would repeat at a larger scale.

**Phase 0 — Feasibility spike (no product risk).** An isolated Three.js
prototype of the single highest-value target (reactor holo or wormhole
tunnel), built in a scratch file, not wired into `preview.html`. Purpose:
get a real bundle-size/load-time/FPS number and a before/after screenshot
before committing to anything further.

**Phase 1 — Reactor holo (start here).** Smallest surface (~200px card),
cleanest data contract (distance tier → orbit radius, phase-tint → color),
no scroll/layout interaction, no hit-testing (the holo isn't clickable
today). Validates the sync-layer pattern at the lowest possible risk.

**Phase 2 — Wormhole tunnel.** Bigger visual payoff, still contained: it
is only on-screen for the ~2-3s transit window, not a persistent surface,
so a rough edge here is brief and self-resolving rather than a standing
regression. This is where true perspective/camera-dolly is an obvious win
over the current CSS spokes-and-rings approximation.

**Phase 3 — Orbit main stage (ship + starfield + markers).** The large,
risky phase: this is the persistent, most-interacted-with surface, and it
has to reproduce every state this sprint hardened — reduced-motion, the
empty-state toggle, mobile-preview-mode, Local/Wide view switching, the
first-load staged entrance — without regressing any of them. Realistically
as much work as Phases 0-2 combined. **Also the one phase that only makes
sense if the product direction shifts toward continuous Local↔Wide
zoom/camera movement** — the current spec treats them as two fixed view
layers (DECISIONS #5), not a continuous camera; if that stays true, CSS
already meets the need and Phase 3 has much weaker justification.

**Phase 4 (optional, may never happen) — Profile Archive planet visual.**
Purely decorative, lowest priority, skippable without loss.

## What does not change

- State machine, routing (`setTab`), i18n/`localize()`, the phase-tint
  color system — WebGL is a renderer swap underneath, not a new layer of
  logic.
- Signal Deck and every rail/card/panel/dock — zero WebGL touches these.
- `test/preview_scene_structure.test.cjs` (string-based) — mostly
  unaffected.

## What does change / open risks

- **`test/preview_layout_qa.test.cjs` gets a blind spot.** Canvas pixels
  aren't inspectable via `getComputedStyle`/`elementsFromPoint`, so the
  occlusion-sweep methodology this sprint built cannot see inside the
  canvas. Would need either pixel-diff visual regression or an explicit,
  documented allowlist for the canvas region — this is a real gap, not
  a detail to defer silently.
- **No-WebGL fallback is mandatory, not optional.** Feature-detect
  `WebGLRenderingContext` at boot and fall back to the existing CSS stage
  when it's unavailable. This means the CSS version cannot be deleted —
  it becomes a permanent second code path, which is a real maintenance
  cost to weigh against the visual upside.
- **Low-end/no-GPU performance.** This sprint measured the *current*
  CSS-only stage at single-digit FPS with no GPU (`docs/STATE.md`). WebGL
  without a GPU is equal or worse, or simply unavailable — the fallback
  above is what makes that survivable rather than a hard failure.
- **Flutter port is not meaningfully easier afterward.** To be direct
  about something easy to oversell: none of the Three.js code ports to
  Flutter. What transfers is the *concept* (which asset, which shader,
  which data contract) — Flutter's 3D story is a different stack
  entirely. This plan does not make `docs/INTEGRATION.md` Track 3 cheaper;
  it only avoids making it more expensive than it already is.

## Recommendation

Start with Phase 0 + Phase 1 (reactor holo) if this gets greenlit, measure
the real result, and decide on Phase 2 from there. Do not start Phase 3
without first revisiting whether Local/Wide should become a continuous
camera — if the answer is still "two fixed layers," Phase 3's cost is hard
to justify against what CSS already delivers.
