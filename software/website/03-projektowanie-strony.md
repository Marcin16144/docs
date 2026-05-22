# 03: Projektowanie strony (UX / UI)

## Architektura informacji

Zanim zaprojektujesz wyglad, zaprojektuj strukture:
- Mapa strony (sitemap) — jakie podstrony i jak sie zaglebiaja.
- Nawigacja — max 5-7 pozycji w menu glownym. Wiecej = chowaj w podmenu.
- Sciezka uzytkownika — od wejscia do celu (kontakt, zakup) w jak najmniej krokach.

## Wireframe przed grafika

Szkielet (wireframe) to uklad blokow bez kolorow i zdjec. Pozwala ustalic hierarchie
i rozmieszczenie, zanim wejdzie estetyka. Narzedzia: Figma, papier, Excalidraw.

## Uklad i hierarchia wizualna

- **Above the fold** — najwazniejszy komunikat i CTA widoczne bez przewijania.
- **Hierarchia** — rozmiar, kontrast i odstep prowadza wzrok: naglowek > podtytul > tresc.
- **Bialy obszar (whitespace)** — odstepy to nie "pusta przestrzen", to oddech. Nie zapelniaj wszystkiego.
- **Wzorce skanowania** — uzytkownik czyta wzorem F lub Z. Najwazniejsze elementy w lewym gornym obszarze i wzdluz tych linii.
- **Siatka (grid)** — 12-kolumnowa siatka porzadkuje uklad i ulatwia responsywnosc.

## Typografia

- Max 2 kroje pisma (jeden na naglowki, jeden na tresc). Trzeci tylko z powodu.
- Tekst podstawowy min. 16px, interlinia ok. 1.5-1.7.
- Dlugosc wiersza 50-75 znakow — dluzsze meczy.
- Hierarchia rozmiarow oparta na skali (np. 16 / 20 / 25 / 31 / 39 px).
- Bezpieczne, czytelne kroje webowe: Inter, Roboto, Open Sans, Source Sans, system-ui.

## Kolory

- Paleta: 1 kolor glowny (marka), 1-2 akcentowe, neutralne (tla, teksty).
- Regula 60-30-10: 60% tlo/neutralny, 30% kolor uzupelniajacy, 10% akcent (CTA).
- Kontrast tekstu do tla musi spelniac WCAG: min. 4.5:1 dla zwyklego tekstu.
- Kolor akcentu zarezerwuj dla przyciskow akcji — niech sie wyroznia.

## Responsywnosc (RWD)

- Projektuj **mobile-first** — w Polsce ponad polowa ruchu to telefony.
- Punkty zlamania (breakpoints): ~360-480 (telefon), ~768 (tablet), ~1024-1280 (desktop).
- Elementy dotykowe min. 44x44 px, odstepy miedzy linkami.
- Testuj na realnych urzadzeniach, nie tylko w trybie responsywnym przegladarki.

## Dostepnosc (WCAG / a11y)

- Wystarczajacy kontrast kolorow.
- Kazdy obraz ma `alt`. Dekoracyjne — `alt=""`.
- Strona obslugiwalna z klawiatury, widoczny focus.
- Poprawna semantyka HTML (naglowki h1-h6 w kolejnosci, `<nav>`, `<main>`, `<button>`).
- Formularze z etykietami `<label>` powiazanymi z polami.
- W Polsce dostepnosc cyfrowa jest obowiazkowa m.in. dla podmiotow publicznych.

## Przyciski i wezwania do dzialania (CTA)

- Jedno glowne CTA na ekran. Tekst konkretny: "Umow wizyte", nie "Kliknij tutaj".
- CTA wyrozniony kolorem, wystarczajaco duzy, z odstepem.
- Stan hover/active/focus widoczny.

## Wydajnosc juz na etapie projektu

- Nie projektuj sekcji wymagajacych 10 ciezkich zdjec w hero.
- Animacje subtelne — nie blokuja czytania.
- Lekkie czcionki, ograniczona liczba wariantow (waga, kursywa).
Wydajnosc to czesc UX i czynnik SEO — patrz `06 — SEO i pozycjonowanie`.

## Najczestsze bledy

- Karuzela/slider w hero — niska skutecznosc, uzytkownik nie czeka.
- Za maly tekst, za niski kontrast "bo ladnie".
- Menu z 12 pozycjami.
- Brak widocznego kontaktu / CTA.
- Projekt tylko na desktopie, mobile "jakos sie ulozy".

## Powiazane materialy

- Szablony i design system — `04 — Szablony i design system`.
- HTML/CSS — `software/www`.
