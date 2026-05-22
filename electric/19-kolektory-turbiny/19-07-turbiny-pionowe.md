# Turbiny wiatrowe pionowe (VAWT) — rodzaje, wielkości, podłączenie do magazynu

Strona rozwija temat turbin o pionowej osi obrotu (VAWT — *Vertical Axis Wind Turbine*): jakie są rodzaje, jak dobrać wielkość oraz — najważniejsze — jak podłączyć turbinę i magazyn energii, gdy w domu masz już panele fotowoltaiczne pracujące na sieć (on-grid).

## Dlaczego turbina pionowa

VAWT mają oś obrotu prostopadłą do ziemi. W porównaniu z klasycznymi turbinami poziomymi (HAWT):

| Cecha | VAWT (pionowa) | HAWT (pozioma) |
|---|---|---|
| Kierunek wiatru | dowolny — nie wymaga ustawiania | wymaga kierownicy / silnika |
| Praca w turbulencji | dobra (zabudowa, dachy) | słaba |
| Hałas i wibracje | niskie | wyższe |
| Sprawność (Cp) | 0,15–0,35 | 0,35–0,45 |
| Generator i serwis | nisko, łatwy dostęp | na szczycie masztu |
| Rozruch | część typów samostartująca | dobra |
| Estetyka, ptaki | mniej inwazyjne | bardziej |

VAWT sprawdza się tam, gdzie wiatr jest słaby, zmienny i porywisty — czyli w typowej zabudowie przydomowej. Kosztem jest niższa sprawność.

> **Uczciwie:** w Polsce nizinnej średnia prędkość wiatru na małej wysokości to często 3–4 m/s. Ponieważ moc rośnie z sześcianem prędkości, turbina przydomowa rzadko bywa opłacalna czysto finansowo. Traktuj ją jako uzupełnienie PV (produkuje zimą i nocą) lub element systemu off-grid, nie jako główne źródło.

## Rodzaje turbin pionowych

### 1. Savonius (oporowa)

Wirnik z łopat w kształcie litery S (półwalce). Działa na zasadzie oporu aerodynamicznego — wiatr „popycha" łopatę.

- **Zalety:** samostartująca przy małym wietrze (już ~2 m/s), wysoki moment obrotowy, cicha, prosta, odporna na turbulencje.
- **Wady:** niska sprawność (Cp ≈ 0,15–0,20), niskie obroty, duża masa na jednostkę mocy.
- **Zastosowanie:** mikroturbiny, ładowanie akumulatorów, napęd pomp, sygnalizacja.

### 2. Darrieus (nośna, „trzepaczka")

Smukłe, zakrzywione łopaty (kształt jajka). Działa na sile nośnej — jak skrzydło samolotu.

- **Zalety:** wyższa sprawność (Cp ≈ 0,30–0,35), wysokie obroty, lekka.
- **Wady:** **nie startuje sama** — wymaga rozruchu (silnik, mały Savonius), pulsujący moment, naprężenia zmęczeniowe łopat.
- **Zastosowanie:** turbiny średniej mocy, zwykle w wariancie hybrydowym.

### 3. H-rotor / Giromill (Darrieus z prostymi łopatami)

Odmiana Darrieusa z prostymi, pionowymi łopatami zamocowanymi do ramion.

- **Zalety:** prosta konstrukcja, łopaty łatwe w produkcji, możliwy zmienny kąt natarcia (pitch).
- **Wady:** nadal słaby samorozruch, drgania.
- **Zastosowanie:** najpopularniejszy typ „komercyjny" wśród VAWT przydomowych.

### 4. Helikalna / spiralna (Gorlov)

Łopaty H-rotora skręcone śrubowo wzdłuż osi.

- **Zalety:** **płynny, równomierny moment** (brak pulsacji), mniejsze wibracje, ciche, lepszy samorozruch niż prosty Darrieus, ładny wygląd.
- **Wady:** droższa produkcja (skomplikowane łopaty).
- **Zastosowanie:** najczęściej wybierana do montażu na dachach domów i przy budynkach.

### 5. Hybrydowa Savonius–Darrieus

Mały Savonius w środku zapewnia samorozruch, zewnętrzny Darrieus/H-rotor — wydajność przy większym wietrze.

- **Zalety:** łączy samostart z dobrą sprawnością — uniwersalna.
- **Wady:** bardziej złożona, droższa.
- **Zastosowanie:** najlepszy kompromis dla domu, jeśli budżet pozwala.

| Typ | Cp | Samostart | Hałas | Typowe zastosowanie |
|---|---|---|---|---|
| Savonius | 0,15–0,20 | tak | b. niski | mikro, ładowanie akumulatorów |
| Darrieus | 0,30–0,35 | nie | niski | średnia moc (hybryda) |
| H-rotor / Giromill | 0,25–0,32 | słaby | niski | przydomowe |
| Helikalna | 0,25–0,32 | tak (lepiej) | b. niski | dachy, domy |
| Hybryda Sav.-Dar. | 0,25–0,35 | tak | niski | uniwersalna domowa |

## Wielkości i klasy mocy

Pole zamiatane VAWT to **A = średnica × wysokość** wirnika (prostokąt), nie koło jak w HAWT.

| Klasa | Moc znamionowa | Napięcie | Wirnik (śr.×wys.) | Zastosowanie |
|---|---|---|---|---|
| Mikro | 100–500 W | 12 / 24 V | ~0,5 × 1 m | monitoring, brama, łódź, działka |
| Mała | 0,5–2 kW | 24 / 48 V | ~1 × 2 m do 1,5 × 3 m | uzupełnienie domu, domek off-grid |
| Średnia | 3–10 kW | 48 V / HV | 2–3 × 4–6 m | dom off-grid / hybrydowy |
| Duża przydomowa | 10–20 kW | HV / 3-faz | >3 × 6 m | gospodarstwo, mała firma |

Moc szacujemy ze wzoru:

```
P = 0,5 · ρ · A · v³ · Cp
ρ = 1,225 kg/m³ (gęstość powietrza)
A = D · H  [m²]   — pole zamiatane VAWT
v = prędkość wiatru [m/s]
Cp = współczynnik wykorzystania (z tabeli wyżej)
```

**Przykład.** Helikalna 1,2 m × 2,5 m (A = 3 m²), wiatr 5 m/s, Cp 0,30:

```
P = 0,5 · 1,225 · 3 · 5³ · 0,30 = 0,5 · 1,225 · 3 · 125 · 0,30 ≈ 69 W
```

Przy 8 m/s ta sama turbina: P ≈ 0,5·1,225·3·512·0,30 ≈ 282 W. Widać sześcienną zależność — dlatego lokalizacja i wysokość masztu są kluczowe.

Produkcja roczna:

```
E_rok = P_średnia · 8760 h · CF
CF (współczynnik wykorzystania) = 0,10–0,20 dla VAWT przydomowej
```

## Generator i wyjście elektryczne turbiny

Niemal wszystkie małe VAWT mają **generator z magnesami trwałymi (PMSG)** dający **„dziki" prąd przemienny 3-fazowy** — o napięciu i częstotliwości zmieniających się wraz z prędkością obrotową. Tego prądu nie da się podać wprost do sieci ani do magazynu.

Ścieżka przetwarzania:

```
Turbina (3-faz AC zmienne)
   → Prostownik (mostek 3-fazowy) → DC zmienne
      → Regulator ładowania wiatrowego (wind charge controller)
         → Magazyn (DC, np. 48 V)
```

**Regulator wiatrowy różni się od solarnego MPPT!** Musi mieć:
- **Obciążenie balastowe (dump load / hamulec elektryczny)** — turbina **nie może pracować bez obciążenia**: gdy magazyn jest pełny, regulator przekierowuje energię na rezystor balastowy (lub grzałkę CWU), inaczej wirnik rozpędza się do prędkości niszczącej.
- **Hamulec zwarciowy** — awaryjne zatrzymanie przez zwarcie faz generatora.
- Krzywą obciążenia dopasowaną do charakterystyki turbiny.

> **Ostrzeżenie:** turbina pozostawiona bez podłączonego obciążenia przy silnym wietrze ulega rozbieganiu (*overspeed*) i zniszczeniu. Dump load to element obowiązkowy, nie opcja.

## Podłączenie turbiny i magazynu, gdy masz już PV on-grid

Sytuacja wyjściowa: w domu działa instalacja fotowoltaiczna podłączona do sieci (falownik *on-grid*, rozliczenie net-billing). Chcesz dołożyć **turbinę pionową** oraz **magazyn energii**. Falownik on-grid sam z siebie nie współpracuje z magazynem ani nie działa przy zaniku sieci. Są trzy drogi.

### Wariant A — dołożenie podsystemu AC-coupled (zalecany przy retrofitcie)

Istniejąca PV zostaje nietknięta. Turbina i magazyn tworzą osobny podsystem dołączony po stronie AC.

```
  ISTNIEJĄCE:
  Panele PV ── Falownik on-grid ──┐
                                  │
  NOWE:                           ▼
  Turbina VAWT                ┌─────────────────┐      ┌──────────┐
   → prostownik               │  Szyna AC domu  │──────│ Licznik  │── Sieć
   → regulator wiatrowy        │  (rozdzielnica) │      │ 2-kier.  │
   → magazyn 48 V ──┐          └────────┬────────┘      └──────────┘
                    │                   │
       Falownik bateryjny (AC-coupled)──┘
       z funkcją backup/EPS
                    │
              dump load (grzałka CWU)
```

- **Zalety:** nie ruszasz działającej PV i jej falownika; modułowo, etapami.
- **Wady:** podwójna konwersja energii z turbiny (DC→AC), nieco niższa sprawność; dwa falowniki.
- Falownik bateryjny mierzy przepływ na złączu (przekładniki CT) i steruje ładowaniem/rozładowaniem magazynu oraz funkcją backup.

### Wariant B — wymiana falownika on-grid na hybrydowy (DC-coupled dla PV)

Wymieniasz istniejący falownik PV na **falownik hybrydowy** z wejściem magazynu. Panele PV wpinasz w MPPT falownika hybrydowego. Turbina nadal idzie przez własny regulator wiatrowy do szyny DC magazynu.

```
  Panele PV ──────────────► MPPT ┐
                                 │
  Turbina VAWT                   ▼
   → prostownik            ┌──────────────────┐    ┌──────────┐
   → regulator wiatrowy ──►│ Falownik         │────│ Licznik  │── Sieć
   → szyna DC 48 V ───────►│ HYBRYDOWY        │    │ 2-kier.  │
        │                  │ (PV + magazyn +  │    └──────────┘
   Magazyn 48 V ──────────►│  sieć + backup)  │
        │                  └────────┬─────────┘
   dump load                        │
                            Obwody backup (EPS)
```

- **Zalety:** najwyższa sprawność dla PV (bez podwójnej konwersji), jeden centralny falownik, spójne sterowanie (EMS).
- **Wady:** koszt wymiany falownika; trzeba ponownie zgłosić zmianę do OSD.

### Wariant C — turbina tylko do magazynu, PV zostaje czysto on-grid

Najprostszy podział: PV pracuje wyłącznie na sieć (jak dotąd), a turbina ładuje wydzielony magazyn, z którego zasilane są tylko obwody krytyczne przez osobny falownik wyspowy.

```
  Panele PV ── Falownik on-grid ── Szyna AC ── Licznik ── Sieć

  Turbina VAWT → prostownik → regulator wiatrowy → Magazyn 48 V
                                                      │
                                            Falownik wyspowy
                                                      │
                                            Wydzielona rozdzielnica
                                            obwodów krytycznych
                                                  │
                                              dump load
```

- **Zalety:** brak ingerencji w działającą PV i umowę, pełna niezależność podsystemu.
- **Wady:** turbina nie wspiera obwodów ogólnych; magazyn ładowany tylko wiatrem (wolno).

### Który wariant wybrać

| Sytuacja | Zalecany wariant |
|---|---|
| Chcesz głównie backup przy zaniku sieci, minimum zmian | A |
| Budujesz docelowy spójny system, akceptujesz wymianę falownika | B |
| Turbina ma zasilać tylko kilka krytycznych obwodów | C |
| PV duża, turbina mała wspomagająca | A lub C |

## Dobór magazynu do turbiny + PV

Pojemność magazynu liczymy od potrzeb, nie od źródeł:

```
C_magazynu = E_dobowe_krytyczne · dni_autonomii / (DoD · η)
```

Turbina i PV są komplementarne (PV — dzień/lato, wiatr — noc/zima/jesień), więc magazyn nie musi pokrywać kilku dni — zwykle 1 dzień autonomii dla obwodów krytycznych. Szczegóły doboru: dział 18 „Magazyny energii".

Dobór napięcia magazynu — dopasuj do turbiny i falownika: do ~2 kW łącznej mocy 24 V, powyżej **48 V** (mniejsze prądy, cieńsze kable). Przy 48 V i mocy 3 kW prąd to ~63 A — kabel magazynu rzędu 16–25 mm².

## Sprawy formalne

- Dołożenie turbiny to **nowe źródło wytwórcze** — wymaga zgłoszenia/aktualizacji w OSD. Łączna moc mikroinstalacji (PV + turbina) nie może przekroczyć progu mikroinstalacji ani mocy przyłączeniowej.
- Wariant B (wymiana falownika) = aktualizacja danych instalacji w OSD i nowa deklaracja zgodności falownika.
- Magazyn dołączany do instalacji prosumenckiej — sprawdź warunki rozliczeń net-billing po dodaniu zasobnika.
- Turbina to też obiekt budowlany — maszt powyżej pewnej wysokości wymaga zgłoszenia lub pozwolenia; sprawdź miejscowy plan zagospodarowania i odległości od granicy działki.
- Falownik backup/wyspowy musi mieć zabezpieczenie *anti-islanding* (nie podaje napięcia do sieci przy jej zaniku).

## Podsumowanie

- Do domu w turbulentnym, słabym wietrze najlepsze są VAWT **helikalne** lub **hybrydowe Savonius–Darrieus** — samostartują i są ciche.
- Wielkość dobieraj realnie: mikro/mała klasa (0,1–2 kW) jako uzupełnienie, nie główne źródło.
- Turbina wymaga **regulatora wiatrowego z dump loadem** — bez obciążenia ulega zniszczeniu.
- Mając PV on-grid, dołożenie turbiny i magazynu zrób najczęściej jako **AC-coupled** (wariant A) — nie ruszasz działającej PV; albo przejdź na **falownik hybrydowy** (wariant B), jeśli chcesz spójny, sprawniejszy system.
- Każda zmiana źródeł = zgłoszenie do OSD.
