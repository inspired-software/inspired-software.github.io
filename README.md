# The Inspired Software website

Sources for the [Inspired Software, LLC](https://inspired.software) website, built with
[Saga](https://github.com/loopwerk/Saga), a static-site generator written in Swift.

## Build

```sh
swift run               # build content/ into Output/
node tools/check.mjs    # check the built site: links, anchors, headings, copy
tools/preview.sh        # build, then serve Output/ at http://localhost:4000
```

Requires Swift 6 on macOS 14 or later. `tools/check.mjs` needs Node, but no packages.
For rebuild-on-save with automatic browser reload, install Saga's command-line tool
(`brew install loopwerk/tap/saga`) and run `saga dev`.

## Layout

```
Package.swift           Saga 3.6.0, and Swim for the templates
content/                the site: one HTML file per page, plus styles.css, img/, CNAME
diagrams/               the SVG diagrams, one file each, by page
drafts/                 full pages hidden for the skeletal launch — not built; see drafts/README.md
Sources/InspiredSoftware/
  main.swift            the whole build pipeline, top to bottom
  Content.swift         reads content/*.html and its front matter
  Shortcodes.swift      {{notify}}, {{platform-strip}}, {{diagram …}}
  Layout.swift          the <head> and <body> every page is wrapped in
  SiteHeader.swift  SiteFooter.swift  NotifyCTA.swift  PlatformStrip.swift
AUTHORING.md            style, component, and accuracy rules — read before editing pages
tools/check.mjs         the pre-deploy check of Output/
tools/og-card/          the social card, and how to re-render it
Output/                 build output — committed, because gh-pages is a subtree of it
```

Pages are HTML fragments with a short front-matter header. The Swift layout supplies
`<html>`, `<head>`, the header and the footer:

```
---
title: Support — Inspired Software, LLC
description: How to get help with Deeplife, and how we think about diving safety.
---
<section class="page-head">
  …
```

The filename is the URL (`content/support.html` → `/support/`). A page missing its front
matter, an unknown `{{shortcode}}`, or a `{{diagram}}` with no file all stop the build
rather than silently emitting nothing.

The stylesheet is linked by a content-hashed filename (`/styles-1a2b3c4d.css`), so a
deploy can never leave a visitor on a stale cached copy.

## Deploying

Hosting is **GitHub Pages** (the `gh-pages` branch of this repo), with Cloudflare in front
for DNS and CDN. `Output/` is committed so that:

```sh
./push.sh
```

publishes `main`'s `Output/` to `gh-pages` as a single commit with no history, so the
published branch holds only what's live. Always build, run the check, and commit on `main`
before pushing. The source is on `main` in the same repository.

## Theming

Dark is the default and light is a full peer — both are defined in `styles.css` via
`prefers-color-scheme` plus a `data-theme` attribute that the header toggle sets and
`localStorage` remembers. An inline script in `<head>` applies the stored choice before
first paint, so the wrong theme never flashes. Anything you add must work in both.
