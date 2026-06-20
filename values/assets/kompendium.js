/* Kompendium — shared client runtime.
   Reads window.KOMP (injected per page) and adds: reading-position memory + resume,
   a related-materials block, a floating launcher, and a full-text search overlay.
   Pure vanilla JS, no dependencies. Degrades gracefully on file:// (search needs a
   server or the desktop app; reading-position works everywhere). */
(function () {
  "use strict";
  var K = window.KOMP;
  if (!K || !K.page) return;
  var LS = window.localStorage;
  var home = K.home || "";

  // ---------- storage helpers ----------
  function get(key, def) { try { return JSON.parse(LS.getItem(key)) || def; } catch (e) { return def; } }
  function set(key, val) { try { LS.setItem(key, JSON.stringify(val)); } catch (e) {} }

  function recordVisit(pct) {
    set("komp:last", { path: K.page, title: K.title, section: K.section, label: K.sectionLabel, pct: pct, ts: Date.now() });
    var scroll = get("komp:scroll", {});
    scroll[K.page] = { pct: pct, ts: Date.now() };
    var keys = Object.keys(scroll);
    if (keys.length > 400) {                      // prune oldest
      keys.sort(function (a, b) { return scroll[a].ts - scroll[b].ts; });
      keys.slice(0, keys.length - 400).forEach(function (k) { delete scroll[k]; });
    }
    set("komp:scroll", scroll);
    var recent = get("komp:recent", []).filter(function (r) { return r.path !== K.page; });
    recent.unshift({ path: K.page, title: K.title, section: K.section, label: K.sectionLabel, ts: Date.now() });
    set("komp:recent", recent.slice(0, 12));
  }

  function scrollPct() {
    var h = document.documentElement;
    var max = (h.scrollHeight || document.body.scrollHeight) - window.innerHeight;
    return max > 0 ? Math.min(1, Math.max(0, (window.scrollY || h.scrollTop) / max)) : 0;
  }
  function scrollToPct(pct) {
    var h = document.documentElement;
    var max = (h.scrollHeight || document.body.scrollHeight) - window.innerHeight;
    window.scrollTo({ top: max * pct, behavior: "smooth" });
  }

  // ---------- desktop host bridge ----------
  function postHost(msg) {
    try { if (window.chrome && window.chrome.webview) window.chrome.webview.postMessage(msg); } catch (e) {}
  }
  function postProgress(pct) { postHost({ t: "progress", pct: pct, path: K.page, title: K.title }); }

  // ---------- progress bar ----------
  var bar = document.createElement("div"); bar.className = "komp-progress";
  document.body.appendChild(bar);

  var savedPct = (get("komp:scroll", {})[K.page] || {}).pct || 0;
  var ticking = false, saveTimer = null;
  function onScroll() {
    if (!ticking) {
      requestAnimationFrame(function () {
        var p = scrollPct();
        bar.style.width = (p * 100).toFixed(1) + "%";
        postProgress(p);
        ticking = false;
      });
      ticking = true;
    }
    clearTimeout(saveTimer);
    saveTimer = setTimeout(function () { recordVisit(scrollPct()); }, 400);
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener("pagehide", function () { recordVisit(scrollPct()); });
  document.addEventListener("visibilitychange", function () { if (document.hidden) recordVisit(scrollPct()); });

  // ---------- resume reading ----------
  function toast(msg, actionLabel, action) {
    var t = document.createElement("div"); t.className = "komp-toast";
    t.innerHTML = "<span>" + msg + "</span>";
    if (actionLabel) {
      var b = document.createElement("button"); b.textContent = actionLabel;
      b.onclick = function () { action(); hide(); };
      t.appendChild(b);
    }
    var close = document.createElement("button"); close.textContent = "✕"; close.onclick = hide;
    t.appendChild(close);
    document.body.appendChild(t);
    requestAnimationFrame(function () { t.classList.add("show"); });
    var to = setTimeout(hide, 7000);
    function hide() { clearTimeout(to); t.classList.remove("show"); setTimeout(function () { t.remove(); }, 300); }
  }
  function maybeResume() {
    if (location.hash && location.hash.length > 1) return;     // honour deep links
    if (savedPct > 0.04 && savedPct < 0.985) {
      setTimeout(function () {
        scrollToPct(savedPct);
        toast("↧ Przywrócono miejsce czytania (" + Math.round(savedPct * 100) + "%)", "na górę", function () { window.scrollTo({ top: 0, behavior: "smooth" }); });
      }, 350);
    }
  }

  // ---------- related materials ----------
  function buildRelated() {
    if (!K.rel || !K.rel.length || document.querySelector(".komp-related")) return;
    var box = document.createElement("section"); box.className = "komp-related";
    var h = document.createElement("h3"); h.innerHTML = "🔗 Powiązane materiały"; box.appendChild(h);
    var grid = document.createElement("div"); grid.className = "komp-rel-grid";
    K.rel.forEach(function (r) {
      var a = document.createElement("a"); a.className = "komp-rel-card"; a.href = r.u;
      a.innerHTML = '<span class="komp-ico">' + (r.s || "📄") + '</span><span>' +
        '<span class="komp-rel-t">' + esc(r.t) + '</span>' +
        '<span class="komp-rel-r">' + esc(r.r || "") + '</span></span>';
      grid.appendChild(a);
    });
    box.appendChild(grid);
    var nav = document.querySelector(".nav-bottom");
    var container = document.querySelector(".container") || document.body;
    if (nav && nav.parentNode) nav.parentNode.insertBefore(box, nav);
    else container.appendChild(box);
  }

  // ---------- launcher ----------
  var fab = document.createElement("button"); fab.className = "komp-fab"; fab.title = "Kompendium (Ctrl+K — szukaj)"; fab.textContent = "📚";
  var panel = document.createElement("div"); panel.className = "komp-panel";
  document.body.appendChild(fab); document.body.appendChild(panel);
  fab.onclick = function () { panel.classList.contains("open") ? closePanel() : openPanel(); };
  document.addEventListener("click", function (e) { if (!panel.contains(e.target) && e.target !== fab) closePanel(); });
  function closePanel() { panel.classList.remove("open"); }
  function openPanel() {
    var last = get("komp:last", null);
    var recent = get("komp:recent", []).filter(function (r) { return r.path !== K.page; });
    var html = '<h4>Nawigacja</h4>';
    html += item("🔎", "Szukaj w bazie", "Ctrl K", "search");
    html += item("🗂️", "Indeks / wszystkie strony", "", "index");
    html += item("🏠", "Strona główna", "", "home");
    if (last && last.path !== K.page)
      html += item("⤴️", "Wznów: " + esc(last.title || last.path), Math.round((last.pct || 0) * 100) + "%", "resume");
    if (recent.length) {
      html += '<div class="komp-divider"></div><h4>Ostatnio czytane</h4>';
      recent.slice(0, 4).forEach(function (r, i) { html += item(iconFor(r.section), esc(r.title || r.path), "", "recent:" + i); });
    }
    panel.innerHTML = html;
    panel.querySelectorAll(".komp-item").forEach(function (el) {
      el.onclick = function () {
        var act = el.getAttribute("data-act");
        if (act === "search") openSearch();
        else if (act === "index") location.href = home + "values/szukaj.html";
        else if (act === "home") location.href = home + "index.html";
        else if (act === "resume" && last) location.href = home + last.path;
        else if (act.indexOf("recent:") === 0) location.href = home + recent[+act.split(":")[1]].path;
        closePanel();
      };
    });
    panel.classList.add("open");
  }
  function item(ico, label, sub, act) {
    return '<button class="komp-item" data-act="' + act + '"><span class="komp-ico">' + ico +
      '</span><span style="flex:1;min-width:0"><span style="display:block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">' + label +
      '</span>' + (sub ? '<span class="komp-sub">' + sub + '</span>' : '') + '</span></button>';
  }

  // ---------- search overlay ----------
  var overlay, input, results, catalog = null, secMap = {}, sel = -1, curRes = [];
  function buildOverlay() {
    overlay = document.createElement("div"); overlay.className = "komp-overlay";
    overlay.innerHTML =
      '<div class="komp-search"><div class="komp-search-top"><span style="font-size:1.1rem">🔎</span>' +
      '<input type="text" placeholder="Szukaj stron, tematów, działów…" autocomplete="off">' +
      '<span class="komp-kbd">Esc</span></div><div class="komp-results"></div></div>';
    document.body.appendChild(overlay);
    input = overlay.querySelector("input");
    results = overlay.querySelector(".komp-results");
    overlay.addEventListener("click", function (e) { if (e.target === overlay) closeSearch(); });
    input.addEventListener("input", function () { sel = -1; runSearch(input.value); });
    input.addEventListener("keydown", function (e) {
      if (e.key === "ArrowDown") { e.preventDefault(); move(1); }
      else if (e.key === "ArrowUp") { e.preventDefault(); move(-1); }
      else if (e.key === "Enter") { var a = results.querySelectorAll(".komp-res")[sel] || results.querySelector(".komp-res"); if (a) location.href = a.href; }
      else if (e.key === "Escape") closeSearch();
    });
  }
  function openSearch() {
    if (!overlay) buildOverlay();
    overlay.classList.add("open"); input.value = ""; input.focus();
    results.innerHTML = '<div class="komp-empty">Ładowanie indeksu…</div>';
    loadCatalog().then(function () { runSearch(""); }).catch(function () {
      results.innerHTML = '<div class="komp-empty">⚠ Wyszukiwarka wymaga uruchomienia jako aplikacja desktop lub przez serwer WWW (http).<br>Otwórz <b>Kompendium.Desktop</b> albo wgraj bazę na serwer.</div>';
    });
  }
  function closeSearch() { if (overlay) overlay.classList.remove("open"); }
  function loadCatalog() {
    if (catalog) return Promise.resolve();
    return fetch(home + "values/data/catalog.json", { cache: "no-cache" }).then(function (r) {
      if (!r.ok) throw new Error("no catalog"); return r.json();
    }).then(function (j) {
      catalog = j.pages || [];
      (j.sections || []).forEach(function (s) { secMap[s.id] = s.icon + " " + s.title; });
    });
  }
  function runSearch(q) {
    q = (q || "").trim().toLowerCase();
    var terms = q.split(/\s+/).filter(Boolean);
    var list;
    if (!terms.length) {
      list = catalog.slice().sort(function (a, b) { return (b.words || 0) - (a.words || 0); }).slice(0, 40);
    } else {
      list = [];
      for (var i = 0; i < catalog.length; i++) {
        var p = catalog[i];
        var hay = (p.title + " " + (p.subtitle || "") + " " + (p.section || "") + " " +
          (p.headings || []).map(function (h) { return h.text; }).join(" ")).toLowerCase();
        var score = 0, ok = true;
        for (var t = 0; t < terms.length; t++) {
          var idx = hay.indexOf(terms[t]); if (idx < 0) { ok = false; break; }
          score += (p.title.toLowerCase().indexOf(terms[t]) >= 0 ? 10 : 1) + (idx < 30 ? 3 : 0);
        }
        if (ok) { p._s = score; list.push(p); }
      }
      list.sort(function (a, b) { return b._s - a._s; });
      list = list.slice(0, 45);
    }
    curRes = list;
    if (!list.length) { results.innerHTML = '<div class="komp-empty">Brak wyników dla „' + esc(q) + '”.</div>'; return; }
    results.innerHTML = list.map(function (p) {
      return '<a class="komp-res" href="' + home + p.path + '"><span class="komp-ico">' + iconFor(p.section) +
        '</span><span><span class="komp-res-t">' + hl(p.title, terms) + '</span>' +
        '<span class="komp-res-s">' + esc(secMap[p.section] || p.section) +
        (p.subtitle ? " · " + esc(p.subtitle) : "") + '</span></span></a>';
    }).join("");
  }
  function move(d) {
    var els = results.querySelectorAll(".komp-res"); if (!els.length) return;
    if (sel >= 0 && els[sel]) els[sel].classList.remove("sel");
    sel = (sel + d + els.length) % els.length;
    els[sel].classList.add("sel"); els[sel].scrollIntoView({ block: "nearest" });
  }

  // ---------- helpers ----------
  function esc(s) { return String(s == null ? "" : s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function hl(s, terms) {
    s = esc(s); if (!terms || !terms.length) return s;
    terms.forEach(function (t) { if (t) s = s.replace(new RegExp("(" + t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "ig"), "<mark>$1</mark>"); });
    return s;
  }
  var ICONS = { software: "💻", electric: "⚡", electronic: "🔌", hardware: "🖥️", monitoring: "📡", music: "🎵", video: "🎬", grafika3d: "🧊", house: "🌿", cars: "🚗", agd: "🏠", cwiczenia: "🧘", Optima: "💼", services: "🌐", Kryptowaluty: "🪙", Terapia: "🧠", Dokumentacje: "📄" };
  function iconFor(s) { return ICONS[s] || "📄"; }

  // ---------- global keys ----------
  document.addEventListener("keydown", function (e) {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") { e.preventDefault(); openSearch(); }
    else if (e.key === "/" && !/^(input|textarea|select)$/i.test((document.activeElement || {}).tagName || "")) { e.preventDefault(); openSearch(); }
  });

  // ---------- desktop integration ----------
  window.kompOpenSearch = openSearch;   // invoked by Kompendium.Desktop toolbar / Ctrl+K

  // ---------- init ----------
  recordVisit(savedPct);
  buildRelated();
  bar.style.width = (scrollPct() * 100).toFixed(1) + "%";
  postProgress(scrollPct());
  maybeResume();
})();
