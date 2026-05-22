# Pętla zwarcia i Zs

## Definicja pętli zwarcia

**Pętla zwarcia** to zamknięta droga elektryczna, którą przepływa prąd zwarciowy w przypadku awaryjnego zwarcia między przewodem fazowym L a przewodem ochronnym PE (lub uziemioną obudową).

```
[transformator]
      │
      ├── L ──── kabel ──── tablica ──── obwód ──── [USZKODZONY ODBIORNIK]
      │                                                    │
      │                                                    × zwarcie L→PE
      │                                                    │
      └── PE ─── kabel ──── tablica ←──── przewód PE ──────┘
```

Wartość prądu zwarciowego zależy od **impedancji całej pętli Zs**:

```
Ik = Uo / Zs
```

gdzie **Uo = 230 V** (napięcie fazowe), **Zs** [Ω] — impedancja pętli zwarcia.

## Warunek samoczynnego wyłączenia (PN-HD 60364-4-41)

Po zwarciu zabezpieczenie nadprądowe (MCB) musi zadziałać w **wymaganym czasie** — krótszym, niż napięcie dotykowe stanie się groźne dla życia.

```
Uo / Zs ≥ Ia
```

gdzie **Ia** — prąd zapewniający zadziałanie zabezpieczenia w wymaganym czasie.

### Wymagane czasy wyłączenia

| Układ sieci | Uo ≤ 120 V | 120 < Uo ≤ 230 V | 230 < Uo ≤ 400 V |
|---|---|---|---|
| **TN** | 0,8 s | **0,4 s** | 0,2 s |
| **TT** | 0,3 s | **0,2 s** | 0,07 s |

Dla standardowego domu (TN-C-S, 230 V) → wymagany czas **t ≤ 0,4 s**.

W praktyce ten warunek najczęściej zapewnia **RCD 30 mA** (wyłącza w <30 ms), ale norma wymaga, by **MCB sam wyłączył w 0,4 s** — RCD jest dodatkowym (rezerwowym) zabezpieczeniem.

## Prąd Ia dla MCB

Wkładki MCB mają **charakterystyki B / C / D** — różny mnożnik In dla wyłączenia magnetycznego (≤ 0,1 s):

| Charakterystyka | Próg magnetyczny | Zastosowanie |
|---|---|---|
| **B** | 3–5 × In | obwody domowe (gniazda, oświetlenie) |
| **C** | 5–10 × In | obwody z udarami (silniki, świetlówki) |
| **D** | 10–20 × In | duże silniki, transformatory |

Aby zapewnić wyłączenie w 0,4 s, prąd zwarciowy musi przekroczyć **górną granicę** progu:

- B: **Ia = 5 × In**
- C: **Ia = 10 × In**
- D: **Ia = 20 × In**

## Tabela maksymalnych dopuszczalnych Zs

```
Zs_max = Uo / Ia = 230 / Ia
```

| MCB | In | Charakterystyka B (Ia=5×In) | Charakterystyka C (Ia=10×In) | Charakterystyka D (Ia=20×In) |
|---|---|---|---|---|
| B6 / C6 / D6 | 6 A | **7,67 Ω** | 3,83 Ω | 1,92 Ω |
| B10 / C10 / D10 | 10 A | **4,57 Ω** *(praktycznie 4,60)* | 2,30 Ω | 1,15 Ω |
| B13 / C13 | 13 A | 3,54 Ω | 1,77 Ω | — |
| B16 / C16 / D16 | 16 A | **2,87 Ω** | **1,45 Ω** | 0,72 Ω |
| B20 / C20 / D20 | 20 A | **2,30 Ω** | **1,15 Ω** | 0,58 Ω |
| B25 / C25 | 25 A | 1,84 Ω | 0,92 Ω | 0,46 Ω |
| B32 / C32 / D32 | 32 A | 1,44 Ω | 0,72 Ω | 0,36 Ω |
| B40 / C40 | 40 A | 1,15 Ω | 0,58 Ω | 0,29 Ω |
| B63 / C63 | 63 A | 0,73 Ω | 0,37 Ω | 0,18 Ω |

**Najczęstsze przypadki w domu:**

- gniazda 16 A B → **Zs ≤ 2,87 Ω**
- gniazda 20 A B → **Zs ≤ 2,30 Ω**
- oświetlenie 10 A B → **Zs ≤ 4,57 Ω**
- kuchnia 16 A C → **Zs ≤ 1,45 Ω**

## Pomiar Zs

Wykonuje się mernikiem **MZC** (Miernik impedancji pętli zwarciaowej):

- **Sonel MZC-300/320/335** — najczęściej w Polsce,
- **Kyoritsu 4140A**,
- **Megger LTW325, LTW335**.

Procedura:

1. **Włącz instalację** pod napięcie (Zs mierzy się przy zasilaniu — to badanie w warunkach roboczych),
2. **Wybierz najodleglejsze gniazdo** każdego obwodu (najgorszy przypadek — najwyższe Zs),
3. **Podłącz mernik** — przewody L (faza), N (neutralny), PE,
4. **Wciśnij pomiar** — mernik symuluje zwarcie L→PE, przepuszczając prąd 25 A przez ok. 30 ms,
5. **Odczyt Zs** [Ω] i wyliczony **Ik** [A],
6. **Porównaj** z tabelą Zs_max,
7. **Zapisz wynik** w protokole.

### Korekcja Zs przy odbiorze

Norma dopuszcza zastosowanie **współczynnika 2/3** do Zs zmierzonej:

```
Zs_obliczeniowe = Zs_zmierzone × (2/3)
```

To zapas na warunki ciepłego/zimnego przewodu (temperatura w czasie zwarcia → wzrost rezystancji o 20–30%). Czyli jeśli Zs_max wg tabeli to 2,87 Ω, mernik powinien pokazać **Zs ≤ 1,91 Ω**.

W praktyce mernik często ma już wbudowaną tę korekcję — sprawdź w instrukcji.

## Kiedy Zs jest za duża

Pomiar pokazuje Zs większe niż dopuszczalne. Co robić?

1. **Zwiększ przekrój kabla** — Zs zmaleje proporcjonalnie. Np. 2,5 → 4 mm² obniża Zs o ~40%.
2. **Skróć obwód** — Zs maleje liniowo z długością. Czasem trzeba dodać kolejną rozdzielnicę bliżej odbiornika.
3. **Zmień charakterystykę** z C na B (jeśli to możliwe — uważaj na udary).
4. **Polepsz uziemienie** (układ TT) — niższa Rz uziomu = niższa Zs.
5. **Dodaj RCD jako zabezpieczenie uzupełniające** — RCD 30 mA wyłączy w <30 ms nawet przy Zs = 1000 Ω, ale to **obejście problemu**, nie rozwiązanie zgodne z PN.

## Przykład — pomiar w gnieździe kuchennym

Obwód: kabel YDY 3×2,5 mm², długość 18 m, MCB B16, rozdzielnica TN-C-S.

```
Mernik: Sonel MZC-300
Zmierzono w najodleglejszym gnieździe:
  Zs = 1,21 Ω
  Ik = 230/1,21 = 190 A

Wymagane: Zs_max (B16) = 2,87 Ω
Korekcja 2/3: 2,87 × 2/3 = 1,91 Ω
Wynik 1,21 Ω < 1,91 Ω → OK ✓

Czas wyłączenia: 190 A > 5×16=80 A → magnetyczny próg B
   przekroczony → wyłączenie w <0,1 s. ✓
```

## Powiązanie z RCD

Jeśli pomiar pokazuje **Zs > Zs_max**, to przy realnym zwarciu prąd nie wzrośnie do progu magnetycznego MCB — wyłączenie zajmie sekundy zamiast 0,4 s. Wtedy:

- **RCD wyłączy zamiast MCB** w 30 ms (bo prąd różnicowy IΔ = Ik, znacznie powyżej 30 mA),
- ale formalnie instalacja **nie spełnia warunku samoczynnego wyłączenia bez RCD**,
- przy odbiorze inspektor może zażądać przeróbki, mimo że RCD „uratuje".

W kategorycznych wymogach (np. obwody bez RCD — przemysł) musimy mieć **Zs < Zs_max bezwarunkowo**.

## Co dalej

➡ [Sekcja 10 — Ochrona przeciwprzepięciowa](../10-przepiecia/index.html)
