# Nawadnianie i woda w ogrodzie

Automatyczne podlewanie to jeden z najbardziej „opłacalnych" projektów: oszczędza czas, wodę i rośliny podczas urlopu. Tu również wybór jest między **gotowym systemem** (kup–zakop–ustaw) a **DIY na ESP32** (taniej i elastyczniej). Zacznijmy od elementów wspólnych.

## Z czego składa się system nawadniania

1. **Źródło wody** — kran/przyłącze ogrodowe, beczka lub zbiornik **IBC** z deszczówką, albo studnia.
2. **Elektrozawór** — otwiera/zamyka przepływ na sygnał ze sterownika (serce automatyki).
3. **Sterownik** — odmierza czas i strefy, realizuje harmonogram, czyta czujniki.
4. **Rozprowadzenie** — linie kropelkujące, zraszacze, mikrozraszacze.
5. **Czujniki (opcjonalnie)** — wilgotność gleby, deszcz, poziom wody, przepływ.
6. **Pompa (opcjonalnie)** — gdy woda nie ma ciśnienia (beczka/IBC, studnia).

## Strefy nawadniania

Ogród dzieli się na **strefy** (np. trawnik, warzywnik, rabaty, donice) — każda z osobnym elektrozaworem, bo różne rośliny mają różne potrzeby, a ciśnienie wody rzadko wystarcza, by podlewać wszystko naraz. Sterownik włącza strefy **po kolei**. Liczba stref to kluczowy parametr przy wyborze sterownika.

## Elektrozawory — 24 V AC kontra 12 V DC

- **24 V AC** — standard w gotowych systemach ogrodowych (Hunter, Rain Bird, Gardena). Zawory tanie i wszechobecne, zasilane z transformatora. Jeśli planujesz rozbudowę, ten standard jest „bezpieczny na przyszłość".
- **12 V DC** — wygodniejsze w DIY (zasilisz tym samym 12 V co resztę elektroniki, łatwo z baterii/solara). Dostępne też zawory **latching** (bistabilne) — utrzymują stan bez ciągłego zasilania, idealne do pracy bateryjnej.

Zawór dobiera się do **średnicy** instalacji (np. 3/4", 1") i ciśnienia. Pamiętaj o **diodzie gaszącej** przy cewce zaworu DC (rozdział 04).

## Droga A: gotowy sterownik nawadniania

Kup, podłącz zawory, ustaw harmonogram. Trzy klasy rozwiązań:

- **Gardena (system pełny)** — bardzo „konsumencki", ekosystem z czujnikami, sterownik **smart** z bramką i aplikacją, łatwe złączki. Najprzyjemniejszy w montażu, droższy za element.
- **Hunter / Rain Bird** — „półprofesjonalne" sterowniki strefowe (np. Hunter **Hydrawise** z WiFi i pogodą). Solidne, dużo stref, standard 24 V AC. Najczęściej wybierane do większych ogrodów.
- **Proste sterowniki czasowe na kran** (np. nakręcane na zawór czerpalny, bateryjne) — najtańsze; jedna strefa, harmonogram bez sieci. Dobre na start dla warzywnika lub donic.

## Droga B: DIY na ESP32 (taniej i elastycznie)

Najtańszy i najbardziej elastyczny wariant: **ESP32** steruje modułem przekaźnikowym/MOSFET, ten otwiera elektrozawory; czujnik wilgotności gleby i dane pogodowe decydują, czy w ogóle podlewać. Całość raportuje do Home Assistant.

```
[Czujnik gleby] -> [ESP32 + ESPHome] -> [Przekaźniki] -> [Elektrozawory stref]
[Prognoza pogody z centralki] --/         \-> [Pompa z beczki/IBC]
```

- **Zalety:** kilkadziesiąt złotych za sterownik, dowolna liczba stref, własne reguły (gleba + pogoda + poziom w beczce), pełna integracja.
- **Wady:** trzeba zbudować i uszczelnić (IP65), zadbać o zasilanie w ogrodzie.
- **Gotowiec pośredni:** moduł **Shelly** (np. Plus 1) też otworzy zawór i da harmonogram bez pisania kodu.

## Czujniki, które naprawdę pomagają

- **Wilgotność gleby (pojemnościowy!)** — podlewaj *według potrzeby*, nie „bo wtorek". Próg z histerezą (np. podlewaj poniżej 30%, przestań przy 45%).
- **Czujnik/dane deszczu** — najtańsza oszczędność wody: **nie podlewaj, gdy pada lub ma padać**. Gotowe sterowniki mają „rain sensor"; w DIY pobierzesz prognozę z centralki.
- **Poziom wody w zbiorniku (pływak/ultradźwięk)** — chroni pompę przed pracą „na sucho" i informuje, kiedy dolać/że deszczówka się skończyła.
- **Przepływomierz** — wykrywa awarię (pękła linia kropelkująca → nagły duży przepływ → zamknij zawór i alarm).

## Pompy i deszczówka

Woda z kranu ma ciśnienie — z **beczki/IBC zwykle nie**. Wtedy potrzebna jest pompa:
- **Pompa membranowa 12 V** — do nawadniania kropelkowego z beczki; cicha, mała, łatwa w DIY. Dodaj **czujnik suchobiegu** (pływak), by nie pracowała pusta.
- **Pompa zatapialna / hydrofor 230 V** — większa wydajność (studnia, duży ogród); sterowana przez przekaźnik/Shelly.

Zbieranie deszczówki (beczka/IBC pod rynną) zauważalnie obniża rachunki i jest łagodniejsze dla roślin niż twarda woda z kranu.

## Harmonogram i integracja z pogodą

- **Podlewaj rano** (4:00–7:00) — mniej parowania, liście schną w ciągu dnia (mniejsze ryzyko chorób).
- **Sezonowość** — latem częściej, wiosną/jesienią rzadziej; gotowe sterowniki mają „seasonal adjust", w DIY zrobisz to regułą.
- **Pomiń przy deszczu/prognozie** — reguła „jeśli suma opadów z ostatnich 24 h > X **lub** prognoza > Y → nie podlewaj". To realnie chroni przed przelaniem i marnowaniem wody.
- **Wilgotność jako nadrzędny warunek** — najlepsze systemy nie trzymają się sztywno zegara, tylko sprawdzają, czy gleba faktycznie jest sucha.

## Kropelkowe czy zraszacze?

- **Linia kropelkująca** — woda prosto do korzeni, minimalne parowanie, najlepsza do warzywnika, rabat i żywopłotów. Najbardziej oszczędna.
- **Zraszacze / mikrozraszacze** — do trawnika i większych powierzchni; więcej parowania, większe zużycie.
- W praktyce łączy się jedno z drugim w różnych strefach.

## Koszty (PLN, 2026)

**DIY na ESP32 — warzywnik, 2 strefy**
| Element | Cena |
|---------|------|
| ESP32 + moduł przekaźnikowy 2-kan. | 35–60 zł |
| 2× elektrozawór 12 V DC | 50–120 zł |
| Czujnik wilgotności gleby (pojemnościowy) | 8–20 zł |
| Zasilacz 12 V + obudowa IP65 | 40–80 zł |
| Linia kropelkująca + złączki (zestaw) | 60–150 zł |
| **Razem** | **~190–430 zł** |

**Pompa z beczki (dodatek)**
| Element | Cena |
|---------|------|
| Pompa membranowa 12 V | 30–70 zł |
| Pływak suchobiegu | 6–15 zł |
| **Razem** | **~36–85 zł** |

**Gotowy system strefowy**
| Wariant | Cena |
|---------|------|
| Prosty sterownik na kran (1 strefa, bateryjny) | 60–150 zł |
| Sterownik 4–6 stref (Hunter/Rain Bird) + zawory | 400–900 zł |
| Gardena smart (sterownik + bramka + czujniki) | 700–1500 zł |
| Linie/zraszacze/rury (wg powierzchni) | 200–800 zł |

## Bezpieczeństwo i trwałość w ogrodzie

- **IP65+ wszędzie** — sterownik w szczelnej puszce z dławikami; złącza wodoszczelne; gniazda na zewnątrz z **RCD/różnicówką**.
- **Niskie napięcie na zewnątrz** — trzymaj się 12/24 V do zaworów i czujników; 230 V (pompa) tylko przez certyfikowane, zabezpieczone gniazdo.
- **Zima** — przed mrozem **odwodnij** instalację (zawory, rury, pompę) albo zdemontuj wrażliwe elementy; woda rozsadza zawory i rury.
- **Filtr na wejściu** — drobny filtr siatkowy chroni kropelkowanie i zawory przed zatkaniem (zwłaszcza z deszczówki/studni).

## Co wybrać — szybki przewodnik

- **Donice/mały warzywnik, minimum zachodu** → prosty sterownik na kran.
- **Chcę taniej, z czujnikami i integracją** → **ESP32 + ESPHome + elektrozawory 12 V**.
- **Duży ogród, wiele stref, „kup i działa"** → Hunter/Rain Bird (24 V AC) lub Gardena smart.
- **Mam deszczówkę w beczce** → dołóż pompę 12 V + czujnik suchobiegu.

---

➡️ Dalej: **[07 — Centrale i oprogramowanie](07-centrale-software.html)** — jak spiąć światło, wodę i czujniki w jeden system z automatyzacjami.
