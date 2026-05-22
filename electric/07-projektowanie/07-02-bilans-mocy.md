# Bilans mocy

Bilans mocy odpowiada na pytanie: **ile mocy faktycznie potrzebujemy z sieci**? Suma mocy wszystkich urządzeń (Pi) byłaby grubo przeszacowana — nigdy nie pracują naraz. Stąd współczynnik jednoczesności.

## Dwa kluczowe pojęcia

| Symbol | Nazwa | Definicja |
|---|---|---|
| **Pi** | moc zainstalowana | suma mocy znamionowej wszystkich odbiorników |
| **Pz** | moc zapotrzebowana | realnie pobierana z sieci szczyt |
| **kz** | współczynnik jednoczesności | Pz / Pi, dla domu 0,5-0,8 |

```
Pz = Pi · kz
```

## Typowe wartości kz

| Obiekt | kz |
|---|---|
| Dom jednorodzinny | **0,5 - 0,8** |
| Mieszkanie w bloku | 0,4 - 0,6 |
| Biuro | 0,7 - 0,8 |
| Sklep | 0,8 - 0,9 |
| Hala produkcyjna | 0,6 - 0,8 |
| Pojedynczy obwód oświetlenia | 0,8 - 1,0 |
| Pojedynczy obwód gniazd | 0,3 - 0,5 |

Im większy obiekt i więcej odbiorników, tym kz niższy.

## Tabela typowych odbiorników domowych

| Odbiornik | Moc [W] | Faza | Uwagi |
|---|---|---|---|
| Oświetlenie całego domu (LED) | 300-500 | 1F | przy 30-50 punktach |
| Gniazda ogólne | 2000 | 1F | suma typowa |
| Lodówka A++ | 100 | 1F | praca cykliczna |
| Pralka | 2000 | 1F | szczyt grzania |
| Suszarka | 2500 | 1F | |
| Zmywarka | 2000 | 1F | |
| Piekarnik | 3500 | 1F | |
| Płyta indukcyjna 4-polowa | 7400 | 3F | typowo na 3 fazy |
| Bojler 80 l | 2000 | 1F | |
| Czajnik / toster / mikrofala | 2000 | 1F | |
| Pompa ciepła 8 kW grzewczych | 4000 | 3F | el. wejściowa |
| Klimatyzacja split | 1500 | 1F | na jednostkę |
| Ładowarka EV (wallbox 11 kW) | 11000 | 3F | |
| Ładowarka EV (wallbox 22 kW) | 22000 | 3F | |
| Sauna fińska | 6000-9000 | 3F | |
| Brama garażowa, furtka | 200 | 1F | |
| Wentylacja mechaniczna (rekuperator) | 200-500 | 1F | |
| Komputer + monitor | 300 | 1F | |
| TV 55" + nagłośnienie | 200 | 1F | |
| Suszarka do włosów | 1800 | 1F | |

## Przykład — dom 100 m²

Założenia: 4-osobowa rodzina, kuchnia indukcyjna, bojler elektryczny, pompa ciepła, jedna ładowarka EV 11 kW.

| Grupa | Pi [kW] |
|---|---|
| Oświetlenie | 0,5 |
| Gniazda ogólne | 2,0 |
| AGD (lodówka, pralka, suszarka, zmywarka) | 4,0 |
| Płyta indukcyjna | 7,0 |
| Piekarnik | 3,5 |
| Bojler | 2,0 |
| Pompa ciepła | 4,0 |
| Ładowarka EV | 11,0 |
| **Suma Pi** | **≈ 34 kW** |

Po zastosowaniu kz = 0,5:

```
Pz = 34 · 0,5 = 17 kW
```

Przy strategii unikania jednoczesności (np. ładowarka EV załącza się po 22:00, gdy pompa zwalnia) realna szczytowa moc to ~15-17 kW.

## Przeliczenie na prąd przyłącza

Dla sieci 3-fazowej:

```
In = Pz / (√3 · U · cos φ)
In = 17000 / (√3 · 400 · 0,95) = 25,8 A
```

→ wybieramy **przyłącze 3F 32 A** (zabezpieczenie przedlicznikowe). Gdyby Pz = 15 kW → 25 A wystarczy.

Dla sieci 1-fazowej:

```
In = Pz / (U · cos φ) = Pz / 218,5
```

Mieszkanie 7 kW → 32 A jednofazowo (typowa wartość dla starszych bloków).

## Wybór taryfy

Taryfę dyktuje styl użytkowania, nie tylko moc:

| Taryfa | Charakterystyka | Dla kogo |
|---|---|---|
| **G11** | jednostrefowa, jedna stawka 24 h | brak dużych odbiorników, mało prądu |
| **G12** | dwustrefowa: dzień drogo, noc tanio (22:00-06:00) | bojler + zmywarka nocą |
| **G12w** | jak G12 + tanio w weekendy i święta | dom z pompą ciepła, duże zużycie |
| **G13** | trzystrefowa szczyt/poza-szczyt/noc | rzadko opłacalna prywatnie |

**Zasada:** im więcej zużywasz nocą i w weekendy, tym bardziej opłaca się G12w. Pompa ciepła + EV — niemal zawsze G12w.

## Margines i rezerwa

Do bilansu doliczamy zwykle **+15-25%** rezerwy na:

- przyszłe rozszerzenia (sauna, druga ładowarka, klimatyzacja całego domu)
- nieuwzględnione drobne odbiorniki
- pomyłki szacunkowe

Lepiej zamówić u OSD 25 A i mieć rezerwę, niż 20 A i co miesiąc wybijać zabezpieczenie.

## Co dalej

➡ [Liczba i rodzaje obwodów](07-03-liczba-obwodow.md)
