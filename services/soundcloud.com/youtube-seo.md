# YouTube SEO — pełny przewodnik dla muzycznego kanału

> **TL;DR:** YouTube to **inna gra niż SC/hearthis**. Algorytm SC patrzy na pierwsze 24-48h odsłuchów + tagi. Algorytm YT patrzy na **CTR (thumbnail + tytuł) × watch time × session time**. Dla kanału muzycznego z auto-generowanym waveform thumbnail'em (jak `MaximumMusicMaxx`) **pojedyncza zmiana — custom thumbnail — daje większy boost niż jakakolwiek inna optymalizacja**.

---

## 1. Hierarchia ważności (co naprawdę liczy w YouTube SEO 2026)

| Priorytet | Element | Wpływ na algorytm | Effort |
|---|---|---|---|
| 🔴 #1 | **Thumbnail** (custom, nie auto) | Bezpośredni CTR → ranking | Średni (Canva 10 min) |
| 🔴 #2 | **Tytuł** (keyword na początku, ≤60 znaków) | CTR + search ranking | Niski |
| 🔴 #3 | **Watch time** / Average view duration | **Najważniejszy** ranking signal | Wysoki (kompozycja muzyki) |
| 🟠 #4 | **Description** (pierwsze 150 znaków) | Search ranking + CTR z preview | Niski |
| 🟠 #5 | **Chapters / timestamps** | Wydłużają watch time + key moments | Niski |
| 🟠 #6 | **Playlists** kanału | Session time (autoplay) + osobny ranking | Niski |
| 🟡 #7 | **End screen + cards** | Session time, link do kolejnego video | Niski |
| 🟡 #8 | **Pinned comment** | Engagement signal | Niski |
| 🟡 #9 | **Shorts jako feeder** | Discovery → main video | Wysoki (osobny content) |
| 🟢 #10 | **Tags** (Studio backend) | Disambiguation, drugorzędne | Niski |
| 🟢 #11 | **Closed Captions** | Accessibility + minor SEO | Średni |
| 🟢 #12 | **Plugin / Effect credits** | Licencja (compliance), nie SEO | Niski (raz, template) |

---

## 2. Thumbnail strategy — najmocniejsza dźwignia

### Problem domyślny
YouTube auto-generuje **waveform visualizer** dla każdego music upload. Wszystkie wyglądają tak samo → Twoje video wygląda jak każde inne → **CTR < 2%** (vs ~6-10% dla custom thumbnails).

### Custom thumbnail — wymagania techniczne
- **Wymiar:** 1280×720 px (16:9), JPG/PNG, max 2MB.
- **Czytelność w 320×180:** YT pokazuje miniaturki bardzo małe — sprawdź czytelność na telefonie.
- **Kontrast wysoki:** thumbnail musi się wybijać z feeda (ciemne tło → jasny tytuł / odwrotnie).

### Wzorzec dla kanału muzycznego

```
┌──────────────────────────────────────┐
│                                      │
│   [TYTUŁ DUŻYMI LITERAMI]      [DH]  │ ← genre signal w rogu
│   [Subtitle / mood]                  │
│                                      │
│   [Visual hook — sunset / city /     │
│    waveform na cinematic photo]      │
│                                      │
└──────────────────────────────────────┘
```

**Co używać jako visual hook:**
- **Sunset / nature** — dla sunset / dreamy / chillout tracków (Far Far Away, Old Love)
- **Kosmos / gwiazdy** — dla cosmic tracków (Lunar Harmony, The Journey)
- **City / metro / neon** — dla urban tracków (Time To Speed Up)
- **Latte / café** — dla café/lounge (Fantastic World)
- **Woda / mgła** — dla water/introspection (Deep Water)

### Spójność serii (compound branding)
Wszystkie thumbnaile w tej samej serii (np. `Sunset Series`) powinny mieć **ten sam layout**, ten sam font, te same kolory marki. Tylko zmiana zdjęcia tła + tytułu. **Widz rozpoznaje serię w 0.2s** = wyższy CTR.

### Tools
- **Canva** (free) — szablony YouTube thumbnail, drag & drop.
- **Figma** (free) — bardziej zaawansowane.
- **Photopea** (free, online Photoshop) — pełna kontrola.

### Quick win
Wykorzystaj **artworky z SoundCloud** (3000×3000) — przekonwertuj do 16:9 przez:
1. Rozszerzenie tła (gradient extend w Photopea/Figma).
2. Dodaj overlay z tytułem (lewy/górny lub centralnie).
3. Genre badge w prawym górnym rogu (`DEEP HOUSE`, `AMBIENT`, `MIX`).

---

## 3. Tytuł — optimal format

YouTube wyświetla **~60 znaków** w wyszukiwarce (sidebar tnie wcześniej). Reguły:

1. **Najważniejszy keyword na początku** (lewa strona = top SEO weight).
2. **Brand / artist name na końcu** lub osobno (nie na początku).
3. **Bez ALL CAPS** (filtr clickbait).
4. **Bez asterisków, ★, emoji w tytule** (chyba że bardzo świadomie).
5. **Liczby konkretne** (`#01`, `2026`) zwiększają CTR.

### Wzorzec dla pojedynczych utworów
```
[Track Title] — [Genre/Subgenre] [Mood Tag] [Year]
```

Przykłady:
- `Far Far Away — Dreamy Sunset Deep House (2026)`
- `Better Me — Melodic Deep House Instrumental [2026]`
- `Deep Water — Atmospheric Deep House (Extended Mix 2026)`

### Wzorzec dla mixów
```
[Genre] Mix — [Mood/Setting] [Year] | [Artist or Series #NN]
```

Przykłady:
- `Melodic Deep House Mix — Sunset Vibes 2026 | Maximum Music Maxx`
- `Summer Deep House Mix #07 — Summertime Melody MAX`

### Wzorzec dla long-tail / use case
Łapie wyszukania "music for X":
- `Deep House for Focus & Work — Instrumental 1 Hour Mix [2026]`
- `Ambient Music for Sleep — Lunar Harmony [Deep Pads + Synth]`
- `Cosmic Deep House for Studying — Anjunadeep Style Mix`

---

## 4. Description — szablon (bilingual PL/EN)

**Pierwsze 150 znaków = krytyczne** (pokazują się w wyszukiwarce + embed preview). Tutaj wsadź hook + najmocniejsze keywordy + link do innej platformy.

### Master template

```
[Title] — [PL hook z keywordami, 1-2 zdania].

🎧 Listen on:
🟠 SoundCloud — https://soundcloud.com/maximummusicmaxx
🔵 hearthis.at — https://hearthis.at/maximummusic

—————————————————

📀 ABOUT THIS TRACK

[Pełen PL opis — mood, użytkowanie, klimat]

Jeśli kochasz [niche genre], [broad genre] i klimat [Artist 1, Artist 2]
— ten utwór jest dla Ciebie.

—————————————————

📀 ABOUT THIS TRACK (English)

[Full EN description — mood, use case, vibe]

Perfect if you love [niche genre], [broad genre] and the vibes of
[Artist 1, Artist 2].

—————————————————

🎵 TIMESTAMPS:
00:00 Intro
00:30 Main melody enters
01:45 Bridge
02:20 Outro

—————————————————

🎵 MORE FROM MAXIMUM MUSIC MAXX
👉 Subscribe: https://www.youtube.com/@MaximumMusicMaxx?sub_confirmation=1
👉 Full catalogue (268 tracks): https://hearthis.at/maximummusic
👉 Curated singles: https://soundcloud.com/maximummusicmaxx

—————————————————

🎬 Video made with FL Studio ZGameEditor Visualizer plugin

Effect author credits:
• HUD 3D — Rado1
• TextTrueType — Ville
• Youlean Drop Shadow — Youlean
• Blooming — Jph Wacheski (http://jph_wacheski.itch.io/)

—————————————————

#deephouse #melodicdeephouse #instrumental #focusmusic #studymusic
#deephouse2026 #instrumentalmusic #chillmusic #relaxingmusic
```

### Dlaczego ta struktura
- **Hook + linki** w pierwszych 150 znakach → widoczne wszędzie, traffic do innych platform.
- **Bilingual PL/EN** → łapie polskie + globalne wyszukania.
- **Timestamps** → YouTube auto-wykrywa format `MM:SS Title`, tworzy chaptery.
- **CTA Subscribe** z parametrem `?sub_confirmation=1` → popup zamiast strony.
- **Hashtagi na końcu** → YT wyświetla **pierwsze 3** nad tytułem video (bonus visibility).
- **Effect credits** → license compliance (zob. sekcja 12).

---

## 5. Chapters / timestamps

YouTube **bardzo lubi** chapters — wydłużają watch time + tworzą "key moments" w timeline (widoczne w wyszukiwarce). Nawet dla 3-min utworu, dodaj 3-5 chapters.

### Wymagania
1. **Pierwszy chapter MUSI być `00:00`** — bez tego YT nie utworzy chapters.
2. **Min. 3 chapters**.
3. **Min. 10 sek między chapters**.
4. Format: `MM:SS Title` lub `HH:MM:SS Title` dla długich.

### Przykład dla 3-min utworu
```
🎵 TIMESTAMPS:
00:00 Intro
00:30 Main melody enters
01:30 Bridge / breakdown
02:10 Drop
02:40 Outro
```

### Przykład dla 60-min mixu
```
🎵 TRACKLIST:
00:00 Intro
01:20 Lunar Harmony 2026
05:40 Far Far Away
10:15 Old Love Will Not Be Forgotten
15:30 Let's Talk About Music (sunny version)
21:00 Fantastic World (No More Coffee)
27:45 The Journey In the Time and Space
35:10 Deep Water (Extended Mix)
44:20 Time To Speed Up (Long Version)
54:00 Outro
```

Każdy track w mixie = osobny **keyword** w timeline + osobny **searchable moment**.

---

## 6. Playlists kanału (compound effect)

YouTube playlisty:
- **Rankują osobno** w wyszukiwarce (np. `melodic deep house playlist` to inna fraza niż `melodic deep house`).
- **Autoplay** → ktoś klika 1 video → leci 5-10 z kolei → masywny boost session time.
- **Profilowane przez YT** do rekomendacji.

### Wzorzec dla muzycznego kanału

Każdy upload **dodaj do co najmniej 2 playlist**:
1. Główna gatunkowa (np. `Melodic Deep House`).
2. Mood-series (np. `Sunset Series`).

### Rekomendowana struktura playlist dla `Maximum Music Maxx`

| Playlist | Zawartość | Cel |
|---|---|---|
| `Melodic Deep House — All Tracks` | Wszystkie deep house tracki | Główny gatunek, szeroka pula |
| `Ambient & Cinematic` | Lunar Harmony i pochodne | Focus / sleep / sync |
| `Sunset Series` | Old Love, Far Far Away, Let's Talk About Music | Sunset DJ-e, lato/jesień |
| `Cosmic Series` | Lunar Harmony, The Journey | Stargazing, zima |
| `Urban / Night Series` | Lunar Harmony, Time To Speed Up | Night drive, club |
| `Water / Introspection Series` | Deep Water | Late night, contemplation |
| `Café & Lounge Series` | Fantastic World | Sync, lounge |
| `Summer Mix Series` | Summertime Melody MAX 01-07+ | Summer, compound effect |
| `Extended / DJ Mixes` | Deep Water Ext, Time To Speed Up Long, Summertime mixes | DJ-friendly |
| `Best of 2026` | Wszystkie świeże tegoroczne | "Co nowego" |
| `Best of Maximum Music — Start Here` | Top 10 z całego katalogu | Onboarding nowych subskrybentów |

**Każdy nowy upload = +1 do compound effect** w 2-3 playlistach.

---

## 7. End screen + cards

### End screen (ostatnie 20 sekund video)
W Studio → Editor → End screen → dodaj 4 elementy:
1. **Subscribe button** (zawsze)
2. **Best for viewer** (auto-suggest od YT)
3. **Specific video** — następny utwór z tej samej serii
4. **Playlist** — mood-series

### Cards (w trakcie video)
2-3 cards rozsianych w trakcie video, linkujących do:
- innego utworu (mood-related)
- playlisty serii
- subskrypcji kanału

Cards są **mniej widoczne** niż end screen (mała ikona `i` w rogu), ale niski-koszt high-reward.

---

## 8. Pinned comment

Po publikacji od razu **przypnij własny komentarz**:

```
🎧 Listen on other platforms:
🟠 SoundCloud: https://soundcloud.com/maximummusicmaxx
🔵 hearthis.at (268 tracks): https://hearthis.at/maximummusic

💬 What does this track make you feel? Drop a comment 👇
```

**Dlaczego:**
- Komentarze (twoje + odpowiedzi) = **silny signal engagement**.
- Twój pinned comment dostaje top spot pod video → naturalny CTA do innych platform.
- Pytanie na końcu zachęca innych do komentowania.

---

## 9. YouTube Shorts jako feeder

**Shorts mają osobny algorytm** i **bardzo wysoki organic reach** (często 10-100× więcej views niż long-form na nowych kanałach).

### Workflow dla muzycznego kanału
1. Z każdego long-form video wytnij **15-30 sek najmocniejszy moment** (drop, hook, melodyjna fraza).
2. Dodaj **visual** — sunset timelapse, neon city, water reflection, etc. (matching mood).
3. Upload jako Shorts.
4. **W opisie Shorts'a:** `Full track: https://www.youtube.com/watch?v=[ID]`

### Efekt
- 1 long video + 3-5 Shorts feeders = **wielokrotny zasięg**.
- Każdy Short → 1-3% widzów klika do długiego video.
- Compound: 10 Shortsów = +30-50% views na main video.

---

## 10. Tags (Studio backend)

YouTube zmienił wagę tagów — teraz **NLP na title + description ważniejszy**. Tagi służą głównie do **disambiguation** (np. odróżnić "deep house" od "deep sea house").

### Best practice
- Max **500 znaków łącznie**, ~10-15 tagów.
- **Pierwszy tag = najważniejszy** (główny keyword).
- Ostatnie 2-3 = **brand tags** (artist name, track title).

### Wzorzec
```
deep house, melodic deep house, instrumental deep house, deep house 2026, instrumental music, focus music, study music, chill music, relaxing music, lane 8 style, ben böhmer style, [artist name], [track title], [series name]
```

---

## 11. Closed Captions (CC)

YouTube **indeksuje CC dla SEO** — nawet dla muzyki instrumentalnej.

### Dla instrumentalu
Wrzuć "sound description" CC:
```
[00:00] [Soft synth pads]
[00:30] [Bass enters]
[00:45] [Main melody — piano]
[01:30] [Atmospheric breakdown]
[02:00] [Drop — full mix]
[02:40] [Outro]
```

### Korzyści
- SEO (Google indeksuje CC).
- Accessibility (deaf/HoH audience).
- Watch time (widzowie z głośnikami wyłączonymi).

---

## 12. Plugin / Effect credits (license compliance)

### Dlaczego to ważne
Większość darmowych VSDC pluginów (Rado1, Ville, Youlean, itd.) ma **licencję free dla użytku publicznego pod warunkiem atrybucji**. Brak credit = naruszenie licencji.

### Gdzie wkleić — 3 opcje (rekomendacja: A)

**Opcja A — w opisie YouTube (rekomendowana, wystarczająca)**
Wydzielona sekcja `🎬 EFFECT CREDITS` na końcu opisu, przed hashtagami.

**Opcja B — end card + opis**
Dla extra-safe: dodaj planszę "Credits" w ostatnich 5-10 sek video + duplikat w opisie.

**Opcja C — pinned comment**
Słaba opcja (komentarze można skasować) — nie rekomenduję jako jedynego miejsca.

### Template do wklejenia

```
🎬 Video made with FL Studio ZGameEditor Visualizer plugin

Effect author credits:
• HUD 3D — Rado1
• TextTrueType — Ville
• Youlean Drop Shadow — Youlean
• Blooming — Jph Wacheski (http://jph_wacheski.itch.io/)
```

### Reguły uniwersalne
1. **Credits są PER-VIDEO, nie uniwersalne!** Każde video może używać **innego zestawu efektów** w ZGameEditor Visualizer. Lista credits musi odpowiadać **dokładnie tym efektom, które faktycznie użyłeś w TYM konkretnym video** — nie kopiuj ślepo jednego bloku wszędzie.
2. **Sprawdź dokładny tekst licencji** każdego efektu — niektóre wymagają konkretnej formy (np. linku do strony autora, jak Blooming → `http://jph_wacheski.itch.io/`).
3. **Prowadź notatnik per-efekt** — zapisz poprawną formę credit dla każdego efektu, którego używasz (z linkiem jeśli wymagany). Przy nowym video składasz blok z tych, które weszły do projektu.
4. Jeśli któryś autor wymaga linku, **zawsze go dodawaj** (Blooming/Jph Wacheski wymaga linku do itch.io).
5. **Sprawdź w ZGameEditor Visualizer** (FL Studio) listę aktywnych efektów w danym projekcie — to ona dyktuje, co wpisać w credits.

### Przykładowy blok (dla The Journey 2026 — 4 efekty)
> ⚠️ To jest **przykład dla konkretnego video**. Twoje inne video mają inny zestaw — dostosuj listę!

```
🎬 Video made with FL Studio ZGameEditor Visualizer plugin

Effect author credits:
• HUD 3D — Rado1
• TextTrueType — Ville
• Youlean Drop Shadow — Youlean
• Blooming — Jph Wacheski (http://jph_wacheski.itch.io/)
```

---

## 13. Case study: Better Me

URL: [youtube.com/watch?v=hb3lrCYbLFA](https://www.youtube.com/watch?v=hb3lrCYbLFA)

### Stan obecny (audyt)
| Element | Stan | Priorytet fix |
|---|---|---|
| **Thumbnail** | Auto-generowany visualizer (jak każdy upload) | 🔴 #1 |
| **Tytuł** | `Better Me *for...` — asterisk + obcięcie | 🔴 #2 |
| **Opis** | Nieznany w fetchu (najpewniej minimalistyczny) | 🟠 #3 |
| **Tagi** | Najpewniej brak | 🟡 |
| **Chapters** | Brak | 🟠 |
| **End screen / cards** | Najpewniej brak | 🟡 |
| **Playlisty kanału** | Nieznany stan | 🟠 |
| **Plugin credits** | Nieznany stan | 🟡 (compliance) |

### Fix #1 — Thumbnail (custom, nie auto)
Wymiar **1280×720**. Wykorzystaj któryś z artworków z SC/hearthis (np. dla "Better Me" — sunset, fields, dreamy) + overlay z tytułem + genre badge `DEEP HOUSE`.

### Fix #2 — Tytuł
Aktualnie: `Better Me *for...` (obcięty, asterisk)

**Rekomendacja** (zakładając full title `Better Me *for you`):
```
Better Me (For You) — Melodic Deep House Instrumental [2026]
```

**Alternatywy:**
- `Melodic Deep House — Better Me (For You) | Instrumental Mix 2026`
- `Better Me — Relaxing Deep House for Focus, Work & Sleep [Instrumental 2026]`

> **Wymaga input'u:** pełen tytuł po asterisku (Better Me *for ...?). Wpisz dosłownie.

### Fix #3 — Description (gotowy do wklejenia)

```
Better Me (For You) — instrumentalny melodic deep house do skupienia,
pracy, nauki i relaksu. Muzyka Maximum Music Maxx z Warszawy.

🎧 Listen on:
🟠 SoundCloud — https://soundcloud.com/maximummusicmaxx
🔵 hearthis.at — https://hearthis.at/maximummusic

—————————————————

📀 ABOUT THIS TRACK

Melodyjny, ciepły instrumental w klimacie deep house — soundtrack
dla focus playlist, długich popołudni i spokojnych wieczorów.

Jeśli kochasz melodic deep house, instrumental electronic
i klimat Lane 8, Yotto, Tycho — ten utwór jest dla Ciebie.

—————————————————

📀 ABOUT THIS TRACK (English)

Better Me (For You) — an instrumental melodic deep house track
for focus, work, study and relaxation. A warm, melodic soundtrack
for long afternoons and peaceful evenings.

Perfect if you love melodic deep house, instrumental electronic
and the vibes of Lane 8, Yotto and Tycho.

—————————————————

🎵 TIMESTAMPS:
00:00 Intro
00:30 Main melody enters
01:45 Bridge
02:20 Outro

—————————————————

🎵 MORE FROM MAXIMUM MUSIC MAXX
👉 Subscribe: https://www.youtube.com/@MaximumMusicMaxx?sub_confirmation=1
👉 Full catalogue (268 tracks): https://hearthis.at/maximummusic
👉 Curated singles: https://soundcloud.com/maximummusicmaxx

—————————————————

🎬 Video made with FL Studio ZGameEditor Visualizer plugin

Effect author credits:
• HUD 3D — Rado1
• TextTrueType — Ville
• Youlean Drop Shadow — Youlean
• Blooming — Jph Wacheski (http://jph_wacheski.itch.io/)

—————————————————

#deephouse #melodicdeephouse #instrumental #focusmusic #studymusic
#deephouse2026 #instrumentalmusic #chillmusic #relaxingmusic
```

### Tags
```
deep house, melodic deep house, instrumental deep house, deep house 2026, instrumental music, focus music, study music, chill music, relaxing music, deep house instrumental, lane 8 style, ben böhmer style, maximum music maxx, better me, melodic house
```

### Playlists — dodaj do
- `Melodic Deep House — All Tracks`
- `Best of 2026`
- (opcjonalnie) mood-series: jeśli `Better Me` to sunset/focus/water — dodaj do odpowiedniej

### Pinned comment
Wklej template z sekcji 8.

### End screen
- Subscribe button
- Best for viewer (auto)
- Specific video: `Far Far Away` lub inny matching mood
- Playlist: `Melodic Deep House`

---

## 14. Master checklist YouTube SEO

Dla **każdego nowego uploadu**:

- [ ] **Thumbnail** — custom 1280×720, spójny z serią
- [ ] **Tytuł** — keyword na początku, ≤60 znaków, bez asterisków/emoji
- [ ] **Opis** — wklej z template (sekcja 4), zawsze bilingual
- [ ] **Pierwsze 150 znaków opisu** — hook + linki do SC/hearthis
- [ ] **Timestamps** — min. 3, pierwszy `00:00`
- [ ] **Tags** — 10-15 (sekcja 10)
- [ ] **Playlists** — dodaj do co najmniej 2 (gatunek + mood-series)
- [ ] **End screen** — subscribe + video + playlist
- [ ] **Cards** — 2-3 w trakcie video
- [ ] **Pinned comment** — multiplatform linktree (sekcja 8)
- [ ] **Effect credits** — w opisie (sekcja 12)
- [ ] **Closed Captions** — sound description (sekcja 11)
- [ ] **Shorts feeder** — 15-30 sek z najmocniejszego momentu

---

## 15. Strategiczne pozycjonowanie YouTube w ekosystemie 4 platform

| Platforma | Główna rola | Audience | Algorithm strengths |
|---|---|---|---|
| **hearthis.at** | Pełne archiwum (268 tracków) | DJ-skie, niemieckojęzyczne community | Weak — polega na external traffic |
| **SoundCloud** | Curated singles (6 best-of) | Indie artists + sync libraries | Algorytm playlist editorial + DJ promo |
| **YouTube** | Long-tail SEO przez Google + wideo discovery | Globalna, focus / study / sync potential | **Najsilniejszy algorytm** + Google indexing |
| **(Dystrybucja)** | Spotify / Apple Music | Mass market | Wymaga DistroKid/AWAL — osobny budget |

### Dlaczego YouTube ma największy long-term potential
1. **Google indexing** — YouTube videos rankują w Google search results.
2. **Auto-play radio** — YouTube Mix dobiera Twoje utwory do podobnych → nieograniczony reach.
3. **Sync placements** — filmowcy szukają muzyki tła **najczęściej przez YT**, nie SC.
4. **Compound thumbnails** — spójna seria miniatur = rozpoznawalna marka.
5. **Shorts boost** — kanały muzyczne często rosną szybciej przez Shorts niż long-form.

### Sekwencja release'u dla nowego utworu (4-platform workflow)
1. **hearthis.at** — natychmiastowy upload (full archive).
2. **SoundCloud** — jeśli to "best of" candidate, wrzuć z pełnym opisem.
3. **YouTube** — wrzuć z custom thumbnail + pełnym opisem + chapters + playlistami.
4. **Shorts** — 1-2 dni później, 15-30 sek feeder do YT main.
5. **Cross-link** — w opisie każdej platformy linki do pozostałych 3.

---

## 16. Common mistakes (na muzycznych kanałach YT)

1. **Auto-generated thumbnail** — najczęstszy błąd. Wszystkie kanały z auto wygląda identycznie.
2. **Tytuł bez keyword'u** — np. tylko `Better Me *for...`. Trzeba dodać gatunek.
3. **Pusty opis** lub tylko link do platformy — traci się SEO + sync potential.
4. **Brak chapters** — krótkie watch time, brak key moments.
5. **Brak playlist** — każde video żyje osobno, brak compound effect.
6. **Inkonsystencja brand'u** — różne fonty, różne layouty thumbnaili w kolejnych video.
7. **Brak Shorts** — gigantyczny niewykorzystany kanał reach.
8. **Brak plugin credits** — naruszenie licencji + ryzyko strike'u na kanał.
9. **Ten sam opis copy-paste bez wariantów** — algorytm wykrywa duplikaty, obniża ranking.
10. **Brak end screen** — traci session time = traci ranking.

---

## Źródła

- [YouTube Creator Academy — Music Channel Best Practices](https://creatoracademy.youtube.com/)
- [VidIQ — YouTube SEO Guide 2026](https://vidiq.com/blog/post/youtube-seo/)
- [TubeBuddy — Thumbnail Best Practices](https://www.tubebuddy.com/)
- [YouTube Help — Add chapters to your videos](https://support.google.com/youtube/answer/9884579)
- [YouTube Help — End screens and cards](https://support.google.com/youtube/answer/2812802)
- [Youlean — Free Plugins (license info)](https://youlean.co/)
- [VSDC Effects authors community — Rado1, Ville](https://www.videosoftdev.com/)
- [Backlinko — YouTube SEO Study 2025](https://backlinko.com/youtube-ranking-factors)
- [Beats by Pao — YouTube for music producers](https://www.beatsbypao.com/)
