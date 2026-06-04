# Scenariusze uzbrojenia

> Tryby uzbrojenia dopasowane do różnych sytuacji życiowych: jest się w domu, nie ma, śpi, idzie na podwórko. Centrala obsługuje zwykle 4–5 wbudowanych scenariuszy.

## Po co kilka trybów uzbrojenia

Najprostsza centrala miałaby dwa stany: **uzbrojona** (wszystko aktywne) lub **rozbrojona** (wszystko śpi). Ale w realnym życiu są sytuacje pośrednie:

- Wychodzimy z domu — chcemy **pełnej ochrony** (Full Arm).
- Jesteśmy w domu wieczorem — chcemy chronić **perymetr** (okna, drzwi), ale poruszać się swobodnie po pomieszczeniach (Stay/Home).
- Idziemy spać — chcemy chronić **perymetr + parter**, ale móc swobodnie chodzić po sypialniach i łazience (Night Arm).
- Wracamy szybko po zostawioną rzecz — chcemy **natychmiastowe** rozbrojenie bez opóźnień (Instant).
- Idziemy do pracy o tej samej godzinie — chcemy **automatyczne uzbrojenie** o ustawionym czasie (Auto-Arm).

Każda nowoczesna centrala (Satel Integra, DSC PowerSeries, Risco, Jablotron) obsługuje wszystkie te scenariusze natywnie.

## 1. Full Arm (Away) — wszyscy poza domem

Najpełniejszy tryb uzbrojenia. **Wszystkie strefy aktywne** — perymetr, czujki ruchu wewnętrzne, kontaktrony okien, kurtyny. Stosowany gdy wszyscy domownicy opuszczają obiekt.

### Charakterystyka

- Aktywne **wszystkie typy stref** (poza 24h, które zawsze są aktywne)
- Wejście do obiektu: **entry delay** 30–60 s (na rozbrojenie z klawiatury)
- Wyjście: **exit delay** 30–60 s + sygnał akustyczny klawiatury (countdown)
- Typowy sposób aktywacji: kod na klawiaturze, pilot RF, brelok RFID, aplikacja mobilna

### Procedura uzbrojenia

```
1. Wpisanie kodu (4–6 cyfr) + ENTER lub przycisk ARM
2. Centrala sprawdza wszystkie strefy — wszystkie muszą być w stanie spoczynku
3. Klawiatura piszczy przez exit delay (np. 45 s)
4. Domownik wychodzi, zamyka drzwi (kontaktron przechodzi do strefy delayed)
5. Po upływie exit delay centrala uzbrojona — kontrolka „Armed" świeci
6. Klawiatura cichnie, alarm aktywny
```

## 2. Stay / Home (Perimeter) — domownicy w domu

Wieczorny scenariusz — uzbrojony **tylko perymetr** (kontaktrony okien/drzwi, kurtyny zewnętrzne, PIR-y kurtynowe przed elewacją), **wykluczone czujki wewnętrzne** (PIR-y w salonie, kuchni, sypialniach).

### Charakterystyka

- Aktywne strefy: **opóźnione + natychmiastowe + 24h**
- Wykluczone: strefy **wewnętrzne** (interior)
- Brak entry delay przy wejściu z perymetru (kontaktron okna = natychmiastowy alarm)
- Pozwala domownikom swobodnie się przemieszczać po wnętrzu
- Idealny dla wieczornego oglądania telewizji, kolacji, pracy w gabinecie

### Typowy zestaw stref Stay Arm

| Strefa | Typ | Stay Arm |
|---|---|---|
| Drzwi wejściowe | opóźniona | ✓ aktywna |
| Kontaktrony okien | natychmiastowa | ✓ aktywna |
| Drzwi tarasowe | natychmiastowa | ✓ aktywna |
| Kurtyna zewnętrzna nad oknem | natychmiastowa | ✓ aktywna |
| PIR salon | wewnętrzna | ✗ wyłączona |
| PIR kuchnia | wewnętrzna | ✗ wyłączona |
| PIR sypialnia | wewnętrzna | ✗ wyłączona |
| Kontaktron sejf | 24h | ✓ aktywna |
| Czujka dymu | 24h pożarowa | ✓ aktywna |

Niektóre centrale mają osobny przycisk **STAY** na klawiaturze lub osobny pilot RF z dedykowanym przyciskiem. Inne — sekwencję *kod + STAY*.

## 3. Night Arm — śpią domownicy

Bardziej restrykcyjne niż Stay — chroni także PIR-y w pomieszczeniach **poza sypialniami** (salon, kuchnia, korytarz). Domownicy mogą swobodnie chodzić tylko między łóżkiem a łazienką w obrębie strefy sypialnej.

### Charakterystyka

- Aktywne strefy: jak Stay **+ strefy nocne (PIR korytarze, salon, kuchnia)**
- Wykluczone: **tylko PIR w sypialniach i łazience**
- Wykrywa intruza, który wszedł oknem do salonu (kontaktron + PIR) — perymetr i wewnętrzne PIR w nieużytkowanych pomieszczeniach

Trzeba dobrze przemyśleć położenie PIR-ów. Klasyczny błąd: PIR w korytarzu między sypialnią a łazienką jako „strefa nocna" — domownik wstaje w nocy do toalety i alarm wyje. Lepiej: **cały korytarz sypialny w wykluczonej strefie**, a PIR na schodach (parter–piętro) jako nocny.

## 4. Instant Arm — bez opóźnień

Wszystko jak Full Arm, ale **entry delay = 0 s**. Otwarcie drzwi wejściowych = natychmiastowy alarm. Stosowane:

- Gdy klawiatura jest **tuż przy drzwiach** (można rozbroić bez wchodzenia w głąb)
- W obiektach gdzie nie ma „zaufanej kategorii" osób wchodzących
- Jako alternatywa Stay — gdy wszyscy są w domu i wiadomo, że **nikt nie wchodzi** z zewnątrz
- Banki, kasy — tam żadna sekunda opóźnienia nie ma sensu

## 5. Auto-Arm — uzbrojenie automatyczne wg czasu

Centrala uzbraja się sama o **zaprogramowanej godzinie**. Typowe scenariusze:

- Codziennie o 23:00 — uzbrojenie Night Arm (gdy domownicy idą spać)
- Codziennie o 8:30 — uzbrojenie Full Arm (gdy wszyscy są w pracy)
- W weekendy o 1:00 — Night Arm (później niż w tygodniu)

### Pre-arm warning

Przed automatycznym uzbrojeniem centrala emituje **ostrzeżenie** (zwykle 1–5 minut wcześniej): klawiatura piszczy, świeci LED. Daje to czas na anulowanie (kod) gdy domownicy planują nocne wyjście do garażu.

### Auto-Disarm (rzadziej)

Centrala rozbraja się sama o ustawionej godzinie. Niezalecane jako zasada — narusza bezpieczeństwo. Stosowane w sklepach (otwarcie o 8:00) z dodatkowym kodem otwarcia po obsłudze.

## 6. Quick Arm — uzbrojenie bez kodu

Centrala umożliwia uzbrojenie **jednym przyciskiem** (bez kodu) — pomocne gdy ktoś szybko wychodzi. Rozbrojenie wymaga kodu (czyli wciąż bezpieczne).

Włączane jako opcja w konfiguracji — bywa wyłączone w obiektach o wyższym poziomie ochrony.

## 7. Force Arm — uzbrojenie z otwartą strefą

Normalnie centrala odmawia uzbrojenia jeśli jakaś strefa jest aktywna (otwarte okno, drzwi, awaria czujki). **Force Arm** = pomimo to uzbroić, automatycznie bypassując otwarte strefy.

Force Arm jest **niebezpieczny** — strefa pozostaje bypassowana do następnego rozbrojenia. Norma EN 50131 Grade 2+ wymaga, by force arm był rejestrowany w pamięci zdarzeń (audyt).

## Tabela porównawcza scenariuszy

| Scenariusz | Perymetr | Wewn. (interior) | Nocne | 24h | Entry delay |
|---|---|---|---|---|---|
| **Full Arm** | ✓ | ✓ | ✓ | ✓ | 30–60 s |
| **Stay Arm** | ✓ | ✗ | ✗ | ✓ | 30 s |
| **Night Arm** | ✓ | ✗ (sypialnia) | ✓ (reszta) | ✓ | 30 s |
| **Instant Arm** | ✓ | ✓ | ✓ | ✓ | 0 s |
| **Disarmed** | ✗ | ✗ | ✗ | ✓ | n/d |

## Realizacja w Satel Integra — przykład

```
# Z klawiatury LCD:
KOD + ARM (#1)          → Full Arm
KOD + ARM (#2)          → Stay (bez wewn.)
KOD + ARM (#3)          → Night (bez sypialni)
KOD + 0 + ARM           → Quick Arm (bez kodu)
KOD + DISARM (#)        → Rozbroić

# Z pilota APT-100 (Satel ABAX2):
Przycisk 1 (zielony)    → Full Arm
Przycisk 2 (żółty)      → Stay
Przycisk 3 (niebieski)  → Disarm
Przycisk 4 (czerwony)   → Panic (24h cichy)
```

## Konfiguracja stref pod scenariusze

Każda strefa ma w konfiguracji centrali **flagi** mówiące, w którym scenariuszu jest aktywna:

| Flaga | Znaczenie |
|---|---|
| NIGHT | aktywna w Night Arm |
| STAY | aktywna w Stay Arm (oznacza, że nie jest „interior") |
| EXIT | strefa wyjścia (drzwi główne) |
| INTERIOR | wewnętrzna — automatycznie wykluczona w Stay i Night |
| NO BYPASS | nie można bypassować (np. tampery) |
| CHIME | generuje dzwonek przy wzbudzeniu (chime mode) |

## Sygnalizacja stanu na klawiaturze

| LED | Stan |
|---|---|
| READY (zielona) | wszystkie strefy zamknięte, można uzbrajać |
| ARMED (czerwona stała) | centrala uzbrojona Full |
| ARMED (czerwona miga) | uzbrojona Stay / Night |
| TROUBLE (żółta) | awaria techniczna — sprawdź historię |
| BYPASS (żółta) | co najmniej jedna strefa bypassowana |
| AC (żółta miga) | brak zasilania 230V (na baterii) |

## Co dalej

➡ [Użytkownicy, kody, piloty](09-03-uzytkownicy-kody.md)
