# Protokół pomiarowy

## Po co protokół

Protokół pomiarowy to **dokument prawny** potwierdzający, że instalacja elektryczna:

- spełnia wymagania PN-HD 60364-6,
- została sprawdzona przez **osobę uprawnioną** (SEP G1 D z kategorią pomiarową),
- jest **bezpieczna w eksploatacji**.

Bez protokołu:

- inspekcja odbiorowa nie przyjmie instalacji,
- ubezpieczyciel może odmówić wypłaty po pożarze instalacji elektrycznej,
- przy sprzedaży nieruchomości nabywca może żądać aktualnych pomiarów,
- inspekcja BHP w obiekcie publicznym zamknie obiekt.

Norma: **PN-HD 60364-6**, **rozporządzenie MGPiPS z 28.04.2003 ws. szczegółowych zasad bhp przy eksploatacji urządzeń energetycznych**.

## Komplet protokołów dla nowej instalacji domowej

Standardowy „komplet 5":

1. **Protokół z pomiaru rezystancji izolacji (Riso)** — wszystkie obwody, kombinacje L-N, L-PE, N-PE,
2. **Protokół z pomiaru impedancji pętli zwarcia (Zs)** — każdy obwód, najodleglejszy punkt,
3. **Protokół z testu wyłączników różnicowoprądowych (RCD)** — wszystkie RCD,
4. **Protokół z pomiaru rezystancji uziemienia (Rz)** — uziom + ewentualnie LPS,
5. **Protokół z pomiaru ciągłości PE i połączeń wyrównawczych** — wszystkie obwody + GSW + MSW.

Plus opcjonalnie:

6. Sprawdzenie kolejności faz (TN-S, 3-faz),
7. Pomiar oświetlenia (jeśli wymagany — przemysł, biura),
8. Pomiar SPD (Up).

## Zawartość protokołu — checklist

Każdy protokół musi zawierać:

### Nagłówek

- **dane obiektu**: adres, nazwa, właściciel,
- **rodzaj instalacji**: nowa / istniejąca / po remoncie,
- **układ sieci**: TN-C / TN-S / TN-C-S / TT / IT,
- **napięcie nominalne**: 230 V / 400 V,
- **maks. prąd zabezpieczenia przedlicznikowego**: np. 25 A (1-faz) / 25 A (3-faz),
- **data pomiarów**,
- **warunki**: temperatura, wilgotność, pogoda.

### Mierniki

Dla każdego użytego miernika:

- **producent, model**,
- **numer seryjny**,
- **klasa dokładności**,
- **data ostatniego wzorcowania** + numer świadectwa,
- **data następnego wzorcowania** (typowo +13 mies.).

Bez aktualnego świadectwa wzorcowania **protokół jest nieważny**.

### Wyniki pomiarów

Tabelarycznie:

```
| Obwód / element | Typ pomiaru | Wartość zmierzona | Wartość dopuszczalna | Ocena |
```

Każdy wiersz to jeden pomiar. Wartości w jednostkach (Ω, MΩ, ms).

### Uwagi

Wszelkie odstępstwa od standardu, propozycje napraw, ograniczenia (np. „nie zmierzono obwodu kuchni z powodu niedostępu do gniazda").

### Wnioski

Jednoznaczna ocena instalacji:

- **„Instalacja spełnia wymagania PN-HD 60364-6 i może być oddana do eksploatacji"**, lub
- **„Instalacja nie spełnia wymagań w obwodach X, Y — wymagane usunięcie usterek przed włączeniem"**.

### Podpis

- **imię i nazwisko**,
- **numer uprawnień SEP G1 D z kategorią pomiarową**,
- **data ważności uprawnień**,
- **pieczęć**,
- **podpis odręczny**.

## Uprawnienia SEP G1 D

Pomiary instalacji elektrycznych może wykonywać tylko osoba mająca **świadectwo kwalifikacyjne SEP G1 D**:

| Symbol | Znaczenie |
|---|---|
| **G1** | grupa 1 — urządzenia elektroenergetyczne |
| **D** | typ „Dozór" — uprawnia do pomiarów i odbiorów (rozszerzenie nad **E** — Eksploatacja) |
| **kategoria pomiarowa** | dodatkowy zapis w świadectwie — uprawnia do wykonywania protokołów |

Świadectwo wystawia komisja kwalifikacyjna SEP. **Ważność: 5 lat**, potem egzamin odnawiający.

Bez kategorii pomiarowej elektryk z SEP G1 E **nie ma prawa** podpisywać protokołów.

## Częstość okresowych pomiarów

| Obiekt | Częstość okresowych pomiarów |
|---|---|
| Mieszkanie, dom jednorodzinny | **co 5 lat** |
| Biuro, sklep, usługi | **co 5 lat** |
| Obiekty użyteczności publicznej (szkoły, szpitale) | **co 1 rok** |
| Place budowy, namioty, imprezy | co 6 miesięcy lub po każdym montażu |
| Pomieszczenia zagrożone wybuchem (Ex) | co 1 rok |
| Obiekty na otwartym powietrzu | co 1 rok |
| Po pracach budowlanych, remoncie | bezwzględnie |
| Po pożarze, zalaniu, uderzeniu pioruna | bezwzględnie |

Częstość ujęta w **rozporządzeniu MGPiPS** oraz w **ustawie Prawo budowlane** (art. 62).

## Wzór protokołu — szkielet

```
═══════════════════════════════════════════════════════════════
PROTOKÓŁ Z POMIARÓW ELEKTRYCZNYCH
Nr: 2026/05/123
═══════════════════════════════════════════════════════════════

DANE OBIEKTU:
   Adres:           ul. Przykładowa 1, 00-000 Miasto
   Nazwa:           Dom jednorodzinny
   Właściciel:      Jan Kowalski
   Rodzaj instal.:  Nowa, do odbioru
   Układ sieci:     TN-C-S, 230/400 V, 50 Hz
   Maks. In:        25 A (3-faz), licznik LZQJ
   Data pomiarów:   2026-05-21
   Pogoda:          21 °C, słonecznie, suchy grunt

MIERNIKI:
   1. Sonel MPI-540, S/N 12345
      kal. 2025-09-15, ważne do 2026-10-15
      świadectwo nr KAL/2025/9821
   2. Sonel MRU-105, S/N 56789
      kal. 2024-09-15, ważne do 2025-10-15
      świadectwo nr KAL/2024/7102

WYNIKI POMIARÓW:

[A] REZYSTANCJA IZOLACJI (Riso, 500 V DC, 60 s)
    Obwód             | L-N    | L-PE   | N-PE   | Wymóg   | Ocena
    ──────────────────┼────────┼────────┼────────┼─────────┼──────
    G1 Gniazda kuchnia| 1850 MΩ| 2100 MΩ| 1900 MΩ| ≥ 1 MΩ  | OK
    G2 Gniazda salon  | >999 MΩ| >999 MΩ| >999 MΩ| ≥ 1 MΩ  | OK
    O1 Oświetlenie    |  650 MΩ|  720 MΩ|  580 MΩ| ≥ 1 MΩ  | OK
    Łaz Oświetlenie   |  120 MΩ|  150 MΩ|  140 MΩ| ≥ 1 MΩ  | OK

[B] IMPEDANCJA PĘTLI ZWARCIA (Zs)
    Obwód         | MCB    | Zs zm. | Ik    | Zs max | Ocena
    ──────────────┼────────┼────────┼───────┼────────┼──────
    G1 kuchnia    | B16    | 0,82 Ω | 280 A | 1,91 Ω | OK
    G2 salon      | B16    | 1,15 Ω | 200 A | 1,91 Ω | OK

[C] TEST WYŁĄCZNIKÓW RCD
    RCD          | Typ | IΔn  | t(1×) | t(5×)| 0,5×| Ocena
    ─────────────┼─────┼──────┼───────┼──────┼─────┼──────
    F&G FI-30/4  | A   | 30mA | 22 ms | 9 ms | OK  | OK

[D] REZYSTANCJA UZIEMIENIA
    Uziom: otokowy FeZn 30×4, obwód ~40 m
    Metoda: 3-pin 62%, sondy H=25 m, P=15,5 m
    Wynik: Rz = 18,2 Ω
    Wymóg dla TT: < 30 Ω → OK

[E] CIĄGŁOŚĆ PE I POŁĄCZEŃ WYRÓWNAWCZYCH
    Element                | R       | Wymóg | Ocena
    ───────────────────────┼─────────┼───────┼──────
    G1 kuchnia, PE→gniazdo | 0,28 Ω  | ≤ 1 Ω | OK
    GSW → uziom            | 0,08 Ω  | ≤0,1Ω | OK
    GSW → rura wodna       | 0,42 Ω  | ≤ 1 Ω | OK
    GSW → rura gazu        | 0,38 Ω  | ≤ 1 Ω | OK
    MSW łazienka → wanna   | 0,31 Ω  | ≤ 1 Ω | OK

UWAGI:
   - wszystkie pomiary wykonane przy odłączonym zasilaniu
     (Riso, ciągłość) lub załączonym (Zs, RCD),
   - SPD typ 2 (Dehn DG M TNC 275) — okienko zielone, sprawny,
   - rura wody ciepłej w kotłowni — łączenie miedź+stal,
     zacisk dwumateriałowy zastosowany.

WNIOSKI:
   Instalacja elektryczna spełnia wymagania PN-HD 60364-6.
   Może być oddana do eksploatacji.

PODPIS:
   Imię i nazwisko: Anna Nowak
   Uprawnienia SEP G1 D, kategoria pomiarowa
   Świadectwo nr 12345/D/2024, ważne do 2029-05
   Data:    2026-05-21
   Podpis:  ......................................
   Pieczęć:
═══════════════════════════════════════════════════════════════
```

## Archiwizacja

- protokół w **2 egzemplarzach** — jeden dla właściciela, jeden dla wykonawcy,
- przechowywać **min. 5 lat** (do kolejnego pomiaru okresowego),
- przy sprzedaży nieruchomości przekazać kupującemu,
- skan PDF w chmurze — dobry zwyczaj (zniszczenia, pożar).

## Co dalej

Powrót: **[Sekcja 11 — spis treści](index.html)**
Następnie: **[Sekcja 12 — Fotowoltaika](../12-fotowoltaika/index.html)**
