# Schemat ideowy

Schemat ideowy (jednokreskowy) to graficzny zapis połączeń aparatów w rozdzielnicy. Pokazuje **logikę** instalacji, a nie jej fizyczne ułożenie. To podstawowy dokument projektowy, na którym pracuje elektryk i kontroler.

## Norma symboli — PN-EN 60617

Symbole graficzne dla schematów elektrycznych są ujednolicone normą **PN-EN 60617** (zestaw zharmonizowany IEC). Najczęściej spotykane:

| Symbol | Element |
|---|---|
| Prostokąt z literą F i numerem | wyłącznik nadprądowy (MCB) |
| Dwa prostokąty połączone z czujnikiem różnicowym | wyłącznik różnicowoprądowy (RCD) |
| Prostokąt z F + symbol różnicówki | RCBO (połączony MCB+RCD) |
| Kółko z dwoma poziomymi kreskami w środku | gniazdo z PE |
| Kółko z X | oprawa oświetleniowa |
| Linia z kółkiem na końcu | łącznik (włącznik światła) |
| Strzałka | zasilanie / kierunek przepływu |
| ZK lub trójkąt z liczbą | uziemienie (PE) lub PEN |
| Kółko z N | przewód neutralny (szyna) |
| Kreska przerywana | obudowa, granica strefy |

## Konwencje rysunkowe

### Kierunki

- **Zasilanie** rysujemy zwykle **poziomo, w górnej części** (szyna L1, L2, L3, N, PE)
- **Obwody odpływowe** schodzą **pionowo w dół**
- Numeracja **od lewej do prawej** (idąc fizycznie wzdłuż szyny TH35)

### Numeracja obwodów

Stosujemy ciągłą numerację z prefiksem:

- **L1, L2, L3, L4...** — obwody oświetlenia
- **G1, G2, G3...** — obwody gniazd
- **D1, D2, D3...** — obwody dedykowane (lodówka, pralka)
- albo prościej: **F1, F2, F3...** — od F (Fuse)

### Opisy

Każdy aparat opisujemy:

```
  F5
  B16
  3×2,5 mm²
  „Gniazda kuchnia"
```

(symbol, charakterystyka i prąd, przekrój przewodu, opis funkcyjny).

## Narzędzia do rysowania

| Narzędzie | Charakter | Cena |
|---|---|---|
| **EPLAN Electric P8** | profesjonalne, branżowe | bardzo wysoka (licencja firmowa) |
| **EPLAN Education** | wersja edukacyjna | darmowa dla studentów |
| **AutoCAD Electrical** | profesjonalne | wysoka |
| **Eagle / KiCad** | bardziej do PCB, ale daje radę | darmowe |
| **Visio** | uniwersalne, ma biblioteki elektryczne | średnia (Microsoft 365) |
| **Draw.io / diagrams.net** | online, darmowe | 0 zł |
| **LibreOffice Draw** | offline, darmowe | 0 zł |
| **Kartka A3 + ołówek** | szkic koncepcyjny | grosze |

Dla domu jednorodzinnego — **diagrams.net** lub **LibreOffice Draw** w zupełności wystarczą. Profesjonalny EPLAN to overkill.

## Czytanie schematu

1. **Zacznij od góry, z lewej** — odszukaj wejście zasilania (WLZ z licznika).
2. **Idź w prawo wzdłuż szyny zasilającej** — zobacz, gdzie są wyłącznik główny i SPD.
3. **Schodź w dół po każdym odpływie** — zabezpieczenie → RCD (jeśli jest) → przewód do odbiornika.
4. **Czytaj opisy** — co jest na końcu obwodu (gniazdo? bojler? oświetlenie?).

## Przykładowy fragment schematu (ASCII)

Rozdzielnica jednofazowa małego mieszkania:

```
  L ────●─────┬───────────┬───────────┬───────────┬───────────┐
              │           │           │           │           │
              [Q1]        [F1]        [F2]        [F3]        [F4]
              C40         B10         B16         B16         B10
              wył.gł.     ośw.        gniazda     pralka      lodówka
              │           │           │           │           │
              ●           ●           ●           ●           ●
              │           │           │           │           │
              │      ┌────┴────┐      │      ┌────┴────┐      │
              │      [RCD30 mA]       │      [RCD30 mA]       │
              │      │         │      │      │                │
  N ──────────┼──────┼─────────┼──────┼──────┼────────────────┼──
              │      │         │      │      │                │
  PE ─────────┼──────┼─────────┼──────┼──────┼────────────────┼──
              │      │         │      │      │                │
                     ▼ obw.1   ▼      ▼      ▼ pralka         ▼
                     OŚW       G1     G2                      L
```

Trzy szyny: L (faza), N (neutralna), PE (ochronna). Wyłącznik główny Q1, potem cztery odpływy. Obwody łazienkowe (G2) i pralka (D1) chronione RCD 30 mA. Obwody „suche" (oświetlenie ogólne, lodówka) — bez RCD lub na osobnym (zależnie od koncepcji ochrony).

## Schemat rozwinięty (3-fazowy)

W instalacji 3-fazowej dokładamy zarządzanie fazami: każdy obwód jednofazowy musi być oznaczony, na której fazie wisi. **Cel:** zbalansowane obciążenie wszystkich trzech faz (różnica nie więcej niż ~30%).

```
  L1 ───────●────────┬──────┬───────┬───────────────
  L2 ───────●────────┼──────┼───────┼──────┬────────
  L3 ───────●────────┼──────┼───────┼──────┼──────┬─
                     │      │       │      │      │
                    [F1]   [F2]    [F3]   [F4]   [F5]
                    B10    B16     B16    B16    B16
                    L1     L2      L3     L1     L2
                    ośw.   gn.     gn.    pralk. zmyw.
                    salon  salon   kuch.
```

## Częste błędy

- Brak opisu obwodów — wystarczy „F1, F2..." bez tekstu, by za 3 lata nikt nie wiedział, co jest gdzie.
- Brak oznaczenia faz — instalator wpiął wszystko na L1, pozostałe fazy puste = przeciążenie L1.
- Mylenie symboli MCB i RCD — często projektant rysuje wszystko jako prostokąt; legenda obowiązkowa.
- Brak szyny PE na schemacie — wygląda na uproszczenie, w praktyce ukrywa, czy w ogóle jest uziemienie.

## Co dalej

➡ [Plan instalacji (rzut)](07-05-plan-instalacji.md)
