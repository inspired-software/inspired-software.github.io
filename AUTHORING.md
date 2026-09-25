# Authoring guide — inspired.software

How to write a page for this site. Read this before touching `content/`.

> **Launch state: skeletal.** The live site is Home (hero only), a Deeplife "coming soon"
> page, About (company only: no Deeplife or diving, no contact section, and the
> "Where we stand" promises held back for rework) and the 404.
> Technology, Support, Privacy, the "Get notified" button and sign-up section, and the full
> versions of Home, Deeplife and About are in `drafts/`, which isn't built.
> `drafts/README.md` says how to bring each one back.
>
> **No contact address on the site.** No email address or `mailto:` link anywhere in the
> output, structured data included. `node tools/check.mjs` fails the build if one appears,
> and the build itself stops on `{{contact}}`, the placeholder left in the drafts and the
> sign-up section where the address used to be.

## The build

The site is built with [Saga](https://github.com/loopwerk/Saga), a static-site generator
written in Swift, pinned to release **3.6.0** in `Package.swift`.

```sh
swift run               # build content/ into Output/
node tools/check.mjs    # the gate: links, anchors, ids, headings, jargon…
tools/preview.sh        # build, then serve Output/ at http://localhost:4000
```

Run both of the first two before you call a change done. The check reads the built pages,
so it catches what the build can't.

```
content/               the site: one HTML file per page, plus styles.css, img/, CNAME
diagrams/              the SVG diagrams, one file each, by page
Sources/InspiredSoftware/
  main.swift           the build pipeline, top to bottom
  Content.swift        the page reader and its front matter
  Shortcodes.swift     {{notify}}, {{platform-strip}}, {{diagram …}}
  Layout.swift         the <head> and <body> every page is wrapped in
  SiteHeader.swift     SiteFooter.swift  NotifyCTA.swift  PlatformStrip.swift
```

Each page in `content/` is an HTML **fragment**: no `<html>`, `<head>`, `<body>`, no
`<header>`/`<footer>`, no `<main>`. The layout supplies all of that. It starts with front
matter:

```
---
title: Page title — Inspired Software, LLC
description: One sentence, 120–160 characters, no marketing fluff.
---
<section class="page-head">
```

Both fields are required, and a page without them fails the build. The filename is the
URL: `content/support.html` becomes `/support/`. `index.html` is the home page, and
`404.html` stays `404.html`, which is the file GitHub Pages serves for a missing URL.
Anything in `content/` that isn't an `.html` page (the stylesheet, images, `CNAME`) is
copied to `Output/` as it is.

### Shortcodes

- `{{notify}}` places the launch call-to-action at the bottom of a page (the Deeplife page
  should have it; Privacy and 404 should not).
- `{{diagram deeplife/03-tone-curve}}` places `diagrams/deeplife/03-tone-curve.svg`
  inline, usually inside a `<figure class="figure">` with its `<figcaption>`.
- `{{platform-strip}}` renders the supported-platform cards (icon, name, role).
  **Show the platforms with it; do not restate them in prose.** The claim was previously
  repeated nineteen times across the site and read as boasting. One strip per page at
  most, and no more than one sentence anywhere near it. "Runs on all six Apple platforms",
  "every Apple platform", and "one layout stretched across six screens" are retired
  phrasings — do not reintroduce them. Naming platforms is fine where it answers a real
  question (the Support FAQ, the platform table, the module-graph discussion on
  Technology).

An unknown shortcode, or a diagram with no file, **fails the build** rather than quietly
rendering nothing.

## Page skeleton

Interior pages open with a page head, then alternating bands:

```html
<section class="page-head">
  <div class="wrap">
    <p class="eyebrow">Section label</p>
    <h1>The page title</h1>
    <p class="lede mt-2">One or two sentences that actually say something.</p>
  </div>
</section>

<section class="band band-deep">
  <div class="wrap"> … </div>
</section>
```

Alternate band backgrounds down the page so sections separate visually: no class →
`band-deep` → no class → `band-mid`. Never put two of the same in a row.

## Components you may use (all defined in `content/styles.css` — do not invent CSS)

| Class | What it is |
|---|---|
| `.wrap` / `.wrap-narrow` | Page-width container (narrow = 760px, for prose) |
| `.band` `.band-tight` `.band-deep` `.band-mid` | Vertical section rhythm + background |
| `.eyebrow` | Small uppercase label above a heading (add `.eyebrow-plain` to drop the rule) |
| `.lede` | Large intro paragraph |
| `.prose` | Body-copy column with automatic vertical rhythm — use for legal/long text |
| `.grid .grid-2/-3/-4` | Responsive card grids |
| `.card`, `.card-icon`, `.card-link` | Cards; `.card-link` for a whole clickable card |
| `.split` (+ `.split-flip`) | Two columns, text beside a figure; flip alternates sides |
| `.figure` + `<figcaption>` | Framed container for a `{{diagram …}}` |
| `.stats` / `.stat` / `.stat-num` / `.stat-label` | Number row |
| `.ticks` | Bulleted list with glowing dots |
| `.pill` / `.pill-accent` / `.pill-row` | Tag chips |
| `.note` / `.note-warn` | Callout (warn = amber, for safety text) |
| `.table-scroll` > `<table>` | Any table **must** be wrapped so it scrolls on mobile |
| `details.faq` > `summary` + `.faq-body` | FAQ disclosure |
| `.btn` `.btn-ghost` `.btn-sm` `.btn-row` | Buttons |
| `.platforms` / `.platform` | Platform icon strip — use `{{platform-strip}}` |
| Helpers | `.mt-1`…`.mt-4`, `.dim`, `.faint`, `.small`, `.xs`, `.center`, `.gradient-text` |

Inline `style=""` is allowed sparingly for one-off spacing. If you find yourself writing
more than a couple of declarations, you are fighting the system — use a component.

## Diagrams

There are **no app screenshots** — the app is unreleased. Do not fabricate any, and do not
draw anything that could pass for a real UI screenshot. SVG **diagrams** are encouraged: a
dive profile, a bathymetry cross-section, a tone curve, a sync topology. Each lives in its
own file under `diagrams/<page>/` and is placed with `{{diagram <page>/<name>}}`. The files
are fragments for inlining: they have no XML prolog and won't open on their own. Rules:

- `viewBox` + no fixed `width`/`height` — they scale inside `.figure`.
- Colours must follow the theme. Use `currentColor` with `fill-opacity`/`stroke-opacity`
  for neutral strokes and text. Set accents through CSS variables in a `style` attribute:
  `style="fill:var(--cyan)"`, never `fill="#38D9EC"`. SVG presentation attributes can't
  take `var()`, so a literal hex stays at its dark-mode value and becomes unreadable on a
  light background. The accents are `--cyan`, `--coral`, `--kelp` and `--sun`.
- Give every `<svg>` `role="img"` and a descriptive `aria-label`.
- **`id`s inside SVG `<defs>` are global to the page.** Prefix every gradient/filter id
  with the diagram's name (`wreck-grad`, not `grad`) or two diagrams will collide.
- Add a `<figcaption>` saying what it shows and that it is illustrative.

## Voice

Plain, specific, quietly confident. British-leaning spelling is fine ("colour",
"metres") — the existing copy uses it, so stay consistent. Concrete numbers over
adjectives. No "revolutionary", "seamless", "cutting-edge", "unleash", "empower".
Short sentences carry the weight. A little dryness is welcome.

Write for a diver. Not for a programmer, and not for someone evaluating the codebase.

## No developer jargon — this is enforced

The reader is someone who dives and takes photographs. Framework names, language names
and internal architecture are implementation detail they have no reason to know, and
naming them makes the page read as though it were written for someone else.

`node tools/check.mjs` **fails the build** on any of these appearing in visible copy:
Swift, SwiftUI, Metal, shader, GPU, kernel, CloudKit, CKShare, MLX, RealityKit, Core
Image, AVFoundation, AVVideoComposition, LazyAsset, Tuist, Xcode, schema, record store,
API, SDK, codebase, softmax, CNN, tensor, dark-channel, quantized, last-writer-wins,
concurrency, runtime, compiler, and `Vision` when it is not `Vision Pro`. `<code>` blocks
are banned outright — identifiers, bundle ids and container names are all internal.

**Allowed**, because Apple markets these to customers directly: iCloud, Apple Health,
HealthKit, Apple Watch Ultra, Apple Vision Pro. Say **iCloud**, never CloudKit — they are
the same thing to a reader, and only one of them is a word they have seen.

**Also allowed**, because divers genuinely use them: Bühlmann ZH-L16C, gradient factors,
NDL, deco, surface interval, no-fly. These are printed on dive computers; removing them
would make the watch section vaguer, not clearer.

Describe the *behaviour*, not the mechanism:

| Instead of | Write |
|---|---|
| "mirrors through CloudKit" | "syncs through your own iCloud" |
| "a custom Metal kernel for dehaze" | "a dehaze tool built for the haze water actually produces" |
| "an on-device MLX classifier" | "species suggestions worked out on your own device" |
| "full-res stills are LazyAssets" | "full-size photos download when you open them" |
| "CC BY models render in RealityKit" | "those wrecks are stored in the app and spin without a connection" |
| "conflicts resolve last-writer-wins" | "the most recent edit is the one that sticks" |
| "the record store is local-first" | "the copy on your device is the real one" |

The engineering is still the reason the app behaves well — say what the reader *gets* from
it, and let that carry the credibility.

## Accuracy — the hard rule

**Every factual claim must be traceable to the Deeplife repository's `README.md` or
`docs/DESIGN.md`.** Do not round numbers up, do not invent
features, do not promise dates, prices, App Store availability, or platform support that
the source does not state.

Deeplife is **unreleased and in active development**. There is no App Store listing, no
TestFlight, no price. There is currently no call to action and no contact address.

The dive computer carries a safety warning in the README; anywhere it is discussed at
length, repeat it in a `.note.note-warn`:

> The dive computer is experimental and has not been validated for real diving. Never
> dive without a commercially certified dive computer.

Entangled, swift-decompression and Meshform are **private repositories**. Describe them as
in-house libraries. Never link to them and never imply they can be downloaded.

## Facts you may rely on

- **Five platforms in the first release: iPhone, iPad, Mac, Apple Vision Pro, Apple TV.**
- **Apple Watch is planned, not shipping.** The watch dive computer is built and tested but
  is NOT in the first release and has no date. Its capabilities may be described in detail
  — Bühlmann ZH-L16C, gradient factors, live depth on an Apple Watch Ultra, NDL and deco
  readouts, ascent and ceiling alerts, one-tap logging, Apple Health workouts — but the
  planned status must come *before* the detail, never as a footnote after it.
- **Android is planned, not shipping.** A version for Android phones and Wear OS is intended
  to follow. There is no date.
- For both: never describe them as available, in beta, or arriving on a timeline —
  "planned to follow" is the whole claim. Never put the two in a promised order.
- 120 species in the field guide; 774 training images across those species.
- 770+ named dive sites, 300 destinations, 100+ countries, 23 regions.
- Site training tiers: Recreational 705, Rec & Tec 59, Technical 14 (deepest 70 m).
- 70 Great Lakes wrecks with photogrammetry models; 30 of those under CC BY render
  natively in RealityKit, the rest stream through the publisher's viewer.
- Seafloor terrain: 716 patches, ~13 MB total, 8 km per site, from GMRT/GEBCO.
- Bundle id `software.inspired.Deeplife`; CloudKit container
  `iCloud.software.inspired.Deeplife`.
- Mastodon: `https://hachyderm.io/@inspiredsoftware`. No contact address is published.
- Sharing in v1 is read-only for participants.
