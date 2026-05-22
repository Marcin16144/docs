# 07-03: Lutowanie

## Czym jest lutowanie

Łączenie elementów elektronicznych za pomocą stopu metali (cyny) topiącego się w niskiej temperaturze (180-220°C). Stop "klei" elementy mechanicznie i elektrycznie.

## Cyna lutownicza

### Typowe stopy

| Stop | Skład | T topnienia | Zastosowanie |
|------|-------|-------------|--------------|
| Sn63/Pb37 | 63% Sn + 37% Pb | 183°C | klasyczna, eutektyczna |
| Sn60/Pb40 | 60% Sn + 40% Pb | 183-188°C | starsza, podobne właściwości |
| Sn99,3/Cu0,7 | 99,3% Sn + 0,7% Cu | 227°C | bezołowiowa, RoHS |
| Sn96,5/Ag3,0/Cu0,5 (SAC305) | jw. + srebro | 217-220°C | bezołowiowa premium |
| Sn50/Pb32/Cd18 | z kadmem | 145°C | niskotopliwa (toksyczna!) |
| Bi/Sn (50/50) | 138°C | naprawa wrażliwych elementów |

### Z ołowiem vs bezołowiowa

**Z ołowiem (leaded, Sn63/Pb37):**
- + Łatwiejsza w lutowaniu (eutektyczna, ostre przejście fazowe)
- + Lepsza zwilżalność
- + Tańsza
- − Toksyczna, zakazana w produkcji komercyjnej (RoHS 2006)

**Bezołowiowa (lead-free, RoHS):**
- + Bezpieczna dla środowiska
- + Standard w handlu (UE, USA)
- − Wyższa temperatura topnienia (+30°C)
- − Trudniejsza, "matowe" łączenie
- − Tin whisker (powstawanie mikroskopijnych nitek cyny)

W hobby (DIY) ołowiowa wciąż dozwolona, łatwiejsza do nauki.

### Grubość drutu

| Średnica | Zastosowanie |
|----------|--------------|
| 0,3-0,4 mm | precyzyjne SMD, BGA |
| 0,5-0,7 mm | standard, większość lutowania |
| 0,8-1,0 mm | THT, gruba elektronika |
| 1,5-2,0 mm | duże połączenia, np. masy mocy |
| 2-3 mm | spawanie blach, bardzo grube przewody |

### Topnik (flux)

W cynie jest **rdzeń topnika** — substancja czyszcząca cyną i ułatwiająca zwilżenie. Po włączeniu lutownicy topnik się rozkłada, czyści powierzchnię miedzi.

Typy:
- **Kalafonia (rosin)** — żywica naturalna, klasyczna, niskoaktywna
- **No-clean** — nie wymaga zmywania resztek
- **Aktywna kwasowa** — silna, ale wymaga zmywania (do trudnych powierzchni)

Dodatkowy topnik w pojemniczku/żelu pomaga przy SMD i naprawach.

## Lutownice

### Lutownica oporowa

Klasyka. Element grzejny + grot. Bez regulacji temperatury (lub prosta).

15-60 W mocy. Do podstawowego lutowania.

### Stacja lutownicza (kolbowa)

Stacja + lutownica z regulacją temperatury. **Standard współczesny.**

Cechy:
- Regulacja 150-450°C
- Wyświetlacz
- Wymienne groty
- Stabilizacja temperatury

Modele:
- **Hakko FX-888D** — klasyk, ~500-800 zł
- **JBC CD-2BE** — premium, ~3000 zł
- **Weller WE1010** — solidna
- **Aoyue, Quick** — tańsze alternatywy

### Stacja gorącego powietrza (hot air)

Wymagana dla SMD, BGA. Dmuchawa + grzałka, 100-450°C, regulowany przepływ.

Modele: 858D (~250 zł), Quick 861DW (premium).

### Stacja BGA / hot plate

Profesjonalne — do reballingu BGA, lutowania całych PCB.

### Lutownice gazowe

Bez kabla, palnik gazowy. Mobilne, ale temperatura trudna do regulacji.

## Groty (tips)

Najczęstsze kształty:

| Kształt | Zastosowanie |
|---------|--------------|
| Stożkowy (B) | uniwersalny, drobne lutowanie |
| Ścinany / dłutkowy (D, BC) | większe powierzchnie, masa |
| Mikro-rouletka (BC, BCM) | przeciąganie cyny |
| Wachlarz / hoof (CC) | drag soldering SMD |
| Mini-stożek (I, T-I) | bardzo małe elementy |

Po godzinach pracy grot się utlenia / zużywa — wymień. Trzymaj zawsze **w cynie** dla ochrony.

## Temperatura lutowania

Ogólna reguła: **temperatura grotu = T_topnienia cyny + 100°C**.

| Cyna | T_grotu |
|------|---------|
| Sn63/Pb37 | 320-360°C |
| Sn99/Cu | 360-410°C |

Wyższa temperatura = szybsze lutowanie, ale **niszczy elementy i PCB**. Trzymaj zawsze najniższą działającą.

## Lutowanie THT (Through Hole)

### Procedura

1. **Wsuń element** w otwory PCB.
2. **Wygnij wyprowadzenia** lekko, by element nie wypadł.
3. **Podgrzej** połączenie (pad + wyprowadzenie) grotem od strony lutowanej — **2-3 sekundy**.
4. **Dodaj cynę** od strony przeciwnej (nie na grocie!). Cyna rozpływa się przez kapilarność.
5. **Wyjmij cynę** ↗
6. **Wyjmij grot** ↗
7. **Studzenie** — element ostygnie w 1-2 sekundy.
8. **Odetnij nadmiar wyprowadzenia** cążkami (jeśli był długi).

### Dobre lutowanie

- **Błyszczące** (matowe = "zimne" lutowanie = źle)
- **Wklęsłe** (parametr cyny od pada do nóżki, gradient)
- **Bez ostrych szczytów** (kuleczki cyny = za mało topnika lub zła technika)
- **Pad jest pokryty** cyną w 100%

### Złe lutowanie

- "Zimne" — szare, matowe, ziarniste → przegrzane lub niedogrzane
- "Kulka cyny" na wyprowadzeniu zamiast pełnego pokrycia padu
- "Mostek" — cyna łączy dwie sąsiednie ścieżki = zwarcie
- "Brak cyny" — wyprowadzenie wygląda jak suche
- "Dziurka" w cyme — może wskazywać na słabe połączenie

## Lutowanie SMD

### Pinpoint / one-by-one

Mała ilość cyny, jeden pin na raz.

### Drag soldering

Dla układów wielonóżkowych (SOIC, TQFP). Pokrycie cyny na grocie, "pociągnięcie" wzdłuż rzędu pinów. Topnik kasuje nadmiar.

Procedura:
1. Wstępne lutowanie **dwóch przeciwległych narożników** (pozycjonowanie).
2. Sprawdzenie prawidłowego ustawienia (lupą).
3. Topnik na rzędu pinów (no-clean lub żelowy).
4. Grot dłutkowy z cyną → przeciągnij wzdłuż pinów.
5. Topnik "zbiera" cyną, każdy pin pokryty.

### Hot air (SMD)

Dla większych komponentów (BGA, QFN, DRP) lub przy zmianie elementów.

1. **Nanieś topnik / pastę lutowniczą** na pady.
2. **Ułóż element**.
3. **Dmuchaj gorącym powietrzem** (300-380°C) z odległości 2-3 cm, aż cyna się rozpłynie.
4. **Stop** — odpust od razu, by element nie zsunął się.

Element "wpadnie" we właściwą pozycję dzięki napięciu powierzchniowemu cyny.

### Reflow oven

Dla większej liczby PCB. Pasta lutownicza na padach, ułożenie elementów, profil temperaturowy w piecu:

```
T
↑
       ───┐
      /   \   peak (ok. 260°C)
     /     \
    /       \
   /         \
  / preheat   \
 /             \
   T
```

Profile: preheat (60-90 s w 150°C), reflow (peak 220-250°C), cooling. Dla cyny ołowiowej peak ~220°C, bezołowiowej ~245°C.

## Rozlutowywanie

### Cynowa pleciona taśma (desoldering wick)

Pleciona miedź ze topnikiem. Przyłożyć do cyny + grot z góry → kapilarność wysysa cynę w taśmę.

Stosowane: usunięcie cyny z mostków, otworów po wyciagnięciu elementu, padów SMD.

### Pompka próżniowa (solder sucker)

Mechaniczna pompka. Podgrzewasz lut, naciskasz spust → wciąga cynę.

Stosowane: usuwanie elementów THT z wieloma pinami.

### Stacja rozlutowująca

Lutownica + odsysanie próżniowe. Najszybsze, profesjonalne. Modele JBC, Hakko 808.

### Hot air do SMD

Podgrzewasz cały element, podnosisz pęsetą. Dla układów z wieloma nogami.

### Heat plate

Płyta grzewcza pod PCB. Razem z hot air ułatwia BGA.

## Wskazówki ogólne

### Czyść grot

Mokra gąbka, mosiężny czyściciel, ścierka czyszcząca. Cyna gromadzi się w czarne grudki — zmniejsz przewodność cieplną.

### "Cynuj" elementy przed lutowaniem

Drut wcześniej "ocynnowany" lutuje się 10× łatwiej. Powiódź cyną po przewodzie, lekkie ślad.

### Lutuj na "podstawce"

Nie trzymaj PCB w rękach. Trzeci ręka, helping hands, imadło PCB.

### Wentylacja

Cyna ołowiowa wydziela opary toksyczne. Wentyluj pomieszczenie lub używaj wentylacji nadstanowiskowej (filtr z węglem aktywnym).

### Higiena

Po lutowaniu (zwłaszcza z ołowiem) **myj ręce**. Nie jedz w warsztacie.

## Typowe defekty i naprawa

### Mostek cyny

Topnik + grot dłutkowy = wyciąga nadmiar. Lub taśma rozlutowująca.

### Niedolutowane wyprowadzenie

Dodaj odrobinę topnika, podgrzej + cyna.

### "Cold solder"

Przegrzej i dodaj odrobinę cyny.

### Spalony pad

Czasem zostaje samej ścieżki — wlótuj nową cynę, czasem trzeba **mostkować** ścieżką drutu do najbliższego via lub elementu.

### Zniszczony PCB

Większe szkody — zmiana na nowe PCB. Naprawa złamanej ścieżki: drut srebrny + przezroczysty lakier UV.

## Bezpieczeństwo

### Oparzenia

Grot ~360°C. Nigdy nie testuj palcem. Trzymaj zawsze lutownicę w stojaku.

### Pożar

Cyna jest zimną stopem, ale topnik i izolacje są palne. Nie zostawiaj rozgrzanej lutownicy bez nadzoru.

### Ołów

Nie wkładaj cyny do ust (niektórzy "zwilżają" — błąd). Po pracy umyj ręce.

### Wzrok

Cyna może "pryskać" przy nagrzewaniu (woda + topnik). Okulary ochronne, zwłaszcza przy gorącym powietrzu.

### Statyka (ESD)

CMOS, MOSFETy → wrażliwe. Opaska antystatyczna, mata uziemiona. Lutownica też uziemiona przez kabel.

## Wskazówki dla początkujących

1. **Zacznij od dużych elementów** (rezystory THT, kondensatory).
2. **Trenuj na płytce uniwersalnej** — bez ryzyka zniszczenia projektu.
3. **Używaj świeżej cyny** (stary drut może mieć utlenioną cyne).
4. **Lutuj w jasnym świetle**, najlepiej z lupą / mikroskopem.
5. **Nie spiesz się** — pośpiech daje zimne lutowanie.
6. **Sprawdzaj po każdym** połączeniu (mostek? cold solder?).
7. **Patrz pod kątem** — czasem widać "wzgórek" cyny, który nie dotyka pada.

## Polecane zestawy startowe

### DIY (200-500 zł)

- Stacja lutownicza Aoyue 469 lub Yihua 936
- Cyna Sn60/Pb40 0,5 mm
- Topnik żelowy
- Pęseta antystatyczna
- Taśma rozlutowująca
- Pompka
- Maty antystatyczne
- Lupa / okulary z lupą

### Hobby+ (500-2000 zł)

- Hakko FX-888D
- Stacja hot air (858D)
- Mikroskop USB lub stereoskopowy
- Liczne groty (B, D, BCM)
- Cyna SAC305 i Sn63/Pb37 (do wyboru)
- Topniki: kalafonia + no-clean

### Profesjonalny (5000+ zł)

- JBC CD-2BE
- Quick 861DW (hot air)
- Mikroskop AmScope
- Reflow oven (T962A)
- Pełen zestaw narzędzi rework

## Częste błędy

1. **Za wysoka temperatura** — niszczy elementy i PCB.
2. **Zbyt długie podgrzewanie** — odlatują pady.
3. **Cyna bezpośrednio na grot** zamiast na pad — zła zwilżalność.
4. **Brak topnika** — matowe, "zimne" lutowanie.
5. **Brudny grot** — słaba transfer ciepła.
6. **Nieumocowane elementy** — krzywe lutowanie.
7. **Lutowanie SMD bez topnika** w hot air — kuleczki, brak adhezji.
8. **Cyna ołowiowa + bezołowiowa w jednym lutowaniu** — gorsze parametry stopu mieszanego.
