# RAID i redundancja

**Sekcja:** 03 Rejestratory CCTV · **Aktualizacja:** 2026-05

RAID 1/5/6/10 w monitoringu — kiedy ciągłość zapisu jest ważniejsza niż pojemność. Hot-spare, czas odbudowy macierzy, ryzyko URE przy dużych dyskach i fundamentalna zasada: RAID to NIE backup.

## Po co RAID w CCTV

RAID (Redundant Array of Independent Disks) łączy wiele dysków w jedną logiczną jednostkę, dodając **redundancję** — odporność na awarię dysku bez utraty danych. W monitoringu ma to dwa konkretne cele:

- **Ciągłość zapisu** — gdy padnie jeden dysk, system nagrywa dalej z uszkodzonej macierzy (degraded mode). Nie ma luki w archiwum, nie tracisz materiału w momencie awarii.
- **Ochrona długiej retencji** — przy 60–90 dniach zapisu na dużych dyskach awaria pojedynczego HDD bez RAID oznacza utratę miesięcy nagrań. RAID pozwala wymienić dysk i odbudować dane.

RAID ma sens głównie w **większych systemach** (≥ 4 dyski, długa retencja, obiekty wymagające ciągłości — banki, lotniska, monitoring miejski). Dla domu z 1–2 dyskami prostszy i tańszy jest zwykły zapis + okresowy eksport krytycznych nagrań.

## Poziomy RAID — porównanie

| Poziom | Min. dysków | Tolerancja awarii | Pojemność użyteczna | Zastosowanie w CCTV |
| --- | --- | --- | --- | --- |
| **RAID 0** (stripe) | 2 | 0 — brak | 100% (N × dysk) | NIE dla CCTV — awaria 1 dysku = utrata całości; tylko wydajność |
| **RAID 1** (mirror) | 2 | 1 dysk | 50% (N/2) | małe NVR, 2 dyski — proste lustro, krytyczne nagrania |
| **RAID 5** (parity) | 3 | 1 dysk | (N−1) × dysk | średnie macierze 4–6 dysków, dobry kompromis pojemność/ochrona |
| **RAID 6** (double parity) | 4 | 2 dyski | (N−2) × dysk | duże macierze ≥ 6 dysków, długa retencja, bezpieczeństwo rebuildu |
| **RAID 10** (1+0) | 4 | 1–2 dyski (po 1 na lustro) | 50% (N/2) | najwyższa wydajność + odporność, krytyczne systemy o dużym bitrate |

### Przykłady pojemności (dyski 12 TB)

| Konfiguracja | Surowo | Użyteczne | Strata na redundancję |
| --- | --- | --- | --- |
| 4× 12 TB RAID 5 | 48 TB | 36 TB | 12 TB (1 dysk) |
| 4× 12 TB RAID 6 | 48 TB | 24 TB | 24 TB (2 dyski) |
| 4× 12 TB RAID 10 | 48 TB | 24 TB | 24 TB (lustra) |
| 6× 12 TB RAID 5 | 72 TB | 60 TB | 12 TB (1 dysk) |
| 6× 12 TB RAID 6 | 72 TB | 48 TB | 24 TB (2 dyski) |
| 8× 12 TB RAID 6 | 96 TB | 72 TB | 24 TB (2 dyski) |

## RAID 5 vs RAID 6 — kluczowy dylemat dużych macierzy

Przy dyskach 12–24 TB różnica między RAID 5 a RAID 6 przestaje być akademicka. Decyduje o niej **czas odbudowy** i **ryzyko URE**.

### Czas odbudowy (rebuild)

Po wymianie uszkodzonego dysku macierz musi **odtworzyć dane z parzystości** na nowym dysku. Dla dużych dysków to *dni*, nie godziny:

| Pojemność dysku | Orientacyjny czas rebuildu | Stan macierzy podczas rebuildu |
| --- | --- | --- |
| 4 TB | ~8–12 h | obciążona, wolniejsza |
| 12 TB | ~20–40 h | pełne obciążenie I/O wszystkich dysków |
| 18–22 TB | ~40–90 h | kilka dni pod stresem — ryzyko kolejnej awarii |

### Ryzyko URE

**URE (Unrecoverable Read Error)** to nieodwracalny błąd odczytu — statystycznie ~1 na 1014–1015 odczytanych bitów dla dysków klasy consumer/surveillance. Podczas rebuildu RAID 5 system musi odczytać *wszystkie* pozostałe dyski w całości. Przy dużych macierzach prawdopodobieństwo natrafienia na URE rośnie — a w RAID 5 (jedna parzystość, dysk już padł) **URE = przerwany rebuild i utrata danych**.

**RAID 5 jest ryzykowny przy dyskach ≥ 8–10 TB.** Jeśli podczas wielogodzinnego rebuildu jeden z pozostałych dysków zwróci URE lub padnie całkowicie (a są pod maksymalnym obciążeniem), tracisz całą macierz. Dlatego dla dużych dysków standardem jest **RAID 6** — toleruje awarię drugiego dysku i URE w trakcie odbudowy.

**Reguła doboru:** macierze do ~4 dysków 4–8 TB → RAID 5 akceptowalny. Macierze ≥ 6 dysków lub dyski ≥ 10 TB → **RAID 6** (lub RAID 10 dla wydajności). Im większy dysk i dłuższy rebuild, tym bardziej opłaca się druga parzystość.

## Hot-spare — dysk zapasowy

**Hot-spare** to dysk wpięty do macierzy, ale nieużywany — czeka w gotowości. Gdy padnie aktywny dysk, kontroler **automatycznie** zaczyna odbudowę na hot-spare, bez czekania na technika. Skraca okno ryzyka (czas w degraded mode), co przy długim rebuildzie dużych dysków jest kluczowe.

- **Global hot-spare** — jeden zapas obsługuje wszystkie macierze w urządzeniu.
- **Dedicated hot-spare** — przypisany do konkretnej macierzy.

Przykład: macierz **RAID 6 (6 dysków) + 1 hot-spare** = 7 zatok. Awaria dysku → automatyczny rebuild na spare → masz znów pełną podwójną parzystość, zanim ktokolwiek pojawi się na obiekcie. Dla zdalnych instalacji (maszt, obiekt bez obsługi) hot-spare jest wręcz obowiązkowy.

## Rejestratory i platformy z RAID

| Urządzenie | Zatoki | Obsługiwane RAID | Cena (2026) |
| --- | --- | --- | --- |
| **Hikvision DS-9664NI-I16** | 16 HDD | RAID 0/1/5/6/10 + hot-spare | ~9 800 zł (bez dysków) |
| **Hikvision DS-9632NI-I8** | 8 HDD | RAID 0/1/5/6/10 + hot-spare | ~5 200 zł |
| **Dahua NVR608-32-4KS2 (8-bay)** | 8 HDD | RAID 0/1/5/6/10 + hot-spare | ~6 400 zł |
| **Synology DVA3221 (Surveillance St.)** | 4 HDD | SHR / RAID 1/5/6/10 | ~3 900 zł |
| **QNAP TS-464 + QVR Pro** | 4 HDD | RAID 1/5/6/10 | ~2 700 zł |

### NVR z RAID vs NAS jako storage

- **NVR z RAID** (Hikvision I-series, Dahua 8-bay) — dedykowane urządzenie, prosta konfiguracja w GUI rejestratora, wsparcie producenta kamer end-to-end.
- **NAS + VMS** (Synology *Surveillance Station*, QNAP *QVR Pro*) — elastyczność, te same dyski mogą służyć też innym danym, zaawansowane SHR (Synology Hybrid RAID) pozwala mieszać pojemności dysków. Synology liczy licencje per kamera (2 gratis, kolejne płatne ~kilkadziesiąt zł/kamera).

Synology **SHR** (Synology Hybrid RAID) to ich nakładka na RAID, która optymalnie wykorzystuje dyski o *różnych pojemnościach* i upraszcza rozbudowę (dokładasz większy dysk, system sam realokuje parzystość). Dla mniejszych instalacji bywa wygodniejsza niż klasyczny RAID 5/6 ze sztywnym wymogiem identycznych dysków.

## RAID to NIE backup — zasada 3-2-1

Najczęstsze i najgroźniejsze nieporozumienie. RAID chroni przed **awarią sprzętową dysku** — i tylko przed nią. NIE chroni przed:

- **Kradzieżą / zniszczeniem rejestratora** — włamywacz zabiera lub niszczy NVR razem z całą macierzą RAID.
- **Pożarem / zalaniem** — wszystkie dyski w jednym urządzeniu giną razem.
- **Skasowaniem / sabotażem** — ktoś usuwa nagrania, RAID wiernie replikuje usunięcie.
- **Awarią kontrolera RAID / ransomware** — uszkodzona macierz lub zaszyfrowane dane to utrata mimo redundancji.

**RAID = wysoka dostępność, NIE kopia zapasowa.** Macierz, która przeżyje awarię dysku, nie przeżyje pożaru serwerowni ani złodzieja, który wyniesie rejestrator. To dwa różne problemy i dwa różne rozwiązania.

### Zasada 3-2-1

```
3 kopie danych
2 różne nośniki / media
1 kopia poza lokalizacją (offsite)
```

W praktyce CCTV pełny backup całego archiwum bywa nierealny (dziesiątki TB), dlatego stosuje się **backup zdarzeń krytycznych**:

- **Eksport incydentów** — nagrania alarmów/włamań natychmiast eksportowane na osobny dysk lub do chmury.
- **Drugi rejestrator / kamera w chmurze** dla najważniejszych punktów (wejście, kasa) — niezależny od głównego NVR.
- **Ukryty NVR zapasowy** — drugi rejestrator schowany w innym miejscu obiektu, równolegle nagrywający kluczowe kamery; gdy złodziej zniszczy główny widoczny rejestrator, materiał zostaje na ukrytym.
- **Kopia offsite** — synchronizacja eksportów na NAS w innej lokalizacji lub do chmury (S3, FTP).

Klasyczny scenariusz: złodziej wybija drzwi, zrywa widoczny rejestrator i wynosi. Cała macierz RAID 6 — bezużyteczna, bo fizycznie zniknęła. **Ukryty drugi NVR** lub kamera wysyłająca klatki do chmury (P2P/FTP w czasie rzeczywistym) to jedyne, co wtedy ocala materiał dowodowy. Redundancja dysków nic tu nie da.
