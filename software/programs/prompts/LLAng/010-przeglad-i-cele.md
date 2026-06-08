# 010 — Przegląd i cele projektu

## Kontekst
Buduję **LLAng** — lokalną aplikację do nauki angielskiego. Ma być lekka,
działać offline i z jednego kodu uruchamiać się jako:
1. aplikacja desktopowa Windows (`.exe` + instalator),
2. aplikacja macOS,
3. zwykła strona WWW (do wrzucenia na hosting).

## Cel tego promptu
Ustal zakres i zasady architektoniczne całego projektu (bez kodu).

## Wymagania funkcjonalne (moduły)
- **Fiszki** — nauka słówek z algorytmem powtórek (spaced repetition) i wymową.
- **Kurs** — biblioteka kupionego kursu (pliki wideo/audio z dysku): nawigacja
  drzewiasta, odtwarzacz z zapamiętywaniem miejsca, notatki, ulubione,
  kontrola integralności plików.
- **Materiały** — własne drzewo plików PDF/EPUB oraz adresów URL (w tym YouTube)
  z czytnikiem i zapamiętywaniem strony/pozycji.
- **Notatki** — bogate (WYSIWYG), powiązane z czasem nagrania, z tagami i
  wyszukiwaniem po tematach.
- **Rozmowa z AI** — konwersacja po angielsku z lokalnym modelem (offline).
- **Motyw** — jasny / ciemny / czarny, przełączany ikoną.

## Zasady architektoniczne
- **Lekkość**: preferuj rozwiązania o małym rozmiarze binarki i niskim RAM.
- **Jeden frontend** dla web i desktop; różnice ukrywaj za interfejsami.
- **Trwałość lokalna**: dane w bazie po stronie aplikacji (bez chmury).
- **Portowalność postępu**: identyfikuj materiały ścieżką WZGLĘDNĄ, by po
  przeniesieniu plików wystarczyła zmiana jednej ścieżki w ustawieniach.
- **Bezpieczeństwo**: dostęp do dysku i sieci realizuj w warstwie natywnej.

## Kryteria akceptacji
- Spisany zakres modułów i zasady, do których odwołują się kolejne prompty.
