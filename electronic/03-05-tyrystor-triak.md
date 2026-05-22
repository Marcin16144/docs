# 03-05: Tyrystor, triak, diak

## Tyrystor (SCR — Silicon Controlled Rectifier)

### Czym jest

Czterowarstwowy element półprzewodnikowy PNPN. Działa jak **przełącznik jednokierunkowy** — przewodzi po impulsie sterującym w bramce i pozostaje przewodzący aż do zaniku prądu anodowego.

```
        A (anoda)
        │
       PNPN
        │
   ┌────G (gate, brama)
   │
   │    
        K (katoda)
```

Symbol:

```
   A ──▷│── K
         │
         G
```

To dioda z dodatkowym wyprowadzeniem (G) sterującym.

### Działanie

1. **Stan zatkany** — brak impulsu na G, prąd nie płynie (jak otwarty wyłącznik).
2. **Impuls na G** — krótki sygnał (mA, μs) → tyrystor "zapala się".
3. **Stan przewodzenia** — zachowuje się jak dioda, prąd A → K.
4. **Wyłączenie** — gdy prąd anodowy spadnie poniżej **I_H (holding current)**, tyrystor sam się wyłącza. Nie można go wyłączyć przez bramkę!

### W AC samoczynnie się wyłącza

W obwodzie AC prąd przechodzi przez zero co 10 ms (50 Hz). Tyrystor wtedy się wyłącza i czeka na kolejny impuls G.

W obwodzie DC raz załączony tyrystor **nigdy się nie wyłączy** bez przerwania prądu w obwodzie głównym.

### Parametry

| Parametr | Symbol | Typowe |
|----------|--------|--------|
| Max napięcie zaporowe | V_DRM | 100 V – 2 kV |
| Max prąd przewodzenia | I_T_AV | 1 A – 1000 A |
| Prąd podtrzymania | I_H | mA – setki mA |
| Prąd zapłonu bramki | I_GT | mA |
| Czas włączania | t_gt | μs |
| dV/dt max | V/μs | krytyczne — szybkie zmiany mogą "samowłączać" tyrystor |

### Popularne modele

- **BT151** — 7,5 A, 500 V — wymienniki, ściemniacze
- **TIC106** — 5 A, 400 V — uniwersalny
- **2N6027** — programmable UJT, do generatorów impulsów
- **C106** — 4 A, sygnałowy

### Regulacja fazowa AC

Klasyczne zastosowanie — ściemniacze, regulatory mocy.

Idea: zmienia się **kąt zapłonu** w każdej połówce sinusoidy. Jeśli zapalimy tyrystor w 90° (połowa półokresu) — przepuszczamy tylko drugą połowę połówki = ~50% mocy.

```
sinus      
   /\           /\
  /  \         /  \
 /    \       /    \
─────────────────────  
        \   /
         \ /
          V

z tyrystorem (zapłon w 90°):
                ┌─\
              ┌─┘  \
            ──┘    \
           /        \
─────────────────────
```

Sterowanie: kondensator + rezystor regulowany (potencjometr) → ładuje się przez R, w pewnym momencie napięcie wystarcza do zapłonu diaka, który zapala tyrystor.

### GTO (Gate Turn-Off Thyristor)

Wariant — można wyłączyć **ujemnym** impulsem bramki. Stosowane w przemyśle (falowniki dużej mocy). Wymagany duży prąd wyłączający.

## Triak

### Czym jest

Dwa tyrystory antyrównoległe w jednej obudowie. Przewodzi w obie strony — idealny do AC.

Symbol:

```
   T2 ──▷│──── T1
         │  
         │  G
   
   (dwie strzałki w przeciwnych kierunkach)
```

### Końcówki

- **T1** (lub MT1, A1) — anoda 1
- **T2** (lub MT2, A2) — anoda 2 (referencja dla G)
- **G** — bramka

### Działanie

Triak zapala się impulsem na G względem T1. **Cztery tryby pracy** (kwadranty):

| Tryb | U(T2-T1) | U(G-T1) |
|------|----------|---------|
| Q1 | + | + |
| Q2 | + | − |
| Q3 | − | − |
| Q4 | − | + |

Q1 i Q3 są najczulsze (najmniejszy I_GT). Q4 najsłabszy — niektóre triaki Q4 nie działają w ogóle.

### Snubber RC

Triaki są wrażliwe na **dV/dt** — szybkie zmiany napięcia mogą je samoczynnie zapalać. Stosuje się **snubber**: rezystor 47-100 Ω + kondensator 10-100 nF równolegle do triaka.

```
        ─T2────┐
               ├─[R]─[C]─┐
        ─T1────┘         │
                          ←
```

To zwłaszcza przy obciążeniach indukcyjnych (transformatory, silniki).

### Popularne triaki

- **BT136** — 4 A, 600 V — standardowy do 1 kW
- **BT139** — 16 A, 800 V — większe obciążenia
- **BTA40** — 40 A — przemysłowe
- **MAC97A6** — 0,6 A — małe sterowania

### Optoodseparowane triaki (MOC)

Połączenie LED + triak w jednej obudowie. Sterowanie z MCU bezpiecznie galwaniczne.

- **MOC3021** — bez zero-cross (sterowanie fazowe)
- **MOC3041** — zero-cross detector (włącza tylko przy U=0, mniej EMI, do termostatów, grzałek)

### Schemat sterowania triaka z MCU

```
   +5V         AC 230V
    │           │
    │       [bezpiecznik]
    │           │
    │           ●──── T2
   LED         [Rg]
    │           ●──── G
   ──            │
    │           T1 ── obciążenie ── N
    R           
    │           
   GND──── opto + triak
```

MOC3021 + triak BT136. R w obwodzie sterowania = 330 Ω. Rezystor R_g między G a obwodem opto ≈ 300-470 Ω.

## Diak

### Czym jest

Dwukońcówkowy element wyzwalający — symetryczny przyrząd przebiciowy. Po przekroczeniu napięcia ~30 V w **dowolnym kierunku** gwałtownie przewodzi i napięcie spada o kilka woltów.

Symbol: dwa trójkąty zwrócone w siebie.

### Zastosowanie

Wyłącznie do generowania impulsów wyzwalających triaki / tyrystory. Stosowane w ściemniaczach:

```
            ┌─[Rt]──● gate triaka
           
   ◇ diak
            │
            ●─── kondensator ── potencjometr ── faza AC
```

Kondensator ładuje się przez potencjometr — gdy napięcie osiągnie próg diaka (~32 V), diak przebija, kondensator rozładowuje się przez bramkę triaka → zapłon.

Sterowanie potencjometrem zmienia szybkość ładowania kondensatora → opóźnienie zapłonu → moc na obciążeniu.

## Sterowanie zero-cross

Dwa sposoby sterowania triakiem:

### 1. Fazowe (phase angle)

Każda połówka sinusoidy jest "przycinana". Płynne sterowanie mocy. **Generuje EMI** (gwałtowne przełączanie w środku sinusa). Stosowane: oświetlenie, drobne grzałki.

### 2. Zero-cross (burst firing)

Triak włącza się tylko gdy U=0 i wyłącza po pełnej liczbie półokresów. Sterowanie procentowe (np. 50% = 5 okresów ON, 5 OFF). Bez EMI, ale dyskretne. Stosowane: grzałki, termostaty.

## Zastosowania w praktyce

### 1. Ściemniacz światła

Triak + diak + R + C w klasycznym układzie regulacji fazowej. Z bramką sterowaną od kondensatora ładującego się przez potencjometr.

### 2. Regulator mocy grzałki

Bardziej zaawansowane — z opto-triakiem i MCU sterującym (np. PID).

### 3. Sterowanie silnikiem AC

Triak z odpowiednim snubberem.

### 4. Stycznik półprzewodnikowy (SSR — Solid State Relay)

Optoseparowany triak w obudowie. Sterowanie 3-32 V DC, przełączanie 230 V AC. Bez ruchomych części, długa żywotność, drogi (~30-100 zł).

### 5. Crowbar

Tyrystor w roli zabezpieczenia. Przy przekroczeniu napięcia (np. uszkodzenie stabilizatora) tyrystor zwiera zasilanie do masy → bezpiecznik się przepala. Chroni odbiornik przed wysokim napięciem.

## Wybór — checklist

### Tyrystor

1. Napięcie blokowania V_DRM z zapasem 2×
2. Prąd I_T_AV z zapasem
3. I_GT — czy sterowanie potrafi dostarczyć?
4. I_H — przy minimalnym prądzie obciążenia, czy tyrystor zostanie włączony?
5. Czas wyłączania t_q — ważny przy DC i wysokich częstotliwościach

### Triak

1. V_DRM (zwykle ≥ 600 V dla 230 V AC)
2. I_T_RMS — RMS prądu obciążenia
3. dV/dt — potrzebny snubber?
4. Kwadranty pracy — Q4 czasem problematyczny
5. Sterowanie galwaniczne — opto?

## Częste błędy

1. **Brak snubbera RC** przy obciążeniu indukcyjnym → samowłączanie triaka.
2. **Bezpośrednie sterowanie z MCU** bez optoizolacji — porażenie / uszkodzenie.
3. **Tyrystor w DC bez mechanizmu wyłączania** — nigdy się nie wyłączy.
4. **Niedostateczny I_H** — przy małym obciążeniu (np. LED) triak nie zostaje włączony.
5. **Brak filtra EMI** w sterowaniu fazowym — zakłócenia w radiu, sąsiedzkim sprzęcie.
6. **Niewłaściwy moc rezystora bramki** — chwilowo płynie duży prąd, mały rezystor się przepala.
7. **Pomylone T1/T2** — bramka jest sterowana **względem T1** (lub MT1) — pomyłka = brak działania.
