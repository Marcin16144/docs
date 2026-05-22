# Moc czynna, bierna, pozorna — cos φ

## Trzy moce w obwodzie AC

W obwodzie prądu stałego mamy jedną moc: P = U·I. W obwodzie AC z indukcyjnością lub pojemnością prąd jest **przesunięty fazowo** względem napięcia, przez co rozróżniamy trzy moce:

| Moc | Symbol | Jednostka | Co opisuje |
|---|---|---|---|
| **Czynna** | P | wat [W] | energia rzeczywiście wykonująca pracę (ciepło, ruch, światło) |
| **Bierna** | Q | war [var] | energia oscylująca między źródłem a odbiornikiem, nie wykonująca pracy |
| **Pozorna** | S | woltoamper [VA] | iloczyn skutecznych U·I, „brutto" obciążenia źródła |

## Wzory

```
P = U · I · cos φ        [W]    — moc czynna
Q = U · I · sin φ        [var]  — moc bierna
S = U · I                [VA]   — moc pozorna
```

gdzie **φ** to kąt przesunięcia fazowego między prądem i napięciem.

## Trójkąt mocy

Trzy moce tworzą trójkąt prostokątny:

```
        S (pozorna)
       /│
      / │
     /  │ Q (bierna)
    /   │
   /____│
   P (czynna)

   S² = P² + Q²
   cos φ = P / S
   sin φ = Q / S
   tan φ = Q / P
```

## Współczynnik mocy cos φ

cos φ (Power Factor, PF) jest stosunkiem mocy czynnej do pozornej:

```
cos φ = P / S
```

| cos φ | Interpretacja |
|---|---|
| 1,0 | obciążenie czysto rezystancyjne — wszystko jest mocą czynną |
| 0,9 | dobre — typowe LED-y, urządzenia z PFC |
| 0,7 | przeciętne — silniki indukcyjne bez korekty |
| <0,5 | bardzo złe — duże silniki bez kompensacji, świetlówki ze starym zapłonem |
| 0 | obciążenie czysto indukcyjne lub pojemnościowe — brak pracy użytecznej |

## Przyczyna powstawania mocy biernej

| Rodzaj obciążenia | Co robi | Skutek dla fazy I |
|---|---|---|
| Rezystancyjne (grzałka, żarówka żarowa) | zamienia E·I na ciepło | I w fazie z U, cos φ = 1 |
| Indukcyjne (silnik, transformator, dławik) | gromadzi energię w polu magnetycznym | I opóźnia się o φ (cos φ < 1, indukcyjne) |
| Pojemnościowe (kondensator, kabel długi) | gromadzi energię w polu elektrycznym | I wyprzedza U o φ (cos φ < 1, pojemnościowe) |

## cos φ typowych urządzeń

| Urządzenie | cos φ |
|---|---|
| Grzałka, czajnik, bojler | 1,00 |
| Żarówka żarowa | 1,00 |
| Żarówka LED z dobrym sterownikiem (PFC) | 0,90-0,95 |
| Żarówka LED bez PFC | 0,50-0,70 |
| Świetlówka kompaktowa CFL | 0,55 |
| Świetlówka liniowa ze starym statecznikiem | 0,50 |
| Świetlówka liniowa z elektronicznym statecznikiem | 0,95 |
| Komputer / zasilacz ATX nowy z PFC | 0,95 |
| Stary zasilacz ATX bez PFC | 0,60 |
| Lodówka, zamrażarka | 0,70-0,80 |
| Pralka (silnik) | 0,70 |
| Pompa ciepła (inwerterowa) | 0,95 |
| Klimatyzator | 0,85 |
| Spawarka transformatorowa (na biegu jałowym) | 0,30 |
| Silnik indukcyjny duży, obciążony | 0,80-0,85 |
| Silnik indukcyjny duży, nieobciążony | 0,20-0,30 |

## Dlaczego cos φ ma znaczenie

Niski cos φ oznacza, że przez przewody i transformatory **przepływa większy prąd** niż wynikałoby z faktycznie wykonanej pracy:

**Przykład.** Silnik o mocy czynnej P = 5 kW, cos φ = 0,7, napięcie 400 V (3-faz):

```
S = P / cos φ = 5 / 0,7 = 7,14 kVA
I = S / (√3 · U) = 7140 / (1,732 · 400) = 10,3 A
```

Przy cos φ = 0,95 dla tej samej mocy P prąd wyniósłby tylko 7,6 A — o 25% mniej.

**Skutki niskiego cos φ:**

- większe straty I²R w przewodach
- większe nagrzewanie transformatorów
- wymóg grubszych kabli i większych zabezpieczeń
- dostawca energii pobiera **opłatę za moc bierną** dla odbiorców biznesowych (zwykle gdy tan φ > 0,4, czyli cos φ < 0,93)

## Kompensacja mocy biernej

Polega na zastosowaniu elementu o przeciwnym charakterze — najczęściej **kondensatorów** (równoważą indukcyjność silników).

**Schemat zasady:**

- silnik pobiera prąd opóźniony (I_L)
- kondensator pobiera prąd wyprzedzający (I_C)
- jeśli ich moce bierne się równoważą (Q_L = Q_C), sieć widzi tylko prąd czynny

**Typowe rozwiązania:**

| Rozwiązanie | Gdzie |
|---|---|
| Indywidualna bateria kondensatorów na zaciskach silnika | duże silniki ≥10 kW |
| Centralna bateria kondensatorów z regulatorem | rozdzielnie zakładów przemysłowych |
| Dynamiczna kompensacja (SVC, STATCOM) | przemysł z szybko zmiennym obciążeniem (spawarki, walcownie) |
| PFC w urządzeniach elektronicznych | wbudowany w nowoczesne zasilacze |

## W domu — czy potrzeba kompensacji

**Krótka odpowiedź: nie.** Powody:

1. **Gospodarstwa domowe rozliczają się tylko za moc czynną** (taryfa G) — moc bierna nie jest fakturowana.
2. Pojedyncze sprzęty domowe mają zwykle wbudowaną własną korektę (PFC w nowych urządzeniach).
3. Sumaryczny cos φ instalacji domowej rzadko spada poniżej 0,9.

**Wyjątki, gdzie sens jest:**

- duże gospodarstwo z agregatami chłodniczymi (gospodarstwo rolne)
- warsztat z silnikami indukcyjnymi
- duża pompa ciepła + klimatyzacja + EV — gdy dystrybutor sygnalizuje przekroczenia

**Uwaga:** instalowanie kondensatorów „na zapas" bez wiedzy może doprowadzić do **przekompensowania** (cos φ < 0 — charakter pojemnościowy), co jest tak samo niekorzystne jak niedokompensowanie.

## Taryfa za moc bierną (odbiorcy biznesowi)

Dostawca rozlicza moc bierną zazwyczaj w oparciu o **współczynnik tg φ = Q/P**:

| tg φ | cos φ | Status |
|---|---|---|
| ≤0,4 | ≥0,93 | dozwolony — brak opłat |
| 0,4-1,0 | 0,93-0,71 | opłata za nadwyżkę Q |
| >1,0 | <0,71 | wysoka opłata karna |

Wzór na opłatę:

```
Opłata = krot · cena_energii · (Q_zmierzona − 0,4·P_czynna)
```

gdzie *krot* (krotność stawki) zależy od taryfy i operatora.

## Cztery wzory do zapamiętania

```
S = U · I                      ← moc pozorna
P = S · cos φ                  ← moc czynna
Q = S · sin φ                  ← moc bierna
S² = P² + Q²                   ← trójkąt mocy
```

## Co dalej

➡ Powrót do [Spisu sekcji 01](index.html) lub do [Sekcji 02 — Bezpieczeństwo](../02-bezpieczenstwo/index.html)
