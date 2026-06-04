# Analiza zagrożeń i macierz ryzyka

> Metodyczna identyfikacja zagrożeń (kradzież, włamanie, pożar, sabotaż, zalanie). Macierz prawdopodobieństwo × skutek i dobór środków zabezpieczeń.
>
> Aktualizacja: 2026

## Dlaczego analiza, a nie „nakupić sprzętu"

Najczęstszy błąd to skupianie się na środkach (ile kamer, jaki alarm), zamiast na celu — przed czym konkretnie się bronimy. Konsekwencje:

- Przepłacanie za niepotrzebne funkcje (Grade 3 do mieszkania)
- Niedoinwestowanie krytycznych punktów (drogi sejf, słabe drzwi)
- Brak ochrony przed realnym zagrożeniem (analizujemy włamanie, ignorujemy zalanie — 10× częstsze)

Analiza odwraca kolejność: **najpierw zagrożenie → potem środek**.

```
1. Zinwentaryzuj aktywa (co chronimy)
2. Zidentyfikuj zagrożenia (przed czym)
3. Oszacuj prawdopodobieństwo i skutek
4. Policz ryzyko (P × S)
5. Dobierz środki redukujące
6. Sprawdź ryzyko rezydualne
7. Powtórz dla obiektu i każdej strefy
```

## Krok 1 — inwentaryzacja aktywów

| Kategoria | Przykład | Wycena |
|---|---|---|
| **Materialne** | sprzęt, biżuteria, gotówka, auto | wartość odtworzeniowa |
| **Informacyjne** | dane osobowe, dokumenty | koszt odtworzenia + kary RODO |
| **Ludzkie** | mieszkańcy, pracownicy, klienci | nieoszacowalne — priorytet maksymalny |
| **Reputacyjne** | marka, ciągłość biznesu | utracone obroty + PR |

## Krok 2 — katalog zagrożeń

### Zagrożenia celowe

| Zagrożenie | Sprawca | Cel | Środki obrony |
|---|---|---|---|
| **Kradzież zewnętrzna** | osoba postronna | mienie | ogrodzenie, KD, alarm peryferyjny, CCTV |
| **Włamanie** | intruz SA2–SA4 | mienie wewnątrz | drzwi RC2+, kontaktrony, PIR, agencja |
| **Napad rabunkowy** | z bronią | gotówka, ludzie | panic button, kasy z opóźnieniem, kamery z audio |
| **Kradzież wewnętrzna** | pracownik, gość | mienie, dane | KD z logami, CCTV z analityką |
| **Wandalizm** | chuligan | uszkodzenie | kamery zewn., oświetlenie, IK10 |
| **Sabotaż systemu** | celowo blokujący | wyłączyć ochronę | anti-mask, jamming detection, dual-path |
| **Cyberatak na CCTV/KD** | haker | wgląd, ransomware | VLAN, hasła, brak UPnP |
| **Podpalenie** | celowo | zniszczenie śladów | czujki dymu, kamery termiczne |
| **Stalking** | nieproszony gość | obserwacja | wideodomofon, bariery IR |

### Zagrożenia losowe

| Zagrożenie | Częstotliwość | Środki obrony |
|---|---|---|
| **Pożar** | ~100 000/rok w PL | SAP, czujki dymu/ciepła/CO, gaśnice |
| **Zalanie** | częstsze niż włamanie | czujki wody, zawory z aktuatorem |
| **Wyciek gazu** | rzadko, ale śmiertelnie | czujki CH4/LPG, odcinacz |
| **Zaczadzenie CO** | dziesiątki zgonów/rok | czujki CO w sypialniach |
| **Zanik zasilania** | kilka razy w roku | UPS, agregat, akumulator |
| **Przepięcie** | sezon burzowy | SPD typ 1+2+3 |
| **Awaria HVAC** | zimą | czujki temperatury, alerty |
| **Awaria HDD rejestratora** | 3–5 lat | RAID, SMART, dyski Surveillance |

## Krok 3 — skala P i S

### Prawdopodobieństwo P

| P | Opis | Częstotliwość |
|---|---|---|
| 1 | bardzo niskie | raz na >10 lat |
| 2 | niskie | raz na 5–10 lat |
| 3 | średnie | raz na 1–5 lat |
| 4 | wysokie | raz na rok |
| 5 | bardzo wysokie | częściej niż rok |

### Skutek S

| S | Opis | Strata |
|---|---|---|
| 1 | pomijalny | < 1 000 zł |
| 2 | niewielki | 1 000–10 000 zł |
| 3 | średni | 10 000–100 000 zł |
| 4 | duży | 100 000–1 mln zł |
| 5 | katastrofalny | > 1 mln zł / życie |

## Krok 4 — macierz R = P × S

|       | S=1 | S=2 | S=3 | S=4 | S=5 |
|---|---|---|---|---|---|
| **P=1** | 1 | 2 | 3 | 4 | 5 |
| **P=2** | 2 | 4 | 6 | 8 | 10 |
| **P=3** | 3 | 6 | 9 | 12 | 15 |
| **P=4** | 4 | 8 | 12 | 16 | 20 |
| **P=5** | 5 | 10 | 15 | 20 | 25 |

- **1–5 niskie** — akceptowalne, monitoring okresowy
- **6–10 średnie** — wymaga ograniczenia, środki standardowe
- **11–16 wysokie** — aktywne środki techniczne i organizacyjne
- **17–25 krytyczne** — natychmiastowe działanie, redundancja

## Przykład — dom jednorodzinny na peryferiach

| Zagrożenie | P | S | R | Strategia |
|---|---|---|---|---|
| Włamanie pod nieobecność | 3 | 4 | 12 | RC2+, alarm Grade 2 + agencja, CCTV |
| Włamanie z domownikami | 1 | 5 | 5 | Strefa nocna, panic button |
| Pożar (kominek) | 2 | 5 | 10 | Czujki dymu wg PN-EN 14604 |
| Zalanie pralka/zmywarka | 4 | 3 | 12 | Czujki wody + zawór z aktuatorem |
| Zaczadzenie CO | 3 | 5 | 15 | Czujka CO w sypialniach |
| Zanik zasilania zimą | 3 | 3 | 9 | Akumulator 12 h, UPS routera |
| Wandalizm auta | 2 | 2 | 4 | Lampa z PIR, kamera z LED |
| Cyberatak na rejestrator | 3 | 3 | 9 | VLAN, brak UPnP, mocne hasła |
| Awaria HDD | 4 | 2 | 8 | RAID 1, SMART |

**Wniosek.** Największe ryzyka to czadzenie CO, zalanie, włamanie. „Kupić więcej kamer" rozwiązuje tylko 1/3 zagrożeń.

## Krok 5 — strategie redukcji

| Strategia | Opis | Przykład |
|---|---|---|
| **Unikanie** | eliminacja źródła | nie trzymać gotówki po zamknięciu |
| **Redukcja** | obniżenie P/S środkami | drzwi RC3, alarm, CCTV |
| **Przeniesienie** | transfer na trzecią stronę | ubezpieczenie, agencja |
| **Akceptacja** | świadoma zgoda | nie zabezpieczać garażu peryferyjnego |

## Krok 6 — ryzyko rezydualne

Po zastosowaniu środków przeliczamy macierz ponownie. **Ryzyko zerowe nie istnieje** — celem jest poziom akceptowalny (≤5 typowo, ≤3 dla krytycznych).

**Pułapka.** Środki same wprowadzają nowe ryzyka:

- Czujka CO w sypialni — fałszywe alarmy
- Elektrozaczep — uwięzienie w pożarze (musi mieć fail-safe)
- KD z biometrią — ryzyko RODO

Analizuj *residual risk po implementacji*.

## Dokumentacja analizy

Dla obiektów grade 3+ analiza musi być pisemna. Minimalna struktura:

1. Opis obiektu (lokalizacja, powierzchnia, użytkowanie, godziny)
2. Lista aktywów z wyceną
3. Katalog zagrożeń z odniesieniem do statystyk policji
4. Macierz P × S z uzasadnieniem
5. Środki techniczne, organizacyjne, ubezpieczeniowe
6. Macierz ryzyka rezydualnego
7. Plan przeglądu (rok lub po istotnej zmianie)
8. Podpisy: właściciel + projektant + audytor

**Standardy referencyjne**: ISO 31000, ISO 27005, PN-EN 50131-7, CLC/TS 50131-7.

## Co dalej

➡ [Sekcja 02 — Kamery CCTV](../02-cctv-kamery/index.md)
