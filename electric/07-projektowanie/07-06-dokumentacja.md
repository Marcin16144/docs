# Dokumentacja powykonawcza

Dokumentacja powykonawcza to teczka, którą wykonawca przekazuje inwestorowi po zakończeniu robót. Bez niej formalny odbiór i podpięcie licznika są **niemożliwe**.

## Spis treści typowej teczki

| Lp. | Dokument | Status |
|---|---|---|
| 1 | Strona tytułowa + spis treści | obowiązkowy |
| 2 | Projekt zaktualizowany („as-built") | obowiązkowy |
| 3 | Protokoły pomiarów odbiorczych (5 typów) | obowiązkowy |
| 4 | Atesty / deklaracje zgodności CE materiałów | obowiązkowy |
| 5 | Instrukcja użytkowania | obowiązkowy |
| 6 | Instrukcja przeciwpożarowa | zalecany |
| 7 | Protokół odbioru końcowego | obowiązkowy |
| 8 | Karty katalogowe nietypowych aparatów | zalecany |

## 1. Strona tytułowa

Powinna zawierać:

- nazwa inwestycji (adres budynku)
- inwestor (imię, nazwisko / firma, adres)
- wykonawca (firma, NIP, numer uprawnień SEP)
- projektant (imię, nazwisko, numer uprawnień)
- data rozpoczęcia i zakończenia robót
- numer egzemplarza (zwykle 3: inwestor, wykonawca, OSD)

## 2. Projekt „as-built"

Wszystkie schematy, rzuty i obliczenia z projektu wykonawczego **z naniesionymi zmianami** wprowadzonymi podczas realizacji. Każda zmiana opisana:

> „Zmiana z 12.06.2024 — przesunięcie gniazda G3.4 z osi 25 cm w lewo, w związku z zabudową szafy."

## 3. Protokoły pomiarów — 5 typów

| Typ pomiaru | Co sprawdza | Wartość graniczna |
|---|---|---|
| **Rezystancja izolacji** | jakość izolacji przewodów | ≥ 1 MΩ (przy 500 V DC) |
| **Impedancja pętli zwarcia L-PE** | czy MCB zadziała przy zwarciu | Ia · Zs ≤ Uo (Ia = prąd zadziałania B/C, Uo = 230 V) |
| **Skuteczność RCD** | czas i prąd zadziałania | t < 300 ms przy IΔn; t < 40 ms przy 5·IΔn |
| **Rezystancja uziemienia** | jakość połączenia z ziemią | < 30 Ω (typowo < 10 Ω) |
| **Ciągłość przewodów PE** | każdy PE dochodzi do każdego gniazda | R < 1 Ω |

Każdy protokół podpisuje uprawniony elektryk (SEP grupy D — dozór).

## 4. Atesty / deklaracje zgodności CE

Wszystkie materiały na stałe wbudowane w instalację muszą mieć:

- **deklarację zgodności WE/CE** producenta
- znak CE na produkcie
- atest higieniczny (dla przewodów w pomieszczeniach mieszkalnych)
- **atest p-poż** (dla osłon przewodów w drogach ewakuacyjnych)

Wykonawca dołącza kserokopię deklaracji dla:

- każdego typu przewodu (kabla)
- każdego modelu aparatu w rozdzielnicy
- rozdzielnicy jako całości
- osprzętu (gniazda, łączniki, oprawy)

## 5. Instrukcja użytkowania

Krótki dokument (2-5 stron) dla użytkownika końcowego — w języku polskim, bez żargonu. Zawiera:

- gdzie znajduje się rozdzielnica (rysunek poglądowy)
- jak wyłączyć cały dom (wyłącznik główny)
- co robić przy „wybiciu korka"
- jak działa RCD i co zrobić przy zadziałaniu (test miesięczny przyciskiem T)
- jakie są zalecenia eksploatacyjne (przegląd co 5 lat, kontakt do uprawnionego elektryka)
- czego **nie wolno robić** (otwierać rozdzielnicy bez uprawnień, podłączać przedłużaczy w łańcuch, samodzielnie wymieniać MCB)

## 6. Instrukcja przeciwpożarowa

W praktyce dla domu jednorodzinnego jest to dokument minimalny (czasem niewymagany formalnie, ale dobry zwyczaj):

- co robić w razie pożaru instalacji elektrycznej
- zakaz gaszenia wodą prądu pod napięciem
- numery alarmowe
- gdzie znajdują się gaśnice
- jak wyłączyć główny prąd przy ewakuacji

Dla obiektów użyteczności publicznej — wymagana pełna instrukcja bezpieczeństwa pożarowego (IBP).

## 7. Protokół odbioru końcowego

Dokument 2-3 stronicowy, podpisany przez **trzy strony**:

- **inwestor** — potwierdza odbiór
- **wykonawca** — gwarantuje zgodność z projektem
- **inspektor nadzoru lub uprawniony SEP D** — potwierdza zgodność z przepisami

Zawiera:

- listę usterek (jeśli są) z terminami usunięcia
- datę odbioru
- okres gwarancji (typowo 2 lata na materiał + 5 lat na robociznę)

## Uprawnienia SEP — kto może podpisać

| Grupa | Zakres |
|---|---|
| **SEP G1, E1** | Eksploatacja urządzeń elektroenergetycznych do 1 kV (instalacja domowa) |
| **SEP G1, D1** | Dozór urządzeń elektroenergetycznych do 1 kV |
| **SEP G2, E/D** | Cieplne (kotłownie, sieć centralnego ogrzewania) |
| **SEP G3, E/D** | Gazowe |

Dla typowej instalacji domu:

- **pomiary i odbiór** — wymagany SEP G1 D (dozór)
- **wykonawstwo** — wymagany SEP G1 E (eksploatacja)
- te same osoba nie powinna wykonywać i odbierać tego samego zakresu

## Archiwizacja

Komplet dokumentacji przechowuje:

1. **Inwestor / właściciel budynku** — egzemplarz nr 1, **bezterminowo**
2. **Zarządca / wspólnota** (w blokach) — egzemplarz nr 2
3. **OSD** — egzemplarz potrzebny do podpięcia licznika (czasem tylko skan)

Po **5 latach** od odbioru — uzupełnia się protokołem pierwszego przeglądu okresowego.

## Praktyczna zasada

> **Bez teczki powykonawczej nie ma odbioru. Bez odbioru nie ma licznika. Bez licznika nie ma prądu.**

Jeśli wykonawca odmawia kompletnej dokumentacji — zatrzymaj 10-20% płatności do momentu jej dostarczenia.

## Co dalej

➡ [Sekcja 08 — Oświetlenie](../08-oswietlenie/index.html)
