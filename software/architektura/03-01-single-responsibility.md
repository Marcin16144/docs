# 03-01: Single Responsibility Principle (SRP) — Zasada pojedynczej odpowiedzialności

## Czym jest SRP?

Zasada pojedynczej odpowiedzialności mówi, że **klasa powinna mieć tylko jeden powód do zmiany**. Sformułował ją Robert C. Martin (Uncle Bob), precyzując później definicję: klasa powinna być odpowiedzialna wobec jednego i tylko jednego aktora (grupy użytkowników lub interesariuszy).

SRP nie oznacza, że klasa powinna robić "jedną rzecz" — to uproszczenie. Chodzi o to, by zmiany wymagane przez jednego aktora nie wpływały na logikę potrzebną innemu aktorowi.

## Jak rozpoznać naruszenie SRP?

Zadaj sobie pytania:
- Ile różnych powodów może spowodować zmianę tej klasy?
- Ile różnych osób/zespołów mogłoby poprosić o zmianę w tej klasie?
- Czy opis klasy wymaga użycia słowa "i" lub "lub"?

### Sygnały ostrzegawcze

- Klasa ma wiele metod niepowiązanych ze sobą
- Klasa importuje zależności z wielu różnych warstw
- Testy klasy wymagają mockowania wielu różnych zależności
- Klasa zmienia się przy każdym nowym wymaganiu, niezależnie od jego natury

## Przykład 1: Klasa raportu — złe podejście

```typescript
// ZLE — klasa odpowiada za obliczenia, formatowanie i zapis
class EmployeeReport {
    constructor(private db: Database) {}

    calculatePay(employeeId: string): number {
        const employee = this.db.find(employeeId);
        const hours = this.db.getHours(employeeId);
        // logika obliczania wynagrodzenia
        if (employee.type === 'fulltime') {
            return employee.salary / 12;
        }
        return hours * employee.hourlyRate;
    }

    formatAsHTML(employeeId: string): string {
        const pay = this.calculatePay(employeeId);
        return `<div class="report">
            <h1>Raport wynagrodzen</h1>
            <p>Kwota: ${pay} PLN</p>
        </div>`;
    }

    saveToFile(employeeId: string, path: string): void {
        const html = this.formatAsHTML(employeeId);
        fs.writeFileSync(path, html);
    }

    sendByEmail(employeeId: string, email: string): void {
        const html = this.formatAsHTML(employeeId);
        this.mailer.send(email, 'Raport', html);
    }
}
```

Aktorzy, którzy mogą wymagać zmian:
- **Dział HR** — zmienia zasady obliczania wynagrodzeń
- **Dział IT/UX** — zmienia format HTML raportu
- **Dział operacyjny** — zmienia sposób zapisu lub wysyłki

## Przykład 1: Po refaktoryzacji — dobre podejście

```typescript
// DOBRZE — rozdzielone odpowiedzialnosci

class PayCalculator {
    constructor(private db: Database) {}

    calculate(employeeId: string): Money {
        const employee = this.db.find(employeeId);
        const hours = this.db.getHours(employeeId);
        if (employee.type === 'fulltime') {
            return Money.of(employee.salary / 12);
        }
        return Money.of(hours * employee.hourlyRate);
    }
}

class ReportFormatter {
    formatAsHTML(data: ReportData): string {
        return `<div class="report">
            <h1>${data.title}</h1>
            <p>Kwota: ${data.amount} PLN</p>
        </div>`;
    }

    formatAsPDF(data: ReportData): Buffer {
        // generowanie PDF
    }
}

class ReportDistributor {
    constructor(
        private fileSystem: FileSystem,
        private mailer: Mailer
    ) {}

    saveToFile(content: string, path: string): void {
        this.fileSystem.write(path, content);
    }

    sendByEmail(content: string, recipient: string): void {
        this.mailer.send(recipient, 'Raport', content);
    }
}
```

## Przykład 2: Moduł użytkownika — złe podejście

```python
# ZLE — modul laczy autentykacje, logike biznesowa i persystencje
class UserService:
    def authenticate(self, username: str, password: str) -> bool:
        user = self.db.query(f"SELECT * FROM users WHERE username='{username}'")
        return bcrypt.check(password, user.password_hash)

    def update_profile(self, user_id: int, data: dict) -> None:
        if 'email' in data:
            self._validate_email(data['email'])
        self.db.execute(f"UPDATE users SET ... WHERE id={user_id}")
        self._send_profile_update_notification(user_id)

    def generate_monthly_report(self, user_id: int) -> str:
        activities = self.db.query(f"SELECT * FROM activities WHERE user_id={user_id}")
        return self._format_report(activities)

    def _validate_email(self, email: str) -> bool:
        # walidacja email
        pass

    def _send_profile_update_notification(self, user_id: int) -> None:
        # wysylanie notyfikacji
        pass

    def _format_report(self, activities: list) -> str:
        # formatowanie raportu
        pass
```

## Przykład 2: Po refaktoryzacji

```python
# DOBRZE — kazdy serwis odpowiada za jednego aktora

class AuthenticationService:
    def __init__(self, user_repo: UserRepository, hasher: PasswordHasher):
        self.user_repo = user_repo
        self.hasher = hasher

    def authenticate(self, username: str, password: str) -> AuthResult:
        user = self.user_repo.find_by_username(username)
        if not user:
            return AuthResult.failed("Nie znaleziono uzytkownika")
        if not self.hasher.verify(password, user.password_hash):
            return AuthResult.failed("Nieprawidlowe haslo")
        return AuthResult.success(user)


class ProfileService:
    def __init__(self, user_repo: UserRepository, validator: ProfileValidator,
                 notifier: NotificationService):
        self.user_repo = user_repo
        self.validator = validator
        self.notifier = notifier

    def update(self, user_id: int, data: ProfileUpdateDTO) -> None:
        self.validator.validate(data)
        self.user_repo.update(user_id, data)
        self.notifier.profile_updated(user_id)


class ActivityReportService:
    def __init__(self, activity_repo: ActivityRepository,
                 formatter: ReportFormatter):
        self.activity_repo = activity_repo
        self.formatter = formatter

    def generate_monthly(self, user_id: int, month: int) -> Report:
        activities = self.activity_repo.find_by_month(user_id, month)
        return self.formatter.format(activities)
```

## Przykład 3: SRP na poziomie modułów

SRP dotyczy nie tylko klas, ale również modułów i pakietów.

```
# ZLE — modul "utils" to worek na wszystko
src/
  utils/
    string-helpers.ts
    date-helpers.ts
    http-client.ts
    logger.ts
    cache.ts
    validators.ts

# DOBRZE — moduly pogrupowane wedlug odpowiedzialnosci
src/
  formatting/
    string-formatter.ts
    date-formatter.ts
  infrastructure/
    http-client.ts
    logger.ts
    cache.ts
  validation/
    email-validator.ts
    phone-validator.ts
```

## Techniki refaktoryzacji ku SRP

### Extract Class
Wydziel grupę powiązanych pól i metod do nowej klasy.

### Extract Interface
Zdefiniuj interfejs dla każdej odpowiedzialności, nawet jeśli implementacja jest wspólna.

### Move Method
Przenieś metodę do klasy, która lepiej pasuje do jej odpowiedzialności.

### Fasada jako krok pośredni
Jeśli istniejący kod jest zbyt mocno powiązany, zachowaj starą klasę jako fasadę delegującą do nowych klas:

```typescript
// Krok posredni — stara klasa deleguje do nowych
class EmployeeReport {
    private calculator: PayCalculator;
    private formatter: ReportFormatter;
    private distributor: ReportDistributor;

    // Stare metody deleguja — istniejacy kod nie wymaga zmian
    calculatePay(id: string) {
        return this.calculator.calculate(id);
    }

    formatAsHTML(id: string) {
        const data = this.buildReportData(id);
        return this.formatter.formatAsHTML(data);
    }
}
```

## Kiedy SRP jest stosowane zbyt agresywnie?

SRP może prowadzić do nadmiernej fragmentacji kodu:

```
// PRZESADA — kazda metoda w osobnej klasie
class EmailValidator { validate(email) {} }
class EmailSanitizer { sanitize(email) {} }
class EmailNormalizer { normalize(email) {} }

// ROZSADNIE — powiazane operacje na emailu w jednej klasie
class EmailProcessor {
    validate(email: string): ValidationResult { ... }
    sanitize(email: string): string { ... }
    normalize(email: string): string { ... }
}
```

Kluczowa różnica: wszystkie te metody zmieniają się z tego samego powodu (zmiana wymagań dotyczących emaili), więc naturalnie należą do jednej klasy.

## Podsumowanie

- SRP to "jeden powód do zmiany", nie "jedna metoda"
- Identyfikuj aktorów — kto może wymagać zmian w danej klasie?
- Refaktoryzuj stopniowo — fasada pozwala na bezpieczne przejście
- Nie przesadzaj — zbyt drobny podział też jest kosztowny
- Stosuj SRP na każdym poziomie: klasy, moduły, mikroserwisy
