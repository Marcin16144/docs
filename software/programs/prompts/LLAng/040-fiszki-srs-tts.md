# 040 — Fiszki: SRS (SM-2) + wymowa (TTS)

## Cel
Moduł nauki słówek z algorytmem powtórek i wymową.

## Zadanie
1. Model `Card` (słowo en/pl, przykład, kategoria + stan SRS: repetition,
   interval, ease, due). Funkcja `withDefaults` (due=0 → należy się od razu).
2. Algorytm **SM-2** w `src/features/srs/sm2.ts`: `review(card, grade, now)`
   zwraca nowy stan. Oceny z UI: again/hard/good/easy → jakość q (2/3/4/5).
   - q<3: reset serii (repetition=0, interval=1), due ≈ now+1 min (powtórka w sesji);
   - q≥3: interval 1 → 6 → round(interval*ease); ease korygowane, min 1.3;
     due = now + interval dni.
3. **TTS** w `src/features/tts/speak.ts` przez Web Speech API
   (`speechSynthesis`), domyślnie `en-US`. Przycisk 🔊 przy słowie.
4. Hook sesji (`useDeck`): ładuje fiszki „do powtórki” (due ≤ now); przy pustej
   bazie wgrywa zestaw startowy (seed); ocena aktualizuje bazę; „again” wraca na
   koniec kolejki tej sesji.
5. Ekran fiszki: przód (EN + 🔊) → klik/Spacja odsłania tył (PL + przykład) →
   przyciski oceny.

## Kryteria akceptacji
- Fiszki pojawiają się i znikają wg harmonogramu SM-2.
- Wymowa działa w web i desktop.
- Postęp zapisany w bazie (z 030).
