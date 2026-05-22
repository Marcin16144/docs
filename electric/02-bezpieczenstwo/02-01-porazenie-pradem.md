# Wpływ prądu na organizm

## Dlaczego prąd jest groźny

Prąd elektryczny przepływający przez ciało człowieka wywołuje trzy typy szkodliwych efektów:

1. **Skurcze mięśni** — niezdolność puszczenia przedmiotu pod napięciem ("przyklejenie się")
2. **Zaburzenia pracy serca** — od arytmii po fibrylację komór (najczęstsza przyczyna zgonu)
3. **Oparzenia** — wewnętrzne (na drodze prądu) i zewnętrzne (w miejscu kontaktu)

Kluczowym parametrem jest **wartość prądu**, a nie napięcie — to prąd zabija. Napięcie jedynie określa, czy w danych warunkach prąd osiągnie groźną wartość.

## Tabela progów prądowych dla AC 50 Hz (droga ręka-ręka)

| Prąd | Czas | Skutek |
|---|---|---|
| **< 0,5 mA** | dowolny | brak odczucia |
| **1 mA** | dowolny | próg odczuwania, lekkie mrowienie |
| **5 mA** | dowolny | wyraźny ból, próg reakcji |
| **10-15 mA** | sekundy | granica samouwolnienia — silne skurcze mięśni, trudność puszczenia przedmiotu |
| **30 mA** | > 0,5 s | groźny — początek fibrylacji, niewydolność oddechowa **(stąd próg RCD = 30 mA)** |
| **50-80 mA** | sekundy | wysokie ryzyko fibrylacji komór serca |
| **100 mA** | > 2 s | praktycznie pewna fibrylacja, zatrzymanie serca |
| **500 mA - 1 A** | krótki | oparzenia wewnętrzne, zatrzymanie akcji serca |
| **kilka A** | bardzo krótki | natychmiastowe zatrzymanie krążenia, ciężkie oparzenia |

## Znaczenie czasu działania

Im krótszy czas przepływu prądu, tym mniejsze ryzyko. Norma PN-EN 60479 definiuje strefy bezpieczeństwa w układzie współrzędnych prąd-czas:

| Strefa | Prąd × czas | Skutek |
|---|---|---|
| AC-1 | <0,5 mA, dowolny czas | brak odczucia |
| AC-2 | do 10 mA przez sekundy | bez efektów patofizjologicznych |
| AC-3 | 10-100 mA, do 1-3 s | bez fibrylacji, ale silny ból, skurcze |
| AC-4 | >100 mA lub >3 s | prawdopodobieństwo fibrylacji rośnie szybko |

Stąd kluczowa rola **wyłączników różnicowoprądowych RCD** (30 mA, czas zadziałania <30 ms) — utrzymują punkt pracy w strefie AC-3.

## Napięcia bezpieczne (SELV / PELV)

Norma PN-EN 61140 definiuje napięcia, przy których ryzyko porażenia jest minimalne w warunkach suchych:

| System | U_max AC | U_max DC | Zastosowanie |
|---|---|---|---|
| **SELV** (Safety Extra-Low Voltage) | 50 V | 120 V | dzwonki, sterowanie, oświetlenie LED 12 V |
| **PELV** | 50 V | 120 V | jak SELV, ale z uziemieniem |
| **FELV** | 50 V | 120 V | niskie napięcie funkcjonalne (bez ochrony) |

W warunkach mokrych (łazienka, basen) napięcia bezpieczne są jeszcze niższe: **12 V AC / 30 V DC**.

## Droga prądu przez ciało

Najgroźniejsza jest droga prądu przechodząca przez serce. Współczynniki ryzyka wg PN-EN 60479:

| Droga prądu | Współczynnik (im wyższy, tym groźniej) |
|---|---|
| Ręka-ręka | 1,0 (referencyjna) |
| Ręka lewa - obie nogi | 1,0-1,4 |
| Ręka prawa - obie nogi | 0,8 |
| Obie ręce - obie nogi | 1,0 |
| Plecy - ręka prawa | 0,3 |
| Klatka piersiowa - ręka lewa | 1,5 (najgroźniej) |

**Stąd zasada elektryka:** **„jedna ręka za plecami"** — pracując pod napięciem trzymamy jedną rękę w kieszeni lub za plecami, by uniknąć drogi ręka-ręka przez serce.

## Opór ciała człowieka

Opór ciała zależy głównie od warunków skóry:

| Stan skóry | Opór ciała (ręka-ręka) |
|---|---|
| Skóra sucha, gruba | 10 000 - 100 000 Ω |
| Skóra normalna, sucha | 1 000 - 10 000 Ω |
| Skóra spocona | 500 - 2 000 Ω |
| Skóra mokra (zanurzona) | 200 - 500 Ω |
| Skóra przebita (np. iglarstwo) | 100 - 500 Ω |

**Przykład obliczenia:** dotknięcie fazy 230 V mokrą ręką, opór ciała 1 000 Ω:

```
I = U / R = 230 / 1 000 = 0,23 A = 230 mA
```

230 mA przez kilka sekund = śmierć z prawdopodobieństwem bliskim 100%. Stąd absolutna konieczność RCD.

## Klasy porażeń wg objawów

| Klasa | Objawy | Postępowanie |
|---|---|---|
| **I** — bez utraty przytomności | mrowienie, ból w mięśniach, otarcia | obserwacja, badanie EKG w ciągu 24 h |
| **II** — utrata przytomności, ale oddech zachowany | nieprzytomność krótkotrwała | pozycja boczna bezpieczna, wezwać pomoc |
| **III** — zatrzymanie oddechu | bezdech, sinica, pojawia się tętno | sztuczne oddychanie + wezwać pomoc |
| **IV** — zatrzymanie krążenia | brak oddechu i tętna | natychmiast RKO (30 uciśnięć + 2 oddechy) + AED + 112 |

## Pierwsza pomoc po porażeniu

**Krok 1 — odłącz napięcie.** Wyłącz wyłącznik, wyciągnij wtyczkę, odsuń ofiarę przedmiotem nieprzewodzącym (drewno, plastik). **Nie dotykaj poszkodowanego, dopóki jest pod napięciem!**

**Krok 2 — sprawdź funkcje życiowe.**

- przytomność (potrząśnij, zawołaj)
- oddech (3 sekundy obserwacji klatki piersiowej)
- tętno (na tętnicy szyjnej, 5-10 sekund)

**Krok 3 — wezwij pomoc 112 (lub 999).**

**Krok 4 — jeśli brak oddechu:** rozpocznij RKO.

- 30 uciśnięć klatki piersiowej (głębokość 5-6 cm, częstotliwość 100-120/min)
- 2 oddechy ratownicze (jeśli umiesz)
- powtarzaj do przyjazdu karetki lub do odzyskania oddechu
- jeśli dostępny AED — użyj go (urządzenie samo prowadzi instrukcją głosową)

**Krok 5 — jeśli oddycha, ale jest nieprzytomny:** pozycja boczna bezpieczna, monitoring oddechu.

## Czego nie robić

- **Nie polewać wodą** — woda przewodzi, ryzyko porażenia ratownika
- **Nie smarować oparzeń** masłem, pastą do zębów ani spirytusem — tylko chłodzić wodą
- **Nie zostawiać ofiary samej** — nawet jeśli pozornie czuje się dobrze, możliwe są późne zaburzenia rytmu serca (do 24-48 h po porażeniu)
- **Nie podawać do picia** — zwłaszcza alkoholu
- **Nie zdejmować przyklejonej odzieży** z miejsc oparzonych

## Statystyki w Polsce

Wg PIP rocznie w Polsce:

- ~100-150 zgonów z powodu porażenia prądem (głównie w przemyśle i rolnictwie)
- ~300-500 ciężkich wypadków porażenia
- ~30% wypadków domowych w łazience i kuchni
- najczęstsze przyczyny: brak RCD, uszkodzona izolacja, "majsterkowanie" pod napięciem

## Co dalej

➡ [Stopnie ochrony IP i IK](02-02-ip-ik.md)
