# Instalacja w kuchni

Kuchnia ma najwięcej mocno obciążonych odbiorników w domu (piekarnik, płyta, zmywarka, czajnik, mikrofalówka). Dobry projekt = **wiele osobnych obwodów** zamiast jednego przeciążonego.

## Lista obwodów modelowej kuchni

| Nr | Obwód | MCB | Kabel | Uwagi |
|---|---|---|---|---|
| 1 | **Gniazda blat — strona 1** | B16 | YDYp 3×2,5 | 3–4 gniazda nad blatem |
| 2 | **Gniazda blat — strona 2** | B16 | YDYp 3×2,5 | 3–4 gniazda nad blatem |
| 3 | **Zmywarka** | B16 | YDYp 3×2,5 | dedykowany + RCD 30 mA |
| 4 | **Pralka** (gdy w kuchni) | B16 | YDYp 3×2,5 | dedykowany + RCD 30 mA |
| 5 | **Lodówka** | B16 | YDYp 3×2,5 | dedykowany — **bez** RCD wspólnego z czymkolwiek |
| 6 | **Piekarnik elektryczny** | B16 | YDYp 3×2,5 | dedykowany |
| 7 | **Płyta indukcyjna** | B16 ×3 (3-faz) | YDYżo 5×2,5 | jedna na fazę lub 4 mm² |
| 8 | **Oświetlenie kuchni** | B10 | YDYp 3×1,5 | sufit + nad blatem |
| 9 | **Okap** | B6/B10 | YDYp 3×1,5 | nad płytą |

> **Razem typowa kuchnia: 7–9 obwodów.** Dlatego rozdzielnica „kuchenna" zajmuje sporo modułów.

## Płyta indukcyjna — najmocniejszy odbiornik

Płyta indukcyjna o mocy **7–11 kW** musi być zasilana **3-fazowo**:

```
   3-faz (5 żył):              moc na fazę:
                  ┌── L1 ─ pole 1
   L1 L2 L3 N PE ─┼── L2 ─ pole 2     2,3–3,7 kW na fazę
                  └── L3 ─ pole 3+4

   przekrój 2,5 mm² (Cu) jeśli MCB B16 na każdą fazę
   przekrój 4 mm² (Cu) jeśli prowadzenie >15 m lub MCB B25
```

| Rodzaj płyty | Moc | Zasilanie | Przewód |
|---|---|---|---|
| **Indukcyjna 3-faz pełna** | 7,4 kW | 5×L+N+PE | 5×2,5 mm² (do 15 m) / 5×4 mm² |
| **Indukcyjna mała 2 pola** | 3,7 kW | 1-faz 230 V | 3×2,5 mm² |
| **Płyta ceramiczna** | 6 kW | 1-faz lub 2-faz | 3×4 mm² / 5×2,5 mm² |
| **Płyta gazowa** | 30 W (elektroniczny zapłon) | gniazdo zwykłe | 3×1,5 mm² |

> **Uwaga:** wiele płyt indukcyjnych ma fabryczny mostek 1F → 3F na zaciskowej (mostki miedziane). Sprawdź instrukcję — błędne ustawienie = przepalenie zacisku.

## Piekarnik

Piekarnik (2,5–3,5 kW) zasilany z **dedykowanego obwodu B16**, gniazdo standardowe 230 V Schuko **za** piekarnikiem (dostępne po wyjęciu szuflady). **Nigdy** wspólny obwód z płytą indukcyjną.

## Lodówka — własny obwód, **bez** wspólnego RCD

| Powód | Skutek wspólnego RCD |
|---|---|
| RCD od pralki/zmywarki czasem wybija | lodówka się rozmraża |
| Wyjazd 2 tygodnie + wybity RCD | jedzenie psuje się |
| Pełne wyłączenie kuchni głównym | lodówka też wyłączona |

Rozwiązanie: **dedykowany RCBO B16 / 30 mA typ A** dla samej lodówki. Niektóre projekty: lodówka bez RCD (TN-S, podwójna izolacja) — wtedy minimum **dedykowany MCB B16** i osobny obwód.

## Gniazda nad blatem — wysokości

- **wysokość gniazd nad blatem:** 110–130 cm od podłogi (5–25 cm nad blatem),
- **wąskie listwy gniazd:** poziome listwy z 3–5 gniazdami montowane bezpośrednio pod szafkami górnymi,
- **gniazda w blacie / w narożniku:** wysuwane (Schulte EVOline Port) — bardzo wygodne, ale wymagają nawiercenia blatu Ø80 mm.

```
   widok kuchni z boku:

   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  szafki górne
                       (h górna = 200 cm)
   ┌─────────────┐
   │ ○○ ○○ ○○    │  ← listwa gniazd 120 cm
   │      blat   │
   └─────────────┘  ← blat 90 cm
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  szafki dolne
                       (h dolna = 0–85 cm)
```

## Mikrofalówka i drobne urządzenia

- **mikrofalówka** (800–1500 W): osobne gniazdo, najlepiej w słupku wysokim na zabudowanej półce; może być w obwodzie blatu lub osobno;
- **ekspres do kawy** (1500 W): gniazdo blatu, dedykowane jeśli profesjonalny (2-grupowy);
- **czajnik** (2 kW): jedno z gniazd nad blatem.

## Okap

Okap (60–250 W) ma własne gniazdo w obrębie szafki nad płytą lub stałe wpięcie. Większość modeli ma kabel 1,5 m z wtyczką — wystarczy gniazdo w sąsiedniej szafce. Dedykowany obwód **nie jest wymagany**, ale wygodny.

## Wyspa kuchenna

Wyspę zasila się przez **kable w szlichcie** prowadzone w peszlach od ścian:

- gniazda w cokole wyspy (3–4 sztuki, jeśli używana z urządzeniami),
- gniazda wysuwane z blatu wyspy (typu pop-up),
- oświetlenie z sufitu nad wyspą (osobne sterowanie).

> **Plan trasowania:** zaplanuj peszle do wyspy **przed** wylewką szlichty. Po wykończeniu posadzki dodanie gniazda do wyspy = kucie posadzki.

## Co dalej

➡ [Instalacja zewnętrzna i ogród](05-08-zewnetrzna.md)
