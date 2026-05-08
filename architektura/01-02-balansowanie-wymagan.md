# 01-02: Balansowanie miedzy wymaganiami funkcjonalnymi a niefunkcjonalnymi

## Wymagania funkcjonalne vs niefunkcjonalne

### Wymagania funkcjonalne (FR)
Co system robi — konkretne zachowania i funkcje.

Przyklady:
- Uzytkownik moze zlozyc zamowienie
- System wysyla potwierdzenie e-mail
- Administrator moze generowac raport sprzedazy

### Wymagania niefunkcjonalne (NFR)
Jak system dziala — jakosciowe cechy systemu.

Przyklady:
- Strona laduje sie w mniej niz 2 sekundy (wydajnosc)
- System obsluguje 10 000 rownoczesnych uzytkownikow (skalowalnosc)
- Dostepnosc 99.9% (niezawodnosc)
- Dane sa szyfrowane AES-256 (bezpieczenstwo)

## Dlaczego balansowanie jest trudne?

Wymagania czesto ze soba koliduja:

```
Bezpieczenstwo ←——→ Wygoda uzytkowania
   (MFA, krotkie sesje)     (szybki dostep)

Wydajnosc ←——→ Spojnosc danych
   (cache, eventual consistency)   (ACID, strong consistency)

Elastycznosc ←——→ Prostota
   (pluginy, konfiguracja)         (mniej kodu, szybszy dev)
```

## Techniki balansowania

### 1. Priorytetyzacja atrybutow jakosciowych
Nie wszystkie NFR sa rownie wazne. Stworz ranking:

| Priorytet | Atrybut | Uzasadnienie |
|-----------|---------|-------------|
| 1 | Bezpieczenstwo | Dane medyczne, regulacje HIPAA |
| 2 | Dostepnosc | System krytyczny 24/7 |
| 3 | Wydajnosc | UX wymaga < 200ms response |
| 4 | Skalowalnosc | Przewidywany wzrost 10x w 2 lata |
| 5 | Modyfikowalnosc | Czeste zmiany wymagan |

### 2. Quality Attribute Scenarios
Formalne opisanie wymagania niefunkcjonalnego:

```
Zrodlo:      Uzytkownik
Bodziec:     Klika "Zloz zamowienie"
Artefakt:    Serwis zamowien
Srodowisko:  Normalne obciazenie (1000 req/s)
Odpowiedz:   Zamowienie przetworzone i potwierdzone
Miara:       W mniej niz 500ms w 99% przypadkow (p99)
```

### 3. Architecture Tradeoff Analysis Method (ATAM)
Formalna metoda oceny architektur pod katem atrybutow jakosciowych:
1. Prezentacja architektury
2. Identyfikacja podejsc architektonicznych
3. Generowanie drzewa uzytkowego (utility tree)
4. Analiza podejsc architektonicznych
5. Identyfikacja kompromisow i ryzyk

### 4. Fitness Functions
Automatyczne testy weryfikujace atrybuty jakosciowe:

```javascript
// Fitness function dla wydajnosci
test("API responds under 200ms at p95", async () => {
    const results = await loadTest({
        url: "/api/orders",
        duration: "60s",
        rate: 1000
    });
    expect(results.p95).toBeLessThan(200);
});

// Fitness function dla modulowosci
test("No circular dependencies between modules", () => {
    const deps = analyzeModuleDependencies();
    expect(deps.circular).toHaveLength(0);
});
```

## Matryca kompromisow

Narzedzie do wizualizacji kompromisow:

```
              Wydajnosc  Bezpiecz.  Skalown.  Prostota
Opcja A:        +++        ++         +         ---
Opcja B:         +         +++       +++         --
Opcja C:         ++         +         ++         ++
```

+++ = doskonale, ++ = dobrze, + = ok, - = slabo, --- = bardzo slabo

## Typowe kompromisy w praktyce

### Mikroserwisy vs Monolit
- **Mikroserwisy:** lepsza skalowalnosc i autonomia, gorsza prostota i debugowanie
- **Monolit:** lepsza prostota i wydajnosc komunikacji, gorsza niezaleznosc zespolow

### Synchroniczne vs Asynchroniczne API
- **Sync:** prostsze, szybsza odpowiedz, wiekszy coupling
- **Async:** luzny coupling, odpornosc na awarie, trudniejsze debugowanie

### SQL vs NoSQL
- **SQL:** spojnosc, zlożone zapytania, trudniejsza skalowalnosc horyzontalna
- **NoSQL:** skalowalnosc, elastyczny schemat, eventual consistency

## Zasada "good enough"

Nie szukaj idealnego rozwiazania — szukaj wystarczajaco dobrego. Perfekcja jest wrogiem dostarczania.

```
Idealny system = nigdy nie dostarczony
Wystarczajaco dobry = dostarcza wartosc i mozna go ulepszac
```
