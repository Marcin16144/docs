# 06-04: Przewijanie transformatora — krok po kroku

## Wstęp

Przewijanie transformatora to praktyczna umiejętność, którą warto poznać. Pozwala:
- Naprawić spalony transformator (zachowując rdzeń)
- Zrobić transformator pod własne specyfikacje (nietypowe napięcia)
- Zaoszczędzić pieniądze
- Zrozumieć, jak działa elektrotechnika

Ten rozdział pokazuje proces krok po kroku — od demontażu starego do gotowego trafo.

## Narzędzia i materiały

### Narzędzia

- **Płaski wkrętak** + młotek (do rozbierania pakietu)
- **Imadło** (do trzymania rdzenia)
- **Ręczna nawijarka** (lub wiertarka z licznikiem zwojów)
- **Cążki, szczypce**
- **Pęseta**
- **Lutownica + cyna**
- **Multimetr** (rezystancja, ciągłość)
- **Suwmiarka** (mierzenie rdzenia, blach)
- **Pióro / mazak** do oznaczania
- **Liczba zwojów** — najlepiej mechaniczny licznik z pokrętłem

### Materiały

- **Drut emaliowany** odpowiednich średnic (np. 0,2 mm, 0,5 mm, 1 mm)
- **Karkas** (cewka, szpula) pasujący do rdzenia
- **Papier elektroizolacyjny** (Nomex, presspan, klasa F lub H)
- **Folia Mylar** lub Kapton (precyzyjna izolacja)
- **Lakier izolacyjny** (impregnacyjny)
- **Taśma elektroizolacyjna** klasa H (180°C)
- **Wstążka termoutwardzalna** (Glass tape) — do mocowania pakietu

## Etap 1: Demontaż starego transformatora

### Dokumentacja

Zanim cokolwiek rozbierzesz, **zmierz wszystko**:
- Napięcia wyjść (bez obciążenia)
- Rezystancje uzwojeń (multimetrem)
- Typ blach (zmierz wymiary: E i I)
- Pakiet (grubość = ilość blach × grubość)
- Zdjęcia z różnych stron

### Rozbieranie pakietu blach EI

Pakiet jest zwykle skręcony 4 śrubami. Po odkręceniu:

1. **Wyrwij "I"** — blaszka zamykająca po jednej stronie. Często wystarczy lekkie uderzenie wkrętakiem z boku.
2. **Wyciągaj "E"** pojedynczo. Mogą być sklejone lakierem — delikatnie podważ wkrętakiem.

UWAGA: blachy są zaostrzone. Rękawice + ostrożność.

### Wyciągnij uzwojenia

Po wyjęciu wszystkich blach karkas z drutem zostaje wolny. Wyciągnij go.

### Odlot starego drutu

Można:
- Rozwinąć stary drut (jeśli karkas dobry, używasz drugi raz)
- Zniszczyć ostre nożem (jeśli karkas brudny od pęknięcia, pożaru)
- Zmierzyć stary drut średnicowo dla referencji

### Czyszczenie

- Karkas: bez resztek izolacji
- Blachy: bez ostrych zadziorów, lekko schropowiać krawędzie

## Etap 2: Przygotowanie karkasu

### Wymiary

Sprawdź czy karkas pasuje do rdzenia. Standardowe karkasy są na konkretne blachy:
- EI28, EI38, EI42... — każdy ma swój.

Karkasy są **plastikowe** (do 130°C) lub **z bakeletu** (do 200°C, trudne dziś dostać). Karkasy w SMPS często **wielokomorowe** (osobne sekcje dla pierwotnego i wtórnego).

### Mocowanie

Karkas zaklin po stronie krawędzi (np. krótka pianka) aby się nie obracał na rdzeniu.

### Nawijanie

Większość karkasów ma **stację mocowania** w nawijarce. Wsuwasz wałek prostopadle przez karkas — wałek obraca, kasyf się nawija.

## Etap 3: Nawijanie pierwotnego (N₁)

### Początek

1. Przeciągnij drut przez otwór startowy karkasu, zostaw 5-10 cm zapasu.
2. Załóż wałek nawijarki.
3. Wyzeruj licznik.
4. Zacznij nawijać, mocno trzymając drut palcami (równomierne napięcie).

### Zasady nawijania

- **Zwoje pokrywaj równomiernie** — nie krzyżuj, nie przeskakuj.
- **Jeden zwój za drugim**, ścisło ułożone.
- Po dotarciu do końca karkasu — **wracaj w drugą stronę** (warstwa 2).
- Co 50-100 zwojów rób przerwę, sprawdź licznik.

### Izolacja międzywarstwowa

Po każdej warstwie wsuń **paseczek papieru izolacyjnego**:
- Cienki (0,03-0,05 mm) — np. Nomex, presspan
- Szerokość = wysokość karkasu
- Lekko skleić taśmą izolacyjną

To izoluje warstwy między sobą i wyrównuje powierzchnię dla kolejnej warstwy.

### Liczba warstw

Zależy od długości karkasu i średnicy drutu. Przykład:

```
Karkas 30 mm długości, drut 0,4 mm (z izolacją 0,43 mm):
zwojów na warstwę = 30 / 0,43 ≈ 70

N_1 = 683 zwoje → 683/70 ≈ 9,8 → 10 warstw
```

### Końcówka pierwotnego

Po nawinięciu N_1 zwojów:
1. Zostaw 5-10 cm zapasu drutu.
2. Wyprowadź końcówkę przez otwór wyjściowy.
3. Pomiar: rezystancja przed dodaniem wtórnego (jako referencja).

### Izolacja przed wtórnym

**Bardzo ważne!** Między pierwotnym (230 V) a wtórnym (niskonapięciowym) musi być:
- Co najmniej **2 warstwy** papieru elektroizolacyjnego (lub folii Mylar)
- Pełna szerokość karkasu
- Bez przerw, bez dziur

Czemu: gdy izolacja przebije, **230 V trafia na wtórny** = porażenie, pożar, śmierć.

W transformatorach trójwarstwowo izolowanych (np. ładowarki USB) drut jest sam z grubszą izolacją (TIW — Triple Insulated Wire).

## Etap 4: Nawijanie wtórnego (N₂)

### Procedura

1. **Wyprowadź początek drutu wtórnego** przez osobny otwór karkasu.
2. Nawijaj jak pierwotny, ale **innym kierunkiem** dla mniejszej pojemności pasożytniczej (opcjonalnie).
3. Drut wtórny jest grubszy (większy I) — wolniej, ostrożniej.
4. Co warstwę — izolacja.
5. Wyprowadź końcówkę.

### Jeśli kilka uzwojeń wtórnych

Każde z izolacją między nimi (taką samą lub mniejszą niż pierwotne-wtórne).

Kolejność:
1. Pierwotne (z izolacją wewnętrzną)
2. Najwyższe napięcie wtórnego (np. 24 V)
3. Średnie (12 V)
4. Najniższe (5 V)

(Czasem stosuje się odwrotnie — zależnie od strat i pojemności.)

### Łączenie odczepów

Jeśli planujesz odczepy (np. co 5 V):
- Skręć drut na tym etapie i wyprowadź pętelkę przez otwór
- Pamiętaj o numeracji

## Etap 5: Wykończenie uzwojenia

### Ostatnia warstwa

Po nawinięciu wszystkich uzwojeń:
1. **2-3 warstwy izolacji** (papier + taśma).
2. **Mocowanie końcówek** taśmą.

### Wyprowadzenia (terminacja)

Końce drutu emaliowanego są pokryte lakierem — **nie można ich lutować bez usunięcia izolacji**.

Sposoby usunięcia lakieru:
- **Lutownica + dużo cyny** — gorąca lutownica spala lakier, cyna pokrywa drut
- **Papier ścierny** — mechanicznie zedrzeć
- **Plomierka, zapalniczka** — spalić (uważnie!)
- **Specjalny ścierający lakier** — chemicznie

Najlepiej w 2-3 cm od końca drutu. Sprawdź multimetrem ciągłość, gdy drut już z cyną — czy uzwojenie nieprzerwane.

### Lutowanie do terminali

Jeśli karkas ma piny / nóżki, **przylutuj koniec drutu**. Jeśli nie — wyprowadź drutem z izolacją silikonową (klasa H 180°C).

## Etap 6: Składanie pakietu

### Wprowadzanie blach E

1. **Wsuń pierwszą blachę "E"** w karkas.
2. **Następną z drugiej strony** — naprzemiennie.
3. Każda blacha ścisło dopasowana, blisko siebie.
4. Sprawdź czy karkas się nie wygina (siła boczna).

Dlaczego naprzemiennie: zmniejsza szczelinę powietrzną, zwiększa wykorzystanie rdzenia.

### Wprowadzanie blach I

Po włożeniu wszystkich "E" — dopasuj blachy "I" do "łapek E".

### Zaciskanie

Pakiet trzeba **mocno ścisnąć**:
- Śruby M3-M5 (zależnie od wielkości)
- Wstążki termoutwardzalne
- Imadło aplikujące siłę

Niedostatecznie ściśnięty pakiet **buczy** (magnetostriction). Mocno ściśnięty — milczy.

### Wyciszanie pakietu

Dodatkowo:
- Nasączyć lakierem izolacyjnym (impregnacyjnym)
- W cieple suszyć 1-2 godziny

## Etap 7: Testy

### Test 1: ciągłość

Multimetrem zmierz rezystancję każdego uzwojenia:
- Pierwotne: typowo 5-100 Ω (zależnie od mocy)
- Wtórne: 0,1-10 Ω

Brak ciągłości = przerwa. Zwarcie do żelaza (rdzenia) = przebicie izolacji.

### Test 2: zwarcie międzyzwojowe

Trudne do wykrycia multimetrem. Objawy:
- Niska rezystancja uzwojenia (sprzedaż się zmniejsza)
- Pod napięciem grzanie się rdzenia
- Niski transfer mocy na wtórnym

Profesjonalne testery: **Surge tester / Hipot tester**.

### Test 3: izolacja

Megger (omomierz wysokonapięciowy):
- Między uzwojeniami: > 100 MΩ przy 500 V DC
- Między uzwojeniami a rdzeniem: > 100 MΩ

### Test 4: pierwsze włączenie

**ZAWSZE z bezpiecznikiem i wolno!**

1. Bezpiecznik T 100 mA (lub odpowiedni do mocy).
2. Lampa szeregowa (np. 60 W żarówka jako "soft start").
3. Włącz na chwilę, dotknij — czy się grzeje?
4. Mierz wtórne — czy napięcia są zgodne z projektem?

Jeśli żarówka świeci jasno (= pełne 230 V) → zwarcie w pierwotnym lub silne sycenie. NIE włączaj na pełne napięcie.
Jeśli żarówka świeci słabo lub gaśnie → OK, idź dalej.

### Test 5: pełne obciążenie

Obciąż wtórne nominalnym prądem (np. rezystorem mocy lub regulowanym obciążeniem). Mierz:
- Napięcie wtórnego (czy spada do nominalnego?)
- Temperatura po godzinie (max 60-80°C dla klasy F)
- Sprawność (P_wy/P_we)

## Najczęstsze problemy i rozwiązania

### "Transformator buczy"

- Zbyt luźno skręcony pakiet → mocniej ścisnąć
- Wibracje mechaniczne → mocowanie na podstawce z piankami
- Magnesowanie zbyt blisko nasycenia → więcej zwojów

### "Transformator się grzeje, choć bez obciążenia"

- Zbyt mała ilość zwojów (B_max za wysokie)
- Zwarcie międzyzwojowe
- Pakiet z niewłaściwej blachy

### "Niewłaściwe napięcie wyjściowe"

- Zbyt mało/dużo zwojów wtórnego → policzyć ponownie, ewentualnie odkręcić kilka zwojów
- Zła kompensacja na obciążenie → pomiar z obciążeniem

### "Nagrzewa się drut, choć moc małą"

- Zbyt cienki drut (gęstość prądu za wysoka)
- Zwarcie międzyzwojowe

### "Iskra przy włączaniu"

- Inrush current (normalne)
- Lub: zwarcie pierwotnego z rdzeniem!

## Wskazówki praktyczne

### Liczenie zwojów

- Mechaniczny licznik zwojów to **must-have**. Zwykle obracasz korbą, on liczy obroty.
- Bez licznika można dwoma "klikaczami" lub aplikacją w telefonie z czujnikiem zbliżeniowym.
- Pamiętaj: każdy obrót karkasu = jeden zwój.

### Tempo nawijania

- Wolniej niż myślisz. Pośpiech = drut się krzyżuje, izolacja się zsuwa.
- Co kilka minut przerwa, oględziny.

### Bezpieczeństwo

- Drut emaliowany ostry — nie ciągnij ręką w dół.
- Mocne napięcie drutu = łatwo zdrapać izolację o krawędź karkasu.
- W razie potrzeby rękawiczki cienkie nylonowe.

### Wyższe szczeliny

Jeśli drut grubszy — niektóre miejsca karkasu mają **wcięcia/żebra** uniemożliwiające ścisłe nawinięcie. Trzeba "łamać" warstwy lub używać karkasu z większą szerokością.

## Przykład rzeczywisty: trafo 230 V → 12 V, 2 A

### Parametry obliczone

(z poprzedniego rozdziału)
- Rdzeń: EI54, pakiet 25 mm
- Pierwotne: 1534 zwoje, drut 0,2 mm
- Wtórne: 88 zwojów, drut 0,8 mm

### Procedura

1. **Karkas EI54** — plastikowy. Mocujemy na nawijarce.
2. **Pierwotne**: ~20 warstw drutu 0,2 mm. Po każdej warstwie kawałek presspanu.
3. **Izolacja po pierwotnym**: 3 warstwy Mylaru.
4. **Wtórne**: 88 zwojów drutu 0,8 mm, w 2 warstwach.
5. **Izolacja zewnętrzna**: 2 warstwy presspanu + taśma izolacyjna H.
6. **Składanie**: blachy EI54 przemiennie, pakiet 25 mm. Skręcić śrubami M4 ze wstążkami.
7. **Nasączenie**: lakier izolacyjny, sucha 2 h.
8. **Test**: 230 V przez żarówkę 60 W → na wtórnym 13,5 V bez obciążenia. Pod 2 A → 12,1 V. ✓

Czas: ok. 3-4 godziny pracy.

## Materiały na karbach (skoki napięcia)

Czasem nawijasz **odczepy** w środku uzwojenia:

1. W połowie potrzebnego zwoju **pętelka drutu** wyprowadzona przez karkas.
2. Kontynuuj nawijanie dalej.
3. Później do pętelki przylutujesz wyprowadzenie.

To pozwala mieć w wtórnym kilka napięć (np. 5 V, 9 V, 12 V) z jednego uzwojenia.

## Podsumowanie

Przewijanie transformatora to:
- **Cierpliwość** — kilka godzin pracy
- **Dokładność** — błąd 10 zwojów = błąd ~1,5%
- **Czystość** — brak zwarć, kurzu, naderwanej izolacji
- **Testy** — najpierw pomiary, potem włączenie z bezpiecznikami

Po nabyciu wprawy można nawijać złożone transformatory wielouzwojeniowe, transformatory toroidalne (z челноком), transformatory impulsowe na ferrytach. Klucz: zacząć od czegoś prostego (EI42, EI54) i nabywać doświadczenie.
