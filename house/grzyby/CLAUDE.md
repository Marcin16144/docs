# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A static Polish mushroom field guide (`Przewodnik grzybowy`). No build system, no package manager, no test runner — all files are plain HTML/CSS/JS opened directly in a browser. Entry point: `D:\docs\house\Grzyby.html` (relative redirect shortcut) → `grzyby/index.html`.

To preview any page, open it directly in a browser (double-click or `start filename.html` in PowerShell).

## File structure

```
grzyby/
  index.html          ← main hub: grid, sidebar, modal gallery
  galeria.html        ← all photos in one masonry grid
  przepisy.html       ← recipes page
  trujace.html        ← poisonous species warning cards
  huby.html           ← bracket fungi overview (3 species, properties, seasonal calendar)
  styles.css          ← shared CSS for the 15 detail pages ONLY
  01-borowik.html … 15-lakownica.html   ← individual species pages
  media/              ← all photos (JPG)
```

## Central data store: `plants[]` array (index.html)

Every mushroom is defined once as an object in the `plants[]` JS array (0-indexed, 15 entries). Each entry:

```js
{
  name:   "Borowik szlachetny",
  latin:  "Boletus edulis",
  photos: ["media/01-1.jpg", "media/01-2.jpg", "media/01-3.jpg"],
  alts:   ["alt text 1", "alt text 2", "alt text 3"],
  info:   ["Occurrence text", "Taste text", "Habitat text"],
  uses:   ["Use 1", "Use 2", "Use 3"],
  warn:   "Warning text or empty string",
  href:   "01-borowik.html"
}
```

The index page grid, sidebar links, modal gallery, and `galeria.html` all render from this array. When adding a species, update `plants[]` first, then create the detail HTML.

## Photo naming conventions

| Context | Pattern | Example |
|---|---|---|
| Standard detail pages (1–3 per species) | `NN-1.jpg`, `NN-2.jpg`, `NN-3.jpg` | `07-1.jpg` |
| Hub/bracket fungi extras (species 13–15) | `NN-4.jpg`, `NN-5.jpg` | `13-4.jpg` |
| Poisonous card — mature | `t-SPECIES-1.jpg`, `t-SPECIES-2.jpg` | `t-virosa-1.jpg` |
| Poisonous card — underside | `t-SPECIES-u.jpg` | `t-pantherina-u.jpg` |
| Poisonous card — young specimen | `t-SPECIES-y.jpg` | `t-galerina-y.jpg` |
| Muchomor sromotnikowy (species 12) | `12-1.jpg`, `12-2.jpg`, `12-u.jpg`, `12-y.jpg` | — |

All photos sourced from **iNaturalist** (research-grade, CC-licensed). Wikimedia Commons is rate-limited from this machine (IP 188.146.146.27 blocked — HTTP 429). Use iNaturalist API instead:

```powershell
$obs = (Invoke-RestMethod "https://api.inaturalist.org/v1/observations?taxon_name=Amanita+phalloides&quality_grade=research&photos=true&per_page=5&order_by=votes").results
$url = $obs[0].photos[0].url -replace "/square\.", "/large."
Invoke-WebRequest $url -OutFile "media/12-1.jpg"
# Use obs.photos[1] for a likely underside/gills shot in multi-photo observations
```

## CSS architecture

### `styles.css` — detail pages only (01–15)

Shared by all 15 `NN-name.html` detail files. Defines `.container`, `.photos`, `.photo`, `.recipe`, `.pros-cons`, `.warn`, `.tip`, `.info-grid`, `.info-box`, `.nav-bottom`. Do **not** reference this file from index.html, galeria.html, przepisy.html, or trujace.html — they use inline `<style>` blocks.

### CSS variables and theme variants

```css
/* Standard theme (edible species) */
--bg: #0f130a;
--accent: #c8943c;   /* amber */
--text: #efe8d8;

/* Poisonous theme (trujace.html, 12-muchomor.html) */
--accent: #f87171;   /* red */
```

Dark forest background `#0f130a` is universal. Muted secondary text uses `#a09878`.

## Modal gallery system (index.html)

`openModal(idx)` → `renderModal()` reads `plants[pIdx]` and renders:
- `buildGallery(p)` — photo carousel using `plants[pIdx].photos[]`
- Info and uses from `plants[pIdx].info[]` and `plants[pIdx].uses[]`

Navigation:
- `ArrowLeft` / `ArrowRight` — cycle photos within mushroom (`galPrev`/`galNext`)
- `Shift+ArrowLeft` / `Shift+ArrowRight` — navigate between mushrooms
- `Escape` — close modal

## Lightbox (detail pages and trujace.html)

Two variants, both inline at end of `<body>` — identical logic, different image selectors:

| Page type | Selector |
|---|---|
| Hub detail pages (13–15) | `.photos .photo img` |
| trujace.html | `.dp-wrap img` |

Lightbox HTML: `#lb` overlay with `#lb-img`, `#lb-cap`, `#lb-cnt`, `#lb-prev`, `#lb-next`, `#lb-close`. JS collects all matching `imgs[]`, supports `ArrowLeft`/`ArrowRight`/`Escape`, closes on backdrop click. Images that fail to load are hidden via `el.onerror = function(){ this.closest('.dp-wrap').style.display='none'; }`.

## Poisonous cards (`trujace.html`) — `.dp-wrap` photo grid

Each danger card has a 2×2 `.danger-photos` grid:

```html
<div class="danger-photos">
  <div class="dp-wrap"><img src="…" alt="…"><span class="dp-tag">dojrzały</span></div>
  <div class="dp-wrap"><img src="…" alt="…"><span class="dp-tag">volva u dołu</span></div>
  <div class="dp-wrap"><img src="…" alt="…"><span class="dp-tag t-bottom">od spodu</span></div>
  <div class="dp-wrap"><img src="…" alt="…"><span class="dp-tag t-young">młody okaz</span></div>
</div>
```

Tag classes: default = mature/detail, `.t-bottom` = green tint for underside view, `.t-young` = amber tint for young specimen. Second slot label varies per species: `volva u dołu` (phalloides/virosa), `podstawa trzonu` (pantherina), `pierścień` (galerina), `dojrzały` (gyromitra), `siedlisko` (omphalotus), `siateczka na trzonie` (tylopilus), `miąższ / sinienie` (satanas).

## Adding a new mushroom species

1. Add entry to `plants[]` in `index.html` (append; it's 0-indexed, currently 15 entries)
2. Download 3–5 photos to `media/NN-1.jpg` … `media/NN-N.jpg`
3. Create `NN-name.html` using an existing detail page as template (include `styles.css` link)
4. Update `nav-bottom` links in the preceding and following detail pages
5. If edible, add to `przepisy.html`; if poisonous, add a card to `trujace.html`

## Sidebar and search (index.html)

Built dynamically from `plants[]`. Real-time filter searches `name` + `latin` fields (case-insensitive). Contains links: Galeria, Przepisy, Trujące, plus one entry per mushroom. Filter state persists while modal is open.
