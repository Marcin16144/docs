# Odbiory techniczne instalacji elektrycznej

## Cel odbioru

Odbiór techniczny instalacji jest formalnym potwierdzeniem, że wykonana praca:

- jest **zgodna z projektem** i wprowadzonymi zmianami
- jest **zgodna z normami** (PN-HD 60364, WT)
- jest **bezpieczna** w eksploatacji (ochrona przeciwporażeniowa działa, brak zwarć, izolacja w porządku)
- ma kompletną **dokumentację**

Odbiór wykonuje się **przed włączeniem do sieci** (przed plombowaniem licznika).

## Próba końcowa — trzy etapy

### 1. Oględziny

Wzrokowa kontrola **bez pomiarów**:

- zgodność z projektem (umieszczenie rozdzielnicy, gniazd, opraw)
- **prawidłowe oznakowanie** obwodów, kabli, zacisków
- **dostęp** do rozdzielnicy, zachowanie odstępów
- **stopień ochrony IP** w pomieszczeniach wilgotnych (IP44 łazienka, IP65 zewnątrz)
- **brak uszkodzeń** mechanicznych izolacji
- **kolory żył** prawidłowe (PE żółto-zielony, N niebieski, L brązowy/czarny/szary)
- **dokręcenie zacisków** (sprawdzane wyrywkowo + moment dokręcania)
- **klasa izolacji** opraw (I/II/III) dopasowana do lokalizacji
- **bariery ognioodporne** przejść przez ściany p-poż

### 2. Pomiary

Pięć podstawowych pomiarów wynikających z PN-HD 60364 część 6:

| # | Pomiar | Minimum / wymóg |
|---|---|---|
| 1 | **Ciągłość przewodu PE** | rezystancja < 1 Ω (im niżej tym lepiej) |
| 2 | **Rezystancja izolacji** | min 1 MΩ przy 500 V DC |
| 3 | **Impedancja pętli zwarcia** | musi pozwalać zadziałać MCB w czasie < 0,4 s (gniazda) / 5 s (rozdzielcze) |
| 4 | **Wyłącznik RCD** — czas zadziałania | < 30 ms przy 1×IΔn (test funkcjonalny + IΔn) |
| 5 | **Rezystancja uziomu** | < 10 Ω (instalacja odgromowa: < 10 Ω; sama ochronna: < 30 Ω) |

Plus opcjonalnie:

- pomiar prądu upływu instalacji
- sprawdzenie kolejności faz
- spadek napięcia w obciążeniu znamionowym

Każdy pomiar — protokół z konkretnymi wartościami i miernikiem (numer seryjny, świadectwo wzorcowania ważne).

Szczegóły każdego z 5 pomiarów: [Sekcja 11 — Pomiary](../11-pomiary/index.html).

### 3. Próby działania

- **Test RCD** — naciśnięcie przycisku TEST (T) na każdym RCD → wyzwolenie w < 0,3 s
- **Działanie wyłączników i włączników** światła
- **Funkcja przycisków, czujników ruchu, dzwonków**
- **Oświetlenie awaryjne** (jeśli wymagane — minimum 1 godzina pracy)
- **System wyłączania awaryjnego** (np. w garażu, przy bramie)
- **Sprawdzenie schematu rozdzielnicy** — przy wyłączeniu konkretnego MCB zanika napięcie w odpowiednim obwodzie

## Protokół odbioru

Dokument zawiera:

| Sekcja | Zawartość |
|---|---|
| **Dane podstawowe** | adres obiektu, inwestor, wykonawca, projektant |
| **Charakterystyka instalacji** | układ sieci (TN-S/TN-C-S/TT), moc przyłączeniowa, liczba obwodów |
| **Wyniki oględzin** | zgodność z projektem, uwagi |
| **Wyniki pomiarów** | tabela 5 pomiarów z wartościami i wymaganiami |
| **Wyniki prób działania** | test RCD, działanie obwodów |
| **Decyzja** | pozytywny / warunkowy (z listą uwag do usunięcia) / negatywny |
| **Podpisy** | wykonawca, kierownik robót, osoba uprawniona (SEP G1 D/E + P) |

Protokół musi się powołać na **PN-HD 60364** jako podstawę.

## Trzy typy decyzji

| Decyzja | Skutek |
|---|---|
| **Pozytywna** | Instalacja gotowa do włączenia. Można zgłosić do OSD. |
| **Warunkowa** | Drobne uwagi do usunięcia. Po usunięciu — protokół uzupełniający. |
| **Negatywna** | Poważne wady (np. brak ochrony, niezgodność z projektem). Wymaga prac naprawczych i powtórzenia odbioru. |

## Dokumenty załączone do odbioru

- **Projekt budowlany** (część elektryczna)
- **Inwentaryzacja powykonawcza** — rzuty z faktycznym przebiegiem instalacji
- **Schemat ideowy rozdzielnicy powykonawczy**
- **Atesty / deklaracje CE** użytych materiałów
- **Protokoły pomiarów** (5 podstawowych)
- **Oświadczenie kierownika robót** o zgodności z projektem i normami
- **Dziennik budowy** (przy budynkach z pozwoleniem)

## Zgłoszenie do OSD i włączenie

Po pozytywnym odbiorze:

1. **Wniosek o przyłączenie** do OSD (PGE, Tauron, Enea, Energa, innogy) — formularz online
2. Dołączasz: protokół odbioru, schemat, dane techniczne
3. OSD wysyła **energetyka** który sprawdza zewnętrzne przyłącze i **plombuje licznik**
4. **Pierwsze włączenie** odbywa się pod nadzorem energetyka

Czas typowo: 14-30 dni od zgłoszenia.

## Przeglądy okresowe

Po pierwszym odbiorze norma wymaga okresowych sprawdzeń:

| Obiekt | Okres |
|---|---|
| Dom jednorodzinny | **co 5 lat** (zalecane) — nieobowiązkowe ale wymagane dla ubezpieczenia |
| Mieszkanie | co 5 lat |
| Obiekty użyteczności publicznej | co 5 lat (obowiązkowe) |
| Place budowy | co rok |
| Łazienki i wilgotne | co 1-3 lat |

Po remoncie, dodaniu nowych obwodów (np. PV, EV) — **odbiór częściowy** dla zmienionej części.

## Kontrowersje praktyczne

- **„Odbiór bez pomiarów"** zdarza się — to nielegalne i nieodpowiedzialne. Bez 5 pomiarów odbioru nie ma.
- **„Stary protokół wystarczy"** — protokół ważny jest tylko dla zakresu którego dotyczył; po nowych pracach nowy protokół.
- **„Świadectwo wzorcowania miernika"** — wymagane, zwykle 12-24 miesięczne. Bez ważnego wzorcowania pomiary są nieważne.

## Co dalej

➡ [Przykłady projektowe — sekcja 15](../15-przyklady/index.html)
