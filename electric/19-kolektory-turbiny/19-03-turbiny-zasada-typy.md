# Turbiny wiatrowe przydomowe — zasada i typy

## Zasada działania

Turbina wiatrowa zamienia energię kinetyczną wiatru na energię elektryczną:

```
wiatr → wirnik (łopaty) → wał → generator → prąd
```

Wiatr napiera na łopaty wirnika, wprawiając je w ruch obrotowy. Wirnik napędza generator, który wytwarza prąd. Przydomowe turbiny generują zwykle 3-fazowy prąd przemienny (AC) o zmiennej częstotliwości — następnie prostownik zamienia go na prąd stały (DC), który ładuje magazyn lub zasila inwerter.

## Typy turbin

### Oś pozioma — HAWT

**HAWT** (Horizontal Axis Wind Turbine) — klasyczne śmigło, oś obrotu równoległa do ziemi.

- Sprawniejsze — najwyższy współczynnik wykorzystania energii wiatru.
- Wymagają **kierunkowania na wiatr** (statecznik kierunkowy lub serwomechanizm).
- Najlepiej pracują przy stałym, jednokierunkowym wietrze (otwarty teren).
- Wirnik wysoko na maszcie — wymagają solidnej konstrukcji nośnej.

### Oś pionowa — VAWT

**VAWT** (Vertical Axis Wind Turbine) — oś obrotu pionowa. Dwa główne rodzaje:

- **Savonius** — wirnik oporowy (łopaty w kształcie połówek cylindra), wolnoobrotowy, duży moment rozruchowy.
- **Darrieus** — wirnik nośny (smukłe profile), szybkoobrotowy, sprawniejszy od Savoniusa, ale słabo się rozkręca samodzielnie.

Cechy VAWT:

- **Niezależne od kierunku wiatru** — nie wymagają kierunkowania.
- Cichsze, mniej wibracji, mogą stać niżej.
- Mniej sprawne od HAWT.
- Dobrze znoszą turbulentny, zmienny wiatr (zabudowa miejska, blisko budynków).

| Cecha | HAWT (pozioma) | VAWT (pionowa) |
|---|---|---|
| Sprawność | wyższa | niższa |
| Kierunkowanie na wiatr | wymagane | niepotrzebne |
| Hałas | większy | mniejszy |
| Wiatr turbulentny | słabo | dobrze |
| Wiatr stały, otwarty teren | bardzo dobrze | przeciętnie |
| Typowe zastosowanie | otwarty teren, działka | zabudowa, dachy, miasto |

## Moc turbin przydomowych

Turbiny przydomowe mają moc znamionową od **0,3 do 10 kW**. Mała turbina balastowa do ładowania akumulatorów to 0,3–1 kW; turbina mająca realnie zasilać dom — 3–10 kW.

## Krzywa mocy — moc rośnie z sześcianem prędkości wiatru

To najważniejsza zależność w energetyce wiatrowej. Moc dostępna w wietrze jest **proporcjonalna do trzeciej potęgi prędkości wiatru**:

```
P ∝ v³
```

> **Dwukrotnie silniejszy wiatr daje OSIEM razy więcej mocy** (2³ = 8). Dlatego lokalizacja turbiny i wysokość masztu mają decydujące znaczenie — niewielki wzrost średniej prędkości wiatru przekłada się na ogromny wzrost produkcji.

Charakterystyczne prędkości na krzywej mocy turbiny:

| Prędkość | Nazwa | Co się dzieje |
|---|---|---|
| ~2–3 m/s | prędkość startowa (cut-in) | turbina zaczyna się obracać i produkować prąd |
| ~10–12 m/s | prędkość znamionowa | turbina osiąga moc znamionową |
| ~25 m/s | prędkość wyłączenia (cut-out) | turbina hamuje / chowa się, by się nie uszkodzić |

Poniżej prędkości startowej turbina nie produkuje nic. Powyżej znamionowej moc nie rośnie dalej (układ ją ogranicza). Powyżej cut-out turbina jest zatrzymywana dla bezpieczeństwa.

## Generator i przetwarzanie prądu

```
wirnik → generator 3-faz AC (zmienna częstotliwość)
       → prostownik → DC
       → regulator ładowania → magazyn / szyna DC
       → inwerter → odbiorniki 230 V AC
```

Stosuje się najczęściej generatory z magnesami trwałymi — nie wymagają wzbudzenia, dobrze pracują przy zmiennych obrotach.

## Maszt — im wyżej, tym lepiej

Wiatr przy gruncie jest hamowany przez tarcie o teren, drzewa i budynki (tzw. profil pionowy wiatru). Wyżej wiatr jest **silniejszy i bardziej stabilny**.

- Maszt powinien wynosić co najmniej 10–12 m, a wirnik wystawać wyraźnie ponad okoliczne przeszkody.
- Zasada praktyczna: dolna krawędź wirnika minimum 8–10 m powyżej najwyższej przeszkody w promieniu ~100 m.
- Turbina zamontowana na dachu domu pracuje w turbulencji i zwykle rozczarowuje — dom jest przeszkodą.

## Realizm — czy turbina przydomowa się opłaca w Polsce?

> **Uczciwe ostrzeżenie.** W większości Polski nizinnej (centrum kraju) średnia prędkość wiatru przy gruncie jest niska. Turbiny przydomowe w takich lokalizacjach **rzadko bywają opłacalne** — produkcja jest mała, a koszt turbiny, masztu i instalacji wysoki. Sprzedawcy często podają moc znamionową przy 11–12 m/s, których w danej lokalizacji niemal nigdy nie ma.
>
> Turbina przydomowa ma sens głównie tam, gdzie wiatr jest realnie dobry: wybrzeże, Suwalszczyzna, otwarte tereny pojezierzy — oraz w instalacjach off-grid, gdzie liczy się dywersyfikacja źródeł, a nie czysty rachunek ekonomiczny.

Szczegółowy dobór i ocena opłacalności — na następnej stronie.

## Co dalej

➡ [Dobór turbiny wiatrowej — obliczenia](19-04-dobor-turbiny.md)
