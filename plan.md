# Plan: premium law-firm website — Adwokat Kamil Niedziejko

## Objective
Transform the existing GitHub Pages static site (HTML + CSS + vanilla JS) into a production-ready, quiet-luxury boutique law-firm site for ADWOKAT KAMIL NIEDZIEJKO (Kraków), grounded in the current repo and moodboard assets, with the banned fictional-lawyer image fully removed.

## End state / definition of done
- `index.html` is valid, UTF-8, uses only allowed photography, passes W3C-style tag-balance check.
- Hero uses cropped photo from `9.png` (no person, desk/lamp/folder motif); About uses `4.png` photo; Practice uses `3.png` motif; Values uses `5.png` motif; Contact uses `6.png` motif.
- Zero references to `2.png` / `web/2.jpg` / `thumbs/2.jpg` in HTML, CSS, JS, meta.
- Design tokens match `7.png`/`8.png`: bg `#F7F4EF`, surface `#FCFAF7`, text `#25211D`, muted `#7B7267`, lines `#D9D1C8`, accent `#2F241D`; headings Baskervville (H1 72 / H2 48 / H3 28), body Inter 18px.
- Public moodboard gallery (`#identyfikacja`) removed; editorial asymmetric layout, generous whitespace, working header/nav/anchors, mailto/tel, LegalService schema, OG/Twitter, favicon, OG image 1200x630.
- Images optimized (each `web/*.jpg` <= 400KB, WebP + srcset + lazy except hero), Lighthouse >= 95 Performance/Accessibility/Best-Practices/SEO (desktop, throttled mobile sanity), no JS errors, no overflow, HTTPS + CNAME verified.
- Release commit on `main`, `git status` clean, Pages build `built`.

## Non-goals
- No backend, CMS, forms backend, or booking system (mailto/tel only).
- No stock lawyers, gavels, Themis, AI portraits, testimonials carousel, circular text.
- No framework migration (stay static HTML/CSS/vanilla JS + GitHub Pages).
- No legal advice content changes beyond premium-legal copy cleanup; contact data (ul. Dobrego Pasterza 189, 31-416 Kraków, kontakt@kamilniedziejko.pl, +48 512 458 132) is preserved verbatim.
- No multi-page expansion (single `index.html` + `404.html` only).

## Environment
- language: static HTML5 + CSS3 + vanilla JS (ES2020, no bundler)
- runtime: any modern browser; hosting GitHub Pages (CNAME `niedziejko.pl`, HTTPS enforced)
- package_manager: none (system tools only: bash, python3 stdlib, ImageMagick `magick`/`convert` if present, `gh` CLI for Pages check)
- os: linux (WSL Ubuntu) / Windows UNC path `\\wsl.localhost\Ubuntu-26.04\home\tom\projects\niedziejko`
- test_command: `python3 .agents/skills/plan-loop/tools/validate_plan.py --tasks tasks.json && bash -n scripts/*.sh && python3 scripts/check_site.py`
- notes: No npm/jest/playwright in repo. Verification is script-based (grep/tag-balance/bytes/HTML lang/alt/anchors) + manual Lighthouse in Chrome + `gh api repos/{owner}/{repo}/pages` for Pages/HTTPS. ImageMagick may be absent on executor — every image task has a python-fallback or fails closed with explicit error.

## Components
| id | name | description |
|----|------|-------------|
| c1 | foundation-cleanup | Purge banned asset 2, fix UTF-8/head/CSS-JS wiring, remove dead files (root style.css vs assets/css, 0-byte placeholders). |
| c2 | hero-9 | Editorial hero from 9.png photo half (light, whitespace, no person). |
| c3 | about-4 | About section from 4.png (hands/document detail, no face). |
| c4 | practice-3 | Practice accordion from 3.png (paper/pencil motif, 5 items + descriptions). |
| c5 | values-5 | Values list from 5.png (wall/shadow/folder, 3 items). |
| c6 | contact-6 | Contact card from 6.png (desk/card motif, mailto/tel, CTA). |
| c7 | design-system | Tokens (7.png), type scale (8.png), spacing/grid/asymmetry, header/nav, buttons, minimal reveal. |
| c8 | seo-meta | Canonical/OG/Twitter/LegalService schema, favicon set, og-image 1200x630, robots/sitemap/404. |
| c9 | quality-release | WebP/srcset/lazy/preload, a11y, Lighthouse>=95, cross-browser, Pages+HTTPS verify, release commit. |

## Task table (in execution order)
| id | title | serves | depends_on | est. LOC |
|----|-------|--------|------------|----------|
| T01 | purge banned 2 + repair HTML skeleton | c1 | — | 120 |
| T02 | rebuild hero from 9.png photo | c2 | T01 | 180 |
| T03 | rebuild About from 4.png photo | c3 | T01 | 150 |
| T04 | rebuild Practice Areas from 3.png | c4 | T01 | 180 |
| T05 | rebuild Values from 5.png | c5 | T01 | 140 |
| T06 | rebuild Contact from 6.png + mailto/tel | c6 | T01 | 150 |
| T07 | remove moodboard gallery + editorial spacing/grid | c7 | T02,T03,T04,T05,T06 | 200 |
| T08 | typography + header/nav + buttons + reveal | c7 | T07 | 220 |
| T09 | SEO/schema/OG/favicon/robots/sitemap/404 | c8 | T08 | 180 |
| T10 | perf (WebP/srcset/lazy) + a11y + JS hardening | c9 | T09 | 220 |
| T11 | final QA + Pages/HTTPS + release commit | c9 | T10 | 120 |

## Dependency graph (ASCII)
```
T01 ─┬─> T02 ─┐
     ├─> T03 ─┤
     ├─> T04 ─┼─> T07 ─> T08 ─> T09 ─> T10 ─> T11
     ├─> T05 ─┤
     └─> T06 ─┘
```
Linear spine after fan-out: content sections (T02–T06) are independent of each other, all block T07.

## Risks / open questions
- R1 (blocking): `assets/images/web/*.jpg` were batch-converted from full moodboards, so burned-in headline text may be present. Every content task must crop the photo half only (e.g. 9.png right ~48%, 4.png right ~50%) — never use full PNG/JPG as `<img>`. Fallback: if crop tools missing, fail closed and record `open_question`.
- R2: `index.html` has broken tags + mojibake (Kraków, anchors `#prakyka`) + stray literal `assets/css/styles.css` text instead of `<link>`. T01 must rewrite head + nav from scratch; partial sed-patch will not hold.
- R3: Dual CSS (`./style.css` 3732B orphan vs `assets/css/styles.css` 6758B live). Single source of truth is `assets/css/styles.css` linked from `index.html`; `./style.css` is deleted in T01.
- R4: `og-image.jpg` (0B), `favicon.svg` (0B), `script.js` (0B) are placeholders. T09 regenerates them; do not hotlink `web/2.jpg` as social image.
- R5: No automated test harness. `scripts/check_site.py` (created in T01) is the gate: tag balance, banned-asset grep, required selectors/anchors/alt, file-size caps.
- Open questions: (1) owner/repo for `gh api .../pages` (assumed `elconcept/niedziejko` from TASKS.md — confirm before T11); (2) final approved Polish copy for 5 practice descriptions (T04 ships with current JS strings, copy-polish is T11 note); (3) whether executor has ImageMagick (each image step has python/PIL-fallback or explicit abort).

## How to execute
Consume `tasks.json` as source of truth in `order`. Each task = one executable `scripts/Txx_*.sh` + one commit. Run the task script, then `python3 scripts/check_site.py`, fix, commit. Rollback = `git revert HEAD` (single-commit tasks) or restore `*.bak.Txx` left by the script. Do not start T07 before T02–T06 all pass.

## Crop table (normative, photo-half only — never full moodboard)
| src | box (l,t,r,b) | output | motif |
|-----|---------------|--------|-------|
| 9.png | 0.52,0.0,1.0,1.0 | assets/images/web/hero-9.jpg | desk/lamp/folder, no person |
| 4.png | 0.45,0.0,1.0,1.0 | assets/images/web/about-4.jpg | hands/document, no face |
| 3.png | 0.63,0.0,1.0,1.0 | assets/images/web/practice-3.jpg | paper/pencil torn edge |
| 5.png | 0.52,0.0,1.0,1.0 | assets/images/web/values-5.jpg | wall shadow + folder |
| 6.png | 0.50,0.0,1.0,1.0 | assets/images/web/contact-6.jpg | desk/card/door |
Executor aborts (fail closed) if PIL/ImageMagick absent. Each output <=400KB + WebP twin. Visual no-text check recorded in reports/.

## Copy-purge gate (T08 + T11)
Diacritics-insensitive grep must return zero hits for: kompleksowa obsluga / najwyzsza jakosc / indywidualne podejscie / profesjonalne uslugi. NAP (ul. Dobrego Pasterza 189, 31-416 Krakow, kontakt@kamilniedziejko.pl, +48 512 458 132) preserved verbatim.
