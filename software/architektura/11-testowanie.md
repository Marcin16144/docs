# Testowanie w architekturze

## Piramida testów

```
         /  E2E  \           ← mało, wolne, kosztowne
        /----------\
       / Integracyjne \      ← umiarkowanie
      /----------------\
     /   Jednostkowe    \    ← dużo, szybkie, tanie
    /____________________\
```

## Rodzaje testów

### Testy jednostkowe (Unit Tests)
- Testują pojedynczą funkcję/klasę w izolacji
- Szybkie (milisekundy)
- Mocki/stuby dla zależności

### Testy integracyjne (Integration Tests)
- Testują współpracę kilku komponentów
- Baza danych, API, kolejki
- Wolniejsze, ale bardziej realistyczne

### Testy E2E (End-to-End)
- Testują cały przepływ użytkownika
- Przeglądarka, API, baza — wszystko razem
- Najwolniejsze, najbardziej kruche

### Testy kontraktowe (Contract Tests)
- Weryfikują zgodność interfejsów między serwisami
- Producer i consumer mają wspólny kontrakt
- **Narzędzia:** Pact, Spring Cloud Contract

### Testy obciążeniowe (Load/Performance Tests)
- Sprawdzają zachowanie pod obciążeniem
- **Narzędzia:** k6, JMeter, Gatling, Locust

### Testy Chaos (Chaos Engineering)
- Celowe wprowadzanie awarii do systemu
- Weryfikacja odporności
- **Narzędzia:** Chaos Monkey, Litmus, Gremlin

---

## Testability w architekturze

### Dependency Injection (DI)
Wstrzykiwanie zależności umożliwia podmianę na mocki w testach.

```
// Łatwe do testowania
class OrderService {
    constructor(
        private repo: OrderRepository,
        private payments: PaymentGateway
    ) {}
}

// W teście
const service = new OrderService(mockRepo, mockPayments);
```

### Interfejsy i abstrakcje
Programuj pod interfejs — w testach podmień implementację.

### Determinizm
- Unikaj zależności od czasu (wstrzykuj zegar)
- Unikaj zależności od losowości (wstrzykuj generator)
- Unikaj zależności od systemu plików (abstrakcja)

---

## Test Doubles

| Typ | Opis |
|-----|------|
| **Stub** | Zwraca z góry ustaloną wartość |
| **Mock** | Weryfikuje czy metoda została wywołana |
| **Fake** | Uproszczona implementacja (np. in-memory DB) |
| **Spy** | Prawdziwy obiekt z nagrywaniem wywołań |
| **Dummy** | Wypełniacz — nie jest używany w teście |
