# Dobór mocy agregatu

Zbyt mały agregat wyłączy się pod obciążeniem; zbyt duży to wyrzucone pieniądze i praca z niską sprawnością. To rozdział, w którym liczymy.

## Moc pozorna S vs moc czynna P

Agregaty są opisywane mocą pozorną **S w kVA**, a odbiorniki — mocą czynną **P w kW**. To nie to samo.

```
S = P / cos φ            [kVA]
P = S · cos φ            [kW]
```

Typowy **cos φ agregatu wynosi 0,8**. Oznacza to:

```
Agregat 5 kVA  →  P = 5 · 0,8 = 4 kW mocy czynnej
Agregat 6 kVA  →  P = 6 · 0,8 = 4,8 kW
Agregat 8 kVA  →  P = 8 · 0,8 = 6,4 kW
```

**Wniosek:** agregat „5 kVA" realnie odda około 4 kW. Licz potrzeby w kW i przeliczaj na kVA dzieląc przez 0,8.

## Prąd rozruchowy — najważniejsza pułapka

Odbiorniki z silnikiem (lodówka, zamrażarka, pompa, klimatyzacja, sprężarka) w chwili startu pobierają **3–7-krotność** prądu znamionowego. Trwa to ułamek sekundy, ale agregat musi tę moc dostarczyć, inaczej napięcie zapadnie i silnik się nie rozkręci.

```
P_rozruch = P_znamionowa · k_rozruch

k_rozruch:  lodówka, zamrażarka   ~6×
            pompa obiegowa CO     ~6×
            pompa wody / hydrofor ~3–4×
            klimatyzacja          ~5×
            elektronarzędzia      ~3×
            grzałki, oświetlenie  1× (brak rozruchu)
```

## Metoda doboru — krok po kroku

1. **Wypisz odbiorniki krytyczne** — to, co naprawdę musi działać podczas blackoutu (nie cały dom).
2. **Zsumuj moc ciągłą** wszystkich tych odbiorników (tak, jakby działały razem).
3. **Dodaj największy prąd rozruchowy** — zakładamy, że w najgorszym momencie startuje jeden, najbardziej „prądożerny" silnik, gdy reszta już pracuje.
4. **Dodaj zapas 20–25 %** — na starzenie się agregatu, temperaturę, niedokładność danych.

```
P_potrzebna = ( Σ P_ciągła + P_rozruch_max ) · 1,25
S_agregatu  = P_potrzebna / 0,8
```

## Przykład liczbowy — dom jednorodzinny

Lista odbiorników krytycznych:

| Odbiornik | Moc ciągła | Rozruch |
|---|---|---|
| Lodówka | 150 W | 900 W (6×) |
| Pompa obiegowa CO | 100 W | 600 W (6×) |
| Oświetlenie LED | 200 W | 200 W |
| Router, elektronika | 100 W | 100 W |
| Pompa wody (hydrofor) | 800 W | 3000 W (~4×) |
| **Suma mocy ciągłej** | **1350 W** | — |

Krok 3 — największy rozruch to pompa wody (3000 W). Zakładamy, że startuje, gdy reszta pracuje już na mocy ciągłej. Ale w czasie rozruchu pompy odejmujemy jej moc ciągłą z sumy, bo „rozruch" ją zawiera:

```
Σ P_ciągła pozostałych = 1350 − 800 = 550 W
moment szczytowy = 550 + 3000 = 3550 W
```

Krok 4 — zapas 25 %:

```
P_potrzebna = 3550 · 1,25 ≈ 4440 W ≈ 4,5 kW
S_agregatu  = 4,5 / 0,8 ≈ 5,6 kVA
```

**Dobór: agregat około 5,5–6 kVA.** Dla samego komfortu (margines, ewentualne dołożenie odbiornika) rozsądny jest model 6 kVA.

## Tabela prądów rozruchowych typowych odbiorników

| Odbiornik | Moc ciągła | Krotność | Moc rozruchowa |
|---|---|---|---|
| Lodówka / zamrażarka | 100–200 W | ~6× | 600–1200 W |
| Pompa obiegowa CO | 60–120 W | ~6× | 360–700 W |
| Pompa głębinowa / hydrofor | 600–1100 W | 3–4× | 2000–4000 W |
| Klimatyzator (split) | 800–1500 W | ~5× | 4000–7500 W |
| Pralka (silnik) | 400 W | 3–4× | 1500 W |
| Elektronarzędzie (szlifierka) | 1000 W | ~3× | 3000 W |
| Grzałka, czajnik, bojler | dowolna | 1× | bez rozruchu |
| Oświetlenie LED, RTV, router | dowolna | 1× | bez rozruchu |

## Zalecenie — agregat inwerterowy dla elektroniki

Jeśli wśród odbiorników krytycznych jest sprzęt z elektroniką (kocioł gazowy ze sterownikiem, pompa ciepła, komputer, sprzęt RTV) — wybierz agregat **inwerterowy** (THD < 3 %). Agregat klasyczny może uszkodzić zasilacze lub powodować błędy sterowników. Inwerterowy lepiej też radzi sobie z rozruchami, bo ma chwilowy zapas mocy szczytowej.

> **Wskazówka.** Nie dobieraj agregatu „na cały dom z zapasem 100 %". Lepiej wydzielić obwody krytyczne (rozdział 16-06) i kupić mniejszy, tańszy, oszczędniejszy agregat, który i tak udźwignie to, co naprawdę potrzebne.

## Co dalej

➡ [Przełączanie sieć/agregat — SZR/ATS](16-05-przelaczanie-szr-ats.md)
