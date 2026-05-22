# Selektywność

## Definicja

**Selektywność** (selektywność działania zabezpieczeń) — przy zwarciu lub przeciążeniu w obwodzie odgałęzionym wyzwala **tylko** bezpiecznik tego obwodu, a zabezpieczenie nadrzędne pozostaje załączone.

Cel: minimalizacja zakresu wyłączenia. Zwarcie w jednym gniazdku nie powinno wyłączyć światła w całym domu.

## Trzy rodzaje selektywności

### 1. Selektywność prądowa (amperażowa)

Realizowana przez dobór **różnych prądów znamionowych**: nadrzędne ma wyraźnie większy In niż podrzędne.

Zasada (praktyczna):

```
In(nadrzędne) ≥ 1,6 × In(podrzędne)
```

Przykład:
```
Główny B40 → podrzędny B16  ✓  (40 / 16 = 2,5)
Główny B25 → podrzędny B16  ✗  (25 / 16 = 1,56 — za blisko)
```

Działa dobrze przy małych prądach zwarciowych. **Nie działa** przy bardzo dużych Ik — bo oba bezpieczniki wpadają w strefę elektromagnetyczną jednocześnie.

### 2. Selektywność czasowa

Nadrzędne zabezpieczenie ma celowo **opóźnione działanie** (symbol **S**). Czeka, aż podrzędne zdąży zadziałać.

```
Główny: RCD typ S 100 mA (opóźnienie 60-200 ms)
          ↓
Podrzędne: RCD 30 mA (czas zadziałania 20-40 ms)
```

Najczęściej spotykana w obwodach RCD/RCBO. MCB typu S też istnieją, ale są droższe.

### 3. Selektywność strefowa (komunikacyjna)

Stosowana w przemyśle, **rzadko** w instalacjach domowych. Zabezpieczenia komunikują się ze sobą (sygnał blokady) — gdy podrzędne wykryło zwarcie, nadrzędne odbiera komunikat „nie wyłączaj, ja się zajmę".

Przykład: szafy SN/nN z zabezpieczeniami typu ABB Emax, Schneider Masterpact.

## Schemat 3-stopniowy w domu jednorodzinnym

Typowy łańcuch zabezpieczeń:

```
┌──────────────────────────────────────────────────────┐
│  Sieć energetyki (OSD)                              │
└──────────────────────────────────────────────────────┘
                          │
                          ▼
        Złącze kablowo-pomiarowe (przy granicy działki)
                          │
                          ▼
        gG 63 A (wkładka topikowa)   ← stopień 1 (OSD)
                          │
                          ▼
                       Licznik
                          │
                          ▼
                    WLZ do domu (~30 m)
                          │
                          ▼
        Główny: rozłącznik FR-S 63 A
                          │
                          ▼
        MCB S40 (lub C40)            ← stopień 2 (główny w rozdzielnicy)
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
   B16 (gniazda)    B10 (oświetl.)    C16 (lodówka)  ← stopień 3 (obwody)
```

**Działanie przy zwarciu w gnieździe:**
1. Zwarcie L-N
2. Prąd zwarciowy ~1-3 kA
3. B16 zadziała w czasie <10 ms (strefa elektromagnetyczna, 5·16=80 A wystarczy)
4. C40 nie zadąży zareagować (jego próg to 200-400 A, ale przy 1-3 kA też by zadziałał — gdyby nie był po prostu wolniejszy)
5. gG 63 A w złączu — pozostaje całkiem niewzruszony
6. Reszta domu działa normalnie ✓

## Tabela selektywności prądowej

Sprawdzenie, czy dwa MCB tworzą selektywną kaskadę:

| Górny In | Dolny In max przy zachowaniu selektywności |
|---|---|
| **B25** | B10 (2,5×) |
| **B32** | B16 (2,0×) — granica |
| **B40** | B16 (2,5×) ✓ |
| **B40** | B25 (1,6×) — granica |
| **B50** | B25 (2,0×) ✓ |
| **B63** | B32 (2,0×) ✓ |
| **gG 80** | B40 (2,0×) ✓ |

Dla zachowania pewnej selektywności **przy zwarciu** (nie tylko przeciążeniu) stosuj zasadę: górny w klasie **C lub gG** (wolniejsze), dolny w klasie **B** (szybsze).

## Selektywność RCD

Tu sytuacja jest trudniejsza — dwa RCD o podobnej czułości **nie są selektywne** automatycznie. Trzeba użyć:

| Górny | Dolny | Selektywność |
|---|---|---|
| RCD 30 mA | RCD 30 mA | **brak** — oba zadziałają |
| RCD typ S 100 mA | RCD 30 mA | **tak** ✓ — S ma opóźnienie 60-200 ms |
| RCD typ S 300 mA | RCD 30 mA | **tak** ✓ — większe opóźnienie |
| RCBO + RCBO równolegle | — | **tak** ✓ — każdy obwód osobno |

W praktyce układ zalecany:

```
RCD typ S 100 mA (główny)
     ↓
RCD 30 mA (gniazda salonu) + RCD 30 mA (gniazda kuchnia) + RCD 30 mA (łazienka)
```

Albo (nowocześniej):

```
RCBO 30 mA / B16 — gniazda salonu
RCBO 30 mA / B16 — gniazda kuchnia
RCBO 30 mA / B16 — łazienka
```

W drugim wariancie selektywność jest naturalna — każdy obwód ma własne RCBO.

## Kiedy selektywność nie działa

Najczęstsze przypadki:

1. **Zbyt bliskie In** — np. B16 nad B16 (jeden obwód „klatka schodowa") — wybije losowy
2. **Identyczne RCD** — bez literki S — wybije pierwszy, który zadziała (zwykle ten bliższy zwarcia, ale nie zawsze)
3. **Bardzo duży Ik** — przy Ik > 1000·In zarówno górny jak dolny wpadną w strefę elektromagnetyczną. Czasem ratuje to charakterystyka (B vs C).
4. **Wkładka topikowa nad MCB** — wbrew pozorom dobra selektywność, bo gG jest wolniejsze
5. **MCB nad wkładką topikową** — fatalna selektywność, MCB zadziała szybciej

## Dobre praktyki

- **Krok rzędu**: 1,6× między In. Lepiej 2×.
- **Charakterystyka**: dolny B / górny C lub gG.
- **RCD**: górny typ S, dolne zwykłe.
- **W rozdzielnicy**: szczegółowy schemat z opisem każdego obwodu i jego selektywności.
- **Test**: po wymianie bezpiecznika warto zasymulować zwarcie (np. miernikiem pętli zwarcia) i sprawdzić, czy wyłączyło się tylko to, co miało.

## Co dalej

➡ [Dobór bezpiecznika — krok po kroku](04-04-dobor.md)
