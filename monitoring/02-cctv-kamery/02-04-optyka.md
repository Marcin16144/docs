# Optyka kamer

> Ogniskowa (2.8 / 3.6 / 4 / 6 / 8 / 12 mm), kąt widzenia, varifocal manualny, motozoom zdalny, Auto-IRIS, P-IRIS, F-stop, IR-corrected.
>
> Aktualizacja: 2026

## Ogniskowa f — pierwsza decyzja

| Ogniskowa | Kąt H (1/2.8") | Kąt H (1/1.8") | Zastosowanie |
|---|---|---|---|
| 1,68 mm | 180° | — | fish-eye |
| 2,1 mm | 140° | — | szeroki kąt, niska recepcja |
| **2,8 mm** | **110°** | 120° | **standard wnętrza, korytarz** |
| 3,6 mm | 90° | 100° | standard zewnątrz, ogród |
| 4 mm | 78° | 87° | elewacja, brama 5–10 m |
| 6 mm | 56° | 60° | parking 15 m, brama |
| 8 mm | 42° | 45° | parking 20–30 m, ANPR bliski |
| 12 mm | 28° | 30° | identyfikacja 30 m, ANPR |
| 16 mm | 22° | 24° | identyfikacja 40–50 m |
| 25 mm | 14° | 15° | długi zasięg, ANPR 50 m |
| 50 mm | 7° | — | alejki, perymetr |

**Wzór na kąt widzenia:**

```
AoV = 2 · arctan(W / 2f)
W = szerokość sensora [mm], f = ogniskowa [mm]
```

## Kąt widzenia 3D

- **HFOV** — kąt poziomy (zwykle podawany)
- **VFOV** — kąt pionowy (~aspect ratio)
- **DFOV** — kąt przekątny

Przy 16:9 i HFOV 90°: VFOV ≈ 50°, DFOV ≈ 105°.

## DORI — reguła pikseli na metr (PN-EN 62676-4)

| Cel | px/m osoba | Co rozpoznasz |
|---|---|---|
| **Detection** | 25 | obecność |
| **Observation** | 62 | cechy (płeć, sylwetka) |
| **Recognition** | 125 | znana osoba |
| **Identification** | 250 | nieznana osoba |

ANPR: **150–200 px na szerokości tablicy** (520 mm).

**Przykład.** Kamera 4 MP (2560 px), f = 4 mm, HFOV 78°, sensor 1/2.8", odległość 10 m:

```
W = 2 · 10 · tan(78°/2) = 16,2 m
Gęstość: 2560 / 16,2 = 158 px/m → recognition, za mało do identification
```

## Typy mocowania

| Mocowanie | Rozmiar | Sensor max | Zastosowanie |
|---|---|---|---|
| **M12** (board) | gwint 12 mm | 1/2.8" | kompaktowe, modułowe |
| **CS-mount** | 17,53 mm | 2/3" | z wymiennym obiektywem |
| **C-mount** | 17,53 + 5 mm | 1" | przemysłowe |

## Varifocal vs Fixed vs Motozoom

### Fixed
- Najtańsze, najmniejsze obudowy
- Brak regulacji — dobierz f przed zakupem
- Standard 2.8 / 3.6 / 4 mm

### Varifocal (manualny)
- Regulacja śrubokrętem (2,7–13,5 mm)
- Ustawia się raz przy montażu
- Najlepszy stosunek jakości do ceny dla nietypowych odległości
- Wymaga drabinki przy korekcie

### Motozoom (zdalny zoom + autofocus)
- Zdalna zmiana ogniskowej z VMS/NVR/app
- Zakresy: 2,7–13,5 mm; 8–32 mm; 8–80 mm (ANPR)
- Cena +200–400 zł
- Niezastąpiona przy kamerach >4 m wysokości
- Często z motorized iris

## Iris (przesłona)

| Typ | Działanie | Zastosowanie |
|---|---|---|
| **Fixed Iris** | stała — sensor reguluje czasem ekspozycji | wnętrza |
| **Manual Iris** | regulacja śrubką | stałe sceny zewn. |
| **Auto-IRIS** (DC drive) | sterowany napięciem | zmienne oświetlenie zewn. |
| **P-IRIS** | silnik krokowy, precyzyjny F-stop | premium |

### F-stop

| F-stop | Względna ilość światła | Kamery |
|---|---|---|
| F0.95–F1.0 | 4× więcej niż F2.0 | flagship ColorVu |
| **F1.2–F1.4** | 2,8× więcej | **standard ColorVu/Starlight** |
| F1.6 | 1,5× więcej | średnia klasa |
| F2.0 | baza | budżet |
| F2.8 | 2× mniej | tanie OEM |

Większa apertura = więcej światła, ale mniejsza głębia ostrości (DoF). W F1.0 osoby <1 m mogą być nieostre.

## IR-corrected lens

Specjalne pokrycie utrzymuje ostrość w świetle widzialnym (400–700 nm) i podczerwonym (850/940 nm). Bez korekcji obraz w nocy rozmyty (focus shift).

**Test.** Jeśli dzień ostry, a noc (IR) miękka — masz obiektyw bez korekcji IR.

## Aberracje optyczne

| Aberracja | Objaw | Rozwiązanie |
|---|---|---|
| Dystorsja beczkowata | linie wyginają się na krawędziach | de-warping (fisheye) |
| Aberracja chromatyczna | kolorowe obwódki | elementy ED, achromatyczne |
| Vignetting | ciemne narożniki | większa apertura |
| Flare | białe smugi | multi-coating, osłona |

## Wzór na dobór ogniskowej

```
HFOV [°] = 2 · arctan( (rozdz_px / gęstość_px_m) / (2 · odległość_m) )
```

**Przykład.** Identyfikacja (250 px/m) na 8 m, kamera 4 MP (2560 px), sensor 1/1.8":

```
W = 2560 / 250 = 10,24 m
HFOV = 2 · arctan(10,24 / 16) = 65°
→ ogniskowa ok. 5 mm (między 4 a 6 mm)
```

## Wybór ogniskowej dla typowych scenariuszy

| Scenariusz | Odległość | Cel | f (4 MP, 1/2.8") |
|---|---|---|---|
| Recepcja, hol | 3–5 m | identyfikacja | 2,8 mm |
| Korytarz | 5–10 m | recognition | 2,8–3,6 mm |
| Brama pieszych | 2–4 m | twarz | 3,6–4 mm |
| Podjazd garaż | 5–8 m | identyfikacja + auta | 4 mm |
| Brama wjazdowa | 8–15 m | kierowca | 6 mm |
| Ogród perymetr | 15–25 m | detekcja+recognition | 8 mm |
| Parking ANPR | 15–25 m | tablice | 8–12 mm motozoom |
| Parking 30 m | 30 m | tablice | 12–25 mm motozoom ANPR |
| Alejka | 40–60 m | detekcja | 16–25 mm |
| Perymetr fabryki | 50–100 m | obserwacja | 25–50 mm motozoom |

## Co dalej

➡ [Oświetlenie nocne i tryb low-light](02-05-oswietlenie-nocne.md)
