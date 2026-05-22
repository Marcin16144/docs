# Piramida testow

## Klasyczna piramida testow

Piramida testow (Mike Cohn) to model, ktory definiuje proporcje roznych typow testow w projekcie. U podstawy — duzo szybkich, tanich testow jednostkowych. Na szczycie — malo wolnych, kosztownych testow E2E.

```
        /\
       /  \        E2E (UI)
      /    \       Malo, wolne, kruche
     /──────\
    /        \     Integration
   /          \    Srednia ilosc, srednia szybkosc
  /────────────\
 /              \  Unit
/________________\ Duzo, szybkie, stabilne
```

## Typy testow

### Unit Tests (jednostkowe)

Testuja pojedyncza funkcje/metode w izolacji. Szybkie (~ms), stabilne, latwe do debugowania.

```javascript
// Funkcja do przetestowania
function calculateDiscount(price, customerType) {
  if (customerType === 'vip') return price * 0.8;
  if (customerType === 'regular') return price * 0.95;
  return price;
}

// Testy jednostkowe
describe('calculateDiscount', () => {
  it('applies 20% discount for VIP', () => {
    expect(calculateDiscount(100, 'vip')).toBe(80);
  });

  it('applies 5% discount for regular', () => {
    expect(calculateDiscount(100, 'regular')).toBe(95);
  });

  it('no discount for unknown type', () => {
    expect(calculateDiscount(100, 'guest')).toBe(100);
  });

  it('handles zero price', () => {
    expect(calculateDiscount(0, 'vip')).toBe(0);
  });
});
```

**Cechy:** Szybkie (tysiace na sekunde), izolowane (mockowane zaleznosci), stabilne (nie zaleza od infrastruktury).

### Integration Tests (integracyjne)

Testuja wspolprace miedzy komponentami — aplikacja + baza danych, aplikacja + API zewnetrzne, kilka serwisow razem.

```javascript
// Test integracyjny — aplikacja + baza danych
describe('OrderService', () => {
  let db;

  beforeAll(async () => {
    db = await setupTestDatabase();
    await db.migrate();
  });

  afterAll(async () => {
    await db.close();
  });

  beforeEach(async () => {
    await db.truncateAll();
  });

  it('creates order and updates inventory', async () => {
    // Given
    await db.products.insert({ id: 'p1', stock: 10 });

    // When
    const order = await orderService.create({
      items: [{ productId: 'p1', quantity: 2 }]
    });

    // Then
    expect(order.status).toBe('created');
    const product = await db.products.findById('p1');
    expect(product.stock).toBe(8);  // stock zmniejszony
  });
});
```

**Cechy:** Wolniejsze (sekundy), testuja prawdziwe interakcje, wymagaja infrastruktury (baza, Redis).

### E2E Tests (end-to-end)

Testuja caly system z perspektywy uzytkownika — przegladarka → frontend → backend → baza.

```javascript
// Playwright E2E test
import { test, expect } from '@playwright/test';

test('user can place an order', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name=email]', 'jan@example.com');
  await page.fill('[name=password]', 'password123');
  await page.click('button[type=submit]');

  // Add to cart
  await page.goto('/products');
  await page.click('[data-testid=product-1] >> text=Dodaj');
  await page.click('[data-testid=cart-icon]');

  // Checkout
  await page.click('text=Zamow');
  await expect(page.locator('[data-testid=order-confirmation]'))
    .toBeVisible();
  await expect(page.locator('[data-testid=order-status]'))
    .toHaveText('Zamowienie przyjete');
});
```

**Cechy:** Najwolniejsze (minuty), kruche (zaleza od UI), testuja prawdziwy przeplyw uzytkownika.

## Alternatywne modele

### Testing Trophy (Kent C. Dodds)

Nacisk na testy integracyjne zamiast jednostkowych — wiecej pewnosci przy umiarkowanym koszcie.

```
        /\
       /  \        E2E
      /    \       Malo
     /──────\
    /        \
   /          \    Integration    ← NAJWIECEJ
  /            \   (tu jest najlepsza wartosc)
 /──────────────\
/                \ Unit
\________________/ Srednia ilosc

+ Static Analysis (TypeScript, ESLint) — podstawa
```

**Filozofia:** Testy integracyjne daja najlepsza rownowage miedzy pewnoscia a kosztem. Unit testy sa przydatne, ale czesto testuja szczegoly implementacji zamiast zachowania.

### Testing Diamond

Popularne w systemach mikroserwisowych — nacisk na testy kontraktowe i integracyjne.

```
     /\          E2E
    /  \         Malo
   /────\
  /      \
 /        \      Contract + Integration
/          \     NAJWIECEJ
\──────────/
 \        /
  \      /       Unit
   \    /        Srednia ilosc
    \  /
     \/
```

### Anti-pattern: Ice Cream Cone

Odwrocona piramida — duzo wolnych testow E2E, malo szybkich unit testow. Powoduje wolne buildy, kruche testy i niski developer experience.

```
________________
\              /  Duzo E2E (wolne, kruche)
 \            /   Duzo manualnych testow
  \──────────/
   \        /     Malo integration
    \──────/
     \    /       Bardzo malo unit
      \  /
       \/

Problemy:
- Pipeline trwa 45+ minut
- Testy losowo failuja (flaky)
- Debugging trudny (ktora warstwa zawinila?)
- Developerzy omijaja testy
```

## Porownanie modeli

| Model | Unit | Integration | E2E | Najlepsze dla |
|-------|------|-------------|-----|---------------|
| Piramida | Duzo | Srednio | Malo | Biblioteki, algorytmy |
| Trophy | Srednio | Duzo | Malo | Aplikacje webowe |
| Diamond | Srednio | Duzo | Malo | Mikroserwisy |
| Ice Cream | Malo | Malo | Duzo | ANTI-PATTERN |

## Proporcje testow

Rekomendowane proporcje (zaleznie od typu projektu):

| Typ projektu | Unit | Integration | E2E |
|-------------|------|-------------|-----|
| Biblioteka/SDK | 70% | 20% | 10% |
| Aplikacja webowa | 40% | 40% | 20% |
| Mikroserwisy | 30% | 50% | 20% |
| MVP / Startup | 20% | 30% | 50% |

## Dobre praktyki testowania

### Zasady ogolne

1. **Testuj zachowanie, nie implementacje** — zmiana refaktoryzacyjna nie powinna lamac testow
2. **Arrange-Act-Assert (AAA)** — czytelna struktura kazdego testu
3. **Jeden test = jedna asercja** (lub logicznie powiazana grupa)
4. **Nazewnictwo** — co testujemy, w jakich warunkach, czego oczekujemy
5. **Izolacja** — testy nie powinny zalezec od siebie

### Co testowac na kazdym poziomie

```
Unit:
  ✓ Logika biznesowa (kalkulacje, walidacja)
  ✓ Transformacje danych
  ✓ Edge cases, boundary conditions
  ✗ Baza danych, API, system plikow

Integration:
  ✓ Endpointy HTTP (request → response)
  ✓ Zapytania do bazy (CRUD)
  ✓ Integracje z zewnetrznymi API
  ✓ Message handling (kolejki)

E2E:
  ✓ Krytyczne sciezki uzytkownika (happy path)
  ✓ Onboarding, checkout, platnosc
  ✗ Edge cases (testuj na nizszych poziomach)
```

### Jak unikac flaky tests

```
1. Nie zalezaj od czasu (sleep, setTimeout)
   ZLE:  await sleep(2000); expect(...)
   DOBRZE: await waitFor(() => expect(...))

2. Izoluj dane testowe
   ZLE:  Testy wspoldziela dane
   DOBRZE: Kazdy test ma wlasne dane (setup/teardown)

3. Nie zalezaj od kolejnosci testow
   ZLE:  Test B wymaga danych z testu A
   DOBRZE: Kazdy test jest niezalezny

4. Retry z umiarem
   CI: retry max 1 raz, potem napraw
   NIE: retry 5 razy (maskuje problem)
```

## Kluczowe wnioski

1. **Piramida** to punkt wyjscia — nie dogmat, dostosuj do projektu
2. **Testing Trophy** jest lepsza dla typowych aplikacji webowych
3. **Ice Cream Cone** to anti-pattern — unikaj za wszelka cene
4. **Integracyjne** daja najlepsza wartosc za zainwestowany czas
5. **Testuj zachowanie**, nie szczegoly implementacji
6. **Flaky tests** to rak — naprawiaj natychmiast lub usuwaj
7. **Pokrycie 80%** to dobry cel — 100% czesto nie jest warte kosztu
