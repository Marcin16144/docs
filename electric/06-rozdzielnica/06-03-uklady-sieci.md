# Układy sieci TN-C, TN-S, TN-C-S, TT, IT

**Układ sieci** opisuje sposób uziemienia źródła (transformatora) i sposób połączenia odbiorcy z ziemią. To jeden z najważniejszych parametrów instalacji — decyduje o **dobór środków ochrony** (RCD, samoczynne wyłączenie).

## Nomenklatura literowa

```
   pierwsza litera = punkt zerowy transformatora:
       T = bezpośrednio uziemiony (Terra)
       I = izolowany (Insulated)
   
   druga litera = obudowy odbiorników:
       T = uziemione lokalnie (Terra, własne uziom)
       N = połączone z N zasilania (Neutral)
   
   trzecia/czwarta = sposób prowadzenia N i PE:
       C = łączone (Combined: PEN — jeden przewód)
       S = oddzielne (Separate)
       C-S = początkowo łączone, potem rozdzielone
```

## TN-C — przestarzały, dopuszczalny tylko do złącza

**T**N-**C**: punkt zerowy transformatora uziemiony, obudowy połączone z **PEN** (przewód łączący funkcję PE i N).

```
   Transformator:                  Odbiorca:
   ┌────────┐                      ┌─────────┐
   │   L1   ├──────────────────────┤   L1    │
   │   L2   ├──────────────────────┤   L2    │
   │   L3   ├──────────────────────┤   L3    │
   │  PEN   ├──────────────────────┤  PEN    │ ←┐
   │   ▼    │                      └─────────┘  │
   │  uziom │                                   │ PEN dochodzi do obudów
   └────────┘                                   │ i do listwy "PE"
```

**ZAKAZ** w nowych domach (od PN-IEC 60364). Dopuszczalny tylko:

- na **odcinku zasilającym** od transformatora do złącza ZK,
- w istniejących starych instalacjach do remontu.

**Dlaczego niebezpieczny?** Pęknięcie PEN = obudowy odbiorników pod napięciem (do 230 V), niemożność stosowania RCD.

## TN-S — najlepszy, standard nowoczesny

**T**N-**S**: PE i N **rozdzielone od źródła**. Każdy ma swój własny przewód.

```
   Transformator:                  Odbiorca:
   ┌────────┐                      ┌─────────┐
   │   L1   ├──────────────────────┤   L1    │
   │   L2   ├──────────────────────┤   L2    │
   │   L3   ├──────────────────────┤   L3    │
   │    N   ├──────────────────────┤   N     │
   │   PE   ├──────────────────────┤   PE    │
   │    ▼   │                      └─────────┘
   │  uziom │
   └────────┘
```

**Zalety:**

- pełna selektywność i niezależność N i PE,
- RCD działa idealnie,
- bezpieczne dla układów z falownikami i UPS.

**Wada:** wymaga 5-żyłowego przyłącza (większy koszt kabla od transformatora).

Stosowane w: **wszystkich nowych domach**, biurowcach, instalacjach elektrowni PV i stacjach ładowania.

## TN-C-S — typowe w polskich domach jednorodzinnych

**T**N-**C**-**S**: na przyłączu (do złącza ZK) jest **PEN** (jak TN-C), w rozdzielnicy domowej PEN się rozdziela na **PE i N** (od tego momentu TN-S).

```
   Transformator:    przyłącze:       złącze ZK:        instalacja domu:
   ┌────────┐                          ┌────────┐
   │   L1   ├─────  L1 ─────────────── L1
   │   L2   ├─────  L2 ─────────────── L2
   │   L3   ├─────  L3 ─────────────── L3
   │  PEN   ├─────  PEN ────────────── ──┬── N (do dalej)
   │    ▼   │      (4-żyłowe)            └── PE (do dalej + uziom domu)
   │  uziom │                            ▲
   └────────┘                            │ rozdzielenie PEN→PE+N
                                         │ z DODATKOWYM uziomem domu
                                         │ (uziom otokowy)
```

**Zasada:** w punkcie rozdzielenia musi być **dodatkowy uziom** (otokowy lub szpilki) — bezpieczeństwo na wypadek pęknięcia PEN w sieci.

**Stosowane w:** ~95% polskich domów jednorodzinnych zasilanych z sieci ZE napowietrznej lub kablowej 4-żyłowej.

## TT — własne uziemienie odbiorcy

**T**T: punkt zerowy transformatora uziemiony, ale obudowy odbiorcy uziemione **niezależnie** (własny uziom). Brak PE z sieci.

```
   Transformator:                  Odbiorca:
   ┌────────┐                      ┌─────────┐
   │   L1   ├──────────────────────┤   L1    │
   │   L2   ├──────────────────────┤   L2    │
   │   L3   ├──────────────────────┤   L3    │
   │    N   ├──────────────────────┤   N     │
   │    ▼   │                      │   PE ── ▼ własny uziom
   │  uziom │                      └─────────┘   odbiorcy
   └────────┘                          (niezależny)
```

**Wymóg krytyczny:** TT **wymaga RCD obowiązkowo** — samoczynne wyłączenie tylko przez RCD przy wysokiej impedancji Zs.

**Stosowane w:**
- gospodarstwa wiejskie z własnym uziomem,
- przyłącza napowietrzne 3-żyłowe (bez PE/PEN),
- niektóre stacje transformatorowe pełnowiejskie.

### Dlaczego TT wymaga RCD?

W TN-S/TN-C-S impedancja pętli zwarcia jest **niska** (Zs <0,5 Ω, czasem <0,1 Ω) — przy zwarciu doziemnym prąd zwarcia jest **bardzo duży** (~500 A) → MCB wybija samoczynnie w <0,4 s.

W TT impedancja jest **wysoka** (Zs często 30–80 Ω, własny uziom + impedancja gruntu) — prąd zwarcia jest **mały** (~3–8 A) → MCB **nie wybija** szybko (B16 wymaga >80 A). Jedyna ochrona to **RCD 30 mA**, który wybija przy 30 mA już w 30 ms.

## IT — izolowany, szczególne zastosowania

**I**T: punkt zerowy transformatora **nie jest uziemiony** (albo przez bardzo dużą impedancję, np. 1000 Ω). Obudowy uziemione lokalnie.

```
   Transformator:                  Odbiorca:
   ┌────────┐                      ┌─────────┐
   │   L1   ├──────────────────────┤   L1    │
   │   L2   ├──────────────────────┤   L2    │
   │   L3   ├──────────────────────┤   L3    │
   │   N    ├──────────────────────┤  N      │
   │   ▼    │   (brak bezpośr.    │  PE ── ▼ własny uziom
   │   Z    │    uziemienia trafo)│         │
   └────────┘                      └─────────┘
```

**Zalety:** pierwsze zwarcie doziemne nie powoduje przepływu prądu (potrzebne dopiero **drugie**) — kontynuacja pracy mimo usterki.

**Stosowane w:** szpitale (sale operacyjne — pacjent nie może być narażony na nagłą utratę zasilania), statki, kopalnie, niektóre obiekty przemysłu.

**Nie stosowane** w domach mieszkalnych.

## Porównanie zbiorcze

| Układ | PE+N | RCD | Stosowanie | Status |
|---|---|---|---|---|
| **TN-C** | wspólny PEN | nie działa | tylko do złącza | **ZAKAZ w domu** |
| **TN-S** | osobne od źródła | działa | nowe domy z 5-żyłowym | **zalecany** |
| **TN-C-S** | PEN do ZK, dalej osobno | działa | typowy dom 4-żyłowe przyłącze | **standard PL** |
| **TT** | brak PE z sieci, własny uziom | **OBOWIĄZKOWY** | wieś, stare przyłącza 3-żył. | dopuszczalny |
| **IT** | bez uziemienia trafo | działa po 2. zwarciu | szpitale, statki | nie w domu |

## Jak rozpoznać układ w istniejącej instalacji

| Cecha | TN-C-S | TT |
|---|---|---|
| Liczba żył w kablu przyłączeniowym | 4 (PEN) lub 5 (PE+N osobno) | 4 (L1+L2+L3+N) — bez PE |
| Czy w ZK są dwa zaciski (PE i N)? | **TAK** w TN-S; PEN w TN-C-S | NIE — tylko N |
| Czy dom ma własny uziom? | TAK (dodatkowy w TN-C-S) | TAK (krytyczny) |
| Impedancja pętli Zs | <1 Ω typowo | 5–80 Ω |
| Czy bez RCD bezpieczne? | częściowo (MCB wybija) | **NIE** |

## Co dalej

➡ [Dobór wielkości rozdzielnicy](06-04-dobor-wielkosci.md)
