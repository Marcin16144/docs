# Audio i mikrofony

> Mikrofony wbudowane vs zewnętrzne, two-way audio (głośnik), RODO i nagrywanie dźwięku — co wolno, a czego nie w Polsce.
>
> Aktualizacja: 2026

## Po co dźwięk w CCTV

- **Weryfikacja zdarzeń** — krzyk, stłuczenie, alarm auta
- **Komunikacja two-way** — interfon z bramą, odstraszanie
- **Analityka audio** — krzyk, stłuczenie szkła (Hikvision, Axis Sound)
- **Dowód w postępowaniu** — rozmowa rejestruje motywy uczestników

**Ważne na wstępie.** Nagrywanie dźwięku w PL jest **znacznie bardziej restrykcyjne** niż obrazu. Sekcja prawna na końcu.

## Typy mikrofonów w CCTV

### Wbudowane (in-built)
- Elektretowy lub MEMS, w obudowie kamery
- Tani, często gratis w kamerach (literą „M" lub „Audio")
- Czułość ograniczona — 2–5 m
- Szum tła w obudowie wodoszczelnej (kondensacja, wibracje)
- Hikvision DS-2CD2347G2-LU (mic), Dahua IPC-HDW3441T-AS

### Zewnętrzne (line-in)
- Mikrofon kablem do wejścia kamery (3,5 mm jack lub klemy)
- Profesjonalne: Hikvision DS-2FP4022 (line), DS-2FP4023 (preamp)
- Zasilanie 5–12 V DC z kamery
- Lepsza jakość, optymalna pozycja
- Mikrofony paraboliczne (kierunkowe) do odległych źródeł

### Audio-over-coax (TVI/CVI)
- HD-TVI 4.0 i HD-CVI 3.0 obsługują audio po tym samym kablu
- Wymaga DVR z AoC (większość 2020+)
- Eliminuje osobny kabel audio

### Mikrofon w IP-cam — protokoły

| Protokół | Opis |
|---|---|
| G.711 (PCMA/PCMU) | standard ONVIF, 64 kbit/s |
| G.726 | ADPCM, 16–40 kbit/s |
| AAC-LC | lepsza jakość |
| RTSP audio | strumień równolegle z wideo |

## Charakterystyka mikrofonu

| Parametr | Wartość | Znaczenie |
|---|---|---|
| Czułość | −42 dB / 1 Pa | wyższa = czulszy |
| Pasmo | 50 Hz – 16 kHz | mowa 300–3400 Hz + tło |
| SNR | >58 dB | sygnał/szum |
| Charakterystyka | omni / kardioida | omni wszechkierunkowa |
| Max SPL | 110–120 dB | nie zniekształca |
| Zasięg | 3–10 m (omni) | realny |

## Two-way audio

Kamera z mic + głośnikiem (line out) = dwukierunkowa rozmowa:

- **Domofon przy drzwiach** — Hikvision DS-KH8350-WTE1
- **Odstraszanie** — „Widzę cię, idź stąd" po AI Human detection
- **Sklepy bezobsługowe**
- **Magazyny** — zdalne instrukcje

Sprzęt: Hikvision DS-2CD2T46G2-LSU/SL, Dahua IPC-HFW3441T-AS-LED-S2, Reolink, Eufy. Głośnik zewnętrzny: Hikvision DS-PA0103-B.

## Analityka audio

| Funkcja | Co wykrywa | Producent |
|---|---|---|
| Sudden rise/drop | nagłe zmiany głośności | standard 2026 |
| Scream detection | krzyk | Axis, Hik DeepInView |
| Gunshot detection | wystrzał | Axis, ShotSpotter |
| Glass break | stłuczenie szyby | Hik, Axis |
| Aggressive speech | agresywna intonacja | Axis (eksp.) |
| Vehicle alarm | alarm samochodowy | Axis |

## Aspekty prawne w Polsce

### Obraz vs dźwięk

Monitoring **wizyjny** — dopuszczalny w wielu kontekstach na podstawie uzasadnionego interesu (art. 6 ust. 1 lit. f RODO), pod warunkiem oznaczenia i informowania.

Monitoring **foniczny** — bardziej ograniczony. Rejestrowanie rozmowy bez wiedzy uczestników może naruszać:

- Art. 49 Konstytucji (tajemnica komunikowania)
- Art. 267 § 3 KK — bezprawne pozyskanie informacji (do 2 lat więzienia)
- Art. 23, 24 KC (dobra osobiste)
- RODO art. 9 — dane głosowe = biometryczne

### Stanowisko UODO

**Monitoring foniczny w przestrzeniach publicznych nie ma uzasadnienia prawnego** w trybie zwykłym. Wymagane:

- Konkretny incydent (operacja policyjna)
- Zgoda wszystkich rejestrowanych
- Wyjątki ustawowe (numery alarmowe)

### Kodeks pracy

Art. 22³ KP — monitoring wizyjny pracowników w określonym celu. **Nie obejmuje fonicznego** zwykle. Pracodawca chcący nagrywać rozmowy musi mieć szczególne uzasadnienie (call center, transport — z wyraźnym poinformowaniem).

### Co wolno

- **Domofon** — push-to-talk, krótkie zastosowanie
- **Call center** z ostrzeżeniem „rozmowa nagrywana"
- **Transport publiczny** — z oznaczeniem
- **Nagrywanie własnej rozmowy** — uczestnik rozmowy (orzecznictwo SN)
- **Two-way intercom** — push-to-talk, bez ciągłego nagrywania
- **Mieszkanie prywatne** — bez osób trzecich (uwaga na gości)

### Czego nie wolno

- Mikrofon na sklepie nagrywający klientów
- Mikrofon w biurze (bez szczególnego uzasadnienia)
- Mikrofon w restauracji/lokalu
- Ciągłe nagrywanie we wspólnych częściach budynków
- Mikrofon w taksówce bez zgody pasażerów
- Mikrofon w wynajmowanym mieszkaniu bez wiedzy najemcy

### Kary

RODO — do **20 mln EUR lub 4% obrotu** (w praktyce dziesiątki–setki tys. zł). KK art. 267 — do 2 lat więzienia, odpowiedzialność osobista administratora.

## Wnioski dla instalatora

1. W kamerach z mic wbudowanym — **domyślnie wyłącz audio** (Settings → Audio → Disable)
2. W obiektach komercyjnych — **nie podpinaj mic zewnętrznych** bez podstawy prawnej
3. W informacji o monitoringu dodaj „monitoring obejmuje rejestrację obrazu, bez dźwięku"
4. Dla intercomów — push-to-talk, nie ciągły nasłuch
5. Jeśli klient nalega — wymagaj pisemnego oświadczenia o ryzyku
6. Przy mieszkaniach prywatnych — informuj o ograniczeniach przy gościach (serwis, opiekunka)

## Praktyczne instalacje audio (dozwolone)

| Zastosowanie | Sprzęt | Tryb |
|---|---|---|
| Domofon analogowy | VTO Dahua, BCS | push-to-talk |
| Wideodomofon IP | Hikvision DS-KH9510-WTE1 | push-to-talk |
| Two-way w bramie | IP cam + mic + głośnik | push-to-talk via VMS |
| Nagrania własne | kamera prywatna z mic | własne zdarzenia |
| Call center | Genesys, Asterisk | z ostrzeżeniem |

## Co dalej

➡ [ANPR — odczyt tablic rejestracyjnych](02-07-anpr-rozpoznawanie.md)
