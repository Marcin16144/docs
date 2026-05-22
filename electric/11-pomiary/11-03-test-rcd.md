# Test wyłącznika RCD

## Czym jest RCD i co testujemy

**RCD** (*Residual Current Device*, wyłącznik różnicowoprądowy) — urządzenie wyłączające obwód przy wykryciu prądu różnicowego IΔ. Standard domowy: **IΔn = 30 mA** (ochrona dodatkowa przed porażeniem).

Norma: **PN-HD 60364-6**, **PN-EN 61008**, **PN-EN 61009**.

Testujemy 4 parametry:

1. **Prąd zadziałania IΔ** — przy jakim prądzie różnicowym RCD się wyłącza,
2. **Czas zadziałania t** — jak szybko (przy 1×IΔn i 5×IΔn),
3. **Brak zadziałania przy 0,5×IΔn** — RCD nie może wyłączać przy małych prądach roboczych,
4. **Test przyciskiem T** — mechanika sprężyny i kontaktów.

## Mernik RCD (MRCD)

| Model | Producent | Tryby | Cena |
|---|---|---|---|
| **Sonel MRP-200** | Sonel | wszystkie typy AC/A/B/F, S | ~4500 zł |
| **Sonel MRP-201** | Sonel | + B+ | ~5500 zł |
| **Sonel MPI-540** | Sonel | wieloparametrowy (RCD + Zs + Riso + R) | ~7000 zł |
| **Kyoritsu 5410** | Kyoritsu | AC, A | ~2500 zł |
| **Megger DLRO10** | Megger | DLRO + RCD | ~5000 zł |

## Procedura: 4 pomiary podstawowe

### 1. Prąd zadziałania IΔ (rampa)

- mernik podaje prąd narastający **od 0,1×IΔn do 1,0×IΔn**,
- mierzy **IΔ rzeczywisty** — przy jakiej wartości RCD wyłączył,
- norma wymaga: **0,5×IΔn ≤ IΔ ≤ 1,0×IΔn** (RCD musi zadziałać między 50% a 100% IΔn).

Dla RCD 30 mA → poprawne IΔ = **15–30 mA**.

### 2. Czas zadziałania przy 1×IΔn

- mernik wymusza dokładnie IΔn (np. 30 mA),
- mierzy **czas wyłączenia** w ms.

| Typ RCD | Maks. czas przy 1×IΔn |
|---|---|
| Standardowy (AC, A) | **300 ms** |
| Selektywny S | **130–500 ms** (świadome opóźnienie) |

### 3. Brak zadziałania przy 0,5×IΔn

- prąd 0,5×IΔn (dla 30 mA → 15 mA),
- RCD **NIE może** się wyłączyć przez minimum 2 s,
- weryfikuje brak fałszywych wyłączeń przy prądach upływowych w normalnej pracy.

### 4. Czas zadziałania przy 5×IΔn

- prąd 5×IΔn (dla 30 mA → 150 mA),
- mernik mierzy czas wyłączenia,
- **wymóg: ≤ 40 ms** (szybkie zadziałanie przy dużym prądzie różnicowym).

## Tabela wymaganych czasów

| Typ RCD | 0,5×IΔn | 1×IΔn | 2×IΔn | 5×IΔn |
|---|---|---|---|---|
| **AC, A standard** | brak zadziałania | ≤ 300 ms | ≤ 150 ms | **≤ 40 ms** |
| **AC, A typ G** (genaralny opóźniony) | brak | ≤ 500 ms | ≤ 200 ms | ≤ 150 ms |
| **AC, A typ S** (selektywny) | brak min. 130 ms | ≤ 500 ms | ≤ 200 ms | ≤ 150 ms |

## Typy RCD i co wykrywają

| Typ | Wykrywa | Symbol | Zastosowanie |
|---|---|---|---|
| **AC** | sinusoidalny AC | ~ | proste odbiorniki rezystancyjne |
| **A** | AC + pulsujący DC | ~ + ⎍ | większość odbiorników domowych, falowniki PWM |
| **F** | A + miks. wysokie częst. | ~ + ⎍ + ~~~ | klimatyzacje inwerterowe, falowniki jednofazowe |
| **B** | A + gładki DC | ~ + ⎍ + ⎯ | falowniki PV, ładowarki EV 3-faz |
| **B+** | B + częstotliwości do 20 kHz | jw. + symbol | nowoczesne ładowarki EV, AC EVSE |

W typowym domu: **A** lub **F**. Dla EV i PV: **B/B+**.

## Test przyciskiem T (test self-check)

Każdy RCD ma przycisk **„T"** (Test) — wewnętrzny rezystor wymusza prąd ~IΔn → RCD powinien się wyłączyć.

- **Częstość**: **raz w miesiącu** (użytkownik),
- nie zastępuje pomiaru mernikiem (tylko sprawdza mechanikę),
- jeśli T nie wybija → RCD do wymiany.

## Test pełny (mernikiem)

- **Częstość**: **raz w roku** dla mieszkań, **raz na 5 lat** dla domów jednorodzinnych przy pomiarach okresowych,
- po każdej burzy z silnym przepięciem,
- po remoncie instalacji.

## Krok po kroku: pomiar mernikiem

1. **Wstaw wtyk MRCD** w dowolne gniazdo chronione przez testowany RCD (lub podłącz krokodylki do obwodu).
2. **Sprawdź typ RCD** (AC, A, F, B) — wybierz w mernku.
3. **Ustaw IΔn** (10, 30, 100, 300 mA — wg etykiety RCD).
4. **Pomiar 0,5×IΔn** — RCD ma NIE zadziałać.
5. **Pomiar 1×IΔn** — czas wyłączenia ≤ 300 ms.
6. **Pomiar 5×IΔn** — czas ≤ 40 ms.
7. **Pomiar IΔ (rampa)** — czy mieści się w 0,5–1,0×IΔn.
8. **Pomiar fazy startowej** — niektóre mierniki testują z fazą 0° i 180° (powinno działać symetrycznie).
9. **Wpisz w protokół**.

## Selektywność RCD (kaskada)

W rozdzielnicy często stosuje się **dwa RCD**:

- **przed**: RCD typu **S** (selektywny, 100 lub 300 mA) — ochrona zwarciowa, ognioodporna,
- **za**: RCD 30 mA — ochrona przeciwporażeniowa.

Wymóg selektywności:

- IΔn przed > 3 × IΔn za (np. 100 mA / 30 mA),
- t_przed > t_za (selektywny S opóźnia o min. 50 ms).

Test obu RCD osobno, plus test selektywności: zwarcie L-PE → wyłącza tylko RCD 30 mA, nie wyłącza RCD S.

## Typowe wyniki w protokole

```
Mernik: Sonel MRP-200, S/N 23456
RCD: F&G FI-30/4 (typ A, 30 mA, 25 A)
Lokalizacja: RCD główne dla obwodów gniazd

Pomiar               | Wartość zmierzona | Wymóg       | Ocena
─────────────────────┼───────────────────┼─────────────┼──────
0,5×IΔn (15 mA), 2s  | brak zadziałania  | brak        | OK
1×IΔn (30 mA)        | 22 ms             | ≤ 300 ms    | OK
5×IΔn (150 mA)       | 9 ms              | ≤ 40 ms     | OK
Rampa IΔ             | 19,2 mA           | 15–30 mA    | OK
Przycisk T           | wyłączył          | musi wyłącz | OK
```

## Najczęstsze problemy

| Symptom | Przyczyna |
|---|---|
| RCD wybija przy 0,5×IΔn | starość, wewnętrzny upływ — wymiana |
| RCD nie wybija przy 1×IΔn | uszkodzony — natychmiastowa wymiana |
| Czas zadziałania > 300 ms | zacięte styki, stara sprężyna |
| RCD wybija „samoistnie" | inne odbiorniki upływowe na obwodzie (kuchenka elektroniczna, falownik PV typu A na RCD typu A) — podziel obwody lub zmień RCD na typ F/B |
| Przycisk T nie działa | wewnętrzny rezystor przegrzany — wymiana |

## Wymiana RCD

Typowy RCD ma żywotność **10–15 lat**. Wymieniaj:

- gdy przekroczy parametry w teście,
- po silnym przepięciu (test mernikiem!),
- gdy zacznie samowyzwalać się przy normalnej pracy,
- przy modernizacji obwodów (np. dodanie EV → typ B).

## Co dalej

➡ [Pomiar uziemienia](11-04-uziemienie.md)
