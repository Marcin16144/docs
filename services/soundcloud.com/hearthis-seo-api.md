# hearthis.at — SEO + integracja API

> **TL;DR:** hearthis.at ≠ SoundCloud. To **mniejsza, niszowa platforma** zorientowana na DJ-skie miksy i edity. API jest **głównie do odczytu — bez publicznego endpointu uploadu**. Discovery wewnętrzne jest słabe, więc strategia SEO opiera się bardziej na **external traffic + niche positioning** niż na algorytmie platformy.
>
> **Dwa scenariusze użycia:**
> - **Nowy artysta** → używaj jako secondary/mirror, główna platforma to SC.
> - **Artysta z istniejącym katalogiem 100+ utworów na hearthis.at** (jak `maximummusic` z 268 tracków) → **odwróć logikę**: hearthis.at jako archiwum/lab, SC jako kuracja best-of. Patrz sekcja 10.

---

## 1. Czym jest hearthis.at (kontekst strategiczny)

| Cecha | hearthis.at | SoundCloud |
|---|---|---|
| Założenie | 2011, Niemcy | 2007, Niemcy/Szwecja |
| Główna nisha | **DJ mixy, edity, sety** | Indie artists, single, mainstream |
| Free upload | 400 MB/tydzień, MP3 only | 3h total, MP3/WAV |
| Pro cena | **€4/mc lub €33/rok** | $12+/mc (Pro Unlimited) |
| Pro formaty | FLAC, WAV, AIF, M4A, AAC, OGG, WMA | Pełne |
| Limit długości utworu | **Brak** (idealne dla 2h+ mixów) | Pro: brak; Free: ograniczony |
| Społeczność (2026) | ~10× mniejsza niż SC | Duża, globalna |
| Discovery wewnętrzne | **Słabe** — feed mocno spamowany "share to download" | Lepsze, algorytm + playlisty |
| Public API | Read-only (feed, tracks, artists, playlists) | OAuth 2.1, pełne CRUD |
| Public upload API | **NIE MA** | TAK (`POST /tracks`) |
| Mobile experience | Słaby | Dobry (native apps) |
| Reliability streamingu | Dobra | Dobra |

**Werdykt strategiczny:**
- **Nie używaj jako platformy podstawowej** dla nowych artystów.
- **Używaj jako secondary/mirror** — backup catalogue, alternative URL dla fanów wolących nie-SC.
- **Idealne dla**: DJ-skich setów (60-120 min), edits/bootlegs, długich form niedopuszczanych przez SC, jako "hosting" do promocji przez Facebook/Twitter.

---

## 2. SEO na hearthis.at — co działa, co nie

### Co działa
1. **External traffic > internal discovery** — link z bloga, Facebook, Twitter ma większy zwrot niż optymalizacja pod feed.
2. **Niche genre tags** — disco edits, DJ mixy mają długi tail. Bardzo niszowe gatunki (np. `italo edits`, `cosmic disco`, `nu disco edits`) konwertują lepiej niż mainstream.
3. **Long-form content** — 60-120 min DJ mixy mają większe szanse niż 3-min single (przeciwnie niż SC). Słuchacze są tu po sety, nie po pojedyncze tracki.
4. **Title + description w opisach** — robi się tutaj **w sposób klasyczny SEO** (Google indeksuje strony tracków), więc tytuł z keywordami się opłaca.
5. **Embed na własnej stronie** — odtwarzacz hearthis.at jest lekki i Google dobrze indeksuje strony z embedem.

### Co nie działa
1. **Spam tagami** — feed jest zaszumiony przez "share to download", więc tagi gubią się w hałasie.
2. **Liczenie na "Trending" / "Recommended"** — autor 5 Magazine wprost mówi: "być HearThis Superstar to nic nie znaczy".
3. **Strategia z SoundCloud 1:1** — to nie zadziała. SC ma algorytm. hearthis.at ma głównie feed + search.
4. **Częste publikowanie** — algorytm cię nie nagrodzi tak jak SC. Raczej **rzadziej + jakość**.

### Konkretne taktyki SEO

#### Tytuł utworu / mixa
- **DJ mix** → format: `[Artist Name] — [Series/Show Name] #[XX] (Genre, BPM, Month YYYY)`
   Przykład: `Maximum Music Maxx — Sunset Sessions #04 (Melodic Deep House, 122 BPM, May 2026)`
- **Track single** → format: `[Track Title] — [Subgenre] [Year]`
   Przykład: `Far Far Away — Dreamy Sunset Deep House 2026`

#### Description (kluczowe — Google indeksuje!)
- Pierwsze 160 znaków = jak meta description w SEO. Tutaj wsadź najmocniejsze keywordy.
- **Tracklist z timestampami** w DJ mixie = potężny SEO (każdy artysta + utwór to oddzielne keywordy w treści strony).
- Linki zwrotne do własnej strony, Mixcloud, SC, Spotify, Instagram, e-mail bookingowy.
- Bilingual PL/EN — Niemcy są drugą po Polakach najliczniejszą grupą na hearthis.at, ale globalnie EN dominuje.

#### Tagi
- **Gatunek + podgatunek + nastrój + dekada + BPM** (np. `deep house, melodic deep house, sunset, 2020s, 122bpm`).
- Tagi DJ-skie: `dj mix`, `dj set`, `live recording`, `radio show`, `podcast`.
- Lokalne keywordy działają na hearthis.at lepiej niż na SC (społeczność EU): `berlin`, `ibiza`, `tulum`, `polska`.

#### Genre (pole oficjalne)
- hearthis.at ma większy katalog gatunków niż SC, **w tym "Disco Edits"** jako osobną kategorię — jeśli kiedykolwiek wrzucisz edit, to tutaj jego dom.
- Trzymaj się tych samych 3 bucketów co na SC dla spójności: `Deep House`, `House`, `Ambient`.

#### Artwork
- Min. 800×800, ale **na hearthis.at działa też custom background + slideshow** — wyróżnia stronę utworu.
- Spójna seria visualna z SC = łatwiejsze rozpoznanie przez fanów krzyżujących platformy.

#### Embed strategy (najmocniejsza karta)
- Osadź odtwarzacz hearthis.at na własnej stronie / blogu / Linktree.
- Google indeksuje stronę → strona linkuje hearthis.at → ruch + autorytet.
- Hearthis.at oferuje **native download button w embedzie** (różnica vs SC) — DJ-e to lubią.

---

## 3. Dostęp do API

### Co API oferuje (read-only)
- `GET feed` — pobieranie feeda z filtrami.
- `GET genres` + `GET tracks by genre`.
- `GET artist` (single + list).
- `GET track` (po URI).
- `POST track_like_unlike`, `POST artist_follow_unfollow`.
- `POST/DELETE playlist` (tworzenie, dodawanie, usuwanie tracków z playlisty — **wymaga sesji użytkownika**).

### Czego API NIE oferuje
- **Brak publicznego endpointu uploadu utworu**.
- **Brak publicznego endpointu update metadanych** (title, tags, description).
- Brak OAuth 2.x — uwierzytelnianie przez **email + hasło** w body requesta (basic, mniej bezpieczne).

### Autoryzacja
- Endpoint bazowy: `https://api-v2.hearthis.at/` (oficjalny API v2).
- Większość endpointów odczytowych — **bez autoryzacji**.
- Akcje wymagające sesji (like, follow, playlist) — login przez:
  ```json
  POST /login
  {
    "email": "user@example.com",
    "password": "..."
  }
  ```
  → response z session token / cookie.
- Brak rotacji tokenów, brak refresh. Sesje trzymane przez cookie.

### Praktyczne wnioski
1. **Automatyzacja uploadu = brak** w czystym sensie. Musisz wgrywać przez web UI.
2. **Workaround** — biblioteki typu Selenium / Playwright (browser automation) — szare strefy, ryzykujesz ban przy intensywnym użyciu.
3. **Read API** wystarczy do: stats tracking, monitor profilu, integracja z własną stroną (auto-feed na blogu), analiza konkurencji.

---

## 4. Upload utworu — przez web UI (skoro nie ma API)

Endpoint web: `https://hearthis.at/upload/`

**Krok po kroku:**
1. **Przygotuj plik** — clean filename (zasada slug-hygiene jak na SC). `far-far-away.wav` lepsze niż `Maximum Music Maxx - Far Far Away (Final v3).wav`.
2. **Drag & drop** lub `Choose file`.
3. **Pola do wypełnienia:**

| Pole | Uwagi |
|---|---|
| **Title** | Format SEO j.w. — gatunek + rok w tytule |
| **Description** | Bilingual PL/EN. Tracklist z timestampami dla mixów. Linki zwrotne. |
| **Tags** | Separator: przecinek. 5–10 tagów. Bez asterisków, czysto. |
| **Genre** | Wybór z listy. Trzymaj się 3 bucketów: Deep House / House / Ambient. |
| **Type** | `Track` / `Mix` / `Live Recording` / `Podcast` — wybieraj precyzyjnie. |
| **Cover image** | ≥ 800×800, JPG/PNG |
| **Background image** | Opcjonalne, customowy layout strony utworu |
| **Slideshow** | Opcjonalne, sekwencja obrazów synchronizowana z waveform |
| **Privacy** | `Public` / `Private` / `Unlisted` |
| **Downloadable** | Tak/Nie — DJ-skie tracki: warto włączyć |
| **License** | Default: All rights reserved |
| **Release date** | Manualne ustawienie |
| **Waveform style** | Soft / Digitized — drobiazg, ale wyróżnia |

4. **Save** → trafia na profil. Bez kolejki transkodowania jak na SC.

### Workaround dla masowego uploadu
- **Browser automation** (Playwright/Selenium) — sekwencyjne wypełnianie formularza.
- **Trzymaj nazwy plików w slug formie** + skrypt który czyta JSON z metadanymi i wpisuje w formularz.
- **Risk:** intensywna automatyzacja może wywołać captcha / blokadę konta.

---

## 5. Strategia mirror catalogue: SoundCloud → hearthis.at

> **Note:** ta sekcja zakłada, że SC jest Twoim main, a hearthis.at jest świeżym mirror'em. **Jeśli masz odwrotnie** (np. 200+ tracków na hearthis i kilka na SC) — przeczytaj najpierw **sekcję 10**, która opisuje odwróconą strategię.

Skoro nie da się uploadować przez API, mirror to **manualny proces** — ale wart roboty raz na zawsze.

### Workflow

1. **Pobierz oryginalne pliki audio** (master WAV/FLAC z DAW, nie streamowy MP3 z SC).
2. **Przygotuj clean filename** zgodnie z zasadą slug-hygiene.
3. **Przygotuj artwork** w wyższej rozdzielczości (3000×3000 jeśli masz, hearthis akceptuje).
4. **Skopiuj** bilingual opisy z SC case studies (mamy je gotowe w `soundcloud-seo-api.md`).
5. **Dostosuj** tagi do format hearthis (separator = przecinek, nie spacja w cudzysłowach).
6. **Crosslink** w opisie:
   ```
   🎵 Also on SoundCloud: https://soundcloud.com/maximummusicmaxx/[slug]
   ```
7. **Privacy: Public**, **License: All rights reserved**, **Downloadable: true** (DJ-e to lubią).

### Mapping katalogu Maximum Music Maxx na hearthis.at

| Utwór | Genre (hearthis) | Type | Specjalność hearthis |
|---|---|---|---|
| Lunar Harmony 2026 | Ambient | Track | Filmowcy + sync (mniej DJ-skie) |
| Old Love Will Not Be Forgotten | Deep House | Track | Sunset DJ-e lubią |
| Let's Talk About Music (sunny) | Deep House | Track | Tropical/summer DJ-e |
| Fantastic World (No More Coffee) | Deep House | Track | Lounge/café — sync target |
| The Journey In the Time and Space | Deep House | Track | Anjunadeep/Lane 8 słuchacze |
| Far Far Away | Deep House | Track | Sunset DJ-e + sync |

### Bonus — DJ mix tylko na hearthis.at
hearthis.at ma **przewagę nad SC dla długich mixów**. Stwórz 60-min mix:

`Maximum Music Maxx — Sunset Sessions #01 (Melodic Deep House Continuous Mix, May 2026)`

Tracklist:
1. Lunar Harmony 2026 (Intro)
2. Far Far Away
3. Old Love Will Not Be Forgotten
4. Let's Talk About Music (sunny version)
5. Fantastic World (No More Coffee)
6. The Journey In the Time and Space (Outro)

To **flagowy content** dla hearthis.at, którego nie wrzucisz na SC (limit czasu/jakości) — i powód, żeby fani Cię śledzili na obu platformach.

---

## 6. Bilingual description — szablon dla hearthis.at

```
[Track Title] — [PL hook z keywordami w 1-2 zdaniach]

Jeśli kochasz [gatunek niszowy] [gatunek szerszy] i klimaty [Artist 1, Artist 2]
— ten utwór jest dla Ciebie.

— — —

[Track Title] — [EN hook with keywords in 1-2 sentences]

Perfect if you love [niche genre] [broad genre] and the vibes of
[Artist 1, Artist 2].

🎧 [Use case]
🎵 Also on SoundCloud: https://soundcloud.com/maximummusicmaxx/[slug]
🌐 More: [your website if any]

#[tag1] #[tag2] #[tag3]
```

---

## 7. Promocja zewnętrzna (rdzeń strategii hearthis.at)

Skoro discovery wewnątrz platformy jest słabe, **promuj poza nią**:

1. **Facebook groups** — `Deep House Lovers`, `Melodic House & Techno`, lokalne grupy DJ-skie. hearthis.at jest dobrze przyjmowany w Niemczech, Holandii, Skandynawii.
2. **Reddit** — r/deephouse, r/edmproduction, r/MelodicHouseTechno. Link do hearthis vs SC może mieć przewagę (mniej "self-promo" stigma).
3. **Mixcloud crossover** — fani Mixcloud często słuchają też hearthis.at. Cross-post.
4. **DJ pools / promo lists** — Beatport curated, Bandcamp followers, własna newsletter list.
5. **Embed w blogowych recenzjach** — jeśli ktoś pisze o tracku, linkuj hearthis (lekkie embed, dobre dla bloga Google).

---

## 8. Checklist publikacji na hearthis.at

- [ ] **Slug hygiene** — clean nazwa pliku przed uploadem
- [ ] **Title** — format SEO (gatunek + rok)
- [ ] **Description** — bilingual PL/EN, 1-2 zdania hooka na początku, linki zwrotne, e-mail bookingowy
- [ ] **Tracklist z timestampami** (dla mixów)
- [ ] **Tags** — 5–10, separator przecinek, niche + broad mix
- [ ] **Genre** — z 3 bucketów (Deep House / House / Ambient)
- [ ] **Type** — Track / Mix / Live / Podcast (precyzyjnie!)
- [ ] **Cover** — ≥ 800×800, spójna z SC dla cross-platform branding
- [ ] **Privacy: Public**, **Downloadable: true**, **License: ARR**
- [ ] **Crosslink do SC** w opisie
- [ ] **Embed** na własnej stronie / blogu
- [ ] **Share** w Facebook groups + Reddit (niche subs)

---

## 9. TL;DR — kiedy używać hearthis.at

| Sytuacja | Werdykt |
|---|---|
| Główna platforma dla nowego artysty | ❌ Nie. SC ma większy zasięg. |
| Archiwum / lab dla istniejącego katalogu 100+ utworów | ✅ **Tak** (patrz sekcja 10) |
| Backup catalogue / świeży mirror | ✅ Tak. Pro €33/rok to nic. |
| Długie DJ mixy (60-120 min) | ✅ **Idealne**. SC tego nie udźwignie. |
| Disco edits / bootlegi | ✅ **Idealne**. Społeczność edits tu siedzi. |
| Automatyzacja uploadu | ❌ Nie. Brak API. Manualnie lub browser automation. |
| Stats / monitoring | ⚠️ Tylko basic, weź pod uwagę zewnętrzne narzędzia. |
| Sync placements pitching | ⚠️ Słabsze niż SC — sync libraries i tak biorą oryginalny WAV. |

---

## 10. Strategia gdy hearthis.at JEST main (katalog 200+ utworów)

Sytuacja Maximum Music Maxx: **268 utworów na hearthis.at vs 6 na SC**. To **odwraca standardową logikę** "SC main, hearthis mirror". Tutaj hearthis to archiwum/lab, a SC to kuracja flagowych singli.

### 10.1. Problem #1: Discovery przy dużym katalogu

268 utworów = nawigacyjny chaos. Słuchacz wchodzi w profil i widzi ścianę 268 tytułów. **Nie ma od czego zacząć** → opuszcza profil.

**Wskaźnik diagnostyczny:** liczba_followerów / liczba_tracków.
- < 5% = poważny problem discoverability (przypadek `maximummusic`: 26/268 ≈ 10%, granicznie OK ale jest praca).
- 5–20% = normalne dla niszowego producenta.
- > 20% = bardzo dobry conversion.

### 10.2. Fix: Playlists / Series strategy

Stwórz **5–8 playlist tematycznych** organizujących katalog według mood/series. Playlisty:
1. Są pierwszą rzeczą jaką widzi nowy słuchacz.
2. Dają natychmiastową ścieżkę "zacznij od X".
3. Rankują w SC search osobno od tracków.

**Proponowane playlisty dla `maximummusic` (do adaptacji do faktycznego katalogu 268 tracków):**

| Playlist (nazwa) | Zawartość | Cel |
|---|---|---|
| `Best of Maximum Music — Start Here` | Top 10 z całego katalogu | "Onboarding" nowych słuchaczy |
| `Sunset Series — Melodic Deep House` | Wszystkie sunset/dreamy tracki | Sunset DJ-e i fani Lane 8 |
| `Cosmic Series — Space & Stars` | Lunar Harmony, The Journey + kosmiczne | Anjunadeep, stargazing |
| `Café & Lounge Series` | Fantastic World + jazzy/lounge | Sync (HoReCa) + lounge DJ |
| `Sunny & Tropical Series` | Let's Talk About Music + summer | Letnie playlisty (V-VIII) |
| `Ambient & Cinematic Series` | Lunar Harmony i podobne | Focus / film score / sync |
| `Continuous DJ Mixes` | Wszystkie 60+ min mixy | DJ-skie sety, długie formy |
| `New 2026 Releases` | Tylko świeże tracki bieżącego roku | "Co nowego" — łatwe odświeżanie |

**Każdy nowy follower powinien w 30 sekund móc kliknąć "Sunset Series" zamiast scrollować 268 tracków.**

### 10.3. Problem #2: Bio profilu

Aktualny bio: "shares sounds on hearthis.at" — generic. Wstaw konkretne:

```
Maximum Music Maxx — Warsaw-based producer of instrumental
deep house & ambient. 268+ tracks across 6+ mood series.

🎧 Currently exploring: Sunset · Cosmic · Café · Lunar · Sunny · Dreamy
🌅 Start here: Best of Maximum Music playlist
🎵 Curated singles on SoundCloud: soundcloud.com/maximummusicmaxx
```

### 10.4. Problem #3: Outbound networking (Follow:Follower ratio)

`maximummusic` ma 26 followerów i obserwuje 26 — symetria 1:1. Na hearthis.at outbound network ma **wyższy zwrot niż na SC** (mniejsza społeczność, więcej reciprocity, niska "follow fatigue").

**Akcja w 7 dni:**
1. Wyszukaj `deep house`, `melodic deep house`, `ambient`, `chillout` w hearthis.at search.
2. Zidentyfikuj **50–100 producentów** z niszy (preferuj Niemcy, Polskę, Holandię, Skandynawię — geo-correlated bottom-up community).
3. Obserwuj ich (przyrost ~10/dziennie).
4. **30–40% odda follow w pierwszych 14 dniach** (typowy reciprocity rate na małych platformach).
5. Po 3 tygodniach: 26 → 60–80 followerów bez żadnej innej akcji.

### 10.5. Cross-platform reversal: SC jako kuracja

Skoro masz 268 tracków na hearthis.at, **SC powinien być selekcją "best of"** — nie odwrotnie.

**Mapping:**
- **hearthis.at** = pełne archiwum, lab, eksperymenty, długie mixy, edits → wszystko co tworzysz.
- **SoundCloud** = top 10–20 utworów wybranych pod kątem playlist editorial / sync potential / DJ promo.

Z 268 tracków wybierz **kolejne 10–15** najlepszych pod kątem:
- Klarowności gatunkowej (3-bucket rule: Deep House / House / Ambient).
- Sezonowości (które utwory mają potencjał w odpowiednim oknie 2026).
- Sync potential (cinematic, café, sunset — łapią placements).
- Spójność wizualnych mood-series (Sunset, Cosmic, etc.).

I wrzuć je na SC z pełnymi opisami z naszego `soundcloud-seo-api.md` — masz tam już framework.

### 10.6. Czek-lista odwróconej strategii

- [ ] Stwórz 5–8 playlist tematycznych na hearthis.at (10.2)
- [ ] Wypełnij bio profilu (10.3)
- [ ] Wybierz 10–15 utworów do "promocji" na SC z 268 (10.5)
- [ ] Outbound follow 50–100 producentów w 7 dni (10.4)
- [ ] Dodaj playlistę `Best of` jako pinned/featured na profilu
- [ ] Cross-link w opisach: hearthis ↔ SC

---

## 11. Case study: Far Far Away na hearthis.at

URL: [hearthis.at/maximummusic/far-far-away](https://hearthis.at/maximummusic/far-far-away/)

### Stan obecny (audyt)

| Pole | Wartość | Status |
|---|---|---|
| Tytuł | `Far Far Away — Dreamy Sunset Deep House (2026)` | ✅ Wdrożona rekomendacja z SC doc |
| Slug | `far-far-away` | ✅ Clean (slug hygiene wdrożone) |
| Genre | `Deep House` | ✅ Zgodne z 3-bucket rule |
| BPM | `119` | ✅ Wpisane |
| Key | `G` (major) | ✅ Wpisane, pasuje do "dreamy" |
| Duration | `3:46` | OK |
| Cover | Spójny z SC | ✅ Cross-platform branding |
| Downloadable | Yes | ✅ DJ-e to lubią |
| Type | Track | ✅ |
| **Tags** | **`Deep House, Deep House`** (zduplikowany!) | ❌ **Krytyczny brak** |
| Description | Niewidoczny w fetch | ⚠️ Wypełnij wg sekcji poniżej |

### Najpilniejsze fixy

**1. Tagi — wklej zamiast `Deep House, Deep House`:**

```
deep house, dreamy deep house, sunset deep house, melodic deep house, cinematic deep house, sunset music, instrumental, dreamy, deep house 2026, melodic
```

Separator na hearthis to **przecinek** (nie cudzysłowy z SC).

**2. Description — wklej bilingual z crosslinkiem do SC:**

```
Far Far Away — instrumentalny dreamy / sunset deep house o miejscach,
które istnieją tylko na horyzoncie. Miękkie pady, dalekie melodie,
głęboki bas i miarowy puls — soundtrack dla samotnych spacerów wzdłuż
brzegu, wieczornych jazd nad morze i wszystkich momentów,
w których chcesz być gdzie indziej, daleko stąd.

Jeśli kochasz dreamy deep house, sunset deep house, cinematic house
i klimat Lane 8, Yotto, Eli & Fur — ten utwór jest dla Ciebie.

— — —

Far Far Away — an instrumental dreamy / sunset deep house track about
places that exist only on the horizon. Soft pads, distant melodies,
deep bass and a steady pulse — a soundtrack for solo walks along
the shore, evening drives to the sea and any moment when you want
to be somewhere else, far away from here.

Perfect if you love dreamy deep house, sunset deep house, cinematic house
and the vibes of Lane 8, Yotto, Eli & Fur.

🌅 Best at golden hour, on headphones
🎵 Also on SoundCloud: https://soundcloud.com/maximummusicmaxx/far-far-away
#dreamydeephouse #sunsetdeephouse #cinematichouse #melodicdeephouse #escapism
```

**3. Add to playlist `Sunset Series — Melodic Deep House`** (utwórz jeśli nie istnieje).

### Porównanie: ten sam utwór na SC vs hearthis.at

| Aspekt | SC (planowane) | hearthis.at (obecne) |
|---|---|---|
| Tytuł | `Far Far Away — Dreamy Sunset Deep House (2026)` | ✅ Już to samo |
| Slug | `far-far-away` (do fix po update) | ✅ Już clean |
| Genre | Deep House | Deep House |
| Tagi (separator) | `"frazy" w cudzysłowach`, oddzielone spacjami | `tagi, oddzielone, przecinkami` |
| Description | Bilingual + crosslink do hearthis | Bilingual + crosslink do SC |
| Public API upload | TAK (`POST /tracks`) | ❌ Brak — manual |
| Algorytm wsparcia | Tak (pierwsze 24-48h kluczowe) | Słaby, polega na external traffic |
| Sync potential | Bardziej widoczny | Mniejszy, ale sync libraries i tak biorą WAV |

### Insight z porównania

1. **Tytuł, slug, BPM, key, downloadable — wszystko wdrożone już na hearthis przed pojawieniem się rekomendacji SC.** Doc'y konwergują w stronę tej samej dobrej praktyki.
2. **Tagi to największa pojedyncza luka cross-platform** — na obu platformach przy fresh uploadzie domyślnie tagi są minimalne (`Deep House, Deep House` na hearthis = `[puste]` na SC). Implementacja pełnego tag string'a = natychmiastowy boost.
3. **Format tagów się różni** — SC chce frazy w cudzysłowach (`"sunset deep house"`), hearthis chce przecinki (`sunset deep house, melodic deep house`). Trzymaj w notatniku oba formaty obok siebie.

---

## Źródła

- [hearthis.at — main](https://hearthis.at/)
- [hearthis.at — upload page](https://hearthis.at/upload/)
- [hearthis.at — API v2 (redirect to RapidAPI)](https://hearthis.at/api-v2/)
- [RapidAPI — hearthis.at](https://rapidapi.com/hearthisat/api/hearthis-at)
- [GitHub — python-hearthis (unofficial library)](https://github.com/jinchuuriki91/python-hearthis)
- [GitHub topic — hearthisat-api](https://github.com/topics/hearthisat-api)
- [Appmus — hearthis.at vs SoundCloud comparison](https://appmus.com/vs/hearthis-at-vs-soundcloud)
- [SaaSHub — SoundCloud vs hearthis.at](https://www.saashub.com/compare-soundcloud-vs-hearthis-at)
- [ExtremRaym — hearthis.at as SoundCloud alternative](https://www.extremraym.com/en/hearthis-at-soundcloud-alternative/)
- [5 Magazine — what happened to the "Soundcloud Killer"](https://5mag.net/features/dj-streaming-sites/hearthis-soundcloud-alternatives/)
- [IONOS — SoundCloud alternatives for musicians](https://www.ionos.com/digitalguide/online-marketing/online-sales/soundcloud-alternatives-for-music-marketing/)
- [Beats by Pao — SoundCloud alternatives](https://www.beatsbypao.com/l/soundcloud-alternatives-where-to-go-with-your-music-if-soundcloud-dies-one-day/)
