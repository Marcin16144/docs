# Generator spisu treści + wyszukiwarki dla modułu Kadry i Płace (Optima)
# 1) dodaje id do naglowkow h2/h3 ktore go nie maja (regex, zachowuje plik)
# 2) skanuje naglowki wszystkich powiazanych stron
# 3) generuje kadry-place/spis-tresci.html z wyszukiwarka
import re, os, io, html, unicodedata
from bs4 import BeautifulSoup

BASE = r'D:\docs\Optima'

PAGES = [
    ('kadry-place/index.html',                    'Moduł Kadry i Płace',        '👥'),
    ('kadry-place/algorytmy-wyplat.html',         'Algorytmy typów wypłat',     '🧮'),
    ('abc-kadr-i-plac/index.html',                'ABC kadr i płac',            '🎓'),
    ('abc-kadr-i-plac/naliczanie-wyplaty.html',   'Naliczanie wynagrodzenia',   '💸'),
    ('abc-kadr-i-plac/naliczanie-urlopu.html',    'Naliczanie urlopu',          '🏖️'),
    ('przepisy-2026/index.html',                  'Przepisy Kadry i Płace 2026','📋'),
    ('integracje/index.html',                     'Integracje i API',           '🔌'),
]

_pl = str.maketrans('ąćęłńóśźżĄĆĘŁŃÓŚŹŻ', 'acelnoszzACELNOSZZ')
def slug(text):
    t = text.strip()
    t = re.sub(r'^[0-9]+[\.\)]?\s+', '', t)          # usun wiodaca numeracje
    t = t.translate(_pl).lower()
    t = unicodedata.normalize('NFKD', t).encode('ascii', 'ignore').decode()
    t = re.sub(r'[^a-z0-9]+', '-', t).strip('-')
    return t or 'sekcja'

def ensure_ids(path):
    src = io.open(path, encoding='utf-8').read()
    used = set(re.findall(r'id="([^"]+)"', src))
    def repl(m):
        lvl, attrs, inner = m.group(1), m.group(2), m.group(3)
        if 'id=' in attrs:
            return m.group(0)
        text = re.sub(r'<[^>]+>', '', inner)
        s = slug(text); base = s; i = 2
        while s in used:
            s = f'{base}-{i}'; i += 1
        used.add(s)
        return f'<h{lvl}{attrs} id="{s}">{inner}</h{lvl}>'
    new = re.sub(r'<h([23])([^>]*)>(.*?)</h\1>', repl, src, flags=re.S)
    if new != src:
        io.open(path, 'w', encoding='utf-8').write(new)
    return new

def link_for(rel, hid):
    target = rel[len('kadry-place/'):] if rel.startswith('kadry-place/') else '../' + rel
    return f'{target}#{hid}'

groups = []
added = 0
for rel, title, emoji in PAGES:
    path = os.path.join(BASE, rel.replace('/', os.sep))
    before = io.open(path, encoding='utf-8').read()
    content = ensure_ids(path)
    added += len(re.findall(r'id="', content)) - len(re.findall(r'id="', before))
    soup = BeautifulSoup(content, 'html.parser')
    items = []
    for h in soup.find_all(['h2', 'h3']):
        hid = h.get('id')
        if not hid:
            continue
        txt = h.get_text(' ', strip=True)
        txt = re.sub(r'^[0-9]+[\.\)]?\s*', '', txt).strip()
        if not txt:
            continue
        items.append((h.name, hid, txt))
    page_link = rel[len('kadry-place/'):] if rel.startswith('kadry-place/') else '../' + rel
    groups.append((rel, title, emoji, page_link, items))

# --- budowa HTML ---
rows = []
total = 0
for rel, title, emoji, page_link, items in groups:
    rows.append(f'  <div class="grp" data-grp>')
    rows.append(f'    <div class="grp-h"><span class="grp-ic">{emoji}</span>'
                f'<a class="grp-t" href="{html.escape(page_link)}">{html.escape(title)}</a>'
                f'<span class="grp-c">{len(items)}</span></div>')
    rows.append(f'    <div class="grp-b">')
    for lvl, hid, txt in items:
        total += 1
        cls = 'it' + (' it3' if lvl == 'h3' else '')
        ds = html.escape((txt + ' ' + title).lower(), quote=True)
        rows.append(f'      <a class="{cls}" href="{html.escape(link_for(rel, hid))}" '
                    f'data-s="{ds}">{html.escape(txt)}</a>')
    rows.append('    </div>')
    rows.append('  </div>')
body = '\n'.join(rows)

TPL = '''<!DOCTYPE html>
<html lang="pl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Spis treści i wyszukiwarka — Kadry i Płace (Optima)</title>
<style>
:root{{--bg:#0f172a;--surface:#1e293b;--surface-hover:#283649;--border:#334155;--text:#e2e8f0;--text-muted:#94a3b8;--accent:#10b981;--accent-hover:#34d399}}
*{{margin:0;padding:0;box-sizing:border-box}}
body{{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--text);line-height:1.6}}
.header{{position:sticky;top:0;z-index:100;background:linear-gradient(135deg,#1e293b 0%,#0f172a 100%);border-bottom:1px solid var(--border);padding:18px 20px 14px;backdrop-filter:blur(10px)}}
.hc{{max-width:980px;margin:0 auto}}
.topnav{{font-size:.8rem;color:var(--text-muted);margin-bottom:8px}}
.topnav a{{color:var(--accent);text-decoration:none}}
h1{{font-size:1.5rem;font-weight:700;margin-bottom:4px;background:linear-gradient(135deg,var(--accent),#60a5fa);-webkit-background-clip:text;-webkit-text-fill-color:transparent;display:inline-block}}
.sub{{color:var(--text-muted);font-size:.85rem;margin-bottom:12px}}
.search{{position:relative;max-width:680px}}
.search .ic{{position:absolute;left:15px;top:50%;transform:translateY(-50%);color:var(--text-muted);font-size:1.05rem;pointer-events:none}}
#q{{width:100%;padding:11px 16px 11px 44px;background:var(--surface);border:1px solid var(--border);border-radius:10px;color:var(--text);font-size:1rem;outline:none;font-family:inherit;transition:all .2s}}
#q:focus{{border-color:var(--accent);box-shadow:0 0 0 3px rgba(16,185,129,.15)}}
#q::placeholder{{color:var(--text-muted)}}
.meta{{font-size:.78rem;color:var(--text-muted);margin-top:8px}}
.container{{max-width:980px;margin:0 auto;padding:22px 20px 80px}}
.grp{{background:var(--surface);border:1px solid var(--border);border-radius:12px;margin-bottom:14px;overflow:hidden}}
.grp.hide{{display:none}}
.grp-h{{display:flex;align-items:center;gap:10px;padding:13px 18px;border-bottom:1px solid var(--border)}}
.grp-ic{{font-size:1.2rem}}
.grp-t{{font-weight:600;color:var(--accent);text-decoration:none;flex:1;font-size:1rem}}
.grp-t:hover{{color:var(--accent-hover)}}
.grp-c{{font-size:.72rem;color:var(--text-muted);background:rgba(16,185,129,.1);padding:2px 9px;border-radius:10px}}
.grp-b{{padding:8px 12px 12px}}
.it{{display:block;padding:7px 12px;border-radius:6px;text-decoration:none;color:var(--text);font-size:.9rem;transition:all .12s;border-left:2px solid transparent}}
.it:hover{{background:rgba(16,185,129,.08);border-left-color:var(--accent)}}
.it.it3{{padding-left:30px;font-size:.84rem;color:var(--text-muted)}}
.it.it3::before{{content:'└ ';color:var(--border)}}
.it.hide{{display:none}}
.empty{{display:none;text-align:center;color:var(--text-muted);padding:40px;font-size:.95rem}}
.empty.show{{display:block}}
mark{{background:rgba(16,185,129,.3);color:var(--accent-hover);border-radius:2px;padding:0 1px}}
footer{{text-align:center;padding:26px;color:var(--text-muted);font-size:.82rem;border-top:1px solid var(--border)}}
footer a{{color:var(--accent);text-decoration:none}}
</style>
</head>
<body>
<div class="header">
<div class="hc">
<div class="topnav"><a href="../../index.html">📚 Kompendium</a> / <a href="../index.html">💼 Optima</a> / <a href="index.html">👥 Kadry i Płace</a> / <span>Spis treści</span></div>
<h1>🔍 Spis treści i wyszukiwarka</h1>
<p class="sub">Wpisz frazę, aby błyskawicznie znaleźć zagadnienie w dokumentacji Kadr i Płac</p>
<div class="search"><span class="ic">🔍</span><input type="text" id="q" placeholder="Szukaj (np. urlop, składka zdrowotna, algorytm 12, PPK, JPK, ekwiwalent)..." autocomplete="off" autofocus></div>
<div class="meta" id="meta">{total} zagadnień w {ngrp} sekcjach</div>
</div>
</div>
<div class="container">
{body}
<div class="empty" id="empty">Brak wyników — spróbuj innej frazy.</div>
</div>
<footer>👥 Kadry i Płace · spis treści · <a href="index.html">⟵ Moduł Kadry i Płace</a></footer>
<script>
var q=document.getElementById('q'),items=[].slice.call(document.querySelectorAll('.it')),
groups=[].slice.call(document.querySelectorAll('[data-grp]')),empty=document.getElementById('empty'),meta=document.getElementById('meta');
var baseMeta=meta.textContent;
function apply(){{
  var s=q.value.trim().toLowerCase();var shown=0;
  items.forEach(function(it){{
    var m=!s||it.getAttribute('data-s').indexOf(s)>-1;
    it.classList.toggle('hide',!m); if(m) shown++;
  }});
  groups.forEach(function(g){{
    var any=g.querySelectorAll('.it:not(.hide)').length>0;
    g.classList.toggle('hide',!any);
  }});
  empty.classList.toggle('show',shown===0);
  meta.textContent = s ? ('Znaleziono: '+shown) : baseMeta;
}}
q.addEventListener('input',apply);
document.addEventListener('keydown',function(e){{if((e.ctrlKey||e.metaKey)&&e.key==='k'){{e.preventDefault();q.focus();q.select();}}}});
</script>
</body>
</html>
'''

out = TPL.format(total=total, ngrp=len(groups), body=body)
op = os.path.join(BASE, 'kadry-place', 'spis-tresci.html')
io.open(op, 'w', encoding='utf-8').write(out)
print(f'Dodano kotwic id: {added}')
print(f'Zagadnien: {total} w {len(groups)} sekcjach')
print(f'Zapisano: {op}')
