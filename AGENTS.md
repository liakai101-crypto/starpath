# AGENTS

## Purpose

This repository contains two parallel development lines:

1. `preview.html`
   - The active product UI and interaction prototype
   - This is the current source of truth for product feel, layout, and scene behavior

2. Flutter app in `lib/`
   - The architecture skeleton
   - Useful for controller logic, repositories, persistence, AI seams, and future integration

Do not confuse these two lines.

## Current Product Rules

- Keep exactly three primary pages:
  - Orbit
  - Command Core
  - Profile Archive
- Keep Signal Deck as a secondary chat page from Command Core
- Every friend is represented as a ship
- Do not turn the product into a dashboard
- Keep Local Orbit sparse and cinematic
- Use Wide Space for scale, not dense interaction
- Treat Traditional Chinese layout quality as a real product requirement

## What To Read First

Read these before making meaningful product changes:

- [`docs/HANDOFF.md`](/C:/starpath/docs/HANDOFF.md)
- [`docs/DECISIONS.md`](/C:/starpath/docs/DECISIONS.md)
- [`docs/STATE.md`](/C:/starpath/docs/STATE.md)
- [`GAME_SPEC.md`](/C:/starpath/GAME_SPEC.md)

Then read:

- [`preview.html`](/C:/starpath/preview.html)
- [`test/preview_scene_structure.test.cjs`](/C:/starpath/test/preview_scene_structure.test.cjs)
- [`lib/core/starpath_controller.dart`](/C:/starpath/lib/core/starpath_controller.dart)

## Working Rules

- If the task is product UI, scene hierarchy, visual state, layout, or interaction flow, work in `preview.html` first.
- If the task is domain logic, persistence, mock data, serializer logic, or future backend seams, work in `lib/` first.
- Prefer small, reviewable slices.
- Do not revert user or prior-agent work unless explicitly asked.
- Do not move or rewrite backup references created for a handoff.

## Verification

### Prototype

```powershell
python -m http.server 8092
node test\preview_scene_structure.test.cjs
```

### Flutter

```powershell
C:\src\flutter\bin\flutter.bat analyze
C:\src\flutter\bin\flutter.bat test
```
