# Czujki dymowe

## Co wykrywa czujka dymu

Czujka dymu reaguje na **cząstki stałe i aerozole spalania** obecne w powietrzu wnikającym do komory pomiarowej. W zależności od fazy pożaru cząstki te mają różny rozmiar:

- **pożar bezpłomieniowy** (tlenie, np. izolacja kabla, materace) — duże cząstki 1–10 µm, ciemny gęsty dym → optyczna,
- **pożar płomieniowy** (np. benzyna, alkohol) — drobne cząstki <0,1 µm, mało dymu → jonizacyjna (historycznie),
- **pożar w fazie zarodkowej** (przegrzewająca się elektronika) — bardzo niskie stężenia → aspiracyjna VESDA.

Norma odniesienia: **PN-EN 54-7** (czujki punktowe działające na zasadzie rozproszonego światła, światła przechodzącego lub jonizacji) oraz **PN-EN 54-12** (czujki liniowe), **PN-EN 54-20** (aspiracyjne).

## Czujka optyczna (fotoelektryczna)

Najpopularniejszy typ w 2026 — praktycznie standard w nowych instalacjach.

**Zasada działania:** w komorze labiryntowej (czarnej, chroniącej przed światłem zewnętrznym) znajduje się dioda LED IR i fototranzystor pod kątem ~135°. W czystym powietrzu fototranzystor nic nie widzi. Cząstki dymu rozpraszają światło (**efekt Tyndalla**) — fototranzystor wykrywa rozproszone fotony.

**Mocne strony:**

- doskonała czułość na **dymy gęste z palenia tworzyw sztucznych** (PVC, poliuretan z kanap), drewna, papieru,
- brak źródeł promieniotwórczych — bezpieczna utylizacja,
- komora opracowana tak, by tolerować kurz codzienny (algorytmy kompensacji starzenia).

**Słabe strony:**

- słabsza reakcja na czyste paliwa (etanol, niektóre rozpuszczalniki) — pożar płomieniowy bez dymu,
- wrażliwa na **parę wodną, mgły, kurz budowlany** (fałszywe alarmy w łazience, kuchni z gotującą się wodą).

**Przykłady:** Polon-Alfa DOR-4046 (adresowalna w systemie POLON 6000), Polon-Alfa DUR-4047 (z czujnikiem ciepła — multisensor), Bosch FAP-425-O, Hochiki ALK-E, Schrack OOH740.

## Czujka jonizacyjna

> **Status prawny:** w Unii Europejskiej **od 2014 r. zakazane jest wprowadzanie do obrotu** nowych czujek z izotopem americu-241 (Am-241, źródło promieniotwórcze). Istniejące w obiektach mogą pracować do końca okresu eksploatacji, ale po awarii nie wolno ich wymienić na taki sam typ — stosujemy optyczne.

Zasada działania (historycznie): komora jonizacyjna z miniaturowym źródłem α-promieniotwórczym (Am-241, ~30 kBq) jonizuje powietrze, między elektrodami płynie mikroprąd jonowy. Cząstki dymu (nawet bardzo małe, niewidoczne) wiążą jony — prąd spada → alarm.

Były bardzo skuteczne na pożary płomieniowe (czyste paliwa). Wycofane ze względu na problemy z utylizacją izotopu i konieczność dokumentacji zgodnej z prawem atomowym.

## Czujka liniowa (bariera dymowa)

Konstrukcja: **nadajnik IR** z jednej strony + **odbiornik z reflektorem** (lub samodzielny odbiornik) po drugiej stronie chronionej przestrzeni.

| Parametr | Typowa wartość |
|---|---|
| Zasięg | 5–100 m (niektóre do 160 m) |
| Wykrywany sygnał | tłumienie wiązki o 30–60 % (próg programowany) |
| Pole chronione | do 7,5 m po obu stronach osi wiązki (PN-EN 54-12) |
| Czas autotestu | co 24 h kompensacja zabrudzeń |

**Zastosowania:** hale przemysłowe i magazynowe, kościoły, dworce, hangary, atrium, korytarze galerii handlowych — wszędzie, gdzie czujka punktowa nie zadziała szybko z powodu wysokości lub gdzie potrzebna jest minimalna liczba urządzeń.

**Przykłady:** Bosch FCI-320, Hochiki FIRElink, ESSER OTI series, Polon-Alfa DOL-4001.

Liniowe oszczędzają budżet — jedna bariera 100 m × 15 m = 1500 m² pokrycia, podczas gdy czujek punktowych potrzeba kilkudziesięciu.

## Czujka aspiracyjna (VESDA)

System najwyższej klasy czułości — najczęściej znany pod marką **VESDA** (Honeywell-Xtralis), choć są też ICAM, FAAST (Honeywell), Bosch Avenar Aspirate.

**Zasada działania:**

1. rurki PCV/ABS z otworami zasysającymi (Ø 2–4 mm) rozprowadzone po chronionym pomieszczeniu,
2. jednostka centralna z wentylatorem stale zasysa próbki powietrza,
3. powietrze trafia do detektora laserowego (chmura cząstek → rozpraszanie światła),
4. wykrycie nawet **0,005 %/m** tłumienia (znacznie więcej niż czujka punktowa, której próg to 5 %/m).

**Klasy czułości wg PN-EN 54-20:**

- klasa **A** (very high) — <0,5 %/m → serwerownie, centra danych, muzea,
- klasa **B** (enhanced) — 0,5–2 %/m → magazyny, archiwa,
- klasa **C** (normal) — 2–10 %/m → odpowiednik czujki punktowej.

**Typowe zastosowania:** serwerownie (chłodzone 18–22 °C, niski przepływ powietrza utrudnia osiągnięcie dymu czujką sufitową), magazyny wysokiego składowania, czyste pokoje, sale operacyjne, podlogi techniczne, sufity podwieszane.

## Porównanie typów

| Typ | Czas detekcji | Wykrywa | Cena (przybl.) | Zastosowanie |
|---|---|---|---|---|
| Optyczna punktowa | 1–5 min | dymy gęste, tlenie | 60–200 zł | biura, mieszkania, korytarze |
| Jonizacyjna | 1–3 min | czyste płomienie | — | (wycofana w UE) |
| Multisensor (O+T) | 30–60 s | dymy + skoki temp. | 150–400 zł | obiekty o zwiększonym ryzyku |
| Liniowa | 1–3 min | dym w długiej osi | 2 500–6 000 zł | hale, kościoły, dworce |
| Aspiracyjna VESDA | 10–60 s (faza zarodkowa) | mikrocząstki, przegrzanie | 10 000–80 000 zł | serwerownie, archiwa, muzea |

## Zasady doboru i montażu (skrót)

Wg **PN-EN 54-14** (zalecenia projektowania) i polskich przepisów ppoż:

- max powierzchnia chroniona jedną czujką punktową: **~80 m²** (sufit do 6 m), zmniejsza się przy wyższych sufitach,
- odległość od ściany min. **0,5 m**, od kratki nawiewu min. **1 m**,
- na suficie skośnym czujka w najwyższym punkcie,
- w mieszkaniach (przepisy zalecane, nie obligatoryjne dla istniejących) — czujka na suficie korytarza i sypialni,
- w obiektach z obowiązkiem SAP (hotele, szpitale, biurowce >3 kondygnacji) — projekt sporządza rzeczoznawca ppoż.

> **Czego NIE wolno robić:** montować czujki dymu w kuchni (gotowanie generuje aerozole), łazience (para), garażu (spaliny), kotłowni z otwartym piecem (sadze) — tam dajemy **czujki ciepła**.

## Konserwacja

Komora optyczna gromadzi kurz — czułość spada. Norma **PN-EN 54-14** i polskie przepisy ppoż:

1. czyszczenie/test funkcjonalny minimum **raz w roku** (próba aerozolem testowym, np. Solo A4),
2. pełna kalibracja/wymiana czujki co **10 lat** (zegar starzenia komory),
3. czujki domowe z bateriami — wymiana baterii zgodnie z sygnalizacją „beep", całość po 10 latach.

## Co dalej

➡ [Czujki ciepła](10-02-czujki-ciepla.md)
