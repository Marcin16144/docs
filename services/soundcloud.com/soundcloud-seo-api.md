# SoundCloud — SEO + integracja API

## 1. SEO na SoundCloud — praktyczne wskazówki

### Tytuł utworu
- Włącz słowo kluczowe + gatunek + rok, np. `Summer Deep House Mix 2026` zamiast samego `Track 03`.
- Unikaj śmieciowych znaków (`★`, `►`) — utrudniają indeksowanie wewnątrz SC i w Google.
- Format `Artist Name – Track Title` poprawia rozpoznawalność i działa lepiej w wyszukiwarce SC.

### Tagi (kluczowe!)
- **5–7 trafnych tagów** daje średnio ~35% więcej organicznych odtworzeń niż brak tagów.
- Mieszaj poziomy szczegółowości: szeroki (`techno`) + niszowy (`melodic techno`, `peak time techno`).
- Dodawaj tagi: gatunek, podgatunek, nastrój (`chill`, `energetic`), instrument (`piano`, `808`), kontekst (`workout`, `lofi study`), BPM.
- Tagi wielowyrazowe owijaj w cudzysłów: `"deep house"`, żeby SC traktował je jako jedną frazę.
- **Nie spamuj** popularnymi tagami bez związku — algorytm degraduje takie ścieżki.

### Opis (description)
- Pierwsze 1–2 zdania = haczyk + najważniejsze słowa kluczowe (ten fragment widać w podglądach i wynikach wyszukiwania).
- Wpleć 3–5 hashtagów naturalnie w tekst, nie listą na końcu — daje wyższe CTR.
- Dodaj linki do innych profili (kolaboracje), własnej strony, Spotify, Bandcamp — backlinki podbijają autorytet profilu.
- Tracklisty z timestampami (`00:00 Intro / 03:45 …`) — wydłużają session time = sygnał jakości dla algorytmu.

### Profil
- **Display name** = artystyczne imię + ewentualnie gatunek (`DJ Nova – House`).
- **Permalink/URL** (`soundcloud.com/twoja-nazwa`) — krótki, z keywordami, bez cyfr.
- **Bio**: lokalizacja, gatunek, kontakt, linki (Instagram, YouTube, e-mail bookingowy).
- Awatar + header w wysokiej rozdzielczości (min. 1240×260 dla nagłówka, 1000×1000 dla awatara).
- Spójna **artwork** (3000×3000, JPG/PNG, min. 800×800) — wpływa na CTR w feedzie i playlistach.

### Algorytm (co się liczy)
- **Pierwsze 24–48 h** — odtworzenia, like'i, reposty i komentarze w tym okienku decydują, czy algorytm zacznie cię polecać.
- Wskaźnik **completion rate** (czy słuchacze dotrwali do końca) — krótsze utwory bywają tu w lepszej pozycji.
- Repost-chain — repostowanie cudzych ścieżek skłania innych do odwzajemnienia (zwiększa zasięg).
- Regularność: 1 utwór tygodniowo > nieregularne wrzutki.
- Playlisty z własnymi + cudzymi tracks wydłużają czas sesji i pojawiają się jako osobny rezultat w wyszukiwaniu.

### SEO zewnętrzne
- Osadzaj odtwarzacz SC na własnej stronie i blogu (oEmbed) — zwrotne linki ze stron HTML pomagają Google indeksować profil.
- Dodaj profil SoundCloud do `sameAs` w JSON-LD `MusicGroup` na własnej stronie — wzmacnia Knowledge Graph.

---

## 2. Dostęp do API

- Wymagane konto **Artist Pro** (płatne).
- Rejestracja aplikacji: [soundcloud.com/you/apps](https://soundcloud.com/you/apps) → otrzymujesz `client_id` + `client_secret`.
- SoundCloud okresowo zamyka nowe rejestracje aplikacji — jeśli formularz jest wyłączony, można dalej używać **oEmbed** (publiczne osadzanie, bez kluczy).
- **API jest non-commercial** — komercyjne case'y (np. odsprzedaż streamingu, generowanie ścieżek z konta klienta jako usługa) wymagają osobnej umowy z SC.

---

## 3. Autoryzacja (OAuth 2.1 + PKCE)

Token wygasa po ~1 h, refresh token jest **jednorazowego użytku**.

### Flow użytkownika (Authorization Code + PKCE)
```
https://secure.soundcloud.com/authorize
  ?client_id=YOUR_CLIENT_ID
  &redirect_uri=YOUR_REDIRECT_URI
  &response_type=code
  &code_challenge=CODE_CHALLENGE
  &code_challenge_method=S256
  &state=STATE
```

Wymiana kodu na token:
```bash
curl -X POST "https://secure.soundcloud.com/oauth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=authorization_code" \
  --data-urlencode "client_id=..." \
  --data-urlencode "client_secret=..." \
  --data-urlencode "redirect_uri=..." \
  --data-urlencode "code_verifier=..." \
  --data-urlencode "code=..."
```

### Client Credentials (tylko publiczne zasoby, bez uploadu)
```bash
curl -X POST "https://secure.soundcloud.com/oauth/token" \
  -H "Authorization: Basic <base64(client_id:client_secret)>" \
  --data-urlencode "grant_type=client_credentials"
```

### Refresh
```bash
curl -X POST "https://secure.soundcloud.com/oauth/token" \
  --data-urlencode "grant_type=refresh_token" \
  --data-urlencode "client_id=..." \
  --data-urlencode "client_secret=..." \
  --data-urlencode "refresh_token=..."
```

---

## 4. Upload utworu

**Endpoint:** `POST https://api.soundcloud.com/tracks`
**Header:** `Authorization: OAuth ACCESS_TOKEN`
**Content-Type:** `multipart/form-data`
**Formaty:** AIFF, WAVE, FLAC, OGG, MP2, MP3, AAC, AMR, WMA
**Limity:** max 4 GB / 24 h audio na utwór.

### Minimalny upload
```bash
curl -X POST "https://api.soundcloud.com/tracks" \
  -H "Authorization: OAuth ACCESS_TOKEN" \
  -F "track[title]=Summer Deep House 2026" \
  -F "track[asset_data]=@/path/to/track.wav"
```

### Pełny upload z metadanymi (rekomendowane)
```bash
curl -X POST "https://api.soundcloud.com/tracks" \
  -H "Authorization: OAuth ACCESS_TOKEN" \
  -F "track[title]=Summer Deep House 2026" \
  -F "track[asset_data]=@track.wav" \
  -F "track[artwork_data]=@cover.jpg" \
  -F "track[description]=Melodic deep house single, mastered at -8 LUFS..." \
  -F 'track[tag_list]=house "deep house" melodic chill summer 2026' \
  -F "track[genre]=Deep House" \
  -F "track[sharing]=public" \
  -F "track[downloadable]=false" \
  -F "track[license]=all-rights-reserved" \
  -F "track[commentable]=true"
```

Uwaga: **tag_list** to jeden string oddzielony spacjami; tagi wielowyrazowe w cudzysłowach.

Po sukcesie utwór trafia do kolejki transkodowania (AAC do streamingu). Plik audio jest **niemodyfikowalny** po uploadzie — możesz później aktualizować tylko metadane i artwork.

---

## 5. Aktualizacja metadanych

**Endpoint:** `PUT https://api.soundcloud.com/tracks/{track_id}`

### JSON (bez plików)
```bash
curl -X PUT "https://api.soundcloud.com/tracks/123456789" \
  -H "Authorization: OAuth ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "track": {
      "title": "Nowy tytuł",
      "description": "Zaktualizowany opis...",
      "tag_list": "house \"deep house\" remix",
      "genre": "Deep House",
      "sharing": "public"
    }
  }'
```

### Multipart (z nowym artworkiem)
```bash
curl -X PUT "https://api.soundcloud.com/tracks/123456789" \
  -H "Authorization: OAuth ACCESS_TOKEN" \
  -F "track[title]=Nowy tytuł" \
  -F "track[artwork_data]=@new-cover.jpg"
```

### Najważniejsze pola obiektu Track

| Pole | Opis |
|---|---|
| `track[title]` | Tytuł (wymagany przy upload) |
| `track[asset_data]` | Plik audio (wymagany przy upload) |
| `track[description]` | Opis — kluczowy dla SEO |
| `track[tag_list]` | Tagi, oddzielone spacjami, wielowyrazowe w `"..."` |
| `track[genre]` | Gatunek (jedno pole tekstowe) |
| `track[sharing]` | `public` / `private` |
| `track[downloadable]` | `true` / `false` |
| `track[license]` | np. `all-rights-reserved`, `cc-by`, `cc-by-nc`… |
| `track[artwork_data]` | Okładka (≥800×800, JPG/PNG) |
| `track[commentable]` | Czy można komentować |
| `track[label_name]` | Wytwórnia |
| `track[release_date]` | Data wydania |
| `track[isrc]` | Kod ISRC (do rozliczeń z DSP) |
| `track[bpm]` | BPM |
| `track[key_signature]` | Tonacja |

### Usuwanie
```bash
curl -X DELETE "https://api.soundcloud.com/tracks/123456789" \
  -H "Authorization: OAuth ACCESS_TOKEN"
```

---

## 6. Wzorzec uploadu w Node.js (przykład)

```javascript
import fs from 'node:fs';
import FormData from 'form-data';
import fetch from 'node-fetch';

async function uploadTrack(accessToken, audioPath, artworkPath, meta) {
  const form = new FormData();
  form.append('track[title]', meta.title);
  form.append('track[description]', meta.description);
  form.append('track[tag_list]', meta.tags.map(t =>
    t.includes(' ') ? `"${t}"` : t
  ).join(' '));
  form.append('track[genre]', meta.genre);
  form.append('track[sharing]', 'public');
  form.append('track[asset_data]', fs.createReadStream(audioPath));
  if (artworkPath) {
    form.append('track[artwork_data]', fs.createReadStream(artworkPath));
  }

  const res = await fetch('https://api.soundcloud.com/tracks', {
    method: 'POST',
    headers: { Authorization: `OAuth ${accessToken}` },
    body: form,
  });
  if (!res.ok) throw new Error(`Upload failed: ${res.status} ${await res.text()}`);
  return res.json();
}
```

---

## 7. Rate limits i higiena integracji

- Trzymaj `client_secret` po stronie serwera, nigdy w frontendzie.
- Zapisuj refresh token w bezpiecznym magazynie (refresh = jednorazowy → zapisuj nową wartość po każdej wymianie).
- Przy uploadach masowych — kolejka + backoff na 429.
- Logging na poziomie endpointu (upload + transcode status) — transkodowanie jest asynchroniczne; status sprawdzasz przez `GET /tracks/:id` (`state: processing | finished | failed`).

---

## 8. Case study: Lunar Harmony 2026

Pełna aplikacja powyższych zasad do realnego utworu:
[soundcloud.com/maximummusicmaxx/lunar-harmony-2026](https://soundcloud.com/maximummusicmaxx/lunar-harmony-2026)

### Charakterystyka utworu
- **Gatunek:** ambient electronic
- **BPM:** 125
- **Typ:** instrumental
- **Artwork:** nocna panorama miasta z neonami odbijającymi się w wodzie
- **Stan początkowy:** opis **pusty**, brak struktury tagów

### Tytuł — rekomendacja

Zostaw `Lunar Harmony 2026` lub wzmocnij:

- `Lunar Harmony 2026 — Ambient Electronic` ✅ (najlepszy SEO)
- `Lunar Harmony 2026 (Atmospheric Instrumental)`

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Lunar Harmony 2026 — instrumentalny utwór ambient electronic w 125 BPM.
Miękkie syntezatory, atmosferyczne pady i miarowy puls nocnego miasta —
soundtrack do pracy, jazdy po zmroku, medytacji i głębokiego skupienia.

Jeśli lubisz cinematic ambient, chillwave, atmospheric electronic
i downtempo z lekkim pulsem — ten utwór jest dla Ciebie.

— — —

Lunar Harmony 2026 — an instrumental ambient electronic track at 125 BPM.
Warm synths, atmospheric pads and the steady pulse of a city at night —
a soundtrack for focus, late night drives, meditation and deep work.

Perfect if you're into cinematic ambient, chillwave, atmospheric electronic
and pulsing downtempo.

🎧 Best on headphones
🌙 Follow for more nightscape soundscapes
💬 Drop a comment with a timestamp where the track hits you most

#ambient #cinematic #chillwave #nightdrive #atmospheric

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
ambient "ambient electronic" "cinematic ambient" chillwave atmospheric "night music" downtempo instrumental "ambient 2026"
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `ambient` | szeroki, łapie globalne wyszukania |
| `"ambient electronic"` | celne dopasowanie (125 BPM + ambient) |
| `"cinematic ambient"` | niszowy, mocno konwertujący — łapie filmowców |
| `chillwave` | spina się z neonową okładką nocnego miasta |
| `atmospheric` | uniwersalny mood tag |
| `"night music"` | long-tail z Google ("music for night") |
| `downtempo` | łapie wyszukania DJ-skie + playlisty |
| `instrumental` | filtr "no vocals" |
| `"ambient 2026"` | aktualność = wyższe miejsce w sortowaniu nowości |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Ambient` |
| BPM | `125` |
| Key signature | wpisz tonację (typowo minor: `Am`, `Dm`, `F#m`) |
| Sharing | `public` |
| Downloadable | `true` (łapie tag "free download") lub `false` jeśli release komercyjny |
| License | `all-rights-reserved` lub `cc-by-nc` |
| Commentable | `true` |
| Release date | rzeczywista data 2026 |
| Label name | `Maximum Music` (lub własna) |

### Plan pierwszych 48 godzin

1. **Playlista** — `Night Vibes 2026 — Ambient Electronic`, "Lunar Harmony 2026" na pozycji 2-3 (najwyższy completion rate).
2. **Repost** — prośba do 2-3 znajomych producentów ambient z większą publiką.
3. **Pinned comment** od autora z timestampem najlepszego momentu — zachęca innych do dodawania własnych.
4. **Cross-post** — Instagram Story/Reels z 15-sek fragmentem + tag SC + link w bio.
5. **Embed** — iframe SC w poście blogowym z keywordami `ambient electronic 125 BPM` w meta description.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 minut i wyszukaj w SC:
- `"ambient electronic 2026"`
- `"cinematic ambient"`
- `"lunar harmony"`

Utwór powinien pojawiać się w wynikach. Jeśli nie — sprawdź czy `sharing` jest `public` i czy tagi zostały zapisane (czasem SC wymaga ponownego edit + save).

---

## 9. Case study: Old Love Will Not Be Forgotten

Drugi utwór z katalogu — z innym mood'em i innym pozycjonowaniem:
[soundcloud.com/maximummusicmaxx/old-love-will-not-be-forgotten-new-version](https://soundcloud.com/maximummusicmaxx/old-love-will-not-be-forgotten-new-version)

### Charakterystyka utworu
- **Gatunek:** melodic / sunset deep house
- **BPM:** typowo 120–124 (uzupełnij dokładnie)
- **Typ:** instrumental
- **Artwork:** tropikalny zachód słońca, palma w sylwetce, refleksy na wodzie
- **Stan początkowy:** opis pusty, brak struktury tagów, `(new version)` w tytule bez kontekstu
- **Mocna karta:** tytuł + okładka mówią tym samym językiem co Ibiza sunset deep house scene (Lane 8, Yotto, Cafe del Mar)

### Tytuł — rekomendacja

**Najmocniejszy SEO:**
```
Old Love Will Not Be Forgotten — Melodic Deep House (2026)
```

**Alternatywy:**
- `Old Love Will Not Be Forgotten (Sunset Deep House Mix)`
- `Old Love Will Not Be Forgotten — Emotional Deep House 2026`
- `Old Love Will Not Be Forgotten (2026 Mix)` — jeśli chcesz zachować ideę "nowej wersji"

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Old Love Will Not Be Forgotten — instrumentalny melodic deep house
o miłości, której wspomnienie wraca z każdym zachodem słońca.
Ciepłe pady, miękkie akordy fortepianu, głęboki bas i puls czterech-na-cztery
— soundtrack dla zachodów słońca, długich jazd wybrzeżem i wieczornych setów.

Odświeżona wersja jednej z moich osobistych kompozycji,
inspirowana klimatem Ibizy, terrace sunsetów i nocy nad ciepłym morzem.

Jeśli lubisz melodic deep house, sunset house, emotional house
i klimaty Lane 8, Yotto, Tinlicker — ten utwór jest dla Ciebie.

— — —

Old Love Will Not Be Forgotten — an instrumental melodic deep house track
about a love whose memory returns with every sunset. Warm pads, soft piano
chords, deep bass and a steady four-on-the-floor pulse — a soundtrack for
sunsets, long coastal drives and evening sets.

A refreshed version of one of my personal compositions, inspired by
the spirit of Ibiza, terrace sunsets and warm summer nights.

Perfect if you love melodic deep house, sunset house, emotional house
and the vibes of Lane 8, Yotto and Tinlicker.

🎧 Best at golden hour, on a good system
🌅 Follow for more sunset deep house
💬 Drop a comment with the moment that hits you most

#deephouse #melodichouse #sunsethouse #emotionalhouse #ibiza

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
"deep house" "melodic deep house" "sunset house" "emotional deep house" "ibiza deep house" instrumental melodic "deep house 2026" cinematic
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"deep house"` | szeroki, najwyższy wolumen wyszukań |
| `"melodic deep house"` | mocno konwertujący, playlisty redaktorskie używają tej frazy |
| `"sunset house"` | dosłowne odbicie okładki — silna synergia wizualna |
| `"emotional deep house"` | spina z tytułem o utraconej miłości |
| `"ibiza deep house"` | location-based, duży ruch turystyczny + DJ |
| `instrumental` | filtr "no vocals" |
| `melodic` | uniwersalny mood + dla playlist |
| `"deep house 2026"` | aktualność = wyższe miejsce w sortowaniu nowości |
| `cinematic` | otwiera sync placements (filmy, reklamy) |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (lub `House` dla catalogue consistency — trzymamy się 3 bucketów: Deep House / House / Ambient) |
| BPM | wpisz dokładnie z DAW (typowo 120–124) |
| Key signature | typowe dla emotional deep house: `Am`, `Cm`, `Dm`, `F#m`, `Gm` |
| Sharing | `public` |
| Downloadable | `true` (silny sygnał + DJ pobierają) lub `false` jeśli release komercyjny |
| License | `all-rights-reserved` (otwiera sync placements) |
| Commentable | `true` |
| Release date | rzeczywista 2026 |
| Label name | `Maximum Music` |
| ISRC | wpisz jeśli masz z dystrybucji |

### Bonus — "(new version)" jako atut

1. **Crosslink z oryginałem** — w opisie dodaj:
   ```
   🎵 Original version: https://soundcloud.com/maximummusicmaxx/[slug-oryginału]
   ```
2. **Playlist "Versions & Mixes"** — oryginał + nowa wersja + alt mixy w jednej playliście.
3. **Pinned comment**: `"2026 reimagining of one of my personal tracks — original here: [link]. Which version hits you more?"` — generuje porównania i komentarze.

### Plan pierwszych 48 godzin

1. **Playlista** `Sunset Deep House 2026 — Melodic Vibes` — Twój utwór na pozycji 2-3, plus 4–6 cudzych melodic deep house tracks.
2. **DJ promo** — prywatne linki do 3–5 DJ-ów grających melodic deep house (Instagram/TikTok DM).
3. **Repost chain** — 2–3 znajomych producentów w pierwszej dobie.
4. **Cross-post Instagram Reels / TikTok** — 15-sek loop najmocniejszego dropu + visual zachodu słońca + tag SC + link w bio.
5. **Submit do playlist** — SubmitHub / Groover / Playlist Push w kategorii deep house / sunset chillout.
6. **Pinned comment** z timestampem najmocniejszego momentu.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"melodic deep house 2026"`
- `"sunset deep house"`
- `"emotional deep house"`
- `"old love will not be forgotten"`

Utwór powinien pojawiać się w wynikach.

### Porównanie strategii: Lunar Harmony 2026 vs Old Love Will Not Be Forgotten

| Aspekt | Lunar Harmony 2026 | Old Love Will Not Be Forgotten |
|---|---|---|
| Gatunek | Ambient electronic | Melodic deep house |
| BPM | 125 (ambient z pulsem) | 120–124 (4/4 deep house) |
| Mood | Nocne miasto, neon, kosmos | Zachód słońca, Ibiza, nostalgia |
| Główny tag SEO | `"ambient electronic"` | `"melodic deep house"` |
| Tag pod okładkę | `"night music"` | `"sunset house"` |
| Tag emocjonalny | `cinematic` | `"emotional deep house"` |
| Główna grupa docelowa | Słuchacze focus/work, filmowcy | DJ-e, słuchacze sunset/Ibiza |
| Kanał promocji | Embed na blogu + playlisty focus | DJ promo + sunset Reels/TikTok |

---

## 10. Case study: Let's Talk About Music (sunny version)

Trzeci utwór z katalogu — deep house z letnim, "sunny" twist'em:
[soundcloud.com/maximummusicmaxx/lets-talk-about-music-sunny-version](https://soundcloud.com/maximummusicmaxx/lets-talk-about-music-sunny-version)

### Charakterystyka utworu
- **Gatunek:** sunny tropical / summer deep house
- **BPM:** typowo 100–124 (uzupełnij dokładnie)
- **Typ:** instrumental
- **Artwork:** sylwetka kobiety na plaży o zachodzie słońca, ciepłe pomarańcze
- **Stan początkowy:** opis pusty, brak struktury tagów, tytuł abstrakcyjny bez gatunku
- **Mocna karta:** słowo "sunny" w tytule = wprost zaproszenie dla letnich playlist; cover (plaża + sunset + sylwetka) — uniwersalny match dla summer/holiday/romance kategorii
- **Drugi tropop:** to już druga wersja w katalogu z sufiksem (`new version`, `sunny version`) — wzorzec wariantowości do wykorzystania w brandingu

### Tytuł — rekomendacja

**Najmocniejszy SEO:**
```
Let's Talk About Music — Tropical Deep House (Sunny Version 2026)
```

Gatunek + sygnatura wersji + rok = trzy mocne keywordy w jednym tytule.

**Alternatywy:**
- `Let's Talk About Music (Sunny Summer Mix 2026)`
- `Let's Talk About Music (Sunny Beach Mix)`

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Let's Talk About Music (sunny version) — instrumentalny tropical / deep house
o letniej radości, plażach i tej rozmowie, która zaczyna się od jednej melodii.
Ciepłe akordy, marimba w tle, miarowy puls i światło popołudnia nad morzem.

Sunny version to lżejsza, jaśniejsza aranżacja mojego utworu —
gotowa do letnich playlist, podróży i wieczornych spotkań na plaży.

Jeśli kochasz tropical house, summer deep house, sunny chillout
i klimat Kygo, Robin Schulz, Sam Feldt — ten utwór jest dla Ciebie.

— — —

Let's Talk About Music (sunny version) — an instrumental tropical / deep house
track about summer joy, beaches and that conversation that starts with
a single melody. Warm chords, marimba, a steady pulse and afternoon light
over the sea.

The sunny version is the brighter, lighter arrangement of my track —
ready for summer playlists, road trips and beachside evenings.

Perfect if you love tropical house, summer deep house, sunny chillout
and the vibes of Kygo, Robin Schulz, Sam Feldt.

🌞 Best on a sunny afternoon
🏖️ Follow for more summer instrumentals
💬 Drop a comment with where this track takes you

#tropicalhouse #summerhouse #sunnyvibes #deephouse #beachmusic

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
"tropical house" "summer house" "sunny vibes" "deep house" "summer deep house" "beach music" instrumental melodic "tropical house 2026"
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"tropical house"` | główny gatunkowy, wysoki wolumen |
| `"summer house"` | sezonowy, ogromne playlisty letnie |
| `"sunny vibes"` | dosłowne odbicie z tytułu — silny match |
| `"deep house"` | spina z resztą katalogu, dużo ruchu |
| `"summer deep house"` | niszowy, mocno konwertujący w sezonie |
| `"beach music"` | spina z okładką (kobieta na plaży) |
| `instrumental` | filtr "no vocals" |
| `melodic` | uniwersalny mood, playlisty redaktorskie |
| `"tropical house 2026"` | aktualność |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (alt: `House` — trzymamy się 3 bucketów katalogu; "tropical" robią tagi) |
| BPM | wpisz z DAW (tropical/deep house typowo 100–124) |
| Key signature | dla "sunny" zwykle major: `C`, `D`, `F`, `G`, `A` |
| Sharing | `public` |
| Downloadable | `true` (DJ pobierają — silny sygnał) |
| License | `all-rights-reserved` |
| Commentable | `true` |
| Release date | rzeczywista 2026, najlepiej maj–sierpień (sezon "summer music") |
| Label name | `Maximum Music` |

### Strategia "wariantów" — wzorzec dla całego katalogu

To już drugi utwór z sufiksem wersji (`new version` w *Old Love*, `sunny version` tutaj). Wykorzystaj to świadomie:

1. **Crosslink z "non-sunny" wersją** (jeśli istnieje) — dodaj na końcu opisu:
   ```
   🌙 Chill / original version: https://soundcloud.com/maximummusicmaxx/[slug]
   ```
2. **Playlist "Versions & Mixes"** — wszystkie wersje + ich oryginały. Playlisty rankują osobno w SC search.
3. **Branding "versions" w bio profilu** — np. *"I release my tracks in moods: sunny, sunset, lunar, rainy. Pick yours."* — buduje tożsamość artystyczną.

### Plan pierwszych 48 godzin

1. **Playlista** `Sunny Summer 2026 — Tropical Deep House` — Twój utwór na pozycji 2-3 + 4–6 cudzych.
2. **DJ promo** — sunset/beach DJ-e (sceny Ibiza, Mykonos, Tulum).
3. **Cross-post Instagram Reels / TikTok** — 15-sek loop dropu + visual plaży/słońca. **Godziny 16-19 CET** — szczyt myślenia o lecie.
4. **Repost chain** — 2–3 znajomych producentów.
5. **Pitch do playlist** — SubmitHub / Groover w kategoriach summer / tropical / chillout.
6. **Pinned comment**: zaproszenie do dyskusji o muzyce (spina z tytułem!) + timestamp najlepszego momentu.
7. **Sezonowy boost** — wrzucaj w okolicach long weekendów i startu sezonu festiwalowego.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"tropical house 2026"`
- `"sunny vibes"`
- `"summer deep house"`
- `"let's talk about music"`

### Porównanie strategii: wszystkie trzy utwory

| Aspekt | Lunar Harmony 2026 | Old Love Will Not Be Forgotten | Let's Talk About Music (sunny) |
|---|---|---|---|
| Gatunek | Ambient electronic | Melodic deep house | Sunny tropical / summer deep house |
| BPM | 125 | 120–124 | 100–124 |
| Mood | Nocne miasto, neon, kosmos | Zachód słońca, Ibiza, nostalgia | Plaża, lato, radość |
| Cover | Skyline nocą + neon | Tropikalny sunset + palma | Sylwetka kobiety na plaży |
| Główny tag SEO | `"ambient electronic"` | `"melodic deep house"` | `"tropical house"` / `"summer house"` |
| Tag pod okładkę | `"night music"` | `"sunset house"` | `"beach music"` |
| Tag mood | `cinematic` | `"emotional deep house"` | `"sunny vibes"` |
| Tonacja | minor (`Am`, `Dm`) | minor (`Am`, `Cm`) | **major** (`C`, `D`, `F`, `G`) |
| Główna grupa docelowa | Focus / work / filmowcy | DJ-e sunset / Ibiza | Letnie playlisty / festiwale / sezon |
| Sezonowość | Całoroczny | Lato + jesień (sunset vibes) | **Stricte letni** (maj–sierpień) |
| Kanał promocji | Embed + playlisty focus | DJ promo + sunset Reels | Reels/TikTok + summer playlists |
| Nazewnictwo wersji | `2026` w tytule | `(new version)` → poprawić na `(2026 Mix)` | `(sunny version)` ✅ trzymać |

### Insight z trzech case study

1. **Konsekwencja sezonowo-emocjonalnego brandingu** — Twój katalog układa się w "moods": lunar (noc), sunset (nostalgia), sunny (lato). To **silna karta** dla profilu. Rozważ uzupełnienie biogramu o ten wzorzec — fani będą szukać kolejnych "wersji".
2. **Tonacje pasują do mood'u** — minor dla emocjonalnych/nocnych, major dla sunny. Wpisuj zawsze pole `Key signature` — to małe pole z dużym znaczeniem dla wyszukiwań DJ-skich i sample producentów.
3. **Tagi sezonowe są warte złota w odpowiednim oknie** — `summer house`, `sunny vibes` w maju-sierpniu, `sunset house` przez cały rok, `night music` zimą. Rotuj tagami jeśli sezon się zmienia, a utwór nadal ma potencjał.
4. **Wszystkie 3 utwory mają ten sam fix #1**: pusty opis → bilingual PL/EN z hookiem + keywordami + linkami + CTA. To natychmiastowy boost przy zerowym koszcie.

---

## 11. Case study: Fantastic World (No More Coffee)

Czwarty utwór z katalogu — jazzy / café downtempo, rozszerzenie deep house w stronę lounge:
[soundcloud.com/maximummusicmaxx/fantastic-world-no-more-coffee](https://soundcloud.com/maximummusicmaxx/fantastic-world-no-more-coffee)

### Charakterystyka utworu
- **Gatunek:** jazzy / café deep house (downtempo / swing, **nie** 4/4)
- **BPM:** typowo 80–110 (uzupełnij dokładnie)
- **Typ:** instrumental
- **Artwork:** close-up cappuccino z latte art (heart pattern) w czarnej filiżance, ciepłe brązy
- **Stan początkowy:** opis pusty, tytuł z asteryskami (`*no more coffee`), bez gatunku
- **Mocna karta:** cover to wzorcowy visual dla café/lounge music — gigantyczna nisha sync (restauracje, hotele, butiki, retail)
- **Słaba karta:** `*no more coffee` z asteryskami źle indeksuje się w SC search → poprawić na nawias

### Tytuł — rekomendacja

**Najmocniejszy SEO:**
```
Fantastic World (No More Coffee) — Jazzy Café Lounge (2026)
```

Gatunek + setting + rok. Asterisk znika, żart broni się w nawiasie.

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Fantastic World (No More Coffee) — instrumentalny, jazzy café downtempo
o tym poranku, kiedy świat wygląda dobrze sam z siebie.
Ciepłe akordy fortepianu, miękki bas, swing'ujący groove
i atmosfera kawiarni przy oknie z deszczem.

Soundtrack dla café, hotelowego lobby, leniwego niedzielnego śniadania
i każdego miejsca, w którym czas zwalnia.

Jeśli kochasz jazzy house, café lounge, nu-jazz, downtempo
i klimat St Germain, Jazzanova, Nicola Conte, Hotel Costes, Buddha Bar
— ten utwór jest dla Ciebie.

— — —

Fantastic World (No More Coffee) — an instrumental jazzy café downtempo
about that morning when the world looks just fine on its own.
Warm piano chords, soft bass, a swinging groove and the atmosphere
of a café by a rainy window.

A soundtrack for cafés, hotel lobbies, lazy Sunday breakfasts
and any place where time slows down.

Perfect if you love jazzy house, café lounge, nu-jazz, downtempo
and the vibes of St Germain, Jazzanova, Nicola Conte, Hotel Costes
and Buddha Bar.

☕ Best with a cup of something warm
🎷 Follow for more jazzy café music
💬 Where would you play this?

#jazzyhouse #cafemusic #lounge #nujazz #downtempo

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
"jazzy house" "café music" lounge "jazzy deep house" "nu jazz" downtempo instrumental "café lounge" "lounge 2026" jazzy
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"jazzy house"` | główny gatunkowy, mocny ruch w niszy |
| `"café music"` | dosłownie z okładki + ogromne playlisty |
| `lounge` | klasyczny tag dla tego klimatu, dużo curated playlist |
| `"jazzy deep house"` | spina z resztą katalogu |
| `"nu jazz"` | niszowy, konwertujący do wyrafinowanej publiki |
| `downtempo` | sygnatura rytmiczna — brak 4/4 |
| `instrumental` | filtr "no vocals" |
| `"café lounge"` | playlist tag, hotelowy/restauracyjny ruch |
| `"lounge 2026"` | aktualność |
| `jazzy` | uniwersalny mood |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (catalogue consistency — "jazzy / lounge / café" robią tagi, nie Genre) |
| BPM | typowo 80–110 (wpisz z DAW) |
| Key signature | jazzowo: minor 7th są częste — `Am`, `Dm`, `Em`, `Cm` |
| Sharing | `public` |
| Downloadable | `true` (DJ-e lounge pobierają do setów hotelowych/café) |
| License | `all-rights-reserved` — **kluczowe**, café music ma ogromny rynek sync |
| Commentable | `true` |
| Release date | rzeczywista 2026 |
| Label name | `Maximum Music` |

### Plan pierwszych 48 godzin

1. **Playlista** `Café Lounge 2026 — Jazzy Downtempo` — Twój utwór poz. 2-3.
2. **Sync potential** — biblioteki Musicbed, Marmoset, Audiosocket, mniejsze sync agencje. Café music to gigantyczna nisha sync (restauracje, hotele, butiki, retail).
3. **Submit do lounge curators** — playlisty stylu Hotel Costes / Buddha Bar / Café del Mar (Spotify + SC). SubmitHub w kategorii "lounge / nu-jazz".
4. **Café / boutique hotel pitching** — lokalne kawiarnie/butiki, oferuj utwór za kredyt i link na ich social.
5. **Cross-post Instagram Reels** — 15-sek loop + visual kawiarni / latte art / deszczu za oknem (matching café aesthetic).
6. **Pinned comment**: "What are you drinking right now? ☕🍷🍵" — proste, działające zaangażowanie.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"jazzy house"`
- `"café music"`
- `"lounge 2026"`
- `"fantastic world"`

### Porównanie strategii: wszystkie cztery utwory

| Aspekt | Lunar Harmony 2026 | Old Love Will Not Be Forgotten | Let's Talk About Music (sunny) | Fantastic World (No More Coffee) |
|---|---|---|---|---|
| Gatunek | Ambient electronic | Melodic deep house | Sunny tropical / summer deep house | Jazzy café downtempo deep house |
| BPM | 125 | 120–124 | 100–124 | **80–110** (downtempo) |
| Puls | Pulsujący ambient | 4/4 deep house | 4/4 deep house | **Swing / broken beat** |
| Mood | Nocne miasto, neon, kosmos | Zachód słońca, Ibiza, nostalgia | Plaża, lato, radość | Kawiarnia, leniwy poranek, jazz |
| Cover | Skyline nocą + neon | Tropikalny sunset + palma | Sylwetka kobiety na plaży | Latte art w czarnej filiżance |
| Główny tag SEO | `"ambient electronic"` | `"melodic deep house"` | `"tropical house"` / `"summer house"` | `"jazzy house"` / `"café music"` |
| Tag pod okładkę | `"night music"` | `"sunset house"` | `"beach music"` | `"café music"` / `"café lounge"` |
| Tag mood | `cinematic` | `"emotional deep house"` | `"sunny vibes"` | `"nu jazz"` / `jazzy` |
| Tonacja | minor | minor | **major** | minor 7th (jazz) |
| Grupa docelowa | Focus / work / filmowcy | DJ-e sunset / Ibiza | Letnie playlisty / festiwale | **Sync (HoReCa)** + lounge DJ |
| Sezonowość | Całoroczny | Lato + jesień | Stricte letni (V–VIII) | **Całoroczny + jesień/zima** |
| Kanał promocji | Embed + playlisty focus | DJ promo + sunset Reels | Reels/TikTok + summer playlists | **Sync libraries + café/hotel pitching** |
| Nazewnictwo | `2026` ✅ | `(new version)` → popraw | `(sunny version)` ✅ | `*no more coffee` → popraw na `(No More Coffee)` |

### Insight rozszerzony (4 utwory)

1. **Katalog rozpięty po 3 osiach gatunkowych z jednym DNA:** ambient (chłodno-kosmiczny) → deep house (Ibiza/sunset emocjonalny) → tropical deep house (letni) → jazzy café deep house (lounge/sync). Wszystkie spina **melodyjność** i **instrumentalność**. To **bardzo zdrowy spread** dla artysty — różne pory roku, różne playlist categories, różne źródła przychodu (streaming + sync).
2. **Sync jako osobna ścieżka monetyzacji** — *Fantastic World* i *Lunar Harmony* są najmocniejszymi kandydatami do sync placements (cafe music + cinematic ambient). Rozważ osobną stronę z portfolio sync (jednorazowo Linktree lub mała strona z embeddami SC + opisami "perfect for X scene").
3. **Wzorzec nazewnictwa wersji** już istnieje (`new version`, `sunny version`, `no more coffee` jako parenthetical) — **wykorzystaj świadomie**. Bio profilu: *"Instrumental music in moods: lunar, sunset, sunny, café. Pick yours."*
4. **Asterisk w tytułach (`*no more coffee`)** — SC search nie radzi sobie z znakami specjalnymi. Wszędzie zamieniaj na nawiasy: `(No More Coffee)`. Stosuj zasadę dla całego przyszłego katalogu.
5. **Fix #1 dalej obowiązuje** — wszystkie 4 utwory miały opis pusty. To wciąż największa pojedyncza luka SEO.
6. **Strategia pola Genre — 3 buckety dla całego katalogu:** `Deep House` / `House` / `Ambient`. Granularność (`jazzy house`, `tropical house`, `melodic deep house`, `sunset house`, `nu jazz`, `cinematic ambient`, `progressive deep house`) robią **tagi**, nie pole Genre. Korzyści: (a) statystyki profilu układają się czytelnie w 3 kategorie, (b) algorytm SC ma jasny sygnał, w której niszy Cię klasyfikować, (c) playlisty redaktorskie SC w tych 3 bucketach mają największe zasięgi. Mapping:
   - `Ambient` → *Lunar Harmony 2026* (i przyszłe ambient electronic / cinematic)
   - `Deep House` → *Old Love*, *Let's Talk About Music*, *Fantastic World*, *The Journey In the Time and Space* (wszystkie odmiany — melodic / sunset / tropical / jazzy / progressive / cosmic)
   - `House` → zarezerwowane dla bardziej taneczno-klubowych pozycji (4/4, wyższe BPM, mniej downtempo'wych)

---

## 12. Case study: The Journey In the Time and Space (Edition 2025)

Piąty utwór z katalogu — progressive / cosmic deep house, kosmiczna osia tematyczna:
[soundcloud.com/maximummusicmaxx/the-journey-in-the-time-and-space-edition-2025](https://soundcloud.com/maximummusicmaxx/the-journey-in-the-time-and-space-edition-2025)

### Charakterystyka utworu
- **Gatunek:** progressive / cosmic / melodic deep house
- **BPM:** typowo 120–125 (uzupełnij dokładnie)
- **Typ:** instrumental
- **Artwork:** fioletowo-purpurowe nocne niebo z gwiazdami i delikatną zorzą, sylwetki sosen — cosmic / Northern Lights visual
- **Stan początkowy:** opis pusty, asterisk w tytule (`*edition 2025`)
- **Mocna karta:** spójność tytuł + cover jest perfekcyjna — wzorzec wizualny **progressive deep house à la Anjunadeep / Lane 8**
- **Słaba karta:** `*edition 2025` z asteryskiem (ten sam problem co `*no more coffee`) — popraw na `(2025 Edition)`

### Tytuł — rekomendacja

**Najmocniejszy SEO:**
```
The Journey In the Time and Space — Progressive Deep House (2025 Edition)
```

Gatunek + numerek edycji + asterisk fix. Możliwy update: `(2025/2026 Edition)` jeśli wciąż aktualny push.

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
The Journey In the Time and Space (2025 Edition) — instrumentalny
progressive / cosmic deep house o podróży przez gwiezdne pustkowia,
ciszę między planetami i światło, które dociera do nas z bardzo daleka.

Głębokie pady, melodyjne syntezatory, miarowy puls — soundtrack
dla nocnej jazdy, długich spacerów pod gwiazdami, sesji medytacji
i wszystkich momentów, w których patrzysz w niebo dłużej niż zwykle.

Jeśli kochasz progressive deep house, cosmic house, melodic house & techno
i klimat Anjunadeep, Lane 8, Yotto, Eli & Fur, ARTBAT
— ten utwór jest dla Ciebie.

— — —

The Journey In the Time and Space (2025 Edition) — an instrumental
progressive / cosmic deep house track about a journey through starry
voids, the silence between planets and the light that reaches us
from very far away.

Deep pads, melodic synths and a steady pulse — a soundtrack for
night drives, long walks under the stars, meditation and any moment
when you look up at the sky longer than usual.

Perfect if you love progressive deep house, cosmic house, melodic house
& techno and the vibes of Anjunadeep, Lane 8, Yotto,
Eli & Fur and ARTBAT.

🌌 Best on headphones, under a clear sky
🪐 Follow for more cosmic deep house
💬 Where does this track take you?

#progressivedeephouse #cosmichouse #melodichouse #anjunadeep #spacemusic

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
"progressive deep house" "cosmic house" "melodic deep house" "space music" "deep house" "melodic house and techno" instrumental "anjunadeep" "deep house 2025" melodic
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"progressive deep house"` | główny gatunkowy, rosnąca nisza |
| `"cosmic house"` | dosłownie z tytułu + cover |
| `"melodic deep house"` | spina z resztą katalogu (*Old Love*) |
| `"space music"` | long-tail z Google, łapie playlisty stargazing |
| `"deep house"` | szeroki, najwyższy wolumen |
| `"melodic house and techno"` | gigantyczna scena (Afterlife, Anjunadeep), mocno konwertujący |
| `instrumental` | filtr "no vocals" |
| `"anjunadeep"` | label-style tag |
| `"deep house 2025"` | rok edycji |
| `melodic` | uniwersalny mood |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (catalogue consistency, 3-bucket rule) |
| BPM | typowo 120–125 (wpisz z DAW) |
| Key signature | cosmic vibes typowo minor: `Am`, `Cm`, `Dm`, `F#m` |
| Sharing | `public` |
| Downloadable | `true` (progressive DJ-e pobierają do setów) |
| License | `all-rights-reserved` |
| Commentable | `true` |
| Release date | rzeczywista 2025 (lub update'u 2026) |
| Label name | `Maximum Music` |

### Plan pierwszych 48 godzin

1. **Playlista** `Cosmic Deep House — Stargazing 2026` — Twój utwór poz. 2-3 + 4–6 cudzych Lane 8 / Anjunadeep style.
2. **DJ promo** — progressive / melodic deep house DJ-e (Anjunadeep submissions, This Never Happened by Lane 8, Afterlife adjacent).
3. **Cross-post Instagram Reels / TikTok** — 15-sek loop dropu + visual gwiezdnego nieba / nocnej jazdy / Northern Lights.
4. **YouTube cosmic playlists** — wyszukaj kanały "cosmic deep house mix" / "anjunadeep mix" / "starry night deep house" i podeślij link.
5. **Pinned comment**: "Looking up at the stars right now? Drop a 🌌 in the comments" — proste, działające w tej niszy.
6. **Long format content** — utwór prosi się o **długi mix** (60 min) — stwórz własny "cosmic deep house mix" z tym utworem w środku.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"progressive deep house"`
- `"cosmic house"`
- `"anjunadeep"`
- `"the journey in the time and space"`

### Porównanie strategii: wszystkie pięć utworów

| Aspekt | Lunar Harmony 2026 | Old Love | Let's Talk About Music (sunny) | Fantastic World (No More Coffee) | The Journey In the Time and Space |
|---|---|---|---|---|---|
| Gatunek | Ambient electronic | Melodic deep house | Sunny tropical deep house | Jazzy café downtempo deep house | Progressive / cosmic deep house |
| BPM | 125 | 120–124 | 100–124 | 80–110 (downtempo) | 120–125 |
| Puls | Pulsujący ambient | 4/4 | 4/4 | Swing / broken beat | 4/4 progresywny |
| Mood | Nocne miasto, neon | Sunset, Ibiza, nostalgia | Plaża, lato, radość | Kawiarnia, jazz | Kosmos, gwiazdy, podróż |
| Cover | Skyline nocą | Tropikalny sunset | Sylwetka na plaży | Latte art | Gwiazdy + zorza |
| Główny tag SEO | `"ambient electronic"` | `"melodic deep house"` | `"tropical house"` | `"jazzy house"` / `"café music"` | `"progressive deep house"` / `"cosmic house"` |
| Tag pod okładkę | `"night music"` | `"sunset house"` | `"beach music"` | `"café music"` | `"space music"` |
| Tag mood | `cinematic` | `"emotional deep house"` | `"sunny vibes"` | `"nu jazz"` | `"melodic house and techno"` |
| Genre (SC) | `Ambient` | `Deep House` | `Deep House` | `Deep House` | `Deep House` |
| Tonacja | minor | minor | major | minor 7th (jazz) | minor |
| Grupa docelowa | Focus / filmowcy | DJ-e sunset / Ibiza | Letnie playlisty | Sync (HoReCa) + lounge DJ | Anjunadeep DJ + stargazing |
| Sezonowość | Całoroczny | Lato/jesień | V–VIII | Całoroczny + jesień/zima | Całoroczny + **zima (długie noce)** |
| Kanał promocji | Embed + focus playlists | DJ promo + sunset Reels | Reels/TikTok + summer | Sync libraries + café | Anjunadeep submissions + cosmic Reels |
| Nazewnictwo | `2026` ✅ | `(new version)` → popraw | `(sunny version)` ✅ | `*no more coffee` → popraw | `*edition 2025` → popraw na `(2025 Edition)` |

### Insight z piątego utworu — kosmiczna osia tematyczna

1. **Druga "kosmiczna" wpadka w katalogu** — *Lunar Harmony* (księżyc) i *The Journey* (kosmos / gwiazdy) tworzą **subkatalog tematyczny**. Rozważ:
   - Mini-EP: `Cosmos Series` zawierający oba utwory + 1-2 nowe ("Solar Eclipse", "Andromeda Drift" — w stylu nazewniczym).
   - Wspólna playlista profilu `Cosmos / Space / Night` linkująca te utwory.
   - Cross-link w opisach: "🌙 Companion ambient track: *Lunar Harmony 2026* [link]" w *The Journey* i odwrotnie.
2. **Asterisk pattern wraca** (`*no more coffee`, `*edition 2025`) — to świadoma stylizacja czy artefakt? Jeśli stylizacja, w SC trzeba ją tłumaczyć na nawiasy. Jeśli przypadek, ustal regułę dla całego katalogu: **żadnych asterisków w tytułach**.
3. **Kosmiczny vibe = mocna karta zimowa** — *The Journey* idealnie pasuje do okresu Polar Night (XII-II), Geminids/Perseids meteor showers, Aurora season w Skandynawii. Rozważ targeted push w grudniu (Geminidy) lub sierpniu (Perseidy) — viral potential przy odpowiednim Reels.
4. **Anjunadeep ekosystem to oddzielna strategia** — dla *The Journey* i *Old Love* (oba melodic / progressive deep house) submituj do `Anjunadeep Edition` (radio show), Lane 8 `Mixtape` series, Hi-Lo / All Day I Dream label radars.

---

## 13. Case study: Far Far Away

Szósty utwór z katalogu — dreamy / sunset deep house z **problemem URL slug** do naprawy:
[soundcloud.com/maximummusicmaxx/maximum-music-maxx-far-far](https://soundcloud.com/maximummusicmaxx/maximum-music-maxx-far-far)

### Charakterystyka utworu
- **Gatunek:** dreamy / sunset / cinematic deep house
- **BPM:** typowo 118–124 (uzupełnij dokładnie)
- **Typ:** instrumental
- **Artwork:** minimalistyczny sunset nad morzem, soft palette pomarańcz/róż
- **Stan początkowy:** opis pusty, **URL slug zepsuty** (`maximum-music-maxx-far-far` — zduplikowana nazwa artysty + ucięty tytuł)
- **Mocna karta:** tytuł + cover to silna emocjonalna karta; "Far Far Away" jest long-tail keyword z naturalnym wolumenem (marzenia, eskapizm, romanse)
- **Słaba karta:** URL slug to artefakt z nazwy pliku — SEO traci

### URL fix (krytyczne, zrób pierwsze!)

W SC: edycja utworu → `Permalink` → zmień na:
```
far-far-away
```

Final URL: `soundcloud.com/maximummusicmaxx/far-far-away` ✅ czysty, z keywordem w slug'u.

> **Uwaga:** zmiana permalinka łamie istniejące linki. SC zachowuje stare URL-e jako redirect, ale dla pewności wymień linki w głównych miejscach (jeśli były).

### Tytuł — rekomendacja

**Najmocniejszy SEO:**
```
Far Far Away — Dreamy Sunset Deep House (2026)
```

Gatunek + setting + rok. Tytuł zachowuje emocjonalny rdzeń.

**Alternatywy:**
- `Far Far Away (Sunset Deep House Mix)`
- `Far Far Away — Cinematic Deep House`

### Opis (bilingual PL/EN) — gotowy do wklejenia

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
🌊 Follow for more sunset deep house
💬 Where would you escape to? Drop it in the comments

#dreamydeephouse #sunsetdeephouse #cinematichouse #melodicdeephouse #escapism

▶ More tracks: https://soundcloud.com/maximummusicmaxx```

### Tagi — string do wklejenia

```
"dreamy deep house" "sunset deep house" "melodic deep house" "cinematic deep house" "deep house" instrumental melodic "sunset music" "deep house 2026" dreamy
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"dreamy deep house"` | dosłownie z mood'u tytułu — niszowy, mocno konwertujący |
| `"sunset deep house"` | spina z okładką + z *Old Love* w katalogu |
| `"melodic deep house"` | duża nisza, scena Anjunadeep/Lane 8 |
| `"cinematic deep house"` | otwiera sync placements |
| `"deep house"` | szeroki, najwyższy wolumen |
| `instrumental` | filtr "no vocals" |
| `melodic` | uniwersalny mood |
| `"sunset music"` | long-tail z Google |
| `"deep house 2026"` | aktualność |
| `dreamy` | uniwersalny mood, łapie playlisty `dream`, `sleep`, `relax` |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | typowo 118–124 (wpisz z DAW) |
| Key signature | dreamy mood typowo major7 lub minor: `Cmaj7`, `Fmaj7`, `Am`, `Dm` |
| Sharing | `public` |
| Downloadable | `true` (DJ-e sunset/melodic pobierają) |
| License | `all-rights-reserved` (sync potential — filmowcy uwielbiają sunset deep house) |
| Commentable | `true` |
| Release date | rzeczywista 2026 |
| Label name | `Maximum Music` |

### Plan pierwszych 48 godzin

1. **URL fix** — najpierw zmień permalink na `far-far-away`.
2. **Playlista** `Dreamy Sunset Deep House — Far Horizons` — Twój utwór poz. 2-3 + cudze sunset deep house tracks.
3. **Crosslink z resztą katalogu** — w opisie dodaj:
   ```
   🌅 Sister track: Old Love Will Not Be Forgotten (also sunset deep house)
   ```
4. **Sync pitching** — tracky o tytułach "Far Far Away" + minimalistyczny sunset cover są idealne do reklam podróżniczych, hoteli, linii lotniczych. Submituj do Musicbed / Marmoset.
5. **Reels / TikTok** — 15-sek loop + visual horyzontu/podróży/morza. Tag `#farfaraway` ma stałe wyszukania.
6. **Pinned comment**: "Where would you escape to right now?" — zaproszenie do dyskusji.
7. **Audiowizualna sekwencja** — utwór + 30-sek video z timelapsem sunsetu = potencjał viralu na TikTok.

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"dreamy deep house"`
- `"sunset deep house"`
- `"far far away"`
- `"cinematic deep house"`

### Porównanie strategii: wszystkie sześć utworów

| Aspekt | Lunar Harmony | Old Love | Let's Talk (sunny) | Fantastic World (Coffee) | The Journey (Space) | Far Far Away |
|---|---|---|---|---|---|---|
| Gatunek | Ambient electronic | Melodic deep house | Sunny tropical deep house | Jazzy café downtempo DH | Progressive / cosmic DH | **Dreamy / sunset DH** |
| BPM | 125 | 120–124 | 100–124 | 80–110 | 120–125 | **118–124** |
| Puls | Pulsujący ambient | 4/4 | 4/4 | Swing/broken | 4/4 progresywny | 4/4 dreamy |
| Mood | Neon, kosmos | Sunset, Ibiza, nostalgia | Plaża, lato, radość | Kawiarnia, jazz | Kosmos, podróż | **Horyzont, marzenia, eskapizm** |
| Cover | Skyline nocą | Tropical sunset + palma | Sylwetka na plaży | Latte art | Gwiazdy + zorza | **Minimalist sunset nad morzem** |
| Główny tag SEO | `"ambient electronic"` | `"melodic deep house"` | `"tropical house"` | `"jazzy house"` | `"progressive deep house"` | **`"dreamy deep house"`** |
| Tag pod okładkę | `"night music"` | `"sunset house"` | `"beach music"` | `"café music"` | `"space music"` | `"sunset music"` |
| Genre (SC) | `Ambient` | `Deep House` | `Deep House` | `Deep House` | `Deep House` | `Deep House` |
| Tonacja | minor | minor | major | minor 7th | minor | **major7 lub minor** |
| Grupa docelowa | Focus / filmowcy | DJ sunset / Ibiza | Letnie playlisty | Sync (HoReCa) | Anjunadeep DJ | Sunset playlists + sync |
| Sezonowość | Całoroczny | Lato/jesień | V–VIII | Całoroczny + jesień/zima | Całoroczny + zima | **Lato/jesień + sync całoroczny** |
| Kanał promocji | Embed + focus | DJ promo + sunset Reels | Reels/TikTok + summer | Sync libraries + café | Anjunadeep submissions | **Sync libraries + sunset Reels** |
| Nazewnictwo | `2026` ✅ | `(new version)` → popraw | `(sunny version)` ✅ | `*no more coffee` → popraw | `*edition 2025` → popraw | OK ale **URL slug do fix** |

### Insight z szóstego utworu — URL slug hygiene + sunset sub-axis

1. **URL slug hygiene — nowa zasada katalogu** — *Far Far Away* ujawnił pierwszy slug problem (`maximum-music-maxx-far-far`). SC bierze nazwę pliku WAV jako slug. **Reguła dla całego katalogu:**
   - Przed uploadem **zmień nazwę pliku audio** na clean slug (`far-far-away.wav`, nie `Maximum Music Maxx - Far Far Away (Final Master v3).wav`).
   - Po uploadzie **sprawdź permalink** w SC i edytuj jeśli trzeba (`Edit track → Permalink`).
   - Reguła: slug = `[clean-title-lowercase-with-dashes]`, bez nazwy artysty (jest już w URL profilu), bez wersji/masteringu, bez nawiasów.
2. **Sunset axis rośnie do 3 utworów** — *Old Love* (tropical sunset + palma), *Let's Talk About Music* (sylwetka kobiety przy sunset), *Far Far Away* (minimalistyczny horyzont sunset). To **kolejna sub-osia tematyczna** obok cosmic (*Lunar Harmony* + *The Journey*). Rozważ playlistę profilu `Sunset Series` linkującą wszystkie 3 + cross-link w opisach każdego.
3. **Dwie osi tematyczne katalogu już widoczne:** Cosmos (2 utwory) + Sunset (3 utwory) + jeden "soliter" (*Fantastic World*). Naturalna ścieżka rozwoju: kolejny utwór = albo Cosmos #3, albo Sunset #4, albo nowa osia (np. Rain, Forest, City).
4. **Sync potential konsoliduje się** — *Fantastic World* (café), *Lunar Harmony* (cinematic), *Far Far Away* (travel/horyzont). Mocne portfolio do sync libraries. Rozważ jednorazową stronę portfolio z embeddami SC + opisami "perfect for [scene type]".
5. **Wszystkie 6 utworów mają wciąż ten sam fix #1** — pusty opis. Po wdrożeniu wszystkich case studies — to **6 darmowych boostów** profilu.

---

## 14. Case study: Summertime Melody MAX 07 (mix, nie single!)

**Pierwszy mix/compilation w analizie** — strategia inna niż dla singli:
[soundcloud.com/maximummusicmaxx/summertime-melody-max-07](https://soundcloud.com/maximummusicmaxx/summertime-melody-max-07)

### Charakterystyka — co odróżnia od singli
- **Format:** DJ-style mix / compilation (3 utwory w jednej ścieżce)
- **Seria:** `Summertime Melody MAX`, episode **#07** → implikuje 6 wcześniejszych
- **BPM/Key:** różne dla 3 utworów (wpisz średnią lub zostaw puste)
- **Artwork:** sunset nad polem zbóż, contrail na niebie — summer rural
- **Stan opisu:** **JEST!** ale minimalistyczny (tylko tracklist bez kontekstu)
- **Tracklist:**
  1. The Summertime Melody 02
  2. The Little Man
  3. Open Your Mind — Big Heart

**To pierwszy utwór w analizie z istniejącym opisem.** Mała baza, ale na czym budować.

### Tytuł — rekomendacja

```
Summertime Melody MAX 07 — Summer Deep House Mix (2026)
```

Zachowuje nazwę serii + numer + dodaje gatunek + rok.

**Alternatywy:**
- `Summertime Melody MAX #07 (Sunset Deep House Mix)`
- `Summertime Melody MAX — Episode 07 — Summer Deep House`

### Description (bilingual PL/EN, bez timestamp'ów — gotowy do wklejenia)

```
Summertime Melody MAX — Episode 07
Letni mix instrumentalnego summer / sunset deep house.
Trzy własne kompozycje połączone w jeden soundtrack dla zachodów słońca,
długich letnich wieczorów, plaży i drogi nad morze.

Część serii Summertime Melody MAX — każde wydanie zbiera kilka utworów
spod tego samego letniego, melodyjnego klimatu.

🎵 Tracklist:
1. The Summertime Melody 02
2. The Little Man
3. Open Your Mind — Big Heart

Jeśli kochasz summer deep house, melodic deep house, sunset house
i klimat Lane 8, Kygo, Sam Feldt — ten mix jest dla Ciebie.

— — —

Summertime Melody MAX — Episode 07
An instrumental summer / sunset deep house mix.
Three of my own compositions tied into one soundtrack for sunsets,
long summer evenings, beach days and drives to the sea.

Part of the Summertime Melody MAX series — each release gathers a few
tracks under the same summery, melodic vibe.

🎵 Tracklist:
1. The Summertime Melody 02
2. The Little Man
3. Open Your Mind — Big Heart

Perfect if you love summer deep house, melodic deep house, sunset house
and the vibes of Lane 8, Kygo, Sam Feldt.

🌅 Best at golden hour
🌊 Follow the series for more summer mixes
💬 Which track hits hardest? Drop a comment

#summerdeephouse #melodicdeephouse #sunsethouse #djmix #summer2026

▶ More tracks: https://soundcloud.com/maximummusicmaxx
🎵 Also on hearthis.at: https://hearthis.at/maximummusic/```

### Tagi — dwa formaty (SC + hearthis)

**SC (frazy w cudzysłowach, spacja):**
```
"summer deep house" "deep house mix" "summertime mix" "dj mix" "sunset house" "melodic deep house" "summer house" instrumental "summer 2026" melodic
```

**hearthis.at (przecinek):**
```
summer deep house, deep house mix, summertime mix, dj mix, sunset house, melodic deep house, summer house, instrumental, summer 2026, melodic
```

**Logika doboru:**

| Tag | Funkcja |
|---|---|
| `"summer deep house"` | sezonowy, ogromne playlisty |
| `"deep house mix"` | sygnalizuje format mixu (różnica vs single!) |
| `"summertime mix"` | spina z nazwą serii |
| `"dj mix"` | otwiera odkrycie przez DJ-skich słuchaczy |
| `"sunset house"` | spina z okładką |
| `"melodic deep house"` | spina z catalogue |
| `"summer house"` | uniwersalny letni |
| `instrumental` | filtr |
| `"summer 2026"` | aktualność sezonowa |
| `melodic` | mood |

### Pozostałe pola

| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | średnia z 3 utworów (typowo 118–124) lub zostaw puste |
| Key | tylko jeśli wszystkie 3 w tej samej tonacji |
| Sharing | `public` |
| Downloadable | `true` (mix DJ-ski) |
| License | `all-rights-reserved` |
| Commentable | `true` |
| Release date | rzeczywista data ep. 07 |
| Label name | `Maximum Music` |

### Najmocniejszy ruch: playlista całej serii

To episode **#07** — istnieją episody 01–06. Stwórz playlistę:

**Nazwa:** `Summertime Melody MAX — Full Series`

**Description playlisty:**
```
Pełna seria letnich mixów Maximum Music Maxx.
Każdy episode = 3 nowe instrumentalne utwory w klimacie
summer / sunset deep house.

Idealne na: zachody słońca, plażę, długie jazdy, summer playlists.
```

**Dlaczego to natychmiastowy boost:**
1. Playlisty rankują **osobno** w SC search.
2. Słuchacz episodu 07 ma natychmiastowy follow-up do 01-06 → wydłuża session time.
3. Algorytm SC podbija profile z curated playlists.
4. **Każdy nowy episode automatycznie zwiększa siłę playlisty** (compound effect).

### Bonus: 3 utwory MAX 07 jako standalone single?

Każdy z 3 utworów mógłby być **osobnym single** z dedykowanym SEO. Sprawdź czy są na hearthis.at (z 268 tracków). Jeśli tak → mix służy jako **kompilacja-trailer**:

```
🎵 Standalone tracks:
- The Summertime Melody 02: [link]
- The Little Man: [link]
- Open Your Mind — Big Heart: [link]
```

Mix zamienia się w **funnel** do indywidualnych utworów.

### hearthis.at mirror — Type: `Mix`

Mixy to **specjalność hearthis.at**. Tam ustaw **Type: `Mix`** (nie `Track`), tytuł i opis te same, format tagów przecinek.

### Mix vs Single — kiedy stosować

| Aspekt | Single track | Mix / Compilation |
|---|---|---|
| Czas trwania | 3–8 min | 10–60+ min |
| Cel SEO | Indywidualny utwór + sync potential | Buduje "shelf" serii, długi session time |
| Tagi | Niche genre + mood | + `"dj mix"`, `"compilation"`, `"deep house mix"` |
| Title format | `Title — Subgenre (Year)` | `Title — Subgenre Mix (Year)` lub `Series #NN (Genre Mix)` |
| Tracklist w opisie | Nie | **TAK** — każdy track = osobny keyword |
| Playlist strategy | Dołącz do mood-series playlist | **Wymaga osobnej playlisty serii** |
| Najlepsza platforma | SC (algorytm + sync) | **hearthis.at** (brak limitu długości, DJ community) |
| Downloadable | Czasem | **Zwykle TAK** (DJ-e biorą do setów) |
| Sync potential | Wysoki | Niski (sync libraries chcą single tracków) |
| Compound effect | Brak | **TAK** — każdy nowy episode podbija starsze |

### Weryfikacja

Po zapisaniu zmian odczekaj ~5 min i wyszukaj w SC:
- `"summer deep house mix"`
- `"summertime"`
- `"deep house mix 2026"`
- `"dj mix sunset"`

### Insight #6 (nowa kategoria w katalogu): Mix episodes jako format

1. **Katalog ma więcej niż jeden format** — single tracki (6 case studies) + mix series (Summertime Melody MAX 01-07+). Każdy wymaga innej strategii SEO.
2. **Series #07 implikuje 6 wcześniejszych episodów** — *to jest gotowy do "uruchomienia" subkatalog*. Po prostu playlistą całej serii zwiększasz widoczność wszystkich 7 episodów naraz.
3. **Mixy są flagshipem hearthis.at** — przekonwertuj wszystkie episody na typ `Mix` (nie `Track`) na hearthis.at jeśli jeszcze nie są.
4. **Cross-pollination single↔mix** — jeśli `The Summertime Melody 02` istnieje jako standalone single (sugestia: wrzuć jako single z osobnym SEO), to mix episode 07 staje się **zwiastunem** wszystkich 3 utworów → funnel.
5. **Compound growth z serii** — episode 08, 09, 10 będą automatycznie wzmacniać siłę playlisty Full Series → najlepsza inwestycja czasu w długofalową widoczność profilu.

---

## 15. Case study: Deep Water (Ext. Ver) — Atmospheric Deep House

[soundcloud.com/maximummusicmaxx/deep-water-ext-ver](https://soundcloud.com/maximummusicmaxx/deep-water-ext-ver)

### Charakterystyka
- **Gatunek:** melancholic / atmospheric / introspective deep house
- **Mood:** głębia, samotność, kontemplacja, zimny błękit, late-night
- **Cover:** drewniany pomost wchodzący w jezioro spowite mgłą, samotna latarnia, deep blue/purple
- **Format:** Extended Version (DJ-friendly 7-10 min)
- **Stan początkowy:** opis pusty, slug `deep-water-ext-ver` zawiera skróty
- **Track ID:** 1874180076
- **Mocna karta:** otwiera **nową oś tematyczną w katalogu — Water/Introspection**, najsilniejsza pojedyncza okazja brandingowa

### URL slug fix
Aktualnie: `deep-water-ext-ver` → popraw na:
```
deep-water-extended-mix
```
lub krócej: `deep-water` (jeśli nie ma kolizji).

### Tytuł — rekomendacja
```
Deep Water — Atmospheric Deep House (Extended Mix 2026)
```

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Deep Water (Extended Mix) — instrumentalny atmospheric / melancholic
deep house o tym momencie, w którym stoisz na końcu pomostu nad ciemną
wodą i tracisz poczucie czasu. Głębokie pady, miarowy puls, dalekie
echo i mgła, która osiada na powierzchni.

Wersja rozszerzona — pełna 7+ minutowa podróż dla DJ-skich setów,
długich jazd nocą i tych chwil, kiedy nie chcesz, żeby się skończyło.

Jeśli kochasz melancholic deep house, atmospheric deep house,
introspective house i klimat Stephan Bodzin, Tale of Us, Massano,
Solomun — ten utwór jest dla Ciebie.

— — —

Deep Water (Extended Mix) — an instrumental atmospheric / melancholic
deep house track about that moment when you're standing at the end of
the pier above dark water and you lose track of time. Deep pads,
a steady pulse, distant echoes and mist settling on the surface.

The extended version — a full 7+ minute journey for DJ sets, late-night
drives and those moments when you don't want it to end.

Perfect if you love melancholic deep house, atmospheric deep house,
introspective house and the vibes of Stephan Bodzin, Tale of Us,
Massano, Solomun.

🌫️ Best on headphones, late at night
💧 Follow for more atmospheric deep house
💬 Where does this track take you?

#deepwater #melancholicdeephouse #atmosphericdeephouse #extendedmix #deephouse2026

▶ More tracks: https://soundcloud.com/maximummusicmaxx
🎵 Also on hearthis.at: https://hearthis.at/maximummusic/```

### Tagi — dwa formaty

**SC:**
```
"deep house" "extended mix" "melancholic deep house" "atmospheric deep house" "introspective house" "late night house" instrumental melodic "deep house 2026" "deep house extended mix"
```

**hearthis.at:**
```
deep house, extended mix, melancholic deep house, atmospheric deep house, introspective house, late night house, instrumental, melodic, deep house 2026, deep house extended mix
```

### Pozostałe pola
| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | 118–124 typowo |
| Key | minor (`Am`, `Cm`, `Dm`, `F#m`, `Gm`) |
| Downloadable | **`true`** (Extended Mix = DJ-friendly) |
| License | `all-rights-reserved` |
| Release date | rzeczywista |

### Bonus — pattern Extended/Original
Jeśli istnieje radio edit/regular wersja, crosslinkuj:
```
🎵 Original / radio version: https://soundcloud.com/maximummusicmaxx/[slug]
```
Jeśli nie ma — wyciągnij standalone radio edit z extended (~3:30) i wrzuć osobno = dwa utwory = dwa razy więcej widoczności.

### Nowa oś tematyczna: Water / Introspection
Katalog wzbogaca się o subkatalog z bardzo silnym signature wizualnym:

| Oś tematyczna | Utwory | Cover language |
|---|---|---|
| Sunset | Old Love, Let's Talk About Music, Far Far Away | Sunset, plaża, horyzont |
| Cosmos | Lunar Harmony, The Journey | Gwiazdy, kosmos, noc |
| Café/Lounge | Fantastic World | Kawa, latte art |
| Summer Mix Series | Summertime Melody MAX 01-07+ | Lato, pole, sunset |
| **NEW: Water/Introspection** | **Deep Water** | Jezioro, mgła, samotność |

**Sugestia rozwoju:** `Still Lake`, `Morning Fog`, `Beneath the Surface`, `River at Dawn` — najsilniejsza pojedyncza okazja brandingowa.

---

## 16. Case study: Time To Speed Up (Long Version) — Urban Deep House

[soundcloud.com/maximummusicmaxx/time-to-speed-up-long-version](https://soundcloud.com/maximummusicmaxx/time-to-speed-up-long-version)

### Charakterystyka
- **Gatunek:** urban / driving / progressive deep house
- **Mood:** pęd miasta, nocna jazda, urgency, energia
- **Cover:** wnętrze stacji metra, duży zegar BVG Metro, łukowy dach, ludzie na peronie, monochromatyczne fiolety/błękity
- **Format:** Long Version (DJ-friendly extended)
- **Stan początkowy:** opis pusty, **asterisk w tytule** (`*long version`)
- **Track ID:** 2221695998
- **Mocna karta:** spójność tytuł + cover (zegar = czas = speed up + urban transit) — bardzo silna karta wizualna. Druga oś **urban/city/night** (razem z *Lunar Harmony*)

### Title asterisk fix (powtarzający się problem!)
Aktualnie: `Time To Speed Up *long version`

**Reguła katalogu (z sekcji 12):** żadnych asterisków w tytułach. SC search źle indeksuje znaki specjalne.

### Tytuł — rekomendacja
```
Time To Speed Up — Driving Deep House (Long Version 2026)
```

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
Time To Speed Up (Long Version) — instrumentalny urban / driving
deep house o tym momencie, kiedy miasto przyspiesza, zegar tyka
głośniej, a Ty wsiadasz do nocnego pociągu. Pulsujący bas,
napięte syntezatory i miarowy, nieubłagany rytm.

Wersja rozszerzona — pełna 7+ minutowa podróż dla DJ-skich setów,
nocnych jazd autostradą i wieczornych energii w klubach.

Jeśli kochasz progressive deep house, driving deep house,
urban house i klimat Solomun, Adriatique, Innellea, Massano,
Stephan Bodzin — ten utwór jest dla Ciebie.

— — —

Time To Speed Up (Long Version) — an instrumental urban / driving
deep house track about that moment when the city accelerates,
the clock ticks louder and you step onto the night train. A pulsing
bass, tense synths and a steady, relentless rhythm.

The extended version — a full 7+ minute journey for DJ sets,
late-night highway drives and club energy.

Perfect if you love progressive deep house, driving deep house,
urban house and the vibes of Solomun, Adriatique, Innellea, Massano
and Stephan Bodzin.

🌃 Best at night, full volume
🚇 Follow for more urban deep house
💬 Where does this track take you?

#drivingdeephouse #progressivedeephouse #urbanhouse #longversion #deephouse2026

▶ More tracks: https://soundcloud.com/maximummusicmaxx
🎵 Also on hearthis.at: https://hearthis.at/maximummusic/```

### Tagi — dwa formaty

**SC:**
```
"deep house" "driving deep house" "progressive deep house" "urban house" "long version" "deep house long mix" "night drive" instrumental melodic "deep house 2026"
```

**hearthis.at:**
```
deep house, driving deep house, progressive deep house, urban house, long version, deep house long mix, night drive, instrumental, melodic, deep house 2026
```

### Pozostałe pola
| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | **122–128** (Speed Up = górny zakres DH) |
| Key | minor (`Am`, `Cm`, `Dm`, `F#m`) |
| Downloadable | **`true`** (Long Version = DJ-friendly) |
| License | `all-rights-reserved` |
| Release date | rzeczywista |

### Druga oś tematyczna katalogu: Urban / Night / City

| Utwór | Cover | Signature |
|---|---|---|
| **Lunar Harmony 2026** | Skyline nocą + neon | Statyczny urban (skyscrapers) |
| **Time To Speed Up** | Stacja metra + zegar | Dynamiczny urban (transit, motion) |

**Sugestia rozwoju:** `Neon District`, `Last Train Home`, `Highway Lights`, `Underground` — kolejny subkatalog z mocną tożsamością wizualną.

---

## Pełne mapowanie osi tematycznych katalogu (stan na sekcję 16)

| Oś | Utwory case study | Liczba | Cover language | Sezonowość |
|---|---|---|---|---|
| **Sunset** | Old Love, Let's Talk About Music, Far Far Away | 3 | Sunset, plaża, horyzont | Lato/jesień |
| **Cosmos** | Lunar Harmony, The Journey | 2 | Gwiazdy, kosmos, noc | Zima (długie noce) |
| **Urban/Night** | Lunar Harmony (overlap), Time To Speed Up | 2 | Skyline, metro, neon | Całoroczny |
| **Café/Lounge** | Fantastic World | 1 | Kawa, latte art | Całoroczny |
| **Summer Mix Series** | Summertime Melody MAX 07 (+01-06) | 7+ | Lato, pole, sunset | Stricte letni |
| **Water/Introspection** | Deep Water | 1 | Jezioro, mgła, samotność | Jesień/zima |

**Insight:** *Lunar Harmony* należy do **dwóch osi naraz** (Cosmos + Urban) — to dobry pattern, można takie utwory używać jako bridges między playlistami serii.

---

## 17. Case study: The Locomotive (new version) — Driving Cinematic Deep House

[soundcloud.com/maximummusicmaxx/locomotive](https://soundcloud.com/maximummusicmaxx/locomotive)

### Charakterystyka
- **Gatunek:** driving / cinematic / journey deep house
- **Mood:** pęd pociągu, vintage power, mostek nad doliną, golden hour energy
- **Cover:** vintage parowóz na stalowym moście, golden hour sun-burst, bujny las, różowo-cyjanowe flare'y światła (klimat filmowego plakatu)
- **Stan początkowy:** opis pusty, `(new version)` w tytule (drugi raz w katalogu po *Old Love*)
- **Track ID:** 2306264627
- **Mocna karta:** spójność tytuł + cover na poziomie filmowym — utwór czyta się jako "soundtrack do filmu drogi". Razem z *Time To Speed Up* otwiera nową oś **Motion/Transit/Journey**.

### Tytuł — rekomendacja
```
The Locomotive — Driving Deep House (2026 Version)
```
`(new version)` → `(2026 Version)` (per reguła sekcji 9 dla *Old Love*).

### Opis (bilingual PL/EN) — gotowy do wklejenia

```
The Locomotive (2026 Version) — instrumentalny driving / cinematic
deep house o sile pędzącego pociągu, stalowym moście nad doliną
i tym momencie, kiedy świat przesuwa się za oknem z prędkością wspomnień.
Pulsujący bas, melodyjne syntezatory, miarowy rytm — jak stukot kół
na szynach.

Odświeżona wersja jednej z bardziej dynamicznych kompozycji z mojego
katalogu — pełna energii podróży i vintage power.

Jeśli kochasz driving deep house, cinematic deep house, journey music
i klimat Solomun, Adriatique, Stephan Bodzin, ARTBAT, Maceo Plex
— ten utwór jest dla Ciebie.

— — —

The Locomotive (2026 Version) — an instrumental driving / cinematic
deep house track about the power of a rushing train, a steel bridge
over the valley and that moment when the world flashes past the window
at the speed of memory. A pulsing bass, melodic synths and a steady
rhythm — like wheels on rails.

A refreshed version of one of the more dynamic compositions in my
catalogue — full of journey energy and vintage power.

Perfect if you love driving deep house, cinematic deep house, journey
music and the vibes of Solomun, Adriatique, Stephan Bodzin, ARTBAT
and Maceo Plex.

🚂 Best on a long road trip
🌅 Follow for more cinematic deep house
💬 Where would this take you?

#drivingdeephouse #cinematicdeephouse #journeydeephouse #deephouse #deephouse2026

▶ More tracks: https://soundcloud.com/maximummusicmaxx
🎵 Also on hearthis.at: https://hearthis.at/maximummusic/```

### Tagi — dwa formaty

**SC:**
```
"deep house" "driving deep house" "cinematic deep house" "journey deep house" "progressive deep house" "deep house 2026" instrumental melodic "deep house version" "train music"
```

**hearthis.at:**
```
deep house, driving deep house, cinematic deep house, journey deep house, progressive deep house, deep house 2026, instrumental, melodic, deep house version, train music
```

### Pozostałe pola
| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | typowo 122–126 (wpisz z DAW) |
| Key | minor (`Am`, `Cm`, `Dm`) |
| Downloadable | `true` |
| License | `all-rights-reserved` |
| Release date | rzeczywista (2026) |
| Label name | `Maximum Music` |

### Nowa oś tematyczna: Motion / Transit / Journey

Razem z *Time To Speed Up* utwór tworzy **trzecią parę osi tematycznej**:

| Utwór | Cover | Tonacja stylistyczna |
|---|---|---|
| **Time To Speed Up** | Stacja metra + zegar | Modern, urban, neon, dynamic |
| **The Locomotive** | Vintage parowóz + most | Organic, vintage, cinematic, nostalgic |

Razem pokrywają **pełen spektrum transitu** — od cyfrowego/urban do mechanicznego/vintage. To może być **mocne playlistowe combo**:

**Sugerowana playlist:** `Motion & Journey — Deep House Soundtracks`

**Sugestie rozwoju osi:** `Highway Lights`, `Last Train Home`, `Tunnel Vision`, `Coastal Drive`, `Through the Valley`, `Speed of Memory`.

### YouTube SEO bonus

Cover jest **cinematic & dramatic** — idealny visual hook do YouTube thumbnail. Jeden ze zdecydowanie **najlepszych covers w całym katalogu** pod kątem CTR.

Sugerowany YT title: `The Locomotive — Cinematic Deep House Mix (2026 Driving Version) [Instrumental]`

---

## Pełne mapowanie osi tematycznych katalogu (stan na sekcję 17)

| Oś | Utwory case study | Liczba | Cover language | Sezonowość |
|---|---|---|---|---|
| **Sunset** | Old Love, Let's Talk About Music, Far Far Away | 3 | Sunset, plaża, horyzont | Lato/jesień |
| **Cosmos** | Lunar Harmony, The Journey | 2 | Gwiazdy, kosmos, noc | Zima (długie noce) |
| **Urban/Night** | Lunar Harmony (overlap) | 1+ | Skyline, neon | Całoroczny |
| **Motion/Transit/Journey** | **Time To Speed Up, The Locomotive** | **2 (NEW)** | Metro, pociąg, transit | Całoroczny |
| **Café/Lounge** | Fantastic World | 1 | Kawa, latte art | Całoroczny |
| **Summer Mix Series** | Summertime Melody MAX 07 (+01-06) | 7+ | Lato, pole, sunset | Stricte letni |
| **Water/Introspection** | Deep Water | 1 | Jezioro, mgła, samotność | Jesień/zima |

**Status katalogu:** 7 zidentyfikowanych osi tematycznych, 17 case studies, mocna struktura subkatalogów.

---

## 18. Case study: The Journey In the Time and Space (2026 Version) — re-release

Druga wersja klasycznego utworu z katalogu — fresh master, nowy cover, clean slug:
[soundcloud.com/maximummusicmaxx/journey-time-and-space-2026](https://soundcloud.com/maximummusicmaxx/journey-time-and-space-2026)

### Charakterystyka
- **Gatunek:** progressive / cosmic / melodic deep house (jak 2025 Edition)
- **Format:** re-release / 2026 version (nowy render w 24-bit/r8brain)
- **Cover:** **NOWY** — widok z okna samolotu, rozgwieżdżone niebo, spadająca gwiazda, sunset horyzont
- **Slug:** `journey-time-and-space-2026` ✅ **clean** (slug hygiene wdrożone perfekcyjnie!)
- **Stan początkowy:** tytuł = surowy slug (`journey-time-and-space-2026`), opis pusty
- **Track ID:** 2328506894
- **Mocna karta:** **cover znacznie mocniej match'uje tytuł niż oryginał** — airplane window = literal "Journey"
- **Słaba karta:** SC wziął nazwę pliku jako tytuł — typowy artefakt świeżego uploadu, do natychmiastowej korekty

### Tytuł — fix (najpilniejsze)

Aktualnie SC pokazuje raw slug. Zmień w SC:
```
The Journey In the Time and Space — Progressive Deep House (2026 Version)
```

> Tytuł w SC to **osobne pole** od slug'a — możesz mieć clean slug w URL ORAZ czytelny tytuł.

### Opis (bilingual PL/EN, z crosslinkiem do 2025 Edition) — gotowy do wklejenia

```
The Journey In the Time and Space (2026 Version) — instrumentalny
progressive / cosmic deep house o podróży przez gwiezdne pustkowia,
widzianej z okna samolotu sunącego przez świt nad horyzontem.
Głębokie pady, melodyjne syntezatory, miarowy puls — soundtrack
dla nocnej jazdy, długich spacerów pod gwiazdami i tych momentów,
w których patrzysz w niebo dłużej niż zwykle.

Odświeżona wersja jednej z bardziej osobistych kompozycji z mojego
katalogu — nowy cover, świeży master, ten sam kosmiczny vibe.

Jeśli kochasz progressive deep house, cosmic house, melodic house & techno
i klimat Anjunadeep, Lane 8, Yotto, Eli & Fur, ARTBAT
— ten utwór jest dla Ciebie.

🪐 Original / 2025 Edition: https://soundcloud.com/maximummusicmaxx/the-journey-in-the-time-and-space-edition-2025

— — —

The Journey In the Time and Space (2026 Version) — an instrumental
progressive / cosmic deep house track about a journey through starry
voids, seen from an airplane window gliding across the dawn horizon.
Deep pads, melodic synths and a steady pulse — a soundtrack for
night drives, long walks under the stars and any moment when you look
up at the sky longer than usual.

A refreshed version of one of my more personal compositions —
new artwork, fresh master, same cosmic vibe.

Perfect if you love progressive deep house, cosmic house, melodic house
& techno and the vibes of Anjunadeep, Lane 8, Yotto,
Eli & Fur and ARTBAT.

🪐 Original / 2025 Edition: https://soundcloud.com/maximummusicmaxx/the-journey-in-the-time-and-space-edition-2025

🌌 Best on headphones, under a clear sky
🛫 Follow for more cosmic deep house
💬 Where does this track take you?

#progressivedeephouse #cosmichouse #melodichouse #anjunadeep #spacemusic

▶ More tracks: https://soundcloud.com/maximummusicmaxx
🎵 Also on hearthis.at: https://hearthis.at/maximummusic
```

### Tagi — dwa formaty

**SC (cudzysłowy + spacja):**
```
"progressive deep house" "cosmic house" "melodic deep house" "space music" "deep house" "melodic house and techno" instrumental "anjunadeep" "deep house 2026" melodic
```

**hearthis.at (przecinek):**
```
progressive deep house, cosmic house, melodic deep house, space music, deep house, melodic house and techno, instrumental, anjunadeep, deep house 2026, melodic
```

### Pozostałe pola
| Pole | Wartość |
|---|---|
| Genre | `Deep House` (3-bucket rule) |
| BPM | typowo 120–125 (wpisz z DAW) |
| Key | minor (`Am`, `Cm`, `Dm`, `F#m`) |
| Sharing | `public` |
| Downloadable | `true` |
| License | `all-rights-reserved` |
| Commentable | `true` |
| Release date | rzeczywista 2026 |
| Label name | `Maximum Music` |
| ISRC | **NOWY ISRC** dla 2026 Version (różny niż 2025 Edition) |

### Strategia: 2 wersje tego samego utworu na profilu

Masz teraz **2 utwory pod tym samym tytułem** (2025 Edition + 2026 Version). To **atut**, ale wymaga porządku:

**Opcja A — Playlist "Versions & Mixes" (rekomendowana)**

Stwórz playlistę profilu:
```
Nazwa: The Journey — All Versions (2025 → 2026)
Opis: Wszystkie wersje mojego utworu "The Journey In the Time and Space"
       — od oryginału 2025 po 2026 Remaster. Wybierz swoją ulubioną.
```

**Opcja B — Cross-link pinned comments na obu utworach:**

Na **2026 Version**:
```
🛫 2026 Version — new artwork, fresh master, 24-bit r8brain render.
🪐 Original 2025 Edition: https://soundcloud.com/maximummusicmaxx/the-journey-in-the-time-and-space-edition-2025

💬 Which version do you prefer?
```

Na **2025 Edition**:
```
🪐 2025 Edition — the original version.
🛫 NEW 2026 Version (refreshed): https://soundcloud.com/maximummusicmaxx/journey-time-and-space-2026

💬 Which version hits harder?
```

Generuje **dyskusję porównawczą** = silny signal engagement.

**Opcja C — Wycofanie 2025 (NIE rekomendowane)** — tracisz historię + komentarze + plays count.

### Porównanie cover'ów 2025 Edition vs 2026 Version

| Element | 2025 Edition | 2026 Version |
|---|---|---|
| Visual | Purple sky + pines + aurora | **Airplane window + stars + dawn horizon + shooting star** |
| **Match z tytułem "Journey"** | Słaby (sosny = stationary) | **Bardzo silny** (airplane = literal journey) |
| **Match z "Time and Space"** | Średni (gwiazdy + zorza) | **Bardzo silny** (gwiazdy + spadająca gwiazda + horyzont) |
| **CTR na YouTube** | Średni | **Wysoki** (intymny POV przez okno samolotu) |
| **Sync potential** | OK | **Wysoki** (travel content, airlines, documentaries) |
| **Cosmiczny mood** | Wprost (kosmos) | Subtelniejszy (kosmos + przyziemny POV) |

**Cover 2026 jest flagship-tier.** Rekomendacja: użyć jako thumbnail YouTube + pitch do sync libraries z keywordami **travel, journey, dawn, airplane, contemplation, cosmic**.

### Insight: wdrożone rekomendacje z poprzednich case studies

Patrząc na 2026 Version, widać **wdrożenie wcześniejszych rekomendacji**:

| Rekomendacja | Skąd | Status |
|---|---|---|
| Slug hygiene (clean slug bez nazwy artysty) | Section 13 (Far Far Away) | ✅ Wdrożone |
| Render 24-bit / r8brain | Sekcja Render audit | ✅ Wdrożone |
| Filename bez "Maximum Music Maxx" prefix | Render audit | ✅ Wdrożone |
| Custom cover spójny z tytułem | Section thumbnail YT | ✅ Wdrożone (nowy cover) |
| Title z gatunkiem + rokiem | Multiple sections | ❌ **Do zrobienia** (aktualnie raw slug) |
| Bilingual description z hookiem | Multiple sections | ❌ Do zrobienia |

**3 z 5 rekomendacji wdrożone na poziomie pliku/uploadu. 2 do dokończenia w UI SC.**

---

## Źródła

- [SoundCloud Developers — API Guide](https://developers.soundcloud.com/docs/api/guide)
- [SoundCloud Developers — main portal](https://developers.soundcloud.com/)
- [SoundCloud Public API Specification (OpenAPI)](https://developers.soundcloud.com/docs/api/explorer/open-api)
- [SoundCloud Help — Public APIs](https://help.soundcloud.com/hc/en-us/articles/115003446727-SoundCloud-Public-APIs)
- [SoundCloud Help — Track Upload Settings & Metadata](https://help.soundcloud.com/hc/en-us/sections/46633476999451-Track-Upload-Settings-Metadata)
- [SoundCloud Backstage Blog — New API Track Object](https://developers.soundcloud.com/blog/soundclouds-new-api-track-object/)
- [SoundCloud Backstage Blog — Artist Name field](https://developers.soundcloud.com/blog/api-artist-metadata/)
- [Famups — SoundCloud SEO Guide](https://www.famups.com/blog/soundcloud-seo/)
- [AMW — SoundCloud Marketing Strategies](https://amworldgroup.com/blog/soundcloud-marketing)
- [UpDigital — How to Do SEO on SoundCloud](https://www.updigital.ca/blog/how-to-do-seo-on-soundcloud)
- [Musicfy — Best SoundCloud Tags](https://musicfy.lol/blog/best-soundcloud-tags)
- [Masterchannel — Upload & Optimize Music on SoundCloud](https://blog.masterchannel.ai/guide-to-uploading-music-to-soundcloud-what-to-know/)
- [RepostExchange — 8 Ways to Optimize Your SoundCloud](https://repostexchange.com/-m/blog/8-ways-optimize-your-soundcloud)
- [Symphonic Blog — SEO for Musicians](https://blog.symphonic.com/2025/07/15/seo-for-musicians-why-it-matters-and-how-to-use-it-2/)
