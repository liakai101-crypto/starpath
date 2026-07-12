# DESIGN

The visual system of the StarPath prototype (`preview.html`), documented as a
portable spec. The intended reader is whoever ports this to Flutter (or any
other runtime): every value here is the canonical one, extracted from the
live prototype. When prototype and this file disagree, the prototype wins —
then fix this file.

Register: **product** (app UI in a cinematic shell), dark-only by design.
The interface is a ship's bridge; panels are glass instruments over a stage.

## 1. Color

### Primitives (`:root` in preview.html)

| Token | Value | Role |
|---|---|---|
| `--bg` | `#050913` | page base (near-black navy) |
| `--bg2` | `#0a1220` | raised background |
| `--bg3` | `#13263a` | highest ambient background |
| `--surface` | `rgba(18,29,44,.84)` | standard panel |
| `--surface-strong` | `rgba(27,43,61,.88)` | emphasized panel |
| `--surface-muted` | `rgba(15,23,36,.88)` | recessed panel |
| `--hud` / `--hud-strong` | `rgba(10,14,22,.38/.62)` | translucent HUD glass |
| `--line` / `--line-strong` | `rgba(255,255,255,.10/.16)` | hairline borders |
| `--text` | `#f6f8fb` | primary ink |
| `--muted` | `#b8c2d0` | secondary ink |
| `--soft` | `#8192a6` | tertiary ink |
| `--accent` | `#6ce3f6` | signature cyan (actions, live state) |
| `--accent-2` | `#9ba7ff` | violet (locked / archive / mystery) |
| `--accent-3` | `#7ce7b2` | green (positive / stable) |
| `--warm` / `--warm-strong` | `#ffb19c` / `#ffb09a` | signature coral-rose counterweight (heat, human warmth) |

**Signature hue, not generic amber.** The warm accent originally sat at
~hue 30-40° — the first-reflex "sci-fi space app" amber, repeated almost
200 times across the file in ~40 slightly-drifted variants (phase tints,
glows, borders, one portrait). Rotated the whole family to **hue 13°**
(coral-rose) with a small saturation lift, preserving each variant's
original lightness so every existing gradient/glow relationship stays
intact — this was a systematic hue rotation (`scripts/` has no permanent
copy; see commit history for the generator), not a one-off restyle. Applies
everywhere `--bridge-warm` / `--bridge-accent-strong` resolve warm and to
Alex's portrait rim (the friend whose copy literally says "warm channel").
`--nebula-warm` (`rgba(210,160,112,.28)`, ambient background haze) is a
separate, deliberately muted environmental tone — left alone.

Contrast floors (enforced by the a11y probe): micro-labels on dark surfaces
use white ink at **alpha ≥ .72**; body/meta text ≥ .74. Anything lower fails
4.5:1 against the composited panel stack.

### Phase tint system (the distinctive architecture)

Relationship posture recolors the whole Command Core through five CSS vars
set by `data-core-phase` on `.base-stage`. Everything downstream
(reactor, beam, holo projection, rings, glows) reads only these vars:

| Phase | `--bridge-accent-strong` | temperature |
|---|---|---|
| cruise | `rgba(142,198,222,.30)` | cool, low-key |
| approach | `rgba(108,227,246,.46)` | cyan, alert |
| lock | `rgba(132,237,251,.56)` | bright cyan, focused |
| wormhole | `rgba(255,217,146,.60)` | amber, dramatic |
| archive | `rgba(130,198,220,.24)` | desaturated, veiled |

(companion vars per phase: `--bridge-accent`, `--bridge-warm`,
`--bridge-core-glow`, `--bridge-floor-glow` — values in preview.html.)

**Port rule**: implement as a theme-extension keyed by posture; never
hard-code a posture color at a use site.

## 2. Typography

- Body/UI family: **Noto Sans TC** (subset woff2, 289KB; regenerate with
  `scripts/subset_font.py`). Weights in use: 400, 800, 900.
- Display family: **Rajdhani** (Light/Medium/Bold, self-hosted Latin woff2,
  SIL OFL — `assets/fonts/OFL-Rajdhani.txt`). Contrast-axis pairing:
  geometric/technical display against Noto Sans TC's humanist body, per the
  product register's "one family is often right, but a display/body pair is
  fine when the display carries a real brand moment" allowance. Scoped to
  exactly two always-Latin, un-localized touchpoints — never applied to a
  shared class that also carries sentence copy or CJK content:
  - `.brand-masthead-title` / `#orbitTitle` — the "StarPath" wordmark
  - `.scene-banner-title` — the four scene names (Orbit / Command Core /
    Profile Archive / Signal Deck)
- Scale (px): 9/10 micro-labels (uppercase, tracked ≥ .14em) · 11–13 meta &
  body · 14–16 values · 18–22 card titles · 26–34 scene titles.
- zh-TW rules: `word-break: keep-all` + `overflow-wrap: break-word`
  (both, always — keep-all alone overflows narrow containers); tracked
  uppercase treatments get letter-spacing reduced ~40% and
  `text-transform: none` where the latin treatment used uppercase.

## 3. Space, radius, elevation

- Rhythm: 4-based. Panel padding 12–24; grid/flex gaps 8/10/12; section
  margins 12–18.
- Radius: `--radius-sm 14 / -md 18 / -lg 24 / -xl 30`, pills `999`.
  Stage containers 30–42.
- Shadows: `--shadow` (`0 20px 50px rgba(0,0,0,.28)`) for floating cards;
  inset `0 1px 0 rgba(255,255,255,.04–.08)` as the glass top-light on
  every panel.
- Z scale (semantic): stage art 0–2 · floating cards `--z-card 3` · HUD
  layer 4–6 · pinned HUD `--z-hud 8` · scene transition layers 12 ·
  full-screen overlays `--z-overlay 18+`. Never use arbitrary large values.

## 4. Motion

One easing: `--ease: cubic-bezier(.2,.8,.2,1)` (decisive out-curve; no
bounce anywhere).

Interaction durations (tokenized, 92 call sites):

| Token | Value | Use |
|---|---|---|
| `--dur-fast` | 200ms | hover, small state flips |
| `--dur-base` | 280ms | panel collapse, card state |
| `--dur-slow` | 420ms | scene-level reveals |

(A few .22–.36s stragglers remain; consolidate into these three at port
time.)

Ambient/scenic animations are bespoke and slow on purpose — signature set:

| Animation | Period | Meaning |
|---|---|---|
| reactor core pulse + beam breathe | 4.6s | the ship is alive |
| reactor dashed ring spin | 42s | slow machinery |
| holo friend orbit | 8.5s local / 13s distant | current relationship, distance-scaled |
| holo signal-traffic ring | 7s | data flowing between you |
| ship wake / engine pulse | .72–1.2s | thrust |
| wormhole transit loops | .92–1.6s | corridor rush (spokes spin + rings race) |
| deep-space parallax stars | 26s / 44s / 96s | three-speed depth |
| galactic band drift | 120s | scale |

Rules: animate transform/opacity only (box-shadow pulses are banned —
measured 43→113fps by removing one); large blurred layers get
`will-change: transform`; **everything** obeys
`prefers-reduced-motion: reduce` via the global collapse rule, which zeroes
`animation-delay`/`transition-delay` as well as duration — a delay-only
reduction still gates content behind an invisible wait, which is exactly
the failure mode the preference exists to prevent.

**First-load staging (Orbit only).** A one-time choreographed entrance —
rails slide in, the ship blooms, HUD/badges/ledger settle in sequence over
~1.14s total — distinct from the `.fade-in` that plays on every routine
scene switch. Gated by `.orbit-scene:not(.intro-done)`; JS adds
`.intro-done` after the last staged element's `animationend`, so revisiting
Orbit later in the session falls back to the light routine fade only (per
the product register's rule against replaying page-load choreography on
every navigation). Every element resolves via `both` fill mode even if the
JS never runs, so nothing is gated behind a class that might not arrive.

## 5. Iconography

Mechanism: CSS `mask-image` (inline SVG data-URI, 24×24 viewBox) on a
`currentColor` box — icons inherit text color for free. Style: solid
geometry, no strokes. Set: orbit ring · command layers · profile card ·
four-point star (brand) · filter funnel · padlock · plus/minus · close ·
chevron L/R. Toggle buttons render icons as `::before` masks keyed off the
`is-collapsed` class; `::after` is reserved for their 44px hit areas.

## 6. Portraits

Photo-style backlit busts (`assets/portraits/<name>.svg`): dark silhouette
against an off-center window glow, rim light via a 3–4px offset duplicate
toward the key light, blurred bloom stroke on the lit edge, lens vignette.
Per-friend signature: silhouette shape, rim hue, key-light side
(Alex amber/R · Iris cyan/L · Morgan violet/R · Ethan teal/L).
Slots: identity hero 72px (radius 22) · rail cards 30px (radius 11) · dock
target 30px (radius 10); all `object-fit: cover`.
**Upgrade path**: drop a real photograph at the same path and repoint
`PORTRAIT_SOURCES` in preview.html. Faces never appear on the Orbit stage —
friends are ships there (product rule).

## 7. Component primitives

pill (status chip; tone variants accent/soft/slate/green) · glass-card
(panel base: surface + hairline + inset top-light + blur) · fold-toggle /
pane-toggle (34/42px round, masked icon, 44px hit area) · signal card
(portrait + name + tier tags) · route ledger · target HUD (expanded bottom
/ collapsed top) · scale indicator · scene banner. Focus: global
`:focus-visible` 2px ring `rgba(122,238,255,.85)` offset 2; containers with
suppressed inner outlines use `:focus-within` instead.

## 8. Flutter port notes

- Tokens → `ThemeExtension`s: one for primitives, one for the phase-tint
  quintet (posture-keyed).
- Durations/easing → `Duration` consts + a single `Curve`
  (`Cubic(.2,.8,.2,1)`).
- Icons → the same 24×24 paths as `CustomPainter` or an icon font; keep
  currentColor behavior via `IconTheme`.
- Portrait SVGs render via flutter_svg, or rebuild the recipe as a
  `CustomPainter` (4 paths + 3 gradients each).
- The blur-heavy glass language is expensive on Skia too: budget
  `BackdropFilter`s per screen (the HTML runs ~30; aim lower) and reuse the
  measured lesson — never animate shadows, only transform/opacity.
