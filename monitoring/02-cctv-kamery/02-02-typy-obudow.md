# Typy obudów kamer

> Dome, bullet, turret/eyeball, fish-eye 180°/360°, PTZ, ukryte (pinhole), corner mount, antywandaliczne IK10.
>
> Aktualizacja: 2026

## Krótki przewodnik

| Typ | Wygląd | Montaż | Cena (4 MP IP) |
|---|---|---|---|
| **Dome** | półkula szklana | sufit | 250–500 zł |
| **Bullet** | cylinder z osłoną | elewacja, słupy | 300–600 zł |
| **Turret / Eyeball** | kula w stelażu | sufit/ściana | 280–550 zł |
| **PTZ** | półkula z silnikiem | słup, narożnik | 1 500–8 000 zł |
| **Fish-eye** | półkula 180°/360° | sufit centralny | 900–2 500 zł |

## Dome (kopułkowe)

- Soczewka schowana w kopułce z polikarbonatu/szkła
- Trudno zobaczyć dokąd skierowana — efekt zastraszający
- Trudna do zniszczenia (anti-vandal IK10)
- 3-osiowa regulacja (pan, tilt, rotate)
- IR LED 20–40 m — kopułka osłabia IR (halo)
- IP66/67, IK10 w wersjach komercyjnych
- Grzałki w zewnętrznych (od −30 °C)

**Halo effect.** IR LED odbija się od kopułki i daje obwódkę. Profesjonalne mają czarną opaskę wokół soczewki (light shield); tanie — nie. Do nocy zewnętrznej lepiej bullet/turret.

**Modele 2026:** Hikvision DS-2CD2143G2-IS (~480 zł), Dahua IPC-HDBW3441E-S (~520 zł), Hilook IPC-D140H (~280 zł).

## Bullet (tubowe)

- Wydłużony kształt, soczewka z osłoną przeciwsłoneczną (sun shield)
- Widoczny kierunek — zastrasza, ale wskazuje sprawcy
- Najlepszy zasięg IR — diody „na czołku", brak halo
- Wygodny montaż na elewacji
- IR 30–80 m, IP66/67, IK08–IK10
- Mikrofony rzadkie (uszczelnienie)

**Modele 2026:** Hikvision DS-2CD2T46G2-4I (4 MP, IR 80 m, ~580 zł), Dahua IPC-HFW3441T-ZAS (motozoom, ~750 zł), BCS-V-TIP35FSR3 (TVI 5 MP, ~330 zł).

## Turret / Eyeball

Hybryda dome i bullet — kula w otwartym stelażu. Pełna regulacja jak dome, bez kopułki:

- Brak halo (otwarta optyka)
- Dobra regulacja w 3 osiach
- Mniejszy opór powietrza niż bullet — lepsza odporność na wiatr
- Estetycznie neutralna — popularna na sufitach

**Modele 2026:** Hikvision DS-2CD2347G2-LU (4 MP, ColorVu, mic, ~600 zł), Dahua IPC-HDW3441T-ZAS (motozoom, ~700 zł).

## PTZ (Pan-Tilt-Zoom)

- **Pan** 360° w poziomie (bez końca obrotu)
- **Tilt** 90–180° w pionie
- **Zoom optyczny** 4×–60× (typowo 25×)
- Preset positions, auto-tour, auto-tracking
- Wymagają PoE++ 60 W lub osobny 24 V AC

### Klasy PTZ

| Klasa | Zoom | Wielkość | Cena | Zastosowanie |
|---|---|---|---|---|
| Mini PTZ | 4×–10× | ø 10 cm, 1 kg | 1 500–2 500 zł | sufit sklepu, lobby |
| Speed Dome | 20×–32× | ø 20 cm, 3 kg | 3 000–6 000 zł | parking, plac, stadion |
| Long-range | 40×–60× | ø 30 cm, 5 kg | 8 000–25 000 zł | perymetr, lotniska |
| Anti-corrosion | 30× | SS316 | 10 000–30 000 zł | statki, porty |

**Auto-tracking** w PTZ AI (Hikvision iDS-2DE7232MW-AB3, Dahua PSDW82431M-A270) — automatyczne podążanie za człowiekiem/pojazdem. Wymaga tour i powrotu do pozycji bazowej po X sekundach.

## Fish-eye (panoramiczne 180°/360°)

- Soczewka fisheye — 180° lub 360°
- Montaż centralny na suficie — cały pokój jedną kamerą
- Rozdzielczość 6–12 Mpx — pixel density spada na krawędziach
- De-warping (prostowanie) w kamerze/VMS — można wyciąć kilka wirtualnych widoków

**Zastosowania:** sklepy (1 kamera zamiast 4 narożnych), magazyny, sale konferencyjne, lobby, busy/tramwaje.

**Modele 2026:** Hikvision DS-2CD63C5G1-IVS (12 MP, ~3 800 zł), Dahua IPC-EBW8842 (8 MP, ~3 200 zł), Axis M3068-P (12 MP, ~5 500 zł).

## Kamery ukryte (pinhole)

- Soczewka 2–3 mm w obudowie (sufit, detektor dymu, ramka)
- Moduły do zabudowy

**Prawo.** Stosowanie kamery ukrytej w miejscu z oczekiwaną prywatnością (mieszkanie, biuro, hotel, toaleta, przebieralnia) jest **przestępstwem** — naruszenie miru, RODO, art. 193 KK. W obiektach komercyjnych monitoring musi być oznaczony.

## Corner mount (narożne)

Obudowa w narożniku pomieszczenia (cele, izby zatrzymań, sale szpitalne):

- Brak martwego pola w narożniku
- Trudna do zdarcia (stal, śruby zabezpieczone)
- IK10+ standard
- Często z mikrofonem i głośnikiem

## Kamery zewnętrzne — co liczy się w obudowie

### Stopień IP (PN-EN 60529)

| Kod | Pył | Woda | Zastosowanie |
|---|---|---|---|
| IP44 | obiekty 1 mm | rozbryzgi | wewnątrz osłonięte |
| IP54 | częściowy | rozbryzgi | łazienki, kuchnie |
| IP65 | pyłoszczelne | strumień | zewn. niekrytyczne |
| **IP66** | pyłoszczelne | silny strumień | **minimum dla zewnętrznych CCTV** |
| IP67 | pyłoszczelne | zanurzenie 1 m, 30 min | zalanie, śnieg |
| IP68 | pyłoszczelne | długie zanurzenie | podwodne, mycie WP |
| IP69K | pyłoszczelne | 80 °C, 100 bar | myjnie, food |

### Stopień IK (PN-EN 62262)

| Kod | Energia | Odpowiednik |
|---|---|---|
| IK06 | 1,0 J | upadek 0,5 kg z 20 cm |
| IK08 | 5,0 J | młotek 1,7 kg z 30 cm |
| **IK10** | 20,0 J | młotek 5 kg z 40 cm, kij baseballowy |

**Praktyka.** Zewnątrz: IP66 + IK10. Wewnątrz: IP4x + IK06/08. Baseny: IP67 + grzałki.

## Tabela decyzyjna

| Sytuacja | Rekomendacja |
|---|---|
| Wnętrze biura, sklepu | Dome lub Turret 4 MP |
| Elewacja domu, słup | Bullet 4 MP, IR 50 m, IP66 IK10 |
| Przedsionek, niski sufit | Turret 2.8 mm — szeroki kąt |
| Parking, plac | PTZ 25× z preset |
| Magazyn, sala konf. | Fish-eye 12 MP centralny |
| Brama (tablice) | Bullet ANPR motozoom 8–80 mm |
| Klatka schodowa | Dome anti-vandal IK10 5 MP |
| Cela, monitoring dziecka | Corner mount IK10 |
| Strzelnica, kuźnia | Bullet IP67 z grzałką, IR dual |

## Co dalej

➡ [Parametry kamer](02-03-parametry.md)
