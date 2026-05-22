# Budowa rozdzielnicy modułowej

Rozdzielnica (potocznie „skrzynka bezpieczników") to centralny punkt instalacji elektrycznej. Współczesna rozdzielnica domowa to **modułowa** konstrukcja na szynach TH35 (DIN), wypełniona standardowymi aparatami szerokości jednego modułu (18 mm).

## Elementy składowe

| Element | Funkcja |
|---|---|
| **Obudowa** (n/p lub p/t) | mechaniczna ochrona i bezpieczeństwo |
| **Drzwiczki** (pełne / przezroczyste) | zamknięcie + ochrona przed dotykiem |
| **Szyny TH35** (DIN-rail) | mocowanie aparatów modułowych |
| **Listwa PE** (zielono-żółta) | wspólny punkt przewodu ochronnego |
| **Listwa N** (niebieska) | wspólny punkt przewodu neutralnego |
| **Wyłącznik główny FR** | rozłącznik izolacyjny dla całej instalacji |
| **MCB** (wyłączniki nadprądowe) | zabezpieczenie obwodów (B16, B10, C20…) |
| **RCD** (różnicowoprądowe) | ochrona przed porażeniem (30 mA) |
| **SPD** (ochronniki przepięciowe) | redukcja przepięć z sieci/atmosferycznych |
| **Styczniki modułowe** | załączanie obciążeń (PV, ogrzewanie) |
| **Przekaźniki bistabilne** | sterowanie oświetleniem przez impulsy |
| **Lampki sygnalizacyjne** | wskazanie obecności faz |
| **Dzwonek** | sygnalizator akustyczny |
| **Licznik energii modułowy** | monitoring (zwłaszcza dla EV i PV) |

## Moduły szerokości

```
   1 moduł = 18 mm szerokości
   
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │M1│M2│M3│M4│M5│M6│M7│M8│M9│M0│M1│M2│   ← rząd 12-modułowy
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
   ◄────────── 216 mm ──────────►
```

| Aparat | Liczba modułów |
|---|---|
| **MCB 1P** (B16) | 1 moduł |
| **MCB 3P** (3-fazowy) | 3 moduły |
| **RCD 2P** (1-faz) | 2 moduły |
| **RCD 4P** (3-faz) | 4 moduły |
| **RCBO** (kombinowany MCB+RCD) | 1–2 moduły |
| **SPD typu 2** | 1–4 moduły |
| **FR rozłącznik główny 3F** | 3 moduły |
| **Stycznik modułowy 25A** | 2 moduły |
| **Przekaźnik bistabilny BIS-411** | 1 moduł |
| **Licznik energii** | 1–4 moduły |

## Rozmiary typowych rozdzielnic

| Rozmiar | Liczba modułów | Rzędy × moduły/rząd | Zastosowanie |
|---|---|---|---|
| **Mała** | **12** | 1 × 12 | mieszkanie 1-faz, 6–8 obwodów |
| **Średnia** | **24** | 2 × 12 | mieszkanie/mały dom, ~14 obwodów |
| **Duża** | **36** | 3 × 12 | dom 1-faz lub mały 3-faz |
| **XL** | **54** | 3 × 18 | dom 3-faz z EV/PV, ~25 obwodów |
| **XXL** | **72** | 4 × 18 (lub 3 × 24) | dom z pełną automatyką, biuro |

## Klasy izolacji obudowy

| Klasa | Symbol | Cecha |
|---|---|---|
| **Klasa I** | ☐ + uziemienie | obudowa metalowa, wymaga PE |
| **Klasa II** | ☐ w ☐ (kwadrat w kwadracie) | **podwójna izolacja**, bez uziemienia obudowy |

Współczesny standard to **klasa II** — obudowa z tworzywa (Hager Volta, Schneider Resi9, Eaton xEnergy) z **podwójną izolacją** wszystkich części pod napięciem. Eliminuje to konieczność uziemiania obudowy i upraszcza montaż.

## Stopień ochrony IP

| Lokalizacja | Wymóg IP |
|---|---|
| Wewnątrz budynku (przedpokój, korytarz) | **IP30** wystarczy (sucho, ograniczony dostęp) |
| Garaż (suchy) | **IP40** |
| Garaż wilgotny / piwnica | **IP44** |
| Zewnątrz (na elewacji) | **IP54** minimum, lepiej **IP65** |
| W kotłowni z parą | **IP54** |

## Typy obudów

### Natynkowa (n/p) — najczęściej w domu jednorodzinnym

```
   ┌─────────────┐  ← na ścianie zewnętrznie
   │ ┌─────────┐ │
   │ │ szyny   │ │
   │ │ TH35    │ │
   │ └─────────┘ │
   └─────────────┘
   ścianka
   ▓▓▓▓▓▓▓▓▓▓▓▓▓
```

**Plusy:** łatwy montaż, łatwa rozbudowa, brak kucia w ścianie.  
**Minusy:** wystaje (60–110 mm od ściany), widoczna.

### Podtynkowa (p/t) — typowo w mieszkaniach

```
   ▓▓▓┌─────────────┐▓▓▓
   ▓▓▓│   wnęka     │▓▓▓  ← w ścianie
   ▓▓▓│   z szynami │▓▓▓
   ▓▓▓└─────────────┘▓▓▓
       ▲
       drzwiczki frontowe licują ze ścianą
```

**Plusy:** elegancka, nie wystaje, łatwo wkomponować.  
**Minusy:** trzeba przygotować wnękę przed wykończeniem ściany, słabsza wentylacja.

## Wentylacja i przegrzewanie

Aparaty modułowe (zwłaszcza MCB i SPD) wydzielają ciepło. Przy gęsto wypełnionej rozdzielnicy temperatura wewnątrz osiąga 40–55 °C — przekroczenie 60 °C powoduje samoczynne wyzwolenie MCB klasy B przy mniejszych prądach niż znamionowy.

**Zalecenia:**

- rezerwa **25–30%** modułów (lepsza wentylacja),
- wentylacja kominkowa (otwory na górze i dole obudowy),
- w dużych rozdzielnicach z PV/EV — wentylator wymuszony 12 V z termostatem.

## Co dalej

➡ [Schemat ideowy rozdzielnicy](06-02-schemat.md)
