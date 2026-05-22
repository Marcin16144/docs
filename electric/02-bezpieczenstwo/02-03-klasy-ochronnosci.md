# Klasy ochronności urządzeń

## Cztery klasy ochronności (PN-EN 61140)

Klasa ochronności określa, **w jaki sposób urządzenie chroni użytkownika** przed porażeniem prądem w razie uszkodzenia izolacji podstawowej.

| Klasa | Sposób ochrony | Symbol |
|---|---|---|
| **0** | tylko izolacja podstawowa (brak żadnej ochrony dodatkowej) | brak / przekreślony |
| **I** | izolacja podstawowa + uziemienie ochronne (PE) | ⏚ (uziemienie) |
| **II** | podwójna lub wzmocniona izolacja | ▢ (kwadrat w kwadracie) |
| **III** | zasilanie SELV/PELV (≤50 V AC, ≤120 V DC) | romb z liczbą III |

## Klasa 0

**Definicja:** urządzenie posiada tylko **izolację podstawową**, bez przewodu PE i bez podwójnej izolacji. W razie uszkodzenia izolacji obudowa może znaleźć się pod napięciem.

**Status w PL/EU:** **zakazane** w nowych instalacjach od dziesięcioleci. Dotyczy wyłącznie:

- starych urządzeń sprzed lat 70-80 XX wieku
- niektórych krajów Azji (gdzie sieć ma niskie napięcie)

**Co zrobić, jeśli znajdziemy klasę 0 w domu?**

- wymienić urządzenie albo
- przerobić do klasy I (dodać PE) — wymaga uprawnień
- użyć transformatora separacyjnego

## Klasa I — z przewodem ochronnym PE

**Definicja:** izolacja podstawowa **plus** połączenie wszystkich dostępnych części przewodzących z przewodem ochronnym PE.

**Zasada działania:**

1. Faza dotyka obudowy → powstaje pętla zwarciowa L-PE.
2. Płynie wysoki prąd zwarcia.
3. Zabezpieczenie nadprądowe (B16, RCD 30 mA) wyłącza obwód w czasie ≤0,4 s.
4. Użytkownik nie zostaje porażony, bo obudowa szybko wraca do potencjału ziemi.

**Wymagania:**

- wtyczka 3-pinowa (z kołkiem PE — Schuko, włoska C/F, polska E)
- gniazdo z bolcem PE
- instalacja z prawidłowym PE
- aktywny RCD (zwiększa skuteczność, ale nie jest formalnie wymagany dla klasy I)

**Typowe urządzenia klasy I:**

| Urządzenie | Dlaczego klasa I |
|---|---|
| Pralka | metalowy bęben, woda — wymóg uziemienia |
| Zmywarka | woda + metal |
| Lodówka | metalowa obudowa, kompresor |
| Czajnik metalowy | metalowa obudowa może się przewodzić |
| Piekarnik elektryczny | metalowa obudowa, wysokie napięcie wewnątrz |
| Bojler | woda + grzałka |
| Komputer stacjonarny | metalowa obudowa, EMC wymaga PE |
| Drukarka laserowa | metalowa obudowa, wysokie napięcie wewnątrz |
| Płyta indukcyjna | metalowa płyta, podłączenie 3-faz |
| Mikrofalówka | duża moc, metalowa obudowa |

## Klasa II — podwójna izolacja

**Definicja:** dwie warstwy izolacji (izolacja podstawowa + izolacja dodatkowa) lub jedna izolacja wzmocniona. **Nie ma żadnego połączenia z PE.**

**Zasada działania:** nawet po uszkodzeniu pierwszej warstwy izolacji druga zapewnia bezpieczeństwo. Brak metalowych dostępnych części lub są one odizolowane od części pod napięciem dwukrotnie.

**Symbol:** **kwadrat w kwadracie** ▢▢ (czasem rysowany jako dwa koncentryczne kwadraty).

**Wtyczka:** zwykle 2-pinowa (bez bolca PE) — typu C (europlug) lub odpowiednik z plastikową obudową.

**Typowe urządzenia klasy II:**

| Urządzenie | Dlaczego klasa II |
|---|---|
| Ładowarka do telefonu | plastik, mała moc |
| Zasilacz laptopa | plastik, separacja transformatorem |
| Wiertarka, szlifierka (akumulatorowa lub przewodowa nowa) | plastikowa obudowa, narzędzia ręczne |
| Suszarka do włosów | plastik, używana z mokrymi rękami |
| Maszynka do golenia | używana w łazience |
| Telewizor LED, monitor | plastikowa obudowa, zasilacz wewnętrzny izolowany |
| Wieża stereo, radio | plastikowa obudowa, mała moc |
| Klasyczna żarówka LED z plastikowym trzonkiem | plastik, izolacja od bańki |
| Większość małych AGD (mikser, blender, toster nowy) | plastik |
| Klasa II w pralkach: rzadko, ale możliwa | producent musi udokumentować |

## Klasa III — bardzo niskie napięcie SELV

**Definicja:** zasilanie z obwodu **SELV/PELV** o napięciu nieprzekraczającym 50 V AC lub 120 V DC. Urządzenie samo w sobie **nie zawiera ochrony** — bezpieczeństwo zapewnia samo niskie napięcie.

**Symbol:** romb z liczbą rzymską III w środku.

**Źródło SELV:** transformator separacyjny, zasilacz impulsowy z separacją galwaniczną, akumulator, ogniwo PV.

**Typowe urządzenia klasy III:**

| Urządzenie | Napięcie |
|---|---|
| Oprawa LED 12 V w łazience | 12 V DC |
| Oświetlenie strefy 0/1 (nad wanną) | 12 V SELV |
| Dzwonek domofonu | 8-24 V AC |
| Sterowanie KNX, automatyka | 24 V DC |
| Zabawki dla dzieci | ≤24 V |
| Latarka, lampka biurkowa USB | 5 V DC |
| Oświetlenie ogrodowe LED | 12 V / 24 V |
| Centrala alarmowa, czujki PIR | 12 V DC |

## Jak rozpoznać klasę ochronności

1. **Wtyczka 3-pin z kołkiem PE** → klasa I
2. **Wtyczka 2-pin + symbol ▢▢ na tabliczce znamionowej** → klasa II
3. **Bez wtyczki, zasilane z zasilacza ≤50 V** → klasa III
4. **Stare urządzenie 2-pin bez symbolu klasy II** → prawdopodobnie klasa 0 — uważać!

## Tabliczka znamionowa — co tam jest

Typowa tabliczka pralki:

```
SAMSUNG WW80T4040CE
220-240 V ~ 50 Hz
2 200 W
I_max = 10 A
Klasa I  ⏚
IP X4
```

Tabliczka ładowarki:

```
APPLE 20W USB-C Power Adapter
INPUT:  100-240 V ~ 50/60 Hz, 0,5 A
OUTPUT: 5,1 V / 3 A lub 9 V / 2,22 A
Klasa II  ▢▢
```

## Konsekwencje praktyczne

**Klasa I wymaga sprawnego PE w instalacji.** Jeśli w starym budynku gniazda nie mają PE (instalacja 2-żyłowa), urządzenia klasy I **nie są bezpieczne** — pomimo bolca w gnieździe!

**Klasa II można używać wszędzie, gdzie jest gniazdko**, nawet bez PE. Stąd małe AGD i elektronika są celowo robione jako klasa II — działają w każdej instalacji.

**Klasa III to jedyna dopuszczalna w strefie 0 łazienki** (nad wanną/brodzikiem). Stąd lampki halogenowe 12 V w łazienkach.

## Co dalej

➡ [Środki ochrony przeciwporażeniowej](02-04-srodki-ochrony.md)
