# Użytkownicy, kody, piloty

**Sekcja:** 09 Konfiguracja alarmu · **Aktualizacja:** 2026-05

Hierarchia użytkowników (instalator / master / user / przymus), kod przymusu (duress), poziomy uprawnień, piloty RF (breloki), karty zbliżeniowe RFID, polityka blokad i dobre praktyki.

## Hierarchia użytkowników

Każda centrala alarmowa (Satel, DSC, Risco, Jablotron) ma wielopoziomową strukturę kont. Najwyższe uprawnienia ma instalator, ale to **administrator (master)** zarządza zwykłymi użytkownikami w codziennym życiu.

| Poziom | Nazwa | Zakres |
| --- | --- | --- |
| 1 | **Instalator (serwisowy)** | pełne programowanie systemu (typy wejść, partycje, komunikacja). Zwykle *nie może* sam rozbroić systemu bez zgody mastera (tryb serwisowy). |
| 2 | **Master / administrator** | zarządza użytkownikami (dodaje/usuwa kody, breloki, karty), nadaje uprawnienia, ustawia harmonogramy. Najwyższy „użytkownik" obiektu. |
| 3 | **Użytkownik zwykły** | uzbraja/rozbraja przypisane partycje, wg nadanych uprawnień. |
| 4 | **Kod przymusu (duress)** | specjalny kod — rozbraja system, ale wysyła cichy alarm napadowy do agencji. |
| — | Konta specjalne | np. *sprzątaczka* (ograniczony czasowo), *strażnik / patrol* (uzbrajanie po obchodzie), *gość*. |

Rozdzielenie **instalatora** i **mastera** jest kluczowe: instalator konfiguruje sprzęt, ale to właściciel (master) panuje nad tym, kto i kiedy może rozbroić alarm. W trybie zgodnym z normą instalator nie wejdzie do programowania bez autoryzacji mastera (tzw. dostęp instalatora włączany przez mastera).

## Kod przymusu (duress code)

**Kod przymusu** (ang. *duress code*) to jedna z najważniejszych funkcji bezpieczeństwa. Działa tak:

- Napastnik zmusza domownika do rozbrojenia alarmu.
- Domownik wpisuje **kod przymusu** zamiast normalnego kodu.
- System **normalnie się rozbraja** (napastnik niczego nie podejrzewa).
- Jednocześnie centrala wysyła **cichy alarm napadowy** (PANIC / HOLD-UP) do stacji monitoringu — bez syreny, bez sygnału na klawiaturze.
- Agencja ochrony wie, że rozbrojenie nastąpiło pod przymusem i reaguje (patrol / policja).

| Producent | Realizacja kodu przymusu |
| --- | --- |
| **Satel** | osobny kod typu „przymus" (DURESS) lub kod o numerze użytkownika z atrybutem przymusu; wysyła kod zdarzenia napadu do PCO |
| **DSC** | dedykowany *Duress Code* w programowaniu kodów; generuje raport „duress" (np. Contact ID 121) |
| **Risco** | atrybut „duress" dla kodu użytkownika; cichy alarm do Risco Cloud / PCO |
| **Jablotron** | kod/uprawnienie z funkcją przymusu; raport napadowy przez MyJABLOTRON / PCO |

Kod przymusu ma sens **tylko przy aktywnym monitoringu (PCO)** lub powiadomieniu, które ktoś odbierze. Jeśli system nie raportuje nigdzie cichego alarmu, funkcja przymusu nic nie zmienia. Domownicy muszą znać i pamiętać ten kod — warto go przećwiczyć.

## Poziomy uprawnień

Każdemu użytkownikowi master nadaje zestaw uprawnień. Typowe atrybuty (nazewnictwo różni się między producentami, ale idea jest wspólna):

| Uprawnienie | Opis |
| --- | --- |
| **Tylko uzbrajanie (arm only)** | użytkownik może załączyć czuwanie, ale nie rozbroić (np. pracownik zamykający lokal) |
| **Uzbrajanie + rozbrajanie** | pełna obsługa czuwania przypisanych partycji |
| **Pełne (full)** | uzbrajanie, rozbrajanie, kasowanie alarmu, pomijanie wejść (bypass) |
| **Sterowanie wyjściami** | obsługa wyjść programowalnych (brama, oświetlenie, rolety) bez wpływu na czuwanie |
| **Dostęp do partycji / sekcji** | lista stref/partycji, do których kod ma dostęp (np. tylko „Parter") |
| **Zmiana własnego kodu** | czy użytkownik może sam zmienić swój PIN |
| **Master** | zarządzanie innymi użytkownikami |

Powiązanie uprawnień z **partycjami** opisano w 09-01 Strefy i partycje, a uzbrajanie warunkowe/harmonogramy w 09-02 Scenariusze uzbrojenia. Tu skupiamy się na samych kontach, kodach i nośnikach.

## Długość kodów i polityka blokady

Kody PIN mają zwykle **4 do 6 cyfr**. Dłuższy kod = większa przestrzeń kombinacji = trudniejszy do zgadnięcia.

| Długość | Kombinacje | Zastosowanie |
| --- | --- | --- |
| 4 cyfry | 10 000 | standard domowy (Grade 2), minimum |
| 5 cyfr | 100 000 | podwyższone bezpieczeństwo |
| 6 cyfr | 1 000 000 | Grade 3, obiekty komercyjne |

Aby utrudnić zgadywanie metodą prób (brute force), centrale stosują **blokadę klawiatury po błędnych próbach**:

- Po **kilku błędnych kodach** (typowo 3–10, konfigurowalne) klawiatura blokuje się na określony czas (np. 90 s – kilka minut).
- Wielokrotna seria błędów może wygenerować zdarzenie sabotażu / próby manipulacji do PCO.
- Norma PN-EN 50131 wymaga, by liczba możliwych kombinacji i ograniczenie prób uniemożliwiały łatwe odgadnięcie kodu (dla Grade 2/3).

Nie używaj kodów oczywistych: `1234`, `0000`, `1111`, daty urodzenia, numeru mieszkania. Unikaj też kodu „o jeden” różnego od kodu przymusu (łatwa pomyłka). Każdy domownik powinien mieć **własny, unikalny** kod.

## Piloty RF (breloki)

Pilot radiowy (brelok) pozwala uzbroić/rozbroić system z dystansu (np. z samochodu, sprzed bramy). Komunikuje się z centralą przez moduł bezprzewodowy (Satel ABAX, DSC PowerG, Risco 868 MHz, Jablotron 868 MHz).

### Typowy układ przycisków

| Przycisk | Funkcja (programowalna) |
| --- | --- |
| 🔒 (kłódka zamknięta) | **Uzbrojenie** (arm) — pełne czuwanie |
| 🔓 (kłódka otwarta) | **Rozbrojenie** (disarm) |
| ● / dom | Uzbrojenie częściowe / nocne (np. tylko obwód) lub wyjście programowalne |
| ★ / panika | **Alarm napadowy (panic)** — np. przytrzymanie 3 s |

- **Przypisanie pilota** — master/instalator dodaje pilot do konkretnego użytkownika; pilot dziedziczy jego uprawnienia i partycje.
- **Dwukierunkowe piloty** (2-way) — mają diodę/sygnał potwierdzający wykonanie komendy (np. „uzbrojono / nie uzbrojono — wejście otwarte”). Dotyczy ABAX 2, PowerG, Risco/Jablotron 868 MHz.
- **Bateria** — pilot zasilany jest baterią litową (np. CR2032 / CR2354 wg modelu). System 2-way zgłasza *niski stan baterii* pilota do centrali i aplikacji. Wymiana co kilka lat.

| Pilot (przykład) | System | Cena (2026) |
| --- | --- | --- |
| **Satel APT-200** (5-przyciskowy, 2-way) | ABAX 2 | ~180 zł |
| **DSC PG8929 / PG9929** (brelok PowerG) | PowerG 2-way | ~190 zł |
| **Risco Panic/Keyfob 2-way** | Risco 868 MHz | ~150 zł |
| **Jablotron JA-152J** (4-przyciskowy) | Jablotron 868 MHz | ~140 zł |

**Zgubiony pilot** = potencjalny dostęp do rozbrojenia. Po utracie pilota natychmiast **usuń go z systemu** (master/instalator) i — jeśli pilot rozbrajał — rozważ zmianę powiązanych kodów. To samo dotyczy zgubionej karty/breloka RFID.

## Karty i breloki zbliżeniowe (RFID)

Klawiatury z wbudowanym czytnikiem (lub osobne czytniki na magistrali) pozwalają autoryzować się przez **zbliżenie karty / breloka RFID** zamiast wpisywania kodu — wygodne przy wielu użytkownikach.

| Standard RFID | Częstotliwość | Cechy |
| --- | --- | --- |
| **EM / Unique** | 125 kHz | tani, popularny, tylko odczyt UID (mniej bezpieczny — łatwy do sklonowania) |
| **Mifare Classic / DESFire** | 13,56 MHz | nowocześniejszy, szyfrowanie (DESFire), trudniejszy do sklonowania |

- **Satel** — czytniki i klawiatury z proximity (np. moduły 125 kHz / Mifare), karty/breloki dodawane jak użytkownik.
- **DSC / PowerG** — proximity tag dodawany do kodu użytkownika na klawiaturze z czytnikiem.
- **Risco** — klawiatura Elegant z proximity, breloki/karty.
- **Jablotron** — RFID to podstawa codziennej obsługi (segment + zbliżenie), karty i breloki przypisane do użytkownika.

Do obiektów o wyższym ryzyku wybieraj **13,56 MHz Mifare DESFire** zamiast 125 kHz EM — karty 125 kHz „tylko-UID” można skopiować tanim duplikatorem. Dla integracji z kontrolą dostępu patrz dział 12 Kontrola dostępu.

## Programowanie — przykłady

### Satel (DLOAD X / klawiatura)

Master dodaje użytkownika z poziomu klawiatury lub programu **DLOAD X**. Schemat menu użytkownika (z klawiatury LCD):

```
[KOD MASTER] # ...... wejscie do menu uzytkownika
  > Uzytkownicy
      > Nowy uzytkownik
          - Schemat uprawnien:  "Uzytkownik" / "Tylko zalaczajacy" / "Przymus" ...
          - Kod:                ****  (4-8 cyfr)
          - Partycje:           [x] Parter   [ ] Pietro
          - Karta zblizeniowa:  (przyloz karte do klawiatury) -> zapis UID
          - Pilot APT-200:      (nacisnij przycisk pilota)    -> rejestracja
      > Edycja / Usun uzytkownika
; Schemat "Przymus" = kod duress (cichy alarm napadowy do PCO)
```

### DSC PowerSeries Neo (klawiatura)

W DSC kody programuje się sekcjami z poziomu kodu master. Uproszczony schemat:

```
[*][5][KOD MASTER]        ; programowanie kodow uzytkownikow
   > wybierz nr uzytkownika (np. 03)
   > wprowadz 4- lub 6-cyfrowy kod
   > [*] atrybuty uzytkownika:
        - partycje, do ktorych ma dostep
        - typ: zwykly / arm-only / Duress / Master
[*][5][KOD MASTER] -> uzytkownik 'Duress'  ; kod przymusu
[*][1] ......                                ; bypass (pomijanie wejsc) wg uprawnien
; Proximity tag: na klawiaturze z czytnikiem przypisz tag do nr uzytkownika
```

W obu systemach **kod master dodaje i usuwa zwykłych użytkowników**, ale to **kod instalatora** definiuje, jakie *schematy uprawnień* / typy kodów w ogóle istnieją i jak system raportuje przymus do PCO. Master operuje w ramach przygotowanych przez instalatora schematów.

## Dobre praktyki

- **Osobny kod / brelok dla każdego domownika** — log zdarzeń pokaże, *kto* uzbroił/rozbroił i o której godzinie (audyt). Wspólny kod „dla wszystkich” niweczy tę wartość.
- **Zmień domyślny kod instalatora i mastera** zaraz po montażu — fabryczne kody (np. master `1234`, instalator `12345` w wielu systemach) są powszechnie znane.
- **Ograniczenie czasowe** dla kont serwisowych — kod sprzątaczki aktywny tylko w określone dni/godziny (harmonogram), automatycznie nieaktywny poza nimi.
- **Skonfiguruj kod przymusu** i przećwicz go z domownikami (tylko gdy jest monitoring/PCO).
- **Usuwaj nieużywane konta, zgubione piloty i karty** niezwłocznie.
- **Dłuższe kody (6 cyfr) i blokada po błędach** dla obiektów komercyjnych / Grade 3.
- **Nie zapisuj kodów** na klawiaturze ani w pobliżu; dla wielu użytkowników rozważ RFID Mifare zamiast jawnych PIN-ów.

## RODO i prywatność logów zdarzeń

Log zdarzeń alarmu (kto, kiedy uzbroił/rozbroił, którą strefę) to w praktyce **dane osobowe** — pozwala odtworzyć obecność i aktywność konkretnych osób (np. godziny pracy pracownika, obecność domownika). W kontekście **RODO** oznacza to:

- Jeśli system rejestruje pracowników (firma, biuro), poinformuj ich o **monitorowaniu** dostępu/uzbrojeń i celu przetwarzania (obowiązek informacyjny). W relacjach pracowniczych monitoring zdarzeń może podlegać przepisom Kodeksu pracy.
- Ogranicz dostęp do logów (panel mastera / chmura) tylko do osób uprawnionych.
- Stosuj **retencję** — nie przechowuj logów dłużej niż to konieczne (chmury producentów mają własne okresy przechowywania).
- Imienne przypisanie kodów (audyt „kto”) jest pożyteczne dla bezpieczeństwa, ale zwiększa zakres danych osobowych — trzymaj to świadomie i proporcjonalnie do celu.
- W domu jednorodzinnym (użytek osobisty) RODO zasadniczo nie ma zastosowania, ale rozsądna higiena danych nadal się przydaje.

To ogólne wskazówki, nie porada prawna. Przy instalacjach komercyjnych z monitorowaniem pracowników skonsultuj zgodność z RODO i Kodeksem pracy z osobą odpowiedzialną za ochronę danych.
