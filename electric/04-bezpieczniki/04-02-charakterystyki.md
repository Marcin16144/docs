# Charakterystyki B/C/D/K/Z

## Co to jest charakterystyka wyzwalania

Każdy MCB ma dwa mechanizmy wyzwalania:

1. **Termiczny (bimetalowy)** — odpowiada za przeciążenia, działa wolno (sekundy do minut)
2. **Elektromagnetyczny (cewka)** — odpowiada za zwarcia, działa natychmiast (milisekundy)

**Charakterystyka** określa, **jaki prąd musi popłynąć, żeby zadziałała część elektromagnetyczna** — czyli wywoła natychmiastowe wyłączenie. Definiuje się ją jako wielokrotność prądu znamionowego In.

## Tabela charakterystyk

| Charakter. | Krotność In (zwarciowa) | Typowe zastosowanie |
|---|---|---|
| **B** | **3 ÷ 5 × In** | oświetlenie LED, gniazda 230 V — odbiorniki bez prądu rozruchowego |
| **C** | **5 ÷ 10 × In** | silniki, klimatyzatory, transformatory, lodówki (rozruch ~5×In) |
| **D** | **10 ÷ 20 × In** | silniki z dużym rozruchem (zgrzewarki, kompresory, pompy ciepła) |
| **K** | **10 ÷ 14 × In** | transformatory specjalne, urządzenia z dużą indukcyjnością |
| **Z** | **2 ÷ 3 × In** | elektronika czuła, obwody pomiarowe, instalacje IT |

Wkładki topikowe:
- **gG** — krzywa wolniejsza, podobna do B/C
- **aM** — tylko zwarciowa, krotność 6-12 × In, do silników

## Dlaczego do lodówki C16 a nie B16

Lodówka, klimatyzator, sprężarka — to **silniki indukcyjne**. Przy starcie ich prąd rozruchowy potrafi sięgać 5-7 razy prądu nominalnego, ale tylko na 100-200 ms.

**Przykład:** lodówka pobierająca normalnie 1,2 A może na chwilę starty pobrać 6-8 A. Pod **B16** wyzwoli się elektromagnes (próg ~48-80 A jest ledwie OK), ale przy częstych włączeniach bezpiecznik może się rozłączyć z powodu nagrzewania bimetalu od skoków prądu.

**C16** ma próg 80-160 A — z dużym zapasem dla rozruchu lodówki czy pralki.

```
Lodówka 200 W = ~0,9 A stały, 4-5 A rozruch — B10 spokojnie wystarczy
Klimatyzator 2 kW = 9 A stały, 25-40 A rozruch — koniecznie C16
Sprężarka warsztatowa 2 kW = 9 A stały, 60-80 A rozruch (mały kondensator) — C16 lub D16
```

## Krzywa wyzwalania czas-prąd

Producent dostarcza wykres **czas wyłączenia [s] w funkcji krotności prądu (I/In)**. Wykres ma dwa odcinki:

```
czas
 ↑
 │  \
1 h ─\ ─ ─ ─ ─ ─ ─ obszar termiczny (bimetal)
     \           
1 s ─ \─ ─ ─ ─ ─ "kolano" — przejście do strefy elektromagnetycznej
       \
10ms ─  └─────── obszar elektromagnetyczny (natychmiastowy)
        │
       1×In  3-5×In   ...   1000×In
```

- Poniżej In: nie zadziała w ogóle (norma: musi nie zadziałać przy 1,13·In w 1 h)
- 1,45·In: zadziała w ciągu godziny (granica)
- 3-5·In (B): może zadziałać natychmiast lub w sekundach
- > 5·In (B): **musi** zadziałać w < 100 ms (elektromagnetyczne)
- 1000·In: natychmiast (~3-5 ms)

## Pełne tabele krotności wg PN-EN 60898-1

| Krotność | B | C | D |
|---|---|---|---|
| **1,13 × In** | musi nie zadziałać w 1 h | musi nie zadziałać w 1 h | musi nie zadziałać w 1 h |
| **1,45 × In** | musi zadziałać w 1 h | musi zadziałać w 1 h | musi zadziałać w 1 h |
| **2,55 × In** | musi zadziałać w 1-60 s | musi zadziałać w 1-60 s | musi zadziałać w 1-60 s |
| **3 × In (B), 5×In (C), 10×In (D)** | dolny próg elektromagnetyczny | dolny próg elektromagnetyczny | dolny próg elektromagnetyczny |
| **5 × In (B), 10×In (C), 20×In (D)** | górny próg — **musi** zadziałać natychmiast | jw. | jw. |

## Charakterystyka Z — elektronika czuła

Z (krotność 2-3 × In) to specjalna charakterystyka dla obwodów, gdzie nawet niewielki nadprąd jest niebezpieczny:
- aparatura medyczna
- układy pomiarowe
- precyzyjne sterowniki

W instalacjach domowych spotykana rzadko. Cechą jest **niska wartość prądu zwarciowego** (im niższa krotność, tym mniejsza odporność na fałszywe wyłączenia od krótkich pików).

## Praktyczna tabela wyboru

| Odbiornik | Zalecana charakterystyka |
|---|---|
| Oświetlenie LED, gniazda komputerowe | **B** |
| Gniazda ogólnego użytku 230 V | **B** lub **C** |
| Lodówka, zamrażarka | **C** |
| Pralka, zmywarka (z grzałką) | **B** lub **C** |
| Klimatyzator (split, multi-split) | **C** |
| Indukcja, piekarnik, kuchenka 3-faz | **C** |
| Pompa ciepła | **C** lub **D** |
| Wentylator dachowy, sprężarka | **D** |
| Zgrzewarka, agregat prądotwórczy | **D** |
| Stół spawalniczy, transformator | **D** lub **K** |

## Charakterystyki dla wkładek topikowych

Wkładki topikowe gG mają **bardziej miękką** charakterystykę — wolniej reagują na krótkie udary prądu. Często stosowane jako **zabezpieczenie nadrzędne** w przyłączu (od strony OSD):

```
Złącze kablowo-pomiarowe:
gG 50 A (wkładka topikowa) — bo trzeba wytrzymać rozruch całego domu

W rozdzielnicy mieszkaniowej:
B16 / C16 (MCB) — szybsze, ostrzejsze, łatwo wymienialne
```

Ta różnica zapewnia naturalną selektywność (patrz [Selektywność](04-03-selektywnosc.md)).

## Co dalej

➡ [Selektywność zabezpieczeń](04-03-selektywnosc.md)
