# 06-07: Pomiary i diagnostyka transformatorów

## Wstęp

Transformator może być nowy (sprawdzamy projekt) lub używany (diagnostyka). Procedury są podobne, ale akcent na różne aspekty.

## Pomiary podstawowe

### 1. Ciągłość uzwojeń

**Multimetr w trybie omomierza.**

Mierzysz między końcówkami każdego uzwojenia:

| Uzwojenie | Typowa rezystancja |
|-----------|--------------------|
| Pierwotne (sieciowy 100 W) | 5-50 Ω |
| Wtórne niskonapięciowe (12 V, 5 A) | 0,1-1 Ω |
| Trafo HF (flyback) — pierwotne | 1-5 Ω |
| Trafo HF — wtórne | 0,01-0,1 Ω |
| Common-mode choke | 0,1-1 Ω |

**Brak ciągłości** (∞) → przerwa w uzwojeniu (zwykle przegrzanie i spalenie).

**Bardzo niska rezystancja** (np. 0,1 Ω przy spodziewanej 10 Ω) → zwarcie międzyzwojowe.

### 2. Izolacja między uzwojeniami

**Megerem (omomierzem wysokiego napięcia).**

Pomiar między:
- pierwotnym a wtórnym
- pierwotnym a rdzeniem
- wtórnym a rdzeniem

Wymagania:
- Sieciowy transformator izolacyjny: > 100 MΩ przy 500 V DC
- SMPS pierwotne ↔ wtórne: > 100 MΩ
- Trafo niskonapięciowe: > 10 MΩ

Niska wartość → wilgoć, przebicie, kontaminacja.

### 3. Wytrzymałość izolacji (Hipot)

**Tylko ze specjalistycznym sprzętem** (3-5 kV próbnik napięciowy).

Przyłożyć 3 kV AC RMS (lub 4,2 kV DC) między pierwotne i wtórne na 60 sekund. Brak przebicia / nadmiernego prądu = OK.

**Niebezpieczne** — nie próbuj bez doświadczenia.

## Pomiar pod napięciem

### 4. Próba jałowa

Podłączysz tylko pierwotne (znamionowe U₁), wtórne **otwarte**.

Mierz:
- **U₁** (napięcie wejściowe)
- **I₀** (prąd pobierany)
- **P₀** (moc pobierana — wattomierz lub szacunkowo)

Wnioski:
- **I₀** = 5-15% I_znam dla typowych. Wyższy → zwarcie międzyzwojowe lub niewłaściwy projekt.
- **P₀** = straty rdzenia (Fe losses) — głównie histereza + wiroprądy.
- Pomiar **napięcia na każdym wtórnym** — przekładnia, czy zgodna z projektem?

### 5. Próba zwarciowa

Zwarcie wtórne (czasem przez bocznik prądowy), przyłożyć **obniżone napięcie** pierwotnego tak, by płynął prąd znamionowy.

```
u_z = U_zwarcia / U_znamionowe · 100%
```

Pomiar:
- **U_z** (np. 5-10% U_znam)
- **P_z** (przy prądzie nominalnym) = **straty miedziane** (R_uzwojenie · I²)

Wyznacza:
- Rezystancję wewnętrzną
- Spadek napięcia pod obciążeniem
- Krótki opór zwarciowy

### 6. Pełne obciążenie

Najbardziej miarodajny test. Obciąż wtórne nominalnym prądem (rezystorem mocy lub regulowanym obciążeniem).

Mierz:
- U_1 (pierwotne)
- I_1 (prąd pierwotnego)
- U_2 (wtórne pod obciążeniem)
- I_2 (prąd wtórny)
- Temperatura po 1-2 godzinach

Sprawność:
```
η = (U_2 · I_2) / (U_1 · I_1 · cos φ_1)
```

(Dla cos φ ≈ 1 dla rezystancyjnego obciążenia można uprościć.)

### 7. Pomiar temperatury

Po godzinie pracy pod obciążeniem nominalnym:
- Powierzchnia 40-60°C → OK (klasa B/F)
- 70-90°C → granica F/H
- > 90°C → przeciążenie, projekt do poprawy

Pomiar bezdotykowym pirometrem lub termoparą.

## Pomiar indukcyjności

### Multimeter LCR

Bezpośrednie L_1 przy odłączonym wtórnym (próba jałowa). Częstotliwość pomiaru zwykle 100 Hz, 1 kHz, 10 kHz.

Dla sieciowego: L_1 = setki H – kilka mH.
Dla SMPS flyback: L_1 = setki μH – kilka mH.

### Indukcyjność wzajemna

Zwarcie wtórnego, pomiar L_pri (impedancja widziana z pierwotnego). Stosunek:
```
L_pri_short / L_pri_open = współczynnik sprzężenia k²
```

k → 1 dla idealnego sprzężenia.

## Diagnostyka usterek

### Objaw 1: Trafo grzeje się gwałtownie po włączeniu

**Możliwe przyczyny:**
- Zwarcie międzyzwojowe (pierwotny lub wtórny)
- Zwarcie wtórnego (zewnętrzne)
- Przeciążenie

**Diagnoza:**
1. Zmierz rezystancję uzwojeń (porównanie z fabryczną).
2. Włącz przez **żarówkę 60 W szeregowo** (soft start). Jeśli świeci jasno → zwarcie wewnętrzne.
3. Odpuść wtórne — czy ten objaw pozostaje?

### Objaw 2: Buczenie / drganie

**Przyczyny:**
- Luźny pakiet blach
- Wibracje mechaniczne
- Nasycenie magnetyczne (zbyt wysokie U)

**Diagnoza:**
- Sprawdź pakiet — dokręć śruby
- Mierz prąd jałowy — czy wzrósł?
- Sprawdź napięcie zasilania (czy nie wzrosło, np. po godzinach mała sieć)

### Objaw 3: Niskie napięcie wyjściowe

**Przyczyny:**
- Mała liczba zwojów wtórnego (błąd projektu)
- Zwarcie międzyzwojowe wtórnego
- Niska sieć

**Diagnoza:**
- Mierz wtórne bez obciążenia. Niski → zwarcie w wtórnym.
- Sprawdź napięcie sieci.
- Sprawdź czy wszystkie odczepy są właściwe.

### Objaw 4: Brak napięcia na jednym wtórnym

**Przyczyny:**
- Przerwa w uzwojeniu wtórnym
- Złe lutowanie końcówek
- Pęknięty drut wewnątrz karkasu

**Diagnoza:**
- Multimetrem ciągłości
- Rozbieranie pakietu i sprawdzanie wzrokowe

### Objaw 5: Spalony / cuchnący lakier

**Przyczyny:**
- Przeciążenie ponad granice termiczne
- Zwarcie międzyzwojowe pozwalające płynąć dużemu prądowi
- Zła wentylacja, otoczenie wysoka temperatura

**Po pożarze:**
- Trafo zwykle do wyrzucenia
- Można przewinąć (jeśli rdzeń nieuszkodzony)

### Objaw 6: Pulsujące napięcie wyjściowe (DC po prostowniku)

**Przyczyny:**
- Mostek prostowniczy częściowo uszkodzony
- Trafo z asymetrią uzwojeń (jedna połówka inna od drugiej)
- Sieć asymetryczna (rzadko)

**Diagnoza:**
- Mostek bezpośrednio sprawdzić
- Oscyloskop na wtórnym

## Lokalizacja zwarcia międzyzwojowego

Najtrudniejsza diagnoza. Multimetr może nie wykryć (zmiana rezystancji tylko o ułamek %).

### Metoda 1: pomiar L

LCR-meter mierzy indukcyjność. Z zwarciem L spada drastycznie (zwarte zwoje = krótki obwód magnetyczny).

Porównaj z fabrycznym (jeśli mamy referencję).

### Metoda 2: prąd jałowy

Trafo ze zwarciem ma **wyraźnie wyższy prąd jałowy** (czasem 2-5× więcej).

### Metoda 3: Test wytrzymałości (Surge / Impulse Tester)

Profesjonalny przyrząd — wysokonapięciowy impuls, obserwacja krzywej zaniku. Każde zwarcie zmienia kształt krzywej.

### Metoda 4: pomiar nagrzewania

Trafo ze zwarciem grzeje się lokalnie. Termowizja, dotyk.

### Metoda 5: porównanie z dobrym

Jeśli masz drugi, identyczny transformator (np. taki sam model) — porównuj parametry przy tych samych warunkach.

## Diagnostyka transformatora SMPS

### Bez wyłutowywania z PCB

1. **Rezystancje uzwojeń** — multimetr, porównanie z drugim PCB lub schematem.
2. **Pomiar pojemności** — czasem zwarcie zwiększa pojemność widzianą.
3. **Test oscyloskopem** w działaniu (jeśli PCB można uruchomić bez awarii).

### Po wyłutowaniu

1. **Rezystancja każdego uzwojenia** (każde z osobna).
2. **Izolacja** między nimi (megger 500 V).
3. **Indukcyjność** każdego uzwojenia (LCR).
4. **Test impulsem** (jeśli mamy odpowiedni sprzęt).

## Sprawdzenie transformatora przed użyciem

Procedura przed zakupem (nowy) lub uruchomieniem (z naprawy):

1. **Wzrokowe** — czy nie spalony, nie wycieka olej (jeśli olejowy), nie pęknięta obudowa.
2. **Multimetr ciągłość** każdego uzwojenia.
3. **Megger izolacja** między uzwojeniami i do rdzenia.
4. **Pomiar U_2 bez obciążenia** przy niskim napięciu pierwotnego (np. przez Variac do 100 V).
5. **Stopniowe nakładanie napięcia** — kontrola I_0 (czy nie rośnie szybciej niż liniowo).
6. **Pełne U_1** + obciążenie + pomiar temperatury po godzinie.

## Bezpieczeństwo pomiarów

### Pomiar z otwartą obudową

Stosuj:
- **Transformator izolacyjny** — żeby nie być w obwodzie sieci
- **Różnicówka** 30 mA
- **Sondy z izolacją** kategorii odpowiedniej (CAT II / CAT III)

### Pomiar wysokich napięć

- Sondy wysokonapięciowe (zwykle 1:100, 1:1000)
- **Nigdy** ręcznie nie dotykaj rdzenia podczas pracy
- Pamiętaj o **rozładowaniu kondensatorów** przed pomiarem

### Pomiar prądów

- **Cęgi prądowe** zamiast szeregowego przerwania
- Nigdy nie zwieraj amperomierza zamiast woltomierza (uszkodzenie)
- **Bezpieczniki w multimetrze** — sprawdź, czy nie przepalone

## Pomiar transformatorów RF / impulsowych

### Analizatorem widma / sieci

VNA (Vector Network Analyzer) — pomiar impedancji, S-parametrów. Pokazuje:
- Pasmo
- Indukcyjność rozproszenia
- Pojemność pasożytniczą

### Generator + oscyloskop

Pobudzaj sygnałem różnych częstotliwości, obserwuj wtórne. Tworzysz charakterystykę częstotliwościową.

### Pomiar B-H

Specjalistyczny — generator + integrator + scope. Wykreśla pętlę histerezy. Można policzyć straty rdzenia.

## Notes z laboratoryjnych pomiarów

**Najczęstsze obserwacje z prawdziwych transformatorów:**

1. **Prąd jałowy spadnie ze wzrostem temperatury** (rosną straty rdzenia, spada μ).
2. **Stary transformator z wycieklym olejem** często działa, ale izolacja zła — przebicia.
3. **Sieciowy 50 Hz w 60 Hz** (USA) — działa, ale B_max wyższe → grzanie.
4. **Małe transformatory są mniej sprawne** — fizyka: stosunek powierzchni do objętości.
5. **Toroidalny lepszy niż EI** o tej samej masie — sprawność wyższa o 2-5%.

## Niepowodzenia trafa — analiza

### Krótki przegląd 100 awarii sieciowych trafa

| Przyczyna | Procent |
|-----------|---------|
| Przeciążenie i przegrzanie | 35% |
| Zwarcie międzyzwojowe (wilgoć, starzenie) | 25% |
| Przebicie izolacji | 15% |
| Mechaniczne uszkodzenie | 10% |
| Wyładowanie atmosferyczne / przepięcia | 10% |
| Wadliwa produkcja | 5% |

Stąd profilaktyka:
- **Nie przeciążaj** powyżej znamionowej mocy
- **Wentylacja** — temperatura otoczenia ≤ 40°C
- **Sieciowe filtry przepięciowe** (warystory, TVS)
- **Regularna inspekcja wzrokowa** sprzętu serwisowego

## Podsumowanie

Diagnostyka transformatorów to:

1. **Pomiar rezystancji** każdego uzwojenia (multimetr)
2. **Pomiar izolacji** między uzwojeniami i do rdzenia (megger)
3. **Pomiar prądu jałowego** (próba jałowa)
4. **Pomiar pod obciążeniem** (rezystor, pomiar U₂, I₂, T)
5. **Specjalistyczne testy** w razie potrzeby (LCR, Surge tester)

Z doświadczeniem wystarczy multimetr + obserwacja, by 90% problemów zdiagnozować poprawnie.
