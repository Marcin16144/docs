# Biometria — odcisk i twarz

## Czym jest biometria w KD

Biometria opiera się na **unikalnych cechach fizycznych lub behawioralnych** człowieka. W kontroli dostępu najpopularniejsze:

- **odcisk palca** — najtańsza, najbardziej dojrzała,
- **geometria/rozpoznawanie twarzy** — popularne od 2020 (bezdotykowe — covid),
- **tęczówka oka** — wysokie bezpieczeństwo, drogie (banki, lotniska),
- **żyły palca / dłoni** — bardzo bezpieczne (wzór wewnątrz ciała), Hitachi VeinID, Fujitsu PalmSecure,
- **głos** — call centers, rzadko w fizycznym KD.

## Czytniki linii papilarnych — technologie

### Optyczne

Najstarsza technologia — szklana płytka z oświetleniem LED. Sensor CMOS rejestruje obraz palca. Cechy:

- tanie (od 80 zł za moduł na ZK Software FR1200),
- łatwo oszukane atrapą papierową lub fotografią palca,
- wrażliwe na zabrudzenia płytki, kondensację,
- nie radzą sobie z suchymi/mokrymi/uszkodzonymi palcami.

### Pojemnościowe

Standard w nowoczesnych czytnikach. Matryca tysięcy mikropłytek pojemnościowych mierzy odległość każdej do skóry — odwzorowuje wzgórki i doliny linii papilarnych.

- wysoka rozdzielczość (500 dpi standardowo, 1000+ dpi w premium),
- trudniej oszukać (nie reaguje na zdjęcie),
- standard: **FBI Certified PIV/MOC**, ANSI INCITS 378,
- marki: Suprema BioMini Plus 2, DataMaster MFP-2000, ZKTeco SLK20R, Hikvision DS-K1F800,
- cena 200–800 zł moduł.

### Ultradźwiękowe

Najnowsze (Qualcomm 3D Sonic) — fala ultradźwiękowa odbija się od skóry, mierzy także podpowierzchniowe szczegóły (np. naczynka krwionośne).

- nie wrażliwa na zabrudzenia powierzchni,
- działa przez szybkę / szkło / metal,
- bardzo trudna do oszukania (anti-spoof natywny — sprawdza tkanki w głębi),
- droższa, głównie smartfony (Samsung S10–S25, Xiaomi premium); w fizycznym KD na razie rzadko.

## Parametry — FAR i FRR

Każdy system biometryczny opisują dwa kluczowe wskaźniki:

| Skrót | Nazwa | Znaczenie |
|---|---|---|
| **FAR** | False Acceptance Rate | % przypadków, gdy obca osoba zostaje wpuszczona |
| **FRR** | False Rejection Rate | % przypadków, gdy uprawniona osoba odrzucona |
| EER | Equal Error Rate | punkt, gdzie FAR = FRR (najlepszy kompromis) |
| FTE | Failure To Enroll | % osób, których nie udaje się zarejestrować |

Typowe wartości dobrego czytnika odcisku:

- **FAR < 0,001 %** (1 na 100 000) — wystarczająco bezpiecznie dla biur,
- **FRR < 1 %** — użytkownik średnio raz na 100 prób musi powtórzyć,
- FTE < 1 % — większość osób da się zarejestrować, problemy z pracownikami fizycznymi (zniszczone opuszki).

Próg czułości jest regulowany. **Im niższy FAR, tym wyższy FRR** — kompromis bezpieczeństwo vs wygoda.

## Anti-spoof / liveness detection

Mechanizmy weryfikacji „żywego palca":

- pomiar temperatury skóry (35–37 °C),
- pomiar wilgotności,
- detekcja pulsu (rezystancja zmienia się w rytm pulsu),
- oświetlenie wielu długości fal — naskórek vs głębsze warstwy (multispektralne),
- analiza tekstury 3D w ultradźwiękowych,
- certyfikat **PAD (Presentation Attack Detection)** — ISO 30107.

> **Ataki:** klasyczne odciski papierowe / silikonowe potrafią oszukać proste czytniki optyczne. Niektóre tańsze pojemnościowe też. Wymóg dla obiektów wysokiego ryzyka: anti-spoof **ISO 30107-3 level B** lub wyższy.

## Rozpoznawanie twarzy

### 2D vs 3D

| Typ | Sensor | Anti-spoof | Przykład |
|---|---|---|---|
| **2D** | kamera RGB | słabe (oszukane zdjęciem na ekranie) | Hikvision DS-K1T341AMF (z opcją) |
| **2D + IR** | kamera RGB + podczerwień | średnie (wykrywa ekran) | ZKTeco SpeedFace M5 |
| **3D (Structured Light)** | projektor + kamera IR (jak FaceID iPhone) | wysokie | Hikvision DS-K1T672, Anviz FaceDeep |
| **3D (ToF)** | Time-of-Flight kamera | wysokie | Suprema FaceStation F2 |

### Algorytmy

Klasyczne (do 2015): geometria twarzy, Eigenfaces (PCA), Fisherfaces. Niska skuteczność (~95 %).

Nowe (deep learning, od 2015):

- **FaceNet (Google)** — 99,6 % na LFW benchmark,
- **ArcFace, CosFace** — open-source, używane w większości czytników chińskich,
- czytniki **NIST FRVT** rankingu klasy A — > 99,9 % przy 1:1.

### Modele w KD

- **Hikvision DS-K1T673DWX** — 2D+IR, ~2500 zł, baza 50 000 twarzy, mask detection,
- **Hikvision DS-K1T672M** — twarz + Mifare, IK10,
- **ZKTeco SpeedFace V5L** — 2D, baza 30 000, ~1800 zł,
- **Suprema FaceStation F2** — 3D ToF, najwyższa klasa, ~9000 zł, baza 100 000,
- **Anviz FaceDeep 5** — 3D structured light, ~5000 zł,
- **DAHUA ASI7XXX** — 2D+IR, podobny do Hikvision.

## RODO i biometria

> **Dane biometryczne (odcisk palca, twarz, tęczówka) to dane szczególnej kategorii** wg art. 9 RODO. Domyślnie ich przetwarzanie jest **ZABRONIONE**, chyba że spełniono jeden z wyjątków.

### Podstawy prawne dla biometrii w KD

- **zgoda wyraźna** osoby (art. 9 ust. 2 lit. a) — w praktyce dla pracowników kontrowersyjna (relacja zależności),
- **obowiązek prawny** (lit. b) — np. dostęp do informacji niejawnych klauzuli „tajne" → wymóg ustawowy,
- **ochrona żywotnych interesów** (lit. c) — rzadko stosowane,
- **znaczący interes publiczny** (lit. g) — np. lotniska, infrastruktura krytyczna.

### Wymogi dla wdrożenia

1. **DPIA** (Data Protection Impact Assessment) — obowiązkowa ocena skutków, przed wdrożeniem,
2. informacja dla pracowników (art. 13 RODO) — kto przetwarza, jakie dane, jak długo, kto ma dostęp,
3. **alternatywa** dla pracownika niechcącego biometrii — karta + PIN,
4. minimalizacja danych — nie przechowywać zdjęcia twarzy, tylko *template* (kod matematyczny),
5. szyfrowanie szablonów (AES-256),
6. retencja: **natychmiast po ustaniu stosunku pracy** usunąć,
7. wpis do *rejestru czynności przetwarzania*.

### Wyrok PUODO 2020 (przedszkole)

Polski organ nadzorczy ukarał przedszkole 250 000 zł za zbieranie odcisków palców dzieci do liczenia posiłków. Wyrok: brak proporcjonalności (cel można osiągnąć kartą). Wnioskiem dla projektantów: **biometrii nie wolno stosować dla wygody, tylko gdy jest naprawdę niezbędna**.

## Multimodalne (multi-biometric)

Łączenie kilku cech biometrycznych — np. odcisk + twarz, lub karta + twarz. Wyższa pewność identyfikacji:

- FAR jednego modułu 0,001 % × FAR drugiego 0,001 % = wspólnie 10⁻⁸ (praktycznie niemożliwe oszustwo),
- kompensacja awarii: nie udaje się odcisk (suche dłonie) → twarz,
- 2FA: karta + biometria (najpopularniejsze w bankach i instytucjach państwowych).

## Architektury — gdzie przechowywany jest szablon

- **na kontrolerze / serwerze (1:N)** — czytnik wysyła zarejestrowany odcisk do bazy centralnej, ta porównuje z wszystkimi → identyfikacja,
- **na karcie (Match-on-Card, MoC)** — szablon zapisany na karcie Mifare DESFire, czytnik porównuje odcisk z szablonem na karcie. **RODO-friendly** (dane biometryczne nie wychodzą poza kartę),
- **na sensorze (Match-in-Sensor)** — najnowsze, cały dialog na sensorze, na zewnątrz wychodzi tylko OK/NIE-OK.

Architektura **Match-on-Card** to obecnie najbezpieczniejsza i najbardziej zgodna z RODO opcja — dane biometryczne nie są przechowywane centralnie, użytkownik zachowuje kontrolę.

## Co dalej

➡ [Elektrozaczepy](12-03-elektrozaczepy.md)
