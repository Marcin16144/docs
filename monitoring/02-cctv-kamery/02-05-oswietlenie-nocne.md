# Oświetlenie nocne i tryb low-light

> IR LED 850 nm vs 940 nm, zasięg IR (10–100 m), Smart IR (anti-overexposure), Starlight (0,001 lux), color night vision z białym LED, ColorVu Hikvision, Full-Color Dahua.
>
> Aktualizacja: 2026

## Trzy filozofie nocnego CCTV

| Tryb | Źródło | Obraz | Widoczność dla intruza |
|---|---|---|---|
| **IR night vision** | diody IR 850/940 nm | B/W | diody świecą (850) lub niewidocznie (940) |
| **Starlight** | brak — księżyc, latarnie | kolor przy 0,01–0,001 lux | pasywna |
| **Color night vision** | białe LED + Starlight + algorytm | pełny kolor w nocy | LED widoczny (efekt latarki) |

## IR night vision

Kamera ma diody IR i mechaniczny **IR-cut filter** przed sensorem. W dzień filtr blokuje IR. W nocy filtr się odsuwa, diody włączają — obraz B/W.

### IR 850 nm vs 940 nm

| Cecha | 850 nm | 940 nm |
|---|---|---|
| Widoczność diod | słabe czerwone | praktycznie niewidoczne |
| Wrażliwość sensora | 90–100% | 40–60% |
| Zasięg przy tej samej mocy | 1,0× | 0,5–0,7× |
| PIR — wzbudzanie | możliwe | bezpieczniejsze |
| Koszt | standard | +10–20% |

**Wybór.** Dla 95% scenariuszy — **850 nm**. Czerwone świecenie jest nawet odstraszające. 940 nm tylko gdy zależy na maskowaniu kamer.

### Zasięg IR — co znaczą metry

| Deklarowany | Realna identyfikacja | LED | Modele |
|---|---|---|---|
| 10 m | 5–7 m | 2–6 LED | wnętrzne |
| 20 m | 10–15 m | 6–12 LED | standard |
| 30 m | 15–25 m | 2× array | standard zewn. |
| 50 m | 30–40 m | EXIR Hikvision | elewacja |
| 80 m | 40–60 m | 4× array | parking |
| 120 m | 70–90 m | laser IR (PTZ) | perymetr |
| 200–500 m | 150–300 m | laser IR | PTZ long-range |

**Trick.** „IR 30 m" = tylko detekcja. Dla rozpoznania twarzy: realna identyfikacja IR = **1/2 deklarowanego zasięgu**.

### Typy źródeł IR

- **LED IR rozproszone** — standard, kąt 60–120°
- **EXIR (Hikvision)** — soczewki skupiające, równomierne oświetlenie
- **Matrix IR (Dahua)** — odpowiednik EXIR
- **Smart IR / IR-array** — diody sterowane niezależnie
- **Laser IR** — kierunkowy, 100–500 m, PTZ long-range

## Smart IR — anti-overexposure

Klasyczne IR ma dwa problemy:

1. Obiekt bliski (1–2 m) **prześwietlony** (biała plama)
2. Obiekt daleki ciemny

Smart IR mierzy odległość/jasność obiektu i **dynamicznie obniża moc IR** dla bliskich. Twarz nie jest spalona przy podejściu.

### Warianty zaawansowane

- **EXIR 2.0 (Hikvision)** — dwie strefy IR (bliska + daleka)
- **IR Adaptive (Dahua)** — zmiana intensywności + kąta z motozoomem

## Starlight (low-light bez IR)

Sensory **Sony Starvis** z bardzo wysoką czułością + obiektyw F1.0–F1.4. Obraz kolorowy przy świetle księżyca/latarni.

| Sensor | Min. iluminacja | Pixel pitch | Format |
|---|---|---|---|
| Sony IMX291 | 0,01 lux | 2,9 µm | 1/2.8" 2 MP |
| Sony IMX335 | 0,005 lux | 2,0 µm | 1/2.8" 5 MP |
| Sony IMX415 | 0,005 lux | 1,45 µm | 1/2.8" 8 MP (4K) |
| Sony IMX678 | 0,003 lux | 2,0 µm | 1/1.8" 8 MP (4K Pro) |
| OmniVision OS08A20 | 0,01 lux | 2,0 µm | 1/1.8" 4K |

**Skala luksów:**

- Bezksiężycowa noc: 0,0001 lux
- Księżyc w pełni: 0,1 lux
- Słaba latarnia: 1 lux
- Dobre oświetlenie chodnika: 10 lux
- Pochmurny dzień: 1 000 lux
- Słoneczny dzień: 100 000 lux

## Color night vision — ColorVu, Full-Color

Najnowsza generacja (2020+): Starlight + F1.0–F1.2 + **biały LED**. Pełny kolor w głębokiej nocy.

### Hikvision ColorVu

- Sensor 1/1.8", F1.0
- Biały LED do 30 m
- Tryby: Always color / Smart hybrid / Schedule
- Modele: DS-2CD2347G2-LU, DS-2CD2T87G2-L, DS-2CD3T56G2-2I

### Dahua Full-Color

- Sensor 1/1.8", F1.0
- Biały LED do 40 m
- Tryby: Color 24/7 / **Smart Dual-light** (kolor + IR jednocześnie!) / IR only
- Modele: IPC-HDW3841EM-AS, IPC-HFW5849T1-ASE-LED, IPC-HDBW5249H

**Smart Dual-light** (Dahua) — innowacja 2022+: jednoczesne LED + IR. Kolor + dodatkowe IR na większych odległościach.

## Warunki używania białego LED

**Świeci jak latarka.** Biały LED 6500 K, kąt 90°, 5–10 W, 30+ m. Dla sąsiadów to zanieczyszczenie świetlne:

- W mieszkaniówce — tryb **Smart hybrid** (LED tylko na ruch)
- Harmonogram (LED 22:00–6:00, w dzień Starlight)
- Kierunek LED w dół, nie w okna
- Sprawdź prawo lokalne (samorządy mogą regulować)

## Tabela decyzyjna

| Scenariusz | Rekomendacja |
|---|---|
| Mieszkanie wewnątrz | IR 850 nm 10 m |
| Sklep, supermarket | Starlight (jest oświetlenie awaryjne) |
| Ogród prywatny | ColorVu z LED 30 m, Smart hybrid |
| Parking firmowy | Starlight + IR 50 m |
| Brama (twarz kierowcy) | ColorVu lub Full-Color |
| Magazyn ciemny | IR 850 nm 30 m, dual array |
| Wojskowy / dyskretny | IR 940 nm |
| Długi zasięg perymetru | Laser IR PTZ + Starlight stacjonarna |
| ANPR | IR 850 nm + filtr IR |

## Pułapki nocnego CCTV

- **Pajęczyny** — pająki + IR + owady = białe smugi i fałszywe alarmy. Spray co 2–3 miesiące.
- **Owady** — komary/ćmy świecą w IR jak punkty. Filtruj AI Human/Vehicle.
- **Halo IR w kopułkach** — patrz 02-02.
- **Odbicie IR od białej ściany** — kamera blisko ściany → prześwietlenie.
- **Promienie słońca nad ranem/wieczorem** — IR-cut nie nadąża, obraz różowy.
- **Mgła** — IR rozprasza się w mgle. ColorVu lepszy.
- **Mróz** — modele <−20 °C bez grzałki mogą zamarzać.

## Test nocnej kamery

1. Wyłącz wszystkie źródła zewnętrzne
2. Stań w odległości deklarowanego zasięgu
3. Spróbuj odczytać tekst na kartce A4
4. Podejdź 1 m — twarz nie spalona? (Smart IR działa?)
5. Przejdź szybko (3–4 m/s) — motion blur?
6. Sprawdź narożniki kadru — równe oświetlenie?

## Co dalej

➡ [Audio i mikrofony](02-06-audio-mikrofony.md)
