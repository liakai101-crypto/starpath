# INTEGRATION

Scoping for the three remaining "not started" tracks: backend, real AI signal
generation, and the Flutter port. Written July 2026, after the layout/QA
sprint stabilized the scene model.

## Honest status

These three tracks are different in kind from everything finished so far:
each needs either credentials, infrastructure, or multi-week porting work,
plus product decisions only Kai can make. What exists today is the correct
*preparation* for them — the Flutter skeleton already has the seams:

- `lib/shared/ai/ai_signal_service.dart` — `AiSignalService` abstract class
  (`suggestionFor`, `generateIcebreaker`) with mock implementations wired
  through the controller.
- `lib/services/repositories.dart` — `FriendRepository`, `SignalRepository`,
  `CapsuleRepository` interfaces backed by `mock_repositories.dart`.
- `lib/services/backend/` — field/collection serializers already shaped for a
  document store.
- `lib/services/time_physics_storage.dart` — persistence for the time-decay
  model, already tested.

## Track 1: Real AI signal generation

**What it is**: replace the canned Hubble suggestions / icebreakers with a
real model call (Claude API is the natural fit).

**Blocking decision**: where the API key lives. Calling the API directly from
the client ships the key to every user; the standard answer is a thin proxy
(one serverless function). That makes this track dependent on Track 2's
hosting decision, or on accepting a dev-only mode (key in local env, never
shipped) for prototyping.

**Concrete path** (once a key + proxy decision exists):
1. Implement `ClaudeSignalService implements AiSignalService` in
   `lib/shared/ai/` — one HTTP call per method, prompt assembled from
   `FriendPlanet` + recent `SignalRecord`s.
2. Keep the mock as the fallback / offline path behind the same interface.
3. Prompt sketch: system prompt carries the product tone rules (light,
   inviting, no pressure — the same voice as the current canned copy);
   user turn carries route state, warmth, cadence, and the last 2-3 signals.
4. The HTML prototype should NOT grow its own AI seam; per DECISIONS #14 the
   Flutter layer owns integration architecture.

**Effort once unblocked**: small (a service class + prompt tuning).

## Track 2: Backend / persistence

**Blocking decision**: local-first vs cloud.

**Recommendation: local-first.** Relationship notes are among the most
private data a person can keep; "your archive never leaves your device" is
both the cheapest architecture (zero infra, no auth, no key management) and
a product story consistent with the Invisibility metaphor. The existing
serializers work as well against a local document store (sqlite / isar /
drift) as against Firestore.

**Concrete path (local-first)**:
1. Pick a store (isar or drift are the current Flutter defaults).
2. Implement the three repository interfaces against it.
3. Reuse `time_physics_storage.dart` patterns for migration-safe writes.
4. Cloud sync, if ever, becomes an export/import or E2E-encrypted layer on
   top — not a rewrite, because the interfaces don't change.

**Effort**: medium (a few days), no external dependencies to buy.

## Track 3: Flutter port of the visual prototype

**Sequencing**: this was correctly deferred while preview.html was unstable.
After the July 2026 sprint the scene model, page hierarchy, copy voice, and
interaction flows are locked and regression-tested, so the port gate is now
open in principle. It remains the largest track by far.

**Concrete path**:
1. Port scene-by-scene in product order: Orbit local → Command Core →
   Profile Archive → Signal Deck → Wide Space → wormhole staging.
2. The CSS-built art (reactor, bridge backdrop SVG, parallax layers)
   translates to CustomPainter / vector assets; the SVG backdrop can be used
   directly via flutter_svg.
3. `test/preview_layout_qa.test.cjs`'s occlusion/overflow methodology should
   be reimplemented as golden tests on the Flutter side before, not after,
   the port — it is what kept the HTML honest.

**Effort**: large (weeks). Do not start it in parallel with Track 1/2 churn.

## Suggested order

Track 2 (local-first persistence, no blockers) → Track 1 (needs only a dev
key once persistence exists) → Track 3 (after Kai signs off that the HTML
prototype is the final visual spec).
