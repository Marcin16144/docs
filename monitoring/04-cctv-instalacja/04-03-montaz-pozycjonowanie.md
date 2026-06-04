# Montaż i pozycjonowanie kamer

**Sekcja:** 04 Instalacja CCTV · **Aktualizacja:** 2026-05

Wysokość, kąt nachylenia, kierunki świata i oślepianie, problem IR z oknami, martwe pola, nakładanie pól widzenia sąsiednich kamer.

## Wysokość montażu — kompromis trzech celów

Wysokość kamery to wynik trzech sprzecznych potrzeb: widoczność twarzy (jak najniżej), bezpieczeństwo przed wandalizmem (jak najwyżej) i odpowiedni kąt widzenia (zależy od ogniskowej).

| Wysokość | Co widać | Plusy | Minusy |
|---|---|---|---|
| **2,2–2,5 m** | twarze osób, identyfikacja | bardzo dobra rozpoznawalność rysów | łatwy wandalizm, łatwa zasłona ręką |
| **2,5–3 m** | twarz + górna część sylwetki | kompromis identyfikacja / bezpieczeństwo | standardowa wysokość drzwi balkonowych — czujnik patrzy „w sufit" |
| **3–4 m** | sylwetka, kolory ubrań, kierunek ruchu | poza zasięgiem ręki, bez drabiny | twarz pod kątem — trudniej zidentyfikować |
| **4–6 m** | obszar, sceny zbiorowe | szeroka pokrywa, brak wandalizmu | identyfikacja prawie niemożliwa bez optyki tele |
| **>6 m (PTZ)** | przegląd posesji, podgląd zdarzeń | pokrycie 360° | kosztowne, wymaga obsługi/AI |

### Reguła twarzy 3 m / 3 m

Dla identyfikacji twarzy potrzeba **min. 80 pikseli między oczami** (PN-EN 62676-4). Praktyczna reguła: kamera 4 MP, ogniskowa 4 mm, wysokość 2,5 m — strefa identyfikacji to obszar 3 m × 3 m bezpośrednio pod i przed kamerą.

## Kąt nachylenia

Kamera skierowana pionowo w dół widzi tylko głowy. Skierowana poziomo łapie horyzont, niebo i daje słabą głębię ostrości w polu zainteresowania. Optimum: **15–30° w dół od horyzontu**.

| Kąt | Efekt | Stosowanie |
|---|---|---|
| 0–10° (prawie poziomo) | długi dystans, mała głębia, niebo w kadrze | długi korytarz, parking dalekosiężnie |
| **15–30°** | dobra identyfikacja + dystans | strefa wejścia, podjazd, ogród |
| 30–45° | krótki dystans, identyfikacja twarzy | drzwi wejściowe, kasa |
| 45–90° (pion w dół) | tylko czubki głów, brak twarzy | bankomat, kasa fiskalna (cyfra), POS |

## Kierunki świata i oślepianie

Słońce świecące prosto w obiektyw to katastrofa: w środku dnia kamera wpada w przeciwświatło, sensor wpada w pełen blowing-out, a kiepski HDR daje czarne ciemne plamy zamiast scen.

| Kierunek kamery (gdzie patrzy) | Ryzyko | Pora dnia |
|---|---|---|
| **S (południe)** — oblicze kamery zwrócone na S | wysokie — słońce przez większość dnia | 9:00–16:00 cały rok |
| **SW / SE** | wysokie poranek / popołudnie | wschód lub zachód słońca w oczy |
| **E (wschód)** | poranek (7:00–10:00 latem) | świt, niskie słońce |
| **W (zachód)** | popołudnie (16:00–20:00 latem) | zachód, niskie słońce |
| **N (północ)** | niskie | słońce nigdy nie wpada w obiektyw |

**Strategia:** kamerę skierowaną na obszar po stronie południowej zamontuj na ścianie północnej i skieruj na południe. Słońce jest *za* kamerą, oświetla scenę. Nigdy odwrotnie — z południa patrzącą na północ — sceny nigdy nie zobaczysz pod światło.

## Martwe pola

Pod każdą kamerą znajduje się tzw. „strefa martwa" — obszar, którego nie widzi z powodu kąta widzenia obiektywu i kąta nachylenia. Im większy kąt nachylenia w dół, tym mniejsza strefa martwa.

```
Kamera na 4 m, kąt nachylenia 20°, ogniskowa 4 mm (FOV ~80° w poziomie):
  Najbliższy widoczny punkt ~ 4 m / tan(20°) - poprawka FOV = 11 m od ściany
  Strefa martwa = pas 0–11 m od ściany pod kamerą
  
Po zwiększeniu nachylenia do 35°:
  Najbliższy punkt = 4 m / tan(35°) - poprawka = 5,7 m
  Strefa martwa znacznie krótsza
```

### Jak walczyć z martwym polem

- **Dwie kamery** — jedna na ścianie, druga na narożniku, ich pola zachodzą.
- **Kamera typu „fish-eye 360°"** pod sufitem — pokrywa całą scenę pod sobą.
- **Niższy montaż** — przy 2,5 m strefa martwa to ledwie 1–2 m.
- **Kamera ze szczytową strefą detekcji** + dodatkowa pod-okienna (skierowana w dół na ścieżkę).

## IR i okna — problem odbić

Kamera IR za szybą (np. w środku domu, patrząca przez okno na podwórko) **nie zadziała w nocy**. Promienie IR-LED odbijają się od szyby z powrotem na sensor — efekt: olśniewający flesh, biały ekran.

> Kamera *na zewnątrz*, IR włączone, w polu widzenia okno odbijające IR — to samo: odbicie LED w szybie wygląda jak biała plama. Także lusterko samochodu, mokra elewacja, blacha rynny mogą generować artefakty IR.

### Rozwiązania

1. **Kamera fizycznie na zewnątrz** — IR-LED bezpośrednio nad polem widzenia, bez szyb.
2. **Wyłącz IR-LED, użyj zewnętrznego promiennika IR** osobno (np. SecureSafe IRL-940 850 nm) z odpowiedniej odległości.
3. **Color night vision** (Reolink ColorX, Hikvision ColorVu) — kamera z dużą aperturą i czułym sensorem, działa przy 0,001 lx bez IR. Wymaga jakiegoś światła (latarnia, czujka).
4. **Doświetl podczerwienią** z zewnątrz, kamera ma zasłonę IR (filtr IR-cut blokujący wbudowane LED).

## Nakładanie pól widzenia (overlap)

Dobry projekt CCTV ma **min. 10–20% nakładania się** pól widzenia sąsiednich kamer. Dzięki temu osoba przemieszczająca się przez teren nigdy nie znika z obrazu nawet na sekundę.

| Konfiguracja | Nakładanie | Efekt |
|---|---|---|
| Brak nakładania, „pasek bez przerw" | 0% | w polu styku obrazów blind spot 1–2 m |
| **10–15% nakładania** | standardowe | ciągłość, sprawdzenie czasu z zegara kamer |
| 30%+ nakładania | zwykle za dużo | marnowanie kamer, chyba że celowy redundans |

### Praktyczna kalkulacja FOV

Pole widzenia w poziomie zależy od rozmiaru sensora i ogniskowej. Dla popularnego sensora 1/2,8" (5,76 × 3,24 mm):

| Ogniskowa | FOV poziomy | Szerokość kadru @ 10 m | Szerokość kadru @ 20 m |
|---|---|---|---|
| 2,8 mm | 92° | 20,7 m | 41,4 m |
| 3,6 mm | 78° | 16,2 m | 32,4 m |
| **4 mm** | **72°** | **14,5 m** | **29,0 m** |
| 6 mm | 52° | 9,7 m | 19,4 m |
| 8 mm | 40° | 7,3 m | 14,5 m |
| 12 mm | 27° | 4,8 m | 9,6 m |

## Listy kontrolne — montaż

### Przed wierceniem

1. Sprawdź skrzynkę przyłączeniową (PoE — switch, kabel UTP do szafy).
2. Zaznacz markerem na ścianie 3 punkty mocowania. Pomyśl raz, wierć dwa.
3. Symuluj kąt — telefonem z aplikacją „kamera + linijka kąta" sprawdź widok docelowy.
4. Sprawdź, czy w polu widzenia nie wpadają cudze działki (**RODO** — maskowanie obowiązkowe).
5. Sprawdź odbicie słońca o porach 9:00, 12:00, 16:00, 18:00 (latem i zimą — różne wysokości słońca).

### Przy montażu

1. Pętla zapasowa kabla 30 cm w puszce — na wymianę kamery, sprzątanie wody.
2. Wszystkie połączenia w puszce IP65 lub żelu hydrofobowym.
3. Uszczelnienie wnętrza obudowy (silikon neutralny) — wilgoć powoduje matowienie obiektywu od środka.
4. Pętla skropleniowa w przewodzie — kropla skraplająca się spływa po pętli, nie do gniazda.
5. Daszek przeciwdeszczowy nad obiektywem (wzrost żywotności o lata, redukcja oślepień).

### Po montażu — kontrola

1. Test obrazu w dzień, w cieniu, w nocy (sprawdź IR), pod sztucznym światłem (CCT).
2. Detekcja ruchu — zaznacz strefę zainteresowania (motion zone), nie cały obraz (drzewa, flagi powodują false positive).
3. Ustaw harmonogram nagrywania / powiadomień (np. brak push w godzinach pracy).
4. Test PoE na obciążeniu — kamera w trybie IR pobiera 2× więcej prądu niż w dzień.

## Co dalej

➡ [OSD i konfiguracja kamery](04-04-osd-konfiguracja.md)
