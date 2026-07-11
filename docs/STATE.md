# STATE

## Current Active Line Of Work

The active line of work is the HTML prototype in [`preview.html`](/C:/starpath/preview.html).

The Flutter app in `lib/` remains important, but it is not the current UI mainline.

## What Was Most Recently Changed

- Fixed real layout collisions in all three primary pages (July 2026 sprint):
  - Command Core: bridge-core-dock / reactor-meaning overlap, plus a `.pill.shell`
    class-name collision with the root `.shell` container that blew up the
    mobile layout
  - Profile Archive: identity panel / hero note-card overlap; identity score is
    now a conic-gradient gauge; leaked internal design-note copy replaced with
    product copy
  - Orbit: at narrow widths the floating cards (caption, quick actions, route
    ledger) no longer collide with the target HUD, stage art, or each other
- Traditional Chinese: `overflow-wrap: break-word` fallback added so
  `word-break: keep-all` can no longer push CJK text out of narrow containers;
  verified zero text overflow across all four scenes in both viewport modes
- The hangar background art (a repair-bay illustration, not a bridge) is now
  dimmed to ambient texture in Command Core so the CSS-built bridge chrome
  reads as the scene

## Current Blockers

### Command Core and Profile Archive final quality

- Both pages are now structurally clean, but reaching the reference-image
  quality bar requires real art assets (bridge interior, reactor, portraits);
  CSS/SVG alone has hit its ceiling
- The only bridge background asset (`assets/base/hangar_background.png`) is
  thematically a repair bay with a corgi mascot, not a command bridge

### Traditional Chinese layout

- Overflow is fixed; remaining work is proportion/spacing taste-tuning, not bugs

## Known Bugs

- Wide Space's hint footnote can be partially overlapped by the view
  explanation card at narrow widths (minor, text remains readable)
- Distant-target markers (Morgan/Ethan) sit fully behind the flow cards at
  narrow widths; invisible rather than broken, but they are not reachable there
- `preview_scene_structure.test.cjs` is shallow and can pass while the UI still feels wrong

## Known TODO

- Finish Command Core bridge scene
- Finish Profile Archive identity hierarchy
- Strengthen deep-space motion and scale
- Upgrade wormhole transit sequence
- Perform full Traditional Chinese spacing and wrapping pass
- Perform full mobile QA pass
- Decide later whether to port the finished prototype back into Flutter UI

## Build And Run

## HTML prototype

From repo root:

```powershell
python -m http.server 8092
```

Then open:

```text
http://127.0.0.1:8092/preview.html
```

## Flutter app

Use the local Flutter executable in this environment:

```powershell
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run -d chrome
```

Important note:

- Historically, the debug Flutter web preview in this environment has been less reliable than the static HTML prototype for visual work.

## Test

### HTML prototype structure check

```powershell
node test\preview_scene_structure.test.cjs
```

### HTML prototype layout QA (occlusion + overflow)

```powershell
npm install
node test\preview_layout_qa.test.cjs
```

Drives the system Edge/Chrome headless (via `puppeteer-core`, no browser
download) across all scenes x zh/en x desktop/mobile-preview and fails when
visible text is covered by another painted element or overflows its box.
This is the regression guard for the layout-collision class of bugs that the
structure check cannot see. Accepted exceptions live in the `ALLOW` list at
the top of the test file.

### Flutter tests

```powershell
C:\src\flutter\bin\flutter.bat test
```

### Flutter static checks

```powershell
C:\src\flutter\bin\flutter.bat analyze
```

## Important Practical Notes

- If a future agent is working on product UI quality, start in `preview.html`.
- If a future agent is working on controller logic, quest logic, repositories, serialization, or persistence, start in `lib/`.
- Do not assume the default `flutter` command is available on PATH in this environment.
- Do not delete or repurpose the backup tag or backup branch created for this handoff.
