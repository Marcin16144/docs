# Środki ochrony przeciwporażeniowej

## Dwustopniowy system ochrony

Norma PN-HD 60364-4-41 dzieli ochronę przeciwporażeniową na dwa poziomy:

| Poziom | Zadanie | Przykłady |
|---|---|---|
| **Ochrona podstawowa** | zapobiega kontaktowi z częściami normalnie pod napięciem | izolacja, obudowy, przegrody |
| **Ochrona przy uszkodzeniu (dodatkowa)** | zapobiega niebezpiecznym skutkom uszkodzenia izolacji | SWZ, RCD, klasa II, SELV, separacja |

W instalacji domowej **wymagane są obie** — pierwsza chroni w warunkach normalnych, druga w razie awarii.

## Ochrona podstawowa

### Izolacja podstawowa

Pokrycie przewodów warstwą materiału nieprzewodzącego (PVC, guma, polietylen). Klasy izolacji:

| Klasa | Wytrzymałość | Zastosowanie |
|---|---|---|
| 300/500 V | do 500 V | przewody H05 (sznurowe, AGD) |
| 450/750 V | do 750 V | przewody H07 (instalacyjne YDY, YKY) |
| 0,6/1 kV | do 1 kV | kable energetyczne YKY, YKXS |

### Obudowy

Wszystkie elementy pod napięciem muszą być w obudowach o odpowiednim stopniu IP — minimum **IPXXB** (palec nie sięga) lub **IPXXD** (drut 1 mm nie sięga). W praktyce: gniazda i osprzęt mają IP20, w mokrych pomieszczeniach IP44+.

### Przegrody i bariery

Stosowane w rozdzielnicach — uniemożliwiają dotknięcie szyn pod napięciem ręką lub narzędziem niezamierzenie.

### Umieszczenie poza zasięgiem ręki

Wymóg dla napięć powyżej 1 kV w niedostępnych pomieszczeniach (transformatory, słupy energetyczne).

## Ochrona dodatkowa — pięć metod

Norma definiuje pięć równoważnych metod ochrony przy uszkodzeniu:

| Metoda | Zasada | Gdzie stosowana |
|---|---|---|
| **Samoczynne wyłączenie zasilania (SWZ)** | szybkie wyłączenie obwodu po wystąpieniu zwarcia | **standard w instalacjach TN/TT** |
| **Klasa II — podwójna izolacja** | brak konieczności PE, sama izolacja chroni | pojedyncze urządzenia, lokalne strefy |
| **Bardzo niskie napięcie SELV/PELV** | napięcie samo w sobie bezpieczne | łazienka strefa 0/1, oświetlenie ogrodowe |
| **Separacja elektryczna** | transformator separacyjny, odbiornik bez kontaktu z ziemią | salony fryzjerskie, gabinety lekarskie |
| **Obniżone napięcie FELV** | jak SELV, ale bez separacji | sterowanie technologiczne |

## Samoczynne wyłączenie zasilania (SWZ)

Najczęstsza metoda w instalacjach domowych. **Warunek skuteczności:**

```
Z_s · I_a ≤ U₀
```

gdzie:

- **Z_s** — impedancja pętli zwarcia [Ω]
- **I_a** — prąd wyłączający zabezpieczenia w wymaganym czasie [A]
- **U₀** — napięcie fazowe (230 V)

Innymi słowy: impedancja pętli zwarcia musi być na tyle mała, aby przepłynął prąd wystarczający do zadziałania zabezpieczenia w czasie regulaminowym.

### Wymagane czasy wyłączenia w układzie TN

| Typ obwodu | U₀ | Czas max wyłączenia |
|---|---|---|
| Obwód końcowy (gniazda) do 32 A | 230 V | **≤0,4 s** |
| Obwód końcowy ≥32 A i obwód rozdzielczy | 230 V | **≤5 s** |
| Obwód oświetleniowy | 230 V | ≤0,4 s |

### Wymagane czasy w układzie TT

| Typ obwodu | U₀ | Czas max wyłączenia |
|---|---|---|
| Obwód końcowy do 32 A | 230 V | ≤0,2 s |
| Obwód rozdzielczy | 230 V | ≤1 s |

W praktyce w TT wymóg ten zwykle realizuje się **przez RCD** — wyłącznik różnicowoprądowy zadziała szybciej i niezależnie od Z_s.

## Wyliczenie I_a dla typowych zabezpieczeń

Prąd wyłączający w wymaganym czasie zależy od charakterystyki MCB:

| MCB | I_a (5×In dla B) | I_a (10×In dla C) |
|---|---|---|
| B6 | 30 A | — |
| B10 | 50 A | — |
| B16 | **80 A** | — |
| B20 | 100 A | — |
| B25 | 125 A | — |
| C16 | — | **160 A** |
| C20 | — | 200 A |

**Przykład.** Obwód gniazd z B16. Maksymalna dopuszczalna impedancja pętli:

```
Z_s ≤ U₀ / I_a = 230 / 80 = 2,87 Ω
```

W praktyce mierzymy multimetrem instalacyjnym (MZC, MIE). Jeśli Z_s > 2,87 Ω — SWZ **nie działa skutecznie** dla tego obwodu. Wymaga to:

- dołożenia RCD 30 mA (działa dla większych Z_s)
- zmniejszenia impedancji (krótszy lub grubszy przewód)
- zmiany zabezpieczenia na czulsze

## Rola RCD jako dopełnienia SWZ

Wyłącznik różnicowoprądowy (RCD) wykrywa **różnicę prądów** wpływających i wypływających z obwodu. Jeśli ktoś dotyka fazy i prąd „ucieka" przez ciało do ziemi, RCD wykrywa różnicę i wyłącza obwód w czasie typowo <30 ms.

**Najważniejszy parametr:** prąd różnicowy wyzwalający I_Δn:

| I_Δn | Przeznaczenie |
|---|---|
| 10 mA | szczególne zagrożenia (medyczne, dziecięce) |
| **30 mA** | **standard ochrony osobowej** (gniazda, łazienka, kuchnia) |
| 100 mA | ochrona pożarowa instalacji |
| 300 mA | ochrona pożarowa rozdzielcza, urządzenia stacjonarne |
| 500 mA | tylko ochrona pożarowa |

**RCD 30 mA jest obowiązkowy w PL** dla:

- wszystkich gniazd w mieszkaniu (od 2002 r.)
- obwodów łazienkowych
- gniazd w pomieszczeniach mokrych (kuchnia, łazienka, garaż)
- obwodów zewnętrznych
- placów budowy

## Bardzo niskie napięcie — SELV

System SELV (Safety Extra-Low Voltage):

- maksymalne napięcie: **50 V AC** lub **120 V DC**
- separacja galwaniczna od sieci (transformator z uzwojeniami ekranowanymi lub akumulator)
- brak uziemienia po stronie odbiornika
- obwody fizycznie oddzielone od obwodów wyższego napięcia

**Przykłady SELV:**

- oświetlenie 12 V w łazience
- dzwonek 12 V
- sterowanie KNX 24 V
- zasilanie laptopa 19 V (z zasilacza)

## Połączenia wyrównawcze (ekwipotencjalizacja)

Dodatkowa ochrona — łączenie wszystkich metalowych części dostępnych w domu z przewodem PE:

- rury wodociągowe (jeśli metalowe)
- rury gazowe (przez specjalną wstawkę dielektryczną — zgodnie z normą gazową)
- rury C.O.
- wanna metalowa, brodzik
- konstrukcja stalowa budynku
- zbrojenie betonu (jeśli dostępne)

**Główne połączenie wyrównawcze (GSW)** znajduje się przy złączu kablowym lub w głównej rozdzielnicy. **Dodatkowe połączenia wyrównawcze (DSW)** wykonuje się w łazience, kotłowni, garażu — przewodem żółto-zielonym 4-6 mm² Cu.

**Cel:** wszystkie metalowe powierzchnie mają ten sam potencjał — nie ma napięcia między nimi, nawet jeśli jedna z nich „uciekła" przez uszkodzenie izolacji.

## Separacja elektryczna

Stosowana rzadziej:

- transformator separacyjny (1:1, 230 V → 230 V)
- brak uziemienia po stronie wtórnej
- pojedynczy odbiornik na transformator
- zwarcie do obudowy nie tworzy pętli → bezpieczne

**Gdzie:** salony fryzjerskie (suszarki), gabinety zabiegowe, naprawa elektroniki, niektóre laboratoria.

## Podsumowanie — co działa w typowym domu

| Warstwa ochrony | Sprzęt |
|---|---|
| Ochrona podstawowa | izolacja przewodów, gniazda IP20+ |
| Ochrona dodatkowa (SWZ) | MCB B10/B16, układ TN-C-S, PE w gniazdach |
| Ochrona uzupełniająca | RCD 30 mA na wszystkie gniazda |
| Ochrona od przepięć | SPD klasy I+II |
| Połączenia wyrównawcze | szyna PE w rozdzielnicy, mostek do rur |
| Klasa II urządzeń | większość elektroniki użytkowej |
| SELV | oświetlenie 12 V w łazience |

## Co dalej

➡ [Przewody PE, N, L — kolory i zasady](02-05-pe-n-l.md)
