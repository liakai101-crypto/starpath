# STATE

## Current Active Line Of Work

The active line of work is the HTML prototype in [`preview.html`](/C:/starpath/preview.html).

The Flutter app in `lib/` remains important, but it is not the current UI mainline.

## What Was Most Recently Changed

- Distant friend selection no longer forces a switch into Wide Space
- Product wording changed from archive to invisibility
- Wide Space now reuses the same main ship language as Local Orbit instead of reading like a totally different vessel
- A handoff blueprint was prepared for external continuation

## Current Blockers

### Command Core

- Still reads too much like layered panels over a background
- The center object does not yet communicate a strong, obvious bridge-core meaning
- Needs real spatial hierarchy, not just cleaned-up widgets

### Profile Archive

- Still not premium enough in hierarchy
- Identity, curated memory, and outward artifact need stronger emphasis
- Still carries some dashboard DNA

### Traditional Chinese layout

- Chinese interface still needs explicit layout tuning
- It is not enough that text appears; it must keep the same product quality as English

## Known Bugs

- Some page states still feel visually crowded even when the logic works
- Mobile preview exists, but not every scene and state has been fully validated
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
