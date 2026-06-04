# Kontaktrony magnetyczne

> Najprostsza i najtańsza czujka — szczelny styk reagujący na pole magnetyczne. Standard dla detekcji otwarcia drzwi, okien, bram, klap.

## Zasada działania — kontaktron (reed switch)

**Kontaktron** (z ang. *reed switch*) to dwie cienkie blaszki ferromagnetyczne w szczelnej szklanej rurce wypełnionej gazem obojętnym. Magnes zbliżony do rurki magnetyzuje blaszki — one przyciągają się i **zwierają obwód**. Po oddaleniu magnesu blaszki rozprostowują się i obwód **rozwiera się**.

Kontaktron typowo działa w konfiguracji **NC** (Normally Closed) — gdy drzwi są zamknięte (magnes blisko), styk zwarty. Otwarcie drzwi = oddalenie magnesu = rozwarcie styku = alarm.

Czujka jest **całkowicie pasywna** — nie pobiera prądu w stanie spoczynku (poza prądem płynącym przez linię alarmową z rezystorem EOL). Żywotność: 10⁶–10⁹ cykli przełączenia. W praktyce: dziesięciolecia.

## Konfiguracje styków — NC, NO, SPDT

| Typ | Działanie | Zastosowanie |
|---|---|---|
| **NC** (Normally Closed) | zwarty gdy magnes blisko, rozwarty gdy daleko | standard dla alarmów (rozłączenie linii = alarm) |
| **NO** (Normally Open) | rozwarty gdy magnes blisko, zwarty gdy daleko | aplikacje sterujące, oświetlenie szafy |
| **SPDT** (3 styki) | jeden wspólny + NC + NO | uniwersalne, można wybrać tryb pracy |

## Typy konstrukcyjne kontaktronów

### Nawierzchniowe (powierzchniowe)

Dwie plastikowe obudowy montowane do ramy i skrzydła drzwi/okna na śruby lub klej. **Najprostsze w montażu** (nie trzeba frezować), idealne do modernizacji.

- typowy rozmiar: 50–70 mm × 10–15 mm × 10 mm
- kolor: biały, brązowy, czarny (dopasowanie do stolarki)
- odległość zadziałania: 12–25 mm
- cena: 5–15 PLN za parę

Modele: Satel B-1, B-2, B-3 BR (brązowy); Elmes CTX; Crow Magnetic Detector.

### Wpustowe (zatapiane)

Walcowe puszki Ø 6, 8, 10 mm wpuszczane w otwór wywiercony w futrynie i skrzydle. Niewidoczne po zamontowaniu — wymóg dla nowoczesnej, estetycznej stolarki.

- średnica: 8 mm (najpopularniejsza), 10 mm, 19 mm
- długość: 25–32 mm
- odległość zadziałania: 15–20 mm
- cena: 8–25 PLN za parę

Modele: Satel B-3-8 (8 mm wpustowy); DSC EV-DW4917; Elmes KSM-08.

### Do drzwi metalowych (wzmocnione)

Metal stalowy **ekranuje pole magnetyczne** — standardowy kontaktron przestaje działać. Czujki do drzwi metalowych mają:

- wzmocniony magnes neodymowy (N40+)
- obudowę z materiału niemagnetycznego (mosiądz, aluminium)
- większą odległość zadziałania (do 35–45 mm)

Modele: Satel B-2M; Magnasphere HSS L1; Detec D-3.

### Do bram garażowych i przemysłowych

Bardzo duże magnesy i kontaktrony w obudowach IP66+ dla bram segmentowych, rolet, krat. Odległość zadziałania nawet 50–100 mm. Modele: Crow Big Mag; Optex BX-100.

## Rezystory końcowe (EOL) — dlaczego warto

Klasyczne podłączenie 2-żyłowe (linia NC do centrali) ma fundamentalną wadę:

- **Zwarcie linii** (np. przebity przewód, sabotaż) wygląda dla centrali jak „drzwi zamknięte" — można obejść alarm.
- **Przerwa** wygląda jak alarm — ale nie wiadomo, czy to alarm prawdziwy czy uszkodzenie kabla.

Z rezystorem EOL (End-Of-Line) na końcu linii centrala mierzy **rezystancję pętli**:

| Konfiguracja | Rezystancja | Interpretacja |
|---|---|---|
| 1 rezystor EOL 2k2 szeregowo | 2,2 kΩ | stan normalny (drzwi zamknięte) |
| jw., styk rozwarty | ∞ (przerwa) | ALARM |
| jw., zwarcie linii | 0 Ω | SABOTAŻ linii (zwarcie) |
| 2 rezystory (DEOL: 1k1 + 1k1) | 1,1 / 2,2 / 0 / ∞ | alarm + sabotaż na 2 żyłach |

Centrale Satel używają standardowo 2k2 (EOL) lub 1k1+1k1 (2EOL). DSC: 5k6. Centrale konfigurowalne pozwalają wybrać wartość.

Rezystory umieszcza się w **czujce** (najbliżej styków), nie w centrali — chroni to przed sabotażem polegającym na przepięciu kabla z pominięciem czujki.

## Strefa sabotażowa (tamper) — kontaktrony z dwoma stykami

Lepsze kontaktrony nawierzchniowe mają **dodatkowy mikroprzełącznik** wyzwalany przy próbie odkręcenia obudowy. Para żył alarmowych + para żył sabotażowych = 4 żyły do czujki.

```
Pin 1-2: NC alarm  (rozwiera przy otwarciu drzwi)
Pin 3-4: NC tamper (rozwiera przy odkręceniu obudowy)
```

W systemach Grade 3 i wyżej — wymagane (norma PN-EN 50131-2-6).

## Bezprzewodowe kontaktrony

Czujka radiowa z bateriami CR123A / 2× AA, transmisja 433 / 868 MHz (rolling code, FSK). Trzon — kontaktron + magnes z osobną obudową. Po wyzwoleniu wysyła ramkę do centrali.

| Model | Pasmo | Bateria / żywotność |
|---|---|---|
| Satel APD-200 (ABAX2) | 868 MHz | CR14250 / 5 lat |
| DSC PG9303 | 915 MHz (PowerG) | 2× CR2032 / 7 lat |
| Risco Wireless WL DCC | 868 MHz | CR2032 / 5 lat |
| Jablotron JA-150M | 868 MHz | CR14250 / 3 lata |

Bezprzewodowe kontaktrony wymagają regularnej **wymiany baterii**. Centrala generuje ostrzeżenie „low battery" na 30–60 dni przed wyczerpaniem. Ignorowanie = czujka „zniknie" z systemu.

## Gdzie montować — typowe zastosowania

### Drzwi wejściowe

- na górze drzwi (kontaktron w futrynie, magnes w skrzydle)
- odstęp magnesu od kontaktronu w zamkniętych drzwiach: 5–15 mm
- strefa **opóźniona** (10–30 s) — czas na wpisanie kodu na klawiaturze

### Okna parteru, balkonowe

- kontaktron w ramie (futrynie), magnes na skrzydle
- w przypadku okien uchylno-rozwiernych — dwa kontaktrony (lub jeden + drugi z czujnikiem przechyłu)
- strefa **natychmiastowa** (0 s)

### Bramy garażowe

- kontaktron przemysłowy IP65+, montaż przy podłodze (najmniej zanieczyszczeń)
- strefa **opóźniona** (do 60 s, czas wjazdu)
- uwaga na wibracje przy pracy napędu — możliwe drgania styku

### Klapy serwisowe, szafy

- kontaktrony miniaturowe Ø 6 mm
- strefa **24h** — alarm również przy rozbrojonej centrali (sabotaż)

## Obejścia i ograniczenia

Kontaktron można **oszukać silnym magnesem zewnętrznym** przyłożonym do kontaktronu — ten myśli, że drzwi nadal są zamknięte. Dlatego w obiektach o wyższej klasie ochrony stosuje się:

- **Kontaktrony Magnasphere** — magnes wewnętrzny w czujce porusza się tylko w ściśle określonym polu magnetycznym. Reagują na manipulację silnym magnesem (anti-tamper magnetyczny).
- **Czujki balansowe** (BMS — Balanced Magnetic Switch) — dwa kontaktrony w przeciwfazie, alarm gdy pole nie jest „prawidłowe".
- Norma PN-EN 50131-2-6 klasa 3 wymaga odporności na obejście silnym magnesem.

## Co dalej

➡ [Kurtyny i czujki zewnętrzne](07-04-kurtyny-zewnetrzne.md)
