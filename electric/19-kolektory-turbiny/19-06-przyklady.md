# Przykłady

Trzy kompletne scenariusze: instalacja kolektorów dla rodziny, mała turbina off-grid i system hybrydowy multi-source.

## Przykład A — kolektory słoneczne dla domu 4-osobowego

### Założenia

- Rodzina 4 osoby, dom jednorodzinny, dach skośny w stronę południową.
- Zapotrzebowanie CWU: ~9,3 kWh/dobę (obliczone w rozdziale 19-02).
- Drugie źródło ciepła: kocioł gazowy / pompa ciepła.

### Dobór instalacji

| Element | Dobór |
|---|---|
| Kolektory | 2 kolektory płaskie po 2,5 m² (razem 5 m²) lub 20 rur próżniowych |
| Zasobnik CWU | 300 l, dwie wężownice (solarna + kotłowa) |
| Grupa pompowa | pompa obiegowa + zawory + manometr |
| Sterownik solarny | z funkcją chłodzenia nocnego |
| Naczynie wzbiorcze | dobrane na pojemność obiegu glikolu |
| Czynnik | glikol propylenowy |
| Kąt / azymut | 40°, kierunek S |

### Schemat hydrauliczny

```
   +-------------------+
   | Kolektory płaskie |
   |     2 x 2,5 m²    |
   +---------+---------+
             |  glikol gorący
             v
      +-------------+
      |   Grupa     |
      |  pompowa    |---- sterownik solarny
      +------+------+
             |
             v
   +---------------------+
   |  ZASOBNIK CWU 300 l |
   |  +---------------+  |
   |  | wężownica     |  | <- ciepło z kolektorów
   |  | solarna (dół) |  |
   |  +---------------+  |
   |  | wężownica     |  | <- dogrzewanie z kotła
   |  | kotłowa (góra)|  |
   |  +---------------+  |
   +----------+----------+
              |
              v
        ciepła woda do kranów
```

### Efekty i ekonomia

| Pozycja | Wartość |
|---|---|
| Pokrycie roczne CWU przez kolektory | ~60% |
| Pokrycie latem | ~100% |
| Pokrycie zimą | ~20% |
| Koszt instalacji (z montażem) | ~8–15 tys. zł |
| Roczna oszczędność na podgrzewaniu CWU | ~600–1200 zł |
| Prosty czas zwrotu | ~10–15 lat |

> Zwrot jest długi i porównywalny z żywotnością instalacji. Kolektory mają sens przy stałym, dużym zużyciu CWU — ale dla wielu gospodarstw PV z grzałką sterowaną nadwyżkami będzie dziś rozwiązaniem o lepszej ekonomii.

## Przykład B — mała turbina wiatrowa 1 kW na działce off-grid

### Założenia

- Działka rekreacyjna off-grid na wybrzeżu — średni wiatr ~5,5 m/s na wysokości masztu.
- Cel: dodatkowe źródło do istniejącego systemu off-grid PV + magazyn z sekcji 17.
- Turbina HAWT 1 kW, maszt 12 m z odciągami.

### Szacunek produkcji

```
P_znamionowa = 1 kW
CF (wybrzeże, 5,5 m/s) ≈ 18-22%

E_rok = 1 kW · 8760 h · 0,20 ≈ 1750 kWh/rok
Zakres realny: 1500-2000 kWh/rok
```

### Integracja z systemem off-grid

```
   +-----------+
   | Turbina   |
   | 1 kW HAWT |
   | maszt 12m |
   +-----+-----+
         | 3-faz AC
         v
   +------------+      +-----------+
   | Prostownik |      | Dump load |
   | + regulat. |<---->| (grzałka  |
   |  wiatrowy  |      |  CWU)     |
   +-----+------+      +-----------+
         |
         v
   +-----------+      istniejący system off-grid PV + magazyn
   | Szyna DC  |<------ regulator MPPT PV
   |   48 V    |
   +-----+-----+
         |
   +-----+-----+
   | Magazyn   |
   +-----------+
```

### Ekonomia — uczciwa ocena

| Pozycja | Wartość |
|---|---|
| Produkcja roczna | ~1500–2000 kWh |
| Koszt (turbina + maszt + montaż + regulator) | ~10–20 tys. zł |
| Wartość energii (przy ~0,8 zł/kWh) | ~1200–1600 zł/rok |
| Prosty czas zwrotu | ~8–15 lat (przy dobrym wietrze) |

> **Uczciwa ocena.** Ten przykład działa, bo lokalizacja ma realnie dobry wiatr (wybrzeże, 5,5 m/s). W większości Polski nizinnej, przy wietrze 3,5–4 m/s, ta sama turbina dałaby ~700–900 kWh/rok, a zwrot przekroczyłby żywotność turbiny. Turbina przydomowa to rozsądny zakup tylko tam, gdzie wiatr został zmierzony i potwierdzony. W off-grid jej dodatkową wartością jest produkcja zimą i w nocy — wtedy, gdy PV milczy — co realnie zmniejsza zużycie paliwa przez agregat.

## Przykład C — system hybrydowy multi-source dla domku off-grid

### Założenia

Całoroczny domek off-grid, bez przyłącza sieciowego. Dobrane źródła:

| Element | Parametry |
|---|---|
| Fotowoltaika | PV 2 kWp |
| Turbina wiatrowa | 0,5 kW |
| Magazyn | akumulatory 10 kWh |
| Agregat backup | 2 kVA (benzynowy / spalinowy) |

### Schemat systemu

```
  +----------+   +-----------+   +-----------+   +-----------+
  | PV 2 kWp |   | Turbina   |   | Magazyn   |   | Agregat   |
  |          |   | 0,5 kW    |   | 10 kWh    |   | 2 kVA     |
  +----+-----+   +-----+-----+   +-----+-----+   +-----+-----+
       | MPPT          | regul.        |               |
       |               | wiatr.        |               |
       v               v               v               |
  +--------------------------------------------+        |
  |            SZYNA DC 48 V                    |        |
  +----------------------+----------------------+        |
                         |                               |
                         v                               |
                  +-------------+                        |
                  | Inwerter/   |<-----------------------+
                  | ładowarka   |   start agregatu
                  | hybrydowa   |   gdy magazyn niski
                  +------+------+
                         |
                         v
                 odbiorniki 230 V AC
                         |
              dump load (rezystor balastowy)
              przejmuje nadwyżkę turbiny
```

### Bilans sezonowy

| Sezon | Główne źródło | Rola pozostałych |
|---|---|---|
| Lato | PV (długi dzień, dużo słońca) | turbina marginalnie, agregat prawie nieużywany |
| Wiosna / jesień | PV + turbina po połowie | agregat sporadycznie przy ciszy i zachmurzeniu |
| Zima | turbina + agregat | PV daje niewiele (krótki dzień, niskie słońce) |

Komplementarność PV i wiatru wyrównuje produkcję: gdy zimą PV niemal milczy, częściej wieje wiatr; gdy latem brak wiatru, słońca jest pod dostatkiem. Agregat jest źródłem ostatniej szansy — w dobrze dobranym systemie pracuje tylko kilkanaście–kilkadziesiąt godzin w roku.

### Koszty całkowite

| Pozycja | Koszt orientacyjny |
|---|---|
| PV 2 kWp z regulatorem MPPT | ~6–9 tys. zł |
| Turbina 0,5 kW z masztem i regulatorem | ~6–12 tys. zł |
| Magazyn 10 kWh | ~12–20 tys. zł |
| Inwerter/ładowarka hybrydowa | ~4–7 tys. zł |
| Agregat 2 kVA | ~2–4 tys. zł |
| Okablowanie, dump load, montaż | ~3–6 tys. zł |
| **Razem** | **~33–58 tys. zł** |

> System hybrydowy off-grid to inwestycja w niezależność i ciągłość zasilania tam, gdzie przyłącze sieciowe jest niemożliwe lub bardzo drogie — nie w czystą oszczędność. Tam, gdzie sieć jest dostępna, zwykle taniej i prościej wypada instalacja przyłączona do sieci.

## Podsumowanie sekcji

Kolektory termiczne i turbiny wiatrowe to dojrzałe technologie, ale obie ustępują dziś fotowoltaice pod względem uniwersalności i ekonomii w typowych warunkach. Kolektory mają sens przy dużym, stałym zużyciu CWU; turbiny — tylko przy realnie dobrym wietrze i przede wszystkim w instalacjach off-grid, gdzie ich największą wartością jest komplementarność z PV.

## Koniec sekcji 19

➡ [Powrót do strony głównej elektryki](../index.html)
