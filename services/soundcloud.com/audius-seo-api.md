# Audius — SEO + integracja API

> **TL;DR:** Audius to **najbliższy duchem odpowiednik SoundCloud z DZIAŁAJĄCYM API uploadu** — w przeciwieństwie do hearthis (read-only) i Deezer/Spotify (brak uploadu). **Rejestracja apki jest OTWARTA** (SoundCloud i Deezer często ją zamykają). Darmowy, decentralizowany (Web3), z oficjalnym **JavaScript SDK** do automatyzacji. Idealny do programowego wrzucania części z Twoich 268 utworów + silna społeczność electronic/deep house.

---

## 1. Audius vs SoundCloud (kontekst strategiczny)

| Cecha | Audius | SoundCloud |
|---|---|---|
| Upload przez API | ✅ **SDK (`createTrack`)** | ✅ OAuth (`POST /tracks`) |
| Rejestracja apki | ✅ **OTWARTA** | ⚠️ często zamknięta |
| Koszt | ✅ Darmowy | Free + Pro płatny |
| Model | Decentralizowany (Web3) | Korporacyjny |
| Społeczność | Electronic / EDM / deep house | Szeroka, mainstream |
| Payout dla artystów | Wyższy (brak pośrednika) | Niższy |
| Free API limit | **10 req/s, 500k/mc** | Limity OAuth |
| Discovery | Trending + genre feeds | Algorytm + playlisty |
| Web3 wymagane? | ❌ Nie musisz znać krypto | — |

**Werdykt:** Audius = **drugie najważniejsze miejsce po SoundCloud** dla Twojego API workflow. Otwarta rejestracja apki to przewaga — możesz zacząć od razu.

---

## 2. Dlaczego Audius dla Ciebie

1. **Otwarta rejestracja API** — zaczynasz dziś, bez czekania (SC/Deezer gatekeepują).
2. **JS SDK** — automatyzacja uploadu (czego nie zrobisz na hearthis bez browser automation).
3. **Electronic community** — deep house ma naturalną publikę; Audius wyrósł na EDM/electronic.
4. **Pełna metadata** — title, genre, mood, tags, description, releaseDate, cover, remix tracking.
5. **Wyższe payouty** — model decentralizowany, mniej pośredników.
6. **Bulk upload** — idealny do przeniesienia best-of z 268 utworów programowo.

---

## 3. Setup API — krok po kroku

### 3.1. Utwórz developer app
```
1. Zaloguj się na audius.co (konto Maximum Music Maxx)
2. Settings → "Manage Your Apps"
3. "Create new developer app"
4. Otrzymujesz: API Key + API Secret
```

### 3.2. Autoryzacja
- **API Key + Bearer Token** identyfikują aplikację i autoryzują zapis.
- **Operacje zapisu (upload) wymagają autoryzacji użytkownika** — przez "Log in with Audius" (OAuth) lub własne dane konta.
- Read-only (search, feeds) — bez autoryzacji użytkownika.

### 3.3. Limity (Free Plan)
- **10 requestów/sekundę**
- **500 000 requestów/miesiąc**
- Unlimited Plan — bez limitu (jeśli kiedyś potrzebne)

---

## 4. Instalacja SDK

```bash
npm install @audius/sdk
```

### Inicjalizacja (backend / Node.js)
```javascript
import { sdk } from '@audius/sdk'

const audiusSdk = sdk({
  apiKey: 'YOUR_API_KEY',
  bearerToken: 'YOUR_BEARER_TOKEN', // z autoryzacji użytkownika
})
```

> `apiKey` trzymaj po stronie serwera. Nigdy w frontendzie.

---

## 5. Upload utworu — pełny przykład (3 kroki)

Audius rozdziela upload na: **audio → cover art → metadata**.

```javascript
import fs from 'node:fs'

// KROK 1: Upload pliku audio
const trackBuffer = fs.readFileSync('path/to/journey-time-and-space-2026.mp3')
const audioUpload = audiusSdk.uploads.createAudioUpload({
  file: {
    buffer: Buffer.from(trackBuffer),
    name: 'journey-time-and-space-2026.mp3',
    type: 'audio/mpeg',
  },
  previewStartSeconds: 30, // 30-sek preview (opcjonalne)
})
const audioResult = await audioUpload.start()

// KROK 2: Upload cover art
const coverArtBuffer = fs.readFileSync('path/to/cover.png')
const imageUpload = audiusSdk.uploads.createImageUpload({
  file: {
    buffer: Buffer.from(coverArtBuffer),
    name: 'cover.png',
    type: 'image/png',
  },
})
const coverArtCid = await imageUpload.start()

// KROK 3: Utwórz track z metadanymi
const { data } = await audiusSdk.tracks.createTrack({
  userId: 'YOUR_USER_ID',
  metadata: {
    title: 'The Journey In the Time and Space (2026 Version)',
    description: 'Instrumental progressive / cosmic deep house...',
    genre: 'Deep House',
    mood: 'Yearning',
    tags: 'deep house, progressive deep house, cosmic house, melodic, instrumental, 2026',
    releaseDate: '2026-05-28',
    ...audioResult,
    coverArtSizes: coverArtCid,
  },
})
```

**Formaty audio:** MP3 (audio/mpeg), WAV, FLAC, AAC, OGG.
**Cover art:** PNG/JPG, min. 1000×1000 (zalecane).

---

## 6. Metadata — pola i wartości

### Pola
| Pole | Wymagane | Opis |
|---|---|---|
| `title` | ✅ | Tytuł utworu |
| `genre` | ✅ | Z enum Audius (patrz niżej) |
| `mood` | opcjonalne | Z enum Audius |
| `tags` | opcjonalne | String oddzielony przecinkami |
| `description` | opcjonalne | Opis (bilingual PL/EN OK) |
| `releaseDate` | opcjonalne | `YYYY-MM-DD`, nie w przyszłości |
| `coverArtSizes` | ✅ | CID z image upload |
| `previewStartSeconds` | opcjonalne | Start 30-sek preview |
| `isStreamGated` / `isDownloadGated` | opcjonalne | Monetyzacja (tip/USDC) |
| `remixOf` | opcjonalne | Parent track (dla remixów) |

### Genre — relevantne dla Ciebie
Audius ma enum gatunków. Dla Twojego katalogu:
- **`Deep House`** ← główny (3-bucket rule)
- `House`
- `Techno`
- `Progressive House`
- `Tech House`
- `Ambient`
- `Downtempo`
- `Electronic` (fallback)

> Pełną listę sprawdź w SDK (`Genre` enum) — Audius ma rozbudowaną taksonomię electronic.

### Mood — relevantne dla Twoich utworów
| Twój utwór | Sugerowany mood |
|---|---|
| The Journey (cosmic) | `Yearning` lub `Cool` |
| Old Love (emocjonalny sunset) | `Sentimental` lub `Romantic` |
| Far Far Away (dreamy) | `Peaceful` lub `Tender` |
| Deep Water (melancholic) | `Melancholy` lub `Brooding` |
| Time To Speed Up (driving) | `Energizing` lub `Fiery` |
| Let's Talk About Music (sunny) | `Upbeat` lub `Easygoing` |
| Fantastic World (café) | `Easygoing` lub `Cool` |
| Lunar Harmony (ambient) | `Peaceful` |

> Mood to **Audius-specific feature** — używaj go, bo Audius filtruje/rekomenduje po mood.

---

## 7. SEO / discovery na Audius

### Co działa
1. **Genre + Mood precyzyjnie** — Audius mocno filtruje feed po gatunku i nastroju. Dokładny genre + mood = lepsze trafienie do właściwej publiki.
2. **Tags** — string z przecinkami, jak na hearthis. Mix szeroki + niszowy.
3. **Trending** — Audius ma Trending per genre. Wczesne odtworzenia + reposty (jak na SC) podbijają.
4. **Reposty + favoryty** — silny sygnał w sieci Audius.
5. **Playlisty** — twórz i dołączaj (mood-series jak na innych platformach).
6. **Spójny cover** — cross-platform branding (te same artworky co SC/YT).

### Co inne niż SC
- **Web3 native audience** — bardziej tech-savvy, electronic-focused. Mniej mainstreamu, więcej niszy.
- **$AUDIO rewards** — aktywność (uploads, engagement) bywa nagradzana tokenami. Nie musisz tego ogarniać, ale to bonus.
- **Brak "share to download" spamu** jak na hearthis — czystszy feed.

### Tagi — format (przecinki, jak hearthis)
```
deep house, progressive deep house, cosmic house, melodic deep house, instrumental, electronic, deep house 2026, melodic
```

---

## 8. Mapping katalogu na Audius

| Utwór | Genre | Mood | Priorytet |
|---|---|---|---|
| The Journey (2026) | Deep House | Yearning | 🟢 wysoki (flagship cover) |
| The Locomotive | Deep House | Fiery | 🟢 wysoki (best performer) |
| Deep Water (Ext) | Deep House | Melancholy | 🟢 wysoki |
| Far Far Away | Deep House | Peaceful | 🟡 średni |
| Old Love | Deep House | Sentimental | 🟡 średni |
| Time To Speed Up | Deep House | Energizing | 🟡 średni |
| Lunar Harmony | Ambient | Peaceful | 🟡 średni (sync) |
| Let's Talk (sunny) | Deep House | Upbeat | 🟢 sezonowy (lato) |
| Fantastic World | Deep House | Easygoing | 🟡 średni |

**Strategia:** zacznij od **best-of 10-15** (jak na SC), nie wszystkich 268. Audius nagradza jakość + spójność, nie ilość.

---

## 9. Automatyzacja bulk upload (przewaga Audius)

Tu Audius bije hearthis — **możesz uploadować programowo**. Wzorzec:

```javascript
import fs from 'node:fs'

const catalog = JSON.parse(fs.readFileSync('catalog.json', 'utf-8'))
// catalog.json: [{ file, cover, title, genre, mood, tags, description, releaseDate }, ...]

for (const track of catalog) {
  try {
    // 1. audio
    const audioUpload = audiusSdk.uploads.createAudioUpload({
      file: {
        buffer: Buffer.from(fs.readFileSync(track.file)),
        name: track.file.split('/').pop(),
        type: 'audio/mpeg',
      },
      previewStartSeconds: 30,
    })
    const audioResult = await audioUpload.start()

    // 2. cover
    const imageUpload = audiusSdk.uploads.createImageUpload({
      file: {
        buffer: Buffer.from(fs.readFileSync(track.cover)),
        name: track.cover.split('/').pop(),
        type: 'image/png',
      },
    })
    const coverArtCid = await imageUpload.start()

    // 3. track
    await audiusSdk.tracks.createTrack({
      userId: process.env.AUDIUS_USER_ID,
      metadata: {
        title: track.title,
        description: track.description,
        genre: track.genre,
        mood: track.mood,
        tags: track.tags,
        releaseDate: track.releaseDate,
        ...audioResult,
        coverArtSizes: coverArtCid,
      },
    })
    console.log(`✅ Uploaded: ${track.title}`)
    await new Promise(r => setTimeout(r, 2000)) // backoff (10 req/s limit)
  } catch (e) {
    console.error(`❌ Failed: ${track.title}`, e.message)
  }
}
```

**Higiena:**
- **Backoff** między uploadami (limit 10 req/s, ale upload to ciężka operacja — daj 2-5s).
- **Clean filenames** (slug hygiene jak wszędzie).
- **Try/catch per track** — jeden błąd nie zatrzymuje całej pętli.
- **Loguj wyniki** do pliku — wiesz co weszło.
- **Trzymaj `apiKey` + `bearerToken` w env**, nie w kodzie.

---

## 10. Web3 — co musisz wiedzieć (mało)

- **Nie musisz znać krypto** by uploadować i budować publikę.
- Konto Audius = email/hasło (jak normalna platforma) LUB wallet.
- **$AUDIO token** — możesz dostawać za aktywność/popularność, ale to opcjonalny bonus, nie wymóg.
- **Monetyzacja** (stream/download gating za USDC) — opcjonalna, dla zaawansowanych. Na start: zwykły darmowy upload.

---

## 11. Checklist publikacji na Audius

- [ ] **Developer app** utworzona (Settings → Manage Your Apps) → API Key + Secret
- [ ] **SDK** zainstalowane (`npm install @audius/sdk`)
- [ ] **Autoryzacja użytkownika** (bearer token) skonfigurowana
- [ ] **Clean filename** audio (slug hygiene)
- [ ] **Genre** z 3-bucket rule (`Deep House` / `House` / `Ambient`)
- [ ] **Mood** dobrany do utworu (Audius-specific!)
- [ ] **Tags** (przecinki, niche + broad)
- [ ] **Description** bilingual PL/EN
- [ ] **Cover** spójny z SC/YT (cross-platform branding)
- [ ] **releaseDate** ustawiona (nie w przyszłości)
- [ ] **Backoff** w pętli przy bulk upload

---

## 12. Mapa ekosystemu (zaktualizowana)

```
Upload bezpośredni (Ty / API):
  • SoundCloud   → best-of single (API OAuth, gdy otwarte)
  • Audius       → katalog + automatyzacja (API SDK, OTWARTE) ← NOWE
  • Mixcloud     → DJ mixy (API, sections/tracklist)
  • hearthis.at  → archiwum (manual, brak upload API)
  • YouTube      → wideo + visualizer (manual)

Przez dystrybutora (RouteNote / Amuse):
  • Spotify, Apple Music, Deezer, Tidal
```

**Audius = jedyna platforma z OTWARTYM API uploadu + SDK do automatyzacji.** Najlepszy kandydat do programowego zarządzania katalogiem.

---

## Źródła

- [Audius — API](https://audius.org/api/)
- [Audius Developer Docs — Getting Started](https://docs.audius.co/)
- [Audius Dev Docs — Upload Track Metadata](https://docs.audius.co/developers/upload-track-metadata/)
- [Audius — JavaScript SDK](https://docs.audius.co/sdk/)
- [Audius SDK — Uploads](https://docs.audius.co/sdk/uploads)
- [Audius SDK — npm @audius/sdk](https://www.npmjs.com/package/@audius/sdk)
- [Audius API Docs — GitHub](https://github.com/AudiusProject/api-docs)
- [Musicfetch — Does Audius have an API?](https://musicfetch.io/services/audius/api)
