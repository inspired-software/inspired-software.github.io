#!/usr/bin/env node
//
//  tools/check.mjs — validate the built site in Output/
//
//  Run `swift run` first, then `node tools/check.mjs`. Exits non-zero if
//  anything is broken, so it works as a pre-deploy gate.
//

import { readFile, readdir, stat } from "node:fs/promises";
import { join, dirname, resolve as resolvePath } from "node:path";
import { fileURLToPath } from "node:url";

const OUT = join(dirname(fileURLToPath(import.meta.url)), "..", "Output");

const problems = [];
const warn = [];
const fail = (page, msg) => problems.push(`${page}: ${msg}`);

/* ---------- collect pages ---------- */

async function walk(dir, acc = []) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const p = join(dir, entry.name);
    if (entry.isDirectory()) await walk(p, acc);
    else acc.push(p);
  }
  return acc;
}

const files = await walk(OUT);
const htmlFiles = files.filter((f) => f.endsWith(".html"));
const assetSet = new Set(files.map((f) => "/" + f.slice(OUT.length + 1)));

/** "/deeplife/" -> Output/deeplife/index.html */
const urlToFile = (u) => {
  const clean = u.split("#")[0].split("?")[0];
  const base = clean.endsWith("/") ? clean + "index.html" : clean;
  return join(OUT, base);
};

const pageName = (f) => "/" + f.slice(OUT.length + 1);

/* ---------- per-page structural checks ---------- */

const idsByPage = new Map();

for (const file of htmlFiles) {
  const html = await readFile(file, "utf8");
  const name = pageName(file);

  // ids (including those inside SVG <defs>, which are page-global)
  const ids = [...html.matchAll(/\sid="([^"]+)"/g)].map((m) => m[1]);
  const seen = new Set();
  for (const id of ids) {
    if (seen.has(id)) fail(name, `duplicate id "${id}"`);
    seen.add(id);
  }
  idsByPage.set(name, seen);

  // exactly one <h1>
  const h1s = [...html.matchAll(/<h1[\s>]/g)].length;
  if (h1s !== 1) fail(name, `expected exactly one <h1>, found ${h1s}`);

  // heading levels must not skip
  const levels = [...html.matchAll(/<h([1-6])[\s>]/g)].map((m) => Number(m[1]));
  for (let i = 1; i < levels.length; i++) {
    if (levels[i] > levels[i - 1] + 1) {
      fail(name, `heading level jumps from h${levels[i - 1]} to h${levels[i]}`);
    }
  }

  // every <img> needs an alt (alt="" is a valid "decorative")
  for (const [tag] of html.matchAll(/<img\b[^>]*>/g)) {
    if (!/\salt=/.test(tag)) fail(name, `<img> without alt: ${tag.slice(0, 90)}`);
  }

  // informational <svg> needs a label; decorative needs aria-hidden
  for (const [tag] of html.matchAll(/<svg\b[^>]*>/g)) {
    const labelled = /aria-label=|aria-labelledby=/.test(tag);
    const hidden = /aria-hidden="true"/.test(tag);
    const isImg = /role="img"/.test(tag);
    if (!hidden && !labelled) fail(name, `<svg> is neither aria-hidden nor labelled: ${tag.slice(0, 90)}`);
    if (isImg && !labelled) fail(name, `<svg role="img"> without aria-label: ${tag.slice(0, 90)}`);
  }

  // tables must be able to scroll on narrow screens
  for (const m of html.matchAll(/<table\b/g)) {
    const before = html.slice(Math.max(0, m.index - 400), m.index);
    if (!before.includes("table-scroll")) fail(name, `<table> not wrapped in .table-scroll`);
  }

  // unclosed / mismatched tags, for the elements that actually nest
  const VOID = new Set(["img", "br", "hr", "meta", "link", "input", "source", "path", "circle",
    "rect", "line", "polygon", "polyline", "ellipse", "stop", "use", "area", "col", "track", "wbr"]);
  const stack = [];
  for (const m of html.matchAll(/<(\/?)([a-zA-Z][a-zA-Z0-9-]*)\b([^>]*)>/g)) {
    const [, slash, tag, attrs] = m;
    const t = tag.toLowerCase();
    if (VOID.has(t) || attrs.trimEnd().endsWith("/")) continue;
    if (t === "!doctype") continue;
    if (!slash) stack.push(t);
    else {
      const open = stack.pop();
      if (open !== t) {
        fail(name, `tag mismatch: </${t}> closes <${open ?? "nothing"}>`);
        break;
      }
    }
  }
  if (stack.length) fail(name, `unclosed tags: ${[...new Set(stack)].join(", ")}`);

  // meta description length
  // Attribute order varies by renderer (Swim writes them alphabetically).
  const descTag = [...html.matchAll(/<meta\b[^>]*>/g)].map((m) => m[0])
    .find((tag) => /\sname="description"/.test(tag)) ?? "";
  const desc = descTag.match(/\scontent="([^"]*)"/)?.[1] ?? "";
  if (!desc) fail(name, "missing meta description");
  else if (desc.length < 80 || desc.length > 200) {
    warn.push(`${name}: meta description is ${desc.length} chars (aim 120–160)`);
  }
}

/* ---------- link checks (second pass, needs every page's ids) ---------- */

for (const file of htmlFiles) {
  const html = await readFile(file, "utf8");
  const name = pageName(file);

  for (const [, href] of html.matchAll(/\shref="([^"]+)"/g)) {
    if (/^(https?:|mailto:|tel:)/.test(href)) continue;

    if (href.startsWith("#")) {
      const id = href.slice(1);
      if (id && !idsByPage.get(name).has(id)) fail(name, `anchor "${href}" has no matching id on this page`);
      continue;
    }
    if (!href.startsWith("/")) {
      warn.push(`${name}: relative href "${href}" — prefer absolute`);
      continue;
    }

    const [path, frag] = href.split("#");
    // stylesheet / asset / feed hrefs
    if (/\.[a-z0-9]+$/i.test(path)) {
      if (!assetSet.has(path)) fail(name, `href "${href}" → missing file`);
      continue;
    }
    const target = urlToFile(path);
    try {
      await stat(target);
    } catch {
      fail(name, `href "${href}" → no page at ${path}`);
      continue;
    }
    if (frag) {
      const targetName = pageName(target);
      if (!idsByPage.get(targetName)?.has(frag)) {
        fail(name, `href "${href}" → page exists but has no id "${frag}"`);
      }
    }
  }

  // src attributes
  for (const [, src] of html.matchAll(/\ssrc="([^"]+)"/g)) {
    if (/^(https?:|data:)/.test(src)) continue;
    if (src.startsWith("/") && !assetSet.has(src)) fail(name, `src "${src}" → missing file`);
  }
}

/* ---------- no contact address ----------
 * The site carries no email address or mailto: link for now. This checks
 * every built file, source included, so the address can't slip back in
 * through a restored draft or a page's structured data.
 */
for (const file of files) {
  if (!/\.(html|xml|txt|json|js|css)$/.test(file)) continue;
  const text = await readFile(file, "utf8");
  const name = pageName(file);
  if (/[a-z0-9._%+-]+@inspired\.software/i.test(text)) fail(name, "contains an @inspired.software email address");
  if (/mailto:/i.test(text)) fail(name, "contains a mailto: link");
}

/* ---------- jargon gate ----------
 * The site is for divers, not engineers. Framework and language names are
 * implementation detail nobody outside the code needs. Apple's *consumer*
 * names are fine (iCloud, Apple Health, HealthKit, Apple Watch Ultra), as are
 * the dive terms printed on every dive computer (Bühlmann, ZH-L16C, NDL).
 */
const BANNED = [
  /\bSwiftUI\b/i, /\bSwift\b/i, /\bObjective-C\b/i,
  /\bMetal\b/i, /\bshader\b/i, /\bGPU\b/i, /\bkernels?\b/i,
  /\bCloudKit\b/i, /\bCKShare\b/i, /\bCKRecord\b/i, /\bCKSL\b/i, /\bcktool\b/i,
  /\bMLX\b/i, /\bRealityKit\b/i, /\bCore ?Image\b/i, /\bAVFoundation\b/i,
  /\bAVVideoComposition\b/i, /\bLazyAssets?\b/i, /\bPhotosPicker\b/i,
  /\bTuist\b/i, /\bXcode\b/i, /\bSPM\b/i, /\bSwift Package Manager\b/i,
  /\bsoftmax\b/i, /\bNHWC\b/i, /\bCNN\b/i, /\bconvolutional?\b/i, /\btensors?\b/i,
  /\bcodebase\b/i, /\bAPIs?\b/i, /\bSDKs?\b/i, /\bschemas?\b/i,
  /\brecord store\b/i, /\bbundle id\b/i, /\bdark[- ]channel\b/i,
  /\bheightfield\b/i, /\bDEFLATE\b/i, /\bquantiz/i, /\blast[- ]writer[- ]wins\b/i,
  /\bstruct\b/i, /\bcompiler\b/i, /\bruntime\b/i, /\bthread\b/i, /\bconcurrency\b/i,
  // "Vision" the framework, but never "Vision Pro" the product.
  /\bVision\b(?!\s*Pro)/,
];

for (const file of htmlFiles) {
  const html = await readFile(file, "utf8");
  const name = pageName(file);

  // Only inspect visible copy: strip the layout's scripts/styles/svg guts, then tags.
  const body = html
    .replace(/<(script|style|svg)[\s\S]*?<\/\1>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&[a-z]+;/gi, " ");

  for (const re of BANNED) {
    const m = body.match(re);
    if (m) fail(name, `developer jargon in visible copy: "${m[0]}"`);
  }
  if (/<code>/.test(html)) fail(name, `<code> block in visible copy — identifiers are implementation detail`);
}

/* ---------- report ---------- */

if (warn.length) {
  console.log(`\n${warn.length} warning(s):`);
  for (const w of warn) console.log(`  · ${w}`);
}
if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ✗ ${p}`);
  process.exit(1);
}
console.log(`\n✓ ${htmlFiles.length} pages checked, no problems found.`);
