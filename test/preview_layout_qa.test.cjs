// Layout QA: automated text-occlusion and text-overflow sweep for preview.html.
//
// Why this exists: preview_scene_structure.test.cjs only string-matches the HTML.
// Every layout regression found in the July 2026 sprint (cards colliding, text
// pushed off-screen, CJK overflow) was invisible to it. This test drives a real
// browser and fails when visible text is covered by another painted element or
// overflows its own box.
//
// Runs against the system Edge/Chrome via puppeteer-core (no browser download).
// Usage: node test/preview_layout_qa.test.cjs   (or: npm run test:layout)
// Override browser: set PUPPETEER_EXECUTABLE_PATH.

const http = require('http');
const fs = require('fs');
const path = require('path');
const puppeteer = require('puppeteer-core');

const ROOT = path.join(__dirname, '..');

const BROWSER_CANDIDATES = [
  process.env.PUPPETEER_EXECUTABLE_PATH,
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
].filter(Boolean);

// Accepted, documented exceptions. Keep this list SHORT and explained.
const ALLOW = [
  // Fixed chrome (bottom dock, top toolbar): content scrolling underneath is
  // normal app behavior, not an occlusion bug.
  { coveredBy: /\b(dock|dock-item|dock-nav|top-tools|top-tool)\b/ },
  // Decorative distant-target markers sit fully behind the opaque flow cards
  // at narrow widths (recorded in docs/STATE.md as accepted).
  { covered: /\b(node-name|node-meta)\b/, coveredBy: /\b(route-ledger|contact-card|caption-card)\b/ },
];

const SCENES = ['orbit', 'orbit-wide', 'base', 'capsule', 'signal'];
const LANGS = ['zh', 'en'];
const MODES = ['desktop', 'mobile'];

function startServer() {
  const MIME = { '.html': 'text/html', '.png': 'image/png', '.ttf': 'font/ttf', '.js': 'text/javascript', '.css': 'text/css' };
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(req.url.split('?')[0]);
    const file = path.join(ROOT, urlPath === '/' ? 'preview.html' : urlPath);
    if (!file.startsWith(ROOT) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
      res.writeHead(404); res.end('not found'); return;
    }
    res.writeHead(200, { 'content-type': MIME[path.extname(file)] || 'application/octet-stream', 'cache-control': 'no-store' });
    fs.createReadStream(file).pipe(res);
  });
  return new Promise((resolve) => server.listen(0, '127.0.0.1', () => resolve(server)));
}

// Runs inside the page. Returns { occlusions: [], overflows: [] } for the
// current scroll position. Occlusion = a painted, non-related element sits
// above the text in the hit-test stack at the text's center point.
function sweepViewport() {
  const occlusions = [];
  const overflows = [];
  const scene = document.querySelector('.scene.active') || document.body;

  // opacity does not inherit into children's computed style, so a child of an
  // opacity:0 overlay still reports opacity:1 — multiply up the chain.
  function effectiveOpacity(el) {
    let o = 1;
    let cur = el;
    while (cur && cur !== document.body && o > 0.1) {
      o *= parseFloat(getComputedStyle(cur).opacity);
      cur = cur.parentElement;
    }
    return o;
  }

  scene.querySelectorAll('*').forEach((el) => {
    const hasText = Array.from(el.childNodes).some((n) => n.nodeType === 3 && n.textContent.trim().length > 0);
    if (!hasText) return;
    const text = el.textContent.trim();
    if (text.length < 2) return;
    const b = el.getBoundingClientRect();
    if (b.width === 0 || b.height === 0) return;

    const cs = getComputedStyle(el);
    if (cs.visibility === 'hidden' || effectiveOpacity(el) < 0.1) return;

    // --- overflow check (position independent) ---
    // text-overflow:ellipsis is intentional clipping, not a layout bug.
    const clipsByDesign = cs.textOverflow === 'ellipsis' && cs.overflow === 'hidden';
    if (!clipsByDesign && el.scrollWidth - el.clientWidth > 4) {
      overflows.push({ text: text.slice(0, 30), cls: String(el.className).slice(0, 50), dw: el.scrollWidth - el.clientWidth });
    }

    // --- occlusion check (only when center is inside the viewport) ---
    const cx = b.left + b.width / 2;
    const cy = b.top + b.height / 2;
    if (cx < 0 || cy < 0 || cx >= innerWidth || cy >= innerHeight) return;

    const stack = document.elementsFromPoint(cx, cy);
    const idx = stack.indexOf(el);
    if (idx <= 0) return; // topmost, or not hit-testable here

    for (let i = 0; i < idx; i++) {
      const over = stack[i];
      if (over.contains(el) || el.contains(over)) continue;
      const ocs = getComputedStyle(over);
      if (ocs.visibility === 'hidden' || effectiveOpacity(over) < 0.1) continue;
      // background-clip:text paints only its own glyphs, not a box.
      if ((ocs.webkitBackgroundClip || ocs.backgroundClip) === 'text') continue;
      // Count only elements that actually paint at this point: a background,
      // an image, or replaced content. Transparent hit-boxes are fine.
      const bg = ocs.backgroundColor;
      const alpha = bg.startsWith('rgba') ? parseFloat(bg.split(',')[3]) : (bg === 'transparent' ? 0 : 1);
      // NOTE: bare <svg> containers are transparent boxes, so they are not
      // counted as painters (their drawn shapes rarely hit the text center;
      // accepting the small miss keeps false positives near zero).
      const paints = alpha > 0.04 || ocs.backgroundImage !== 'none' ||
        ['IMG', 'CANVAS', 'VIDEO'].includes(over.tagName) ||
        ocs.backdropFilter !== 'none';
      if (!paints) continue;
      occlusions.push({
        text: text.slice(0, 30),
        cls: String(el.className).slice(0, 50),
        coveredBy: String(over.className).slice(0, 50) || over.tagName,
      });
      break;
    }
  });
  return { occlusions, overflows };
}

function isAllowed(kind, item) {
  if (kind !== 'occlusion') return false;
  return ALLOW.some((rule) => {
    const coveredOk = !rule.covered || rule.covered.test(item.cls);
    const byOk = !rule.coveredBy || rule.coveredBy.test(item.coveredBy);
    return coveredOk && byOk;
  });
}

// A failed launch attempt can leave a detached promise that rejects later
// with EBUSY while puppeteer deletes its temp profile; that cleanup noise
// must not kill the run after we've already moved to the next browser.
process.on('unhandledRejection', (err) => {
  if (err && err.code === 'EBUSY' && String(err.path || '').includes('puppeteer_dev_')) {
    console.error('layout-qa: ignored temp-profile cleanup EBUSY from a failed launch');
    return;
  }
  throw err;
});

// A browser binary can exist yet fail to launch headless (e.g. a running
// interactive Edge holding the profile). Try candidates until one launches.
async function launchAnyBrowser() {
  const existing = BROWSER_CANDIDATES.filter((p) => fs.existsSync(p));
  if (!existing.length) {
    console.error('layout-qa: no Edge/Chrome found; set PUPPETEER_EXECUTABLE_PATH');
    process.exit(2);
  }
  let lastErr;
  for (const exe of existing) {
    try {
      return await puppeteer.launch({ executablePath: exe, headless: 'new' });
    } catch (e) {
      lastErr = e;
      console.error(`layout-qa: launch failed for ${exe}, trying next candidate`);
    }
  }
  throw lastErr;
}

async function run() {
  const server = await startServer();
  const port = server.address().port;
  const browser = await launchAnyBrowser();
  const failures = [];
  let sweeps = 0;

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1280, height: 800 });

    for (const sceneKey of SCENES) {
      const scene = sceneKey === 'orbit-wide' ? 'orbit' : sceneKey;
      for (const lang of LANGS) {
        for (const mode of MODES) {
          const state = `${sceneKey}/${lang}/${mode}`;
          // Signal Deck has no URL entry; it is opened from Command Core.
          const urlScene = scene === 'signal' ? 'base' : scene;
          await page.goto(`http://127.0.0.1:${port}/preview.html?scene=${urlScene}&lang=${lang}`, { waitUntil: 'load' });
          await page.evaluate(async () => { await document.fonts.ready; });

          if (mode === 'mobile') {
            await page.evaluate(() => document.body.classList.add('mobile-preview-mode'));
          }
          if (scene === 'signal') {
            await page.evaluate(() => document.getElementById('openSignalDeckBtn')?.click());
          }
          if (sceneKey === 'orbit-wide') {
            const ok = await page.evaluate(() => {
              if (typeof setOrbitViewMode === 'function') { setOrbitViewMode('wide'); return true; }
              return false;
            });
            if (!ok) { failures.push({ state, kind: 'setup', detail: 'setOrbitViewMode not reachable' }); continue; }
          }
          await new Promise((r) => setTimeout(r, 600)); // let fades/layout settle

          // Sanity: the scene we intend to test must actually be active.
          const active = await page.evaluate(() => document.querySelector('.scene.active')?.getAttribute('data-scene'));
          if (active !== scene) {
            failures.push({ state, kind: 'setup', detail: `expected scene ${scene}, active is ${active}` });
            continue;
          }

          // Make hit-testing reflect paint order (pointer-events:none layers
          // would otherwise be invisible to elementsFromPoint).
          await page.evaluate(() => {
            if (!document.getElementById('__qa_pe')) {
              const s = document.createElement('style');
              s.id = '__qa_pe';
              s.textContent = '*{pointer-events:auto !important}';
              document.head.appendChild(s);
            }
          });

          // Sweep at multiple scroll offsets to cover the full scene height.
          const totalH = await page.evaluate(() => {
            const vp = document.querySelector('.viewport');
            return Math.max(document.documentElement.scrollHeight, vp ? vp.scrollHeight : 0);
          });
          for (let offset = 0; offset < totalH; offset += 700) {
            await page.evaluate((y) => {
              window.scrollTo(0, y);
              const vp = document.querySelector('.viewport');
              if (vp) vp.scrollTop = y;
            }, offset);
            await new Promise((r) => setTimeout(r, 120));
            const res = await page.evaluate(sweepViewport);
            sweeps++;
            for (const o of res.occlusions) {
              if (!isAllowed('occlusion', o)) failures.push({ state: `${state}@${offset}`, kind: 'occlusion', ...o });
            }
            if (offset === 0) { // overflow is scroll-independent; record once per state
              for (const o of res.overflows) failures.push({ state, kind: 'overflow', ...o });
            }
          }
        }
      }
    }
  } finally {
    await browser.close();
    server.close();
  }

  // De-duplicate (same element may be flagged at several scroll offsets).
  const seen = new Set();
  const unique = failures.filter((f) => {
    const key = `${f.kind}|${f.text}|${f.cls}|${f.coveredBy || ''}|${f.state.split('@')[0]}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });

  if (unique.length) {
    console.error(`layout-qa: ${unique.length} problem(s) across ${sweeps} sweeps:`);
    for (const f of unique) console.error(' ', JSON.stringify(f));
    process.exit(1);
  }
  console.log(`layout-qa ok (${sweeps} viewport sweeps, ${SCENES.length * LANGS.length * MODES.length} states)`);
}

run().catch((e) => { console.error('layout-qa crashed:', e); process.exit(2); });
