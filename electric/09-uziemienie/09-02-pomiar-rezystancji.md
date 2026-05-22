# Pomiar rezystancji uziemienia

## Co mierzymy

**Rz** — rezystancja statyczna uziomu wobec „ziemi odległej". Powinna być wystarczająco mała, żeby:

- prąd zwarciowy w układzie TT wywołał zadziałanie RCD/MCB,
- prąd pioruna spłynął do gruntu bez napięcia krokowego,
- napięcie dotykowe pozostało < 50 V AC.

## Dopuszczalne wartości Rz

| Zastosowanie | Maks. Rz | Norma |
|---|---|---|
| Układ TT (uziom roboczy z RCD 30 mA) | **<30 Ω** (praktycznie <10 Ω) | PN-HD 60364-4-41 |
| LPS — instalacja odgromowa | **<10 Ω** | PN-EN 62305-3 |
| Stacja transformatorowa | **<5 Ω** | PN-E |
| Sieci telekomunikacyjne | <5 Ω | branżowe |
| Centralka p.poż. | <10 Ω | branżowe |

Dla RCD 30 mA matematycznie wystarcza Rz = UL/IΔn = 50/0,03 = **1666 Ω**, ale w praktyce dążymy do <30 Ω ze względu na pewność zadziałania i wpływ wilgotności.

## Metoda 4-pinowa (Wennera)

Najprecyzyjniejsza metoda — niezbędna do pomiaru **rezystywności gruntu** (ρ).

```
    A ───────── E ───────── E' ───────── B
    |    a      |    a      |    a       |
[pin C1]   [pin P1]    [pin P2]    [pin C2]
    \__źródło prądu I__/      \__woltomierz U__/
```

- 4 sondy pomiarowe wbite w grunt w jednej linii, równe odstępy **a**,
- mernik przesyła prąd między C1 i C2,
- mierzy napięcie między P1 i P2,
- wynik: **ρ = 2π · a · R**, gdzie R = U/I.

Stosujemy gdy projektujemy uziom (znamy ρ → dobierzemy długość prętów).

## Metoda 3-pinowa — spadek napięcia 62%

Standardowy pomiar gotowego uziomu.

```
[badany uziom E] ───── d × 0,62 ───── [sonda potencjałowa P] ───── d × 1,0 ───── [sonda prądowa H]
```

Procedura:

1. wbij sondę prądową H **w odległości min. 20–30 m** od uziomu (im dalej, tym lepiej — dla domowego uziomu 25 m wystarcza),
2. wbij sondę potencjałową P na **62% odległości E–H** (np. 15,5 m dla 25 m),
3. mernik wymusi prąd I między E i H, zmierzy U między E i P,
4. wynik: **Rz = U/I** — odczytaj z miernika,
5. **kontrola:** przesuń P o ±2 m, wyniki powinny się różnić < 5%. Jeśli więcej — H jest za blisko, oddal go.

## Mierniki

| Model | Producent | Funkcje | Cena |
|---|---|---|---|
| **MRU-105** | Sonel | 3- i 4-pinowy, ρ gruntu, cęgi | ~3500 zł |
| **MRU-120** | Sonel | + selektywny pomiar (cęgi) | ~5500 zł |
| **MRU-200** | Sonel | + pamięć, Bluetooth, ρ pełne | ~7000 zł |
| **4140A** | Kyoritsu | 3-pinowy podstawowy | ~2500 zł |
| **MR-3000** | Eurotest | 3-pin + ciągłość | ~2000 zł |

Wzorcowanie miernika **co 13 miesięcy** w akredytowanym laboratorium — bez aktualnego świadectwa pomiar nieważny.

## Sezonowość — bardzo ważne

Rezystancja uziomu **silnie zależy od wilgotności i temperatury gruntu**:

| Pora roku | Współczynnik korekcyjny |
|---|---|
| Lato suche | ×1,0 (baseline) |
| Wiosna/jesień | ×1,2–1,5 |
| Zima (grunt zamarznięty) | **×3–5** |
| Pierwsze 6 mies. po montażu | ×1,5–2 (grunt nie osiadł) |

Praktyka: pomiar wykonujemy w **suchych warunkach jesienią lub latem** — wtedy wynik bliski wartości średniej rocznej. Pomiar zimą daje wartość zawyżoną, ale daje pewność, że nawet w najgorszym przypadku Rz spełnia wymagania.

## Procedura pomiarowa krok po kroku

1. **Odłącz uziom od instalacji** — odkręć zacisk w studzience kontrolnej lub na ścianie. Inaczej zmierzysz uziom + sieć (zawyżenie zaniżone).
2. **Wbij sondy** — sonda prądowa H w odległości 25–30 m, sonda potencjałowa P na 62%.
3. **Podłącz mernik:**
   - zacisk E (czerwony lub „rE") → uziom,
   - zacisk P (żółty) → sonda 15,5 m,
   - zacisk H (zielony lub niebieski) → sonda 25 m.
4. **Włącz pomiar 3p**, odczytaj Rz.
5. **Sprawdź ciągłość** kabla pomiarowego (przycisk „TEST" lub krótki obwód).
6. **Przesuń P** o ±2 m — kontrola błędu metody.
7. **Zapisz w protokole** — Rz, długość kabli, wilgotność gruntu, data.
8. **Podłącz uziom z powrotem**.

## Częstość pomiarów okresowych

| Obiekt | Częstość |
|---|---|
| Dom jednorodzinny, mieszkanie | **co 5 lat** |
| Obiekt użyteczności publicznej | co 1 rok |
| LPS (odgromówka) | co 5 lat (LPS IV) lub 1 rok (LPS I-II) |
| Po pracach budowlanych, dobudowie | bezwzględnie |
| Po uderzeniu pioruna | przegląd wzrokowy + ewentualnie pomiar |

## Przykład — dom jednorodzinny

Dom z uziomem otokowym FeZn 30×4 mm, obwód 40 m, gruntem glina sucha:

```
Pomiar 3-pinowy, jesień, sonda H = 25 m, P = 15,5 m
Mernik: Sonel MRU-105
Odczyt: Rz = 18,4 Ω
Kontrola P ±2 m: 18,1 / 18,6 — różnica <3% ✓

Wniosek: spełnia <30 Ω dla TT.
Gdyby planowana odgromówka — nie spełnia <10 Ω.
   → doegenezowanie: 2× pręt Cu/Fe 3 m + złącze krzyżowe.
```

## Co dalej

➡ [Połączenia wyrównawcze](09-03-polaczenia-wyrownawcze.md)
