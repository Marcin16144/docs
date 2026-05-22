# Rodzaje uziomów

## Po co uziom

Uziom to celowo wprowadzony do gruntu element przewodzący, który zapewnia połączenie elektryczne instalacji z ziemią. Jego zadaniem jest:

- odprowadzanie prądów zwarciowych do ziemi (układ TT, system ochrony przed porażeniem),
- odprowadzanie prądu pioruna (LPS — instalacja odgromowa),
- wyrównanie potencjałów na metalowych konstrukcjach budynku,
- redukcja napięcia dotykowego do bezpiecznych wartości (UL ≤ 50 V AC).

Norma odniesienia: **PN-EN 62561** (komponenty urządzeń piorunochronnych) oraz **PN-HD 60364-5-54** (uziemienia i przewody ochronne w instalacjach niskiego napięcia).

## Klasyfikacja uziomów

| Typ uziomu | Wykonanie | Typowe Rz | Zastosowanie |
|---|---|---|---|
| **Fundamentowy** | bednarka w fundamencie betonowym | 1–10 Ω | nowy budynek — najlepszy |
| **Otokowy** | taśma 1 m od ściany, 0,7 m głębokości | 5–30 Ω | najczęstszy w domach jednorodzinnych |
| **Pionowy (szpilkowy)** | pręty 1,5–3 m wbite w grunt | 10–50 Ω | dogenezowanie, słabe grunty |
| **Poziomy taśmowy** | bednarka ułożona poziomo w wykopie | 10–40 Ω | gdy nie można pionowych |
| **Punktowy** | płyta lub pojedynczy pręt | 30–100 Ω | rozwiązanie awaryjne |

## Uziom otokowy

Najczęściej stosowane rozwiązanie w polskich domach jednorodzinnych.

**Wykonanie:**

- bednarka **FeZn 30 × 4 mm** (stal ocynkowana ogniowo, min. 70 µm Zn),
- układana wokół całego budynku, w odległości **~1 m od ściany** fundamentu,
- na głębokości **min. 0,5 m**, zalecane **0,7–0,8 m** (poniżej przemarzania),
- końce wyprowadzone do złącza kontrolnego — w studzience lub na ścianie zewnętrznej.

**Połączenia:**

- na łukach — gięcie, nie spawanie ostrym kątem,
- skrzyżowania — **zaciski krzyżowe** lub spawanie + zabezpieczenie antykorozyjne (masa bitumiczna, taśma),
- wyprowadzenia — pręty Cu lub FeZn Ø10 mm.

## Uziom fundamentowy

**Najlepsza technicznie opcja** — wykonuje się go **przed wylaniem betonu fundamentowego**.

- bednarka FeZn 30 × 4 mm zatopiona w ławie fundamentowej,
- minimalne przykrycie betonem 50 mm,
- wyprowadzenia w narożnikach budynku oraz w miejscu rozdzielnicy głównej,
- beton z zawartością wilgoci stanowi przedłużenie uziomu (efekt klatki Faradaya „suchy" → niska Rz),
- niewrażliwy na korozję, „na całe życie budynku".

Po wylaniu fundamentu trzeba mieć **dokumentację fotograficzną** — później nikt już tego nie sprawdzi.

## Uziom pionowy (szpilkowy)

Pojedyncze pręty wbijane pionowo w grunt:

- długość **1,5–3 m** (najczęściej zestawy skręcane — np. 4 × 1,5 m sklejone do 6 m),
- materiał: **stal pokryta miedzią** (Cu/Fe, „omedziowane") — Ø 14–20 mm,
- alternatywnie czysta Cu lub FeZn.

**Zalety:** szybki montaż, można dobić w gotowym terenie.
**Wady:** wysoka rezystancja przy płytkich, suchych gruntach; w terenie kamienistym trudne wbicie.

Często stosowane jako **doegenezowanie** istniejącego uziomu otokowego, gdy nie spełnia wymagań Rz.

## Uziom poziomy taśmowy

Bednarka FeZn lub Cu ułożona poziomo w wykopie 0,5–0,8 m, długość 10–25 m. Stosowany, gdy:

- nie można wbić prętów (skały),
- nie ma fundamentu betonowego,
- modernizacja w istniejącym terenie.

## Materiały — porównanie

| Materiał | ρ [Ω·mm²/m] | Odporność na korozję | Cena | Uwagi |
|---|---|---|---|---|
| **FeZn** (stal ocynkowana) | ~0,15 | dobra (powłoka Zn) | niska | standard polski, 30×4 mm bednarka |
| **Cu** (miedź) | 0,0178 | bardzo dobra | wysoka | dla układów wymagających trwałości |
| **Cu/Fe** (omedziowane) | jak Fe | bardzo dobra | średnia | pręty pionowe |
| **V2A** (stal nierdzewna 1.4301) | ~0,72 | doskonała | wysoka | grunty agresywne (sól, kwas) |

W gruntach o pH < 5 lub z dużą zawartością siarczanów FeZn koroduje szybko — wtedy V2A lub Cu.

## Wpływ rodzaju gruntu

Rezystywność gruntu ρ (rho) [Ω·m] decyduje o końcowej Rz uziomu.

| Grunt | ρ [Ω·m] | Wniosek |
|---|---|---|
| Bagno, torf wilgotny | 5–30 | bardzo dobry, krótki uziom wystarczy |
| Glina wilgotna | 30–100 | dobry |
| Glina sucha | 100–300 | umiarkowany |
| Piasek wilgotny | 100–300 | umiarkowany |
| Piasek suchy | 1 000–3 000 | słaby — długie uziomy, kilka prętów |
| Żwir | 1 000–5 000 | słaby |
| Skała | 5 000–20 000 | bardzo słaby — uziom w wykopie z gliną |

Praktyka: w pierwszej kolejności **zmierzyć rezystywność gruntu** (metoda Wennera, 4 sondy), potem dobrać typ i długość uziomu.

## Schemat decyzyjny

```
NOWY BUDYNEK?
├── TAK → fundamentowy (zawsze!) + ew. otokowy łączony
└── NIE  → otokowy + ew. pręty pionowe doegenezujące

GRUNT AGRESYWNY (sól, kwas, pH<5)?
├── TAK → V2A lub Cu
└── NIE  → FeZn 30×4 mm

NISKA Rz NIE OSIĄGNIĘTA?
├── dobić pręty pionowe Cu/Fe 3 m
├── wydłużyć uziom otokowy
└── grunty wymienić (zasypka bentonitem)
```

## Pomiar przed montażem instalacji

Sekwencja prac:

1. wykonać uziom (otokowy lub fundamentowy) **przed zasypaniem fundamentów**,
2. zmierzyć Rz mernikiem MRU metodą 3- lub 4-pinową,
3. uzyskać wartość **<30 Ω dla TT**, **<10 Ω jeśli będzie odgromówka**,
4. dopiero potem przyłączyć do GSW (głównej szyny wyrównawczej) w rozdzielnicy,
5. spisać **protokół z pomiaru** — załącznik do dokumentacji odbiorowej.

## Co dalej

➡ [Pomiar rezystancji uziemienia](09-02-pomiar-rezystancji.md)
