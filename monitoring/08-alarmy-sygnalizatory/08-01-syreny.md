# Syreny wewnętrzne i zewnętrzne

> Sygnalizatory akustyczne i optyczne — fizyczne wezwanie pomocy i odstraszenie intruza. Bez syreny działającej nawet po przecięciu zasilania, alarm jest niewidoczny.

## Po co głośna syrena?

Syrena pełni trzy funkcje równocześnie:

- **Odstraszanie intruza** — psychologia: hałas + lampa strobo > 100 dB obraca każdego niedoświadczonego włamywacza w panikę, większość kradzieży trwa < 8 minut, syrena skraca ten czas o połowę
- **Informacja dla sąsiadów** — alarm zwraca uwagę otoczenia (potencjalni świadkowie)
- **Sygnalizacja dla agencji ochrony** — patrol wracający na obiekt namierza alarm po dźwięku

## Parametry akustyczne — SPL i dB(A)

**SPL** (Sound Pressure Level) jest podawane w decybelach mierzonych w odległości 1 m od źródła. Wartości typowe:

| Klasa syreny | SPL @1 m | Zasięg słyszalny |
|---|---|---|
| Wewnętrzna mała (piezzo) | 95–105 dB | cały dom 100–200 m² |
| Wewnętrzna pełna | 105–115 dB | cała kamienica, kondygnacja biurowa |
| Zewnętrzna standardowa | 110–115 dB | 50–80 m otwartej przestrzeni |
| Zewnętrzna „wielka" | 118–124 dB | do 150 m, słyszalna w pełni z drugiej strony ulicy |
| Przemysłowa (Klaxon) | 120–135 dB | halę produkcyjną, parking |

Skala dB jest logarytmiczna — wzrost o **10 dB to 10× większa moc akustyczna** i ok. 2× głośność wrażenia subiektywnego. Syrena 115 dB to nie „trochę głośniej" niż 105 dB, tylko dziesięć razy więcej energii.

## Konstrukcja syreny — wewnątrz

Typowa syrena alarmowa zewnętrzna zawiera:

- **Membrana piezoelektryczna lub głośnik dynamiczny** — źródło dźwięku
- **Generator akustyczny** — moduł elektroniczny modulujący ton (najczęściej 2–4 brzmienia: pożar, włamanie, pomoc medyczna)
- **Akumulator buforowy** 12 V / 1,2–7 Ah — autonomia po sabotażu kabla
- **Ładowarka** akumulatora z linii centrali
- **Mikroswitch tamper** — wykrycie odkręcenia obudowy
- **LED stroboskopowe** — najczęściej żółte/czerwone/niebieskie, błyski 1–2 Hz
- **Obudowa** z poliwęglanu lub blachy, IP54–IP65, antywandalowa

### Schemat podłączenia syreny zewnętrznej (4-żyłowej + tamper)

```
SAB    ─── styk sabotażu obudowy (linia 24h centrali)
+12V   ─── stałe zasilanie/ładowanie z PSAC
GND    ─── masa
+IN    ─── wejście wyzwalające „głośnik" (zasilenie 12V = sygnał wł.)
+STR   ─── wejście wyzwalające „strobo" (osobne — strobo może pulsować dłużej)
        opcjonalnie:
CTRL   ─── modyfikator dźwięku (włamanie / pożar / napad)
KILL   ─── komenda „wyłącz" z centrali (przerywa odliczanie autonomii)
```

## Akumulator wsparcia — niezbędny w syrenie zewnętrznej

Klasyczny atak: intruz wchodzi na obiekt, natychmiast tnie kabel zasilania od syreny. Bez akumulatora — syrena milczy. Dlatego norma **PN-EN 50131-4** wymaga w klasie Grade 2+ **autonomii minimum 30 minut**, w Grade 3 — 60 minut.

| Wymóg | Grade 2 | Grade 3 | Grade 4 |
|---|---|---|---|
| Autonomia akustyczna po sabotażu | 30 min | 60 min | 90 min |
| Autonomia stroboskopu | nie wymaga | do wyładowania (godziny) | jw. |
| Sygnalizacja niskiego stanu akumulatora | tak | tak | tak |
| Sabotaż obudowy | tak | tak + odporność wandalowa | tak + IK10 |

Akumulator syreny ma żywotność 3–5 lat — po tym okresie pojemność spada poniżej 50% i autonomia jest fikcją. **Wymiana co 4 lata** niezależnie od pozornego „dobrego stanu". Akumulator Yuasa NP1.2-12 (1,2 Ah) — ok. 40 PLN.

## Popularne modele

### Syreny zewnętrzne Satel

| Model | SPL | Akumulator | Funkcje |
|---|---|---|---|
| **SPL-2010 R/BL** | 117 dB | 2,2 Ah, autonomia 30 min | strobo czerwone/niebieskie, sabotaż 4-stopniowy |
| **SPLZ-1011 BL** | 115 dB | 1,2 Ah | 2-tonowa, strobo |
| **SP-500** | 120 dB | 2,2 Ah, akustyczna 30 min | 5 tonów, strobo LED, Grade 3 |
| **SP-4001 R** | 108 dB | 1,2 Ah | kompaktowa, gospodarcza |

### Syreny wewnętrzne

| Model | SPL | Cechy |
|---|---|---|
| Satel SPW-100 | 105 dB | piezo, podtynkowa, dyskretna |
| Satel SPW-210 | 110 dB | wbudowane LED strobo |
| DSC LC-105 | 106 dB | klasyk, montaż dowolny |
| Optex SAS-90 | 90 dB | do dyskretnego użytku (recepcje) |

### Syreny dla agencji / Grade 3+

| Model | Klasa | Cena |
|---|---|---|
| Texecom Premier Elite Odyssey 3E | Grade 3 | 800 PLN |
| Pyronix Deltabell Plus | Grade 3, akustyczna 90 min | 700 PLN |
| Honeywell SD7 | Grade 3 | 900 PLN |

## Lampy stroboskopowe — sygnalizacja optyczna

Strobo (xenon w starszych, LED w nowych) służy do **identyfikacji obiektu** w nocy z odległości — patrol agencji lub policja widzą migający światło i wiedzą, że to ten dom.

- **Kolor**: czerwony (klasyczny), niebieski (od kilku lat moda), żółty (przemysł), pomarańczowy (pożar)
- **Częstotliwość**: 1–2 Hz (standard PN-EN 54-23 dla sygnalizatorów świetlnych ppoż.)
- **LED vs xenon**: LED — niski pobór (50–200 mA), długa żywotność, mniej intensywne błyski; xenon — bardzo jasne błyski, krótsza żywotność, większy pobór
- w wielu modelach strobo działa **znacznie dłużej** niż akustyk po sabotażu (bo pobór jest mniejszy)

Lampa stroboskopowa zostaje włączona **i nie wyłącza się po cichu** po incydencie — pokazuje patrolowi obiekt, na którym był alarm, do czasu reset centrali z klawiatury. To celowe rozwiązanie.

## Sabotaż obudowy — 4-stopniowy

Norma EN 50131 wymaga wykrywania manipulacji obudową syreny na czterech poziomach (Grade 3):

1. **Odkręcenie obudowy** — mikroswitch styk
2. **Odłączenie od ściany** — drugi mikroswitch dolny
3. **Przecięcie kabla** — utrata komunikacji z centralą = autonomia + sygnalizacja
4. **Zwarcie linii sterującej** — centrala wykrywa zmianę rezystancji EOL

## Sterowanie dwóch wyjść — głośnik vs strobo

Większość syren ma **osobne wejścia** dla akustyki i stroboskopu — pozwala to centrali wyłączyć dźwięk po np. 3 minutach (zgodnie z prawem), ale zostawić migające strobo do reset.

| Wyjście centrali | Sygnał | Typowy czas aktywności |
|---|---|---|
| SIREN (OUT 1) | akustyka | 1–3 min (zgodność z prawem o hałasie) |
| STROBE (OUT 2) | lampa | do ręcznego reset (15+ min) |
| PIEZO (OUT 3) | buzzer klawiatury | entry/exit delay |

Polski **Kodeks Wykroczeń (art. 51 § 1)** oraz przepisy gminne mogą karać uporczywe alarmy dźwiękowe. Praktyka: 3 min akustyki, dalej tylko strobo. Centrale Satel/DSC mają to fabrycznie skonfigurowane.

## Sygnalizator akustyczno-optyczny do wnętrza obiektu

Czasem stosuje się **wewnętrzną dyskretną „brzęczyk + LED"** u góry ściany — sygnalizuje stan uzbrojenia (jeden ton, jeden błysk co 5 s) lub problemy techniczne (low battery, wybór strefy). Nie zastępuje to syreny alarmowej.

## Co dalej

➡ [Moduły komunikacji GSM, IP, dual-path](08-02-modul-gsm-ip.md)
