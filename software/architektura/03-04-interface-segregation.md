# 03-04: Interface Segregation Principle (ISP) — Zasada segregacji interfejsów

## Czym jest ISP?

Zasada segregacji interfejsów mówi: **klienty nie powinny być zmuszane do zależności od interfejsów, których nie używają**. Zamiast jednego dużego, "tłustego" interfejsu, lepiej zdefiniować wiele małych, specyficznych interfejsów dopasowanych do potrzeb klientów.

ISP to zasada dotycząca projektowania granic między komponentami. Zbyt szerokie interfejsy tworzą niepotrzebne zależności i utrudniają testowanie, refaktoryzację oraz ponowne użycie kodu.

## Problem "tłustego" interfejsu

```typescript
// ZLE — "tlusty" interfejs wymusza implementacje niepotrzebnych metod

interface Worker {
    work(): void;
    eat(): void;
    sleep(): void;
    attendMeeting(): void;
    writeReport(): void;
    driveCompanyCar(): void;
}

// Pracownik biurowy — uzywa wszystkiego
class OfficeWorker implements Worker {
    work() { /* OK */ }
    eat() { /* OK */ }
    sleep() { /* OK */ }
    attendMeeting() { /* OK */ }
    writeReport() { /* OK */ }
    driveCompanyCar() { /* OK */ }
}

// Robot na linii produkcyjnej — nie je, nie spi, nie jezdzi autem
class RobotWorker implements Worker {
    work() { /* OK */ }
    eat() { throw new Error("Robot nie je!"); }
    sleep() { throw new Error("Robot nie spi!"); }
    attendMeeting() { throw new Error("Robot nie chodzi na spotkania!"); }
    writeReport() { throw new Error("Robot nie pisze raportow!"); }
    driveCompanyCar() { throw new Error("Robot nie jezdzi autem!"); }
}
```

Problemy:
- RobotWorker musi implementować metody, których nie obsługuje
- Rzucanie wyjątków narusza LSP
- Zmiana w `Worker` (np. nowa metoda) wymusza zmiany we wszystkich implementacjach
- Testy wymagają mockowania niepotrzebnych metod

## Rozwiązanie: Małe, rolowe interfejsy

```typescript
// DOBRZE — male, skoncentrowane interfejsy

interface Workable {
    work(): void;
}

interface Feedable {
    eat(): void;
    sleep(): void;
}

interface MeetingAttendee {
    attendMeeting(): void;
}

interface ReportWriter {
    writeReport(): void;
}

interface CompanyCarDriver {
    driveCompanyCar(): void;
}

// Pracownik biurowy implementuje to, czego potrzebuje
class OfficeWorker implements Workable, Feedable,
    MeetingAttendee, ReportWriter, CompanyCarDriver {
    work() { /* ... */ }
    eat() { /* ... */ }
    sleep() { /* ... */ }
    attendMeeting() { /* ... */ }
    writeReport() { /* ... */ }
    driveCompanyCar() { /* ... */ }
}

// Robot implementuje TYLKO Workable
class RobotWorker implements Workable {
    work() { /* ... */ }
}

// Funkcje przyjmuja dokladnie to, czego potrzebuja
function scheduleWork(worker: Workable): void {
    worker.work();
}

function scheduleLunch(worker: Feedable): void {
    worker.eat();
}
```

## Przykład 2: Repozytorium danych

```python
# ZLE — jedno repozytorium ze wszystkimi operacjami

class UserRepository:
    def find_by_id(self, id: int) -> User: ...
    def find_all(self) -> list[User]: ...
    def find_by_email(self, email: str) -> User: ...
    def save(self, user: User) -> None: ...
    def update(self, user: User) -> None: ...
    def delete(self, id: int) -> None: ...
    def count(self) -> int: ...
    def exists(self, id: int) -> bool: ...
    def find_by_role(self, role: str) -> list[User]: ...
    def bulk_insert(self, users: list[User]) -> None: ...
    def export_to_csv(self) -> str: ...        # co to robi w repo?
    def send_welcome_email(self, user: User): ... # i to?
```

Problem: serwis, który potrzebuje tylko odczytu, jest zależny od metod zapisu, usuwania, eksportu i wysyłki emaili.

```python
# DOBRZE — interfejsy wedlug ról

from abc import ABC, abstractmethod

class UserReader(ABC):
    @abstractmethod
    def find_by_id(self, id: int) -> User: ...

    @abstractmethod
    def find_by_email(self, email: str) -> User: ...

    @abstractmethod
    def find_all(self) -> list[User]: ...


class UserWriter(ABC):
    @abstractmethod
    def save(self, user: User) -> None: ...

    @abstractmethod
    def update(self, user: User) -> None: ...


class UserRemover(ABC):
    @abstractmethod
    def delete(self, id: int) -> None: ...


class BulkUserOperations(ABC):
    @abstractmethod
    def bulk_insert(self, users: list[User]) -> None: ...

    @abstractmethod
    def count(self) -> int: ...


# Implementacja moze realizowac wiele interfejsow
class SqlUserRepository(UserReader, UserWriter, UserRemover, BulkUserOperations):
    def find_by_id(self, id: int) -> User:
        return self.db.query("SELECT * FROM users WHERE id = %s", id)

    def find_by_email(self, email: str) -> User:
        return self.db.query("SELECT * FROM users WHERE email = %s", email)

    def find_all(self) -> list[User]:
        return self.db.query("SELECT * FROM users")

    def save(self, user: User) -> None:
        self.db.execute("INSERT INTO users ...", user)

    def update(self, user: User) -> None:
        self.db.execute("UPDATE users SET ... WHERE id = %s", user)

    def delete(self, id: int) -> None:
        self.db.execute("DELETE FROM users WHERE id = %s", id)

    def bulk_insert(self, users: list[User]) -> None:
        self.db.execute_many("INSERT INTO users ...", users)

    def count(self) -> int:
        return self.db.query_scalar("SELECT COUNT(*) FROM users")


# Serwisy deklaruja DOKLADNIE to, czego potrzebuja
class UserProfileService:
    def __init__(self, reader: UserReader, writer: UserWriter):
        self.reader = reader
        self.writer = writer

    def update_email(self, user_id: int, new_email: str):
        user = self.reader.find_by_id(user_id)
        user.email = new_email
        self.writer.update(user)


class UserReportService:
    def __init__(self, reader: UserReader):  # tylko odczyt!
        self.reader = reader

    def generate_report(self) -> str:
        users = self.reader.find_all()
        return format_report(users)
```

## Przykład 3: Adapter pattern dla ISP

Gdy pracujesz z zewnętrzną biblioteką, która ma "tłusty" interfejs, użyj adaptera.

```typescript
// Zewnetrzna biblioteka z szerokim API
interface CloudProvider {
    createVM(config: VMConfig): VM;
    deleteVM(id: string): void;
    listVMs(): VM[];
    createStorage(config: StorageConfig): Storage;
    deleteStorage(id: string): void;
    listStorage(): Storage[];
    createNetwork(config: NetworkConfig): Network;
    // ... 50 kolejnych metod
}

// Twoj kod potrzebuje tylko VM
interface VMManager {
    create(config: VMConfig): VM;
    delete(id: string): void;
    list(): VM[];
}

// Adapter zaweza interfejs do potrzeb klienta
class CloudVMManager implements VMManager {
    constructor(private cloud: CloudProvider) {}

    create(config: VMConfig): VM {
        return this.cloud.createVM(config);
    }

    delete(id: string): void {
        this.cloud.deleteVM(id);
    }

    list(): VM[] {
        return this.cloud.listVMs();
    }
}

// Twoj serwis zalezy od waskiego interfejsu
class DeploymentService {
    constructor(private vms: VMManager) {} // nie caly CloudProvider!

    deploy(app: Application): void {
        const vm = this.vms.create({
            cpu: app.requiredCPU,
            memory: app.requiredMemory
        });
        // ...
    }
}
```

## Przykład 4: ISP w konfiguracji

```typescript
// ZLE — jeden obiekt konfiguracji dla calej aplikacji
interface AppConfig {
    dbHost: string;
    dbPort: number;
    dbUser: string;
    dbPassword: string;
    redisHost: string;
    redisPort: number;
    smtpHost: string;
    smtpPort: number;
    smtpUser: string;
    logLevel: string;
    logFile: string;
    jwtSecret: string;
    jwtExpiry: number;
}

// Serwis emailowy widzi haslo do bazy danych!
class EmailService {
    constructor(private config: AppConfig) {
        // uzywa tylko smtp*, ale widzi wszystko
    }
}

// DOBRZE — wydzielone konfiguracje
interface DatabaseConfig {
    host: string;
    port: number;
    user: string;
    password: string;
}

interface SmtpConfig {
    host: string;
    port: number;
    user: string;
}

interface LogConfig {
    level: string;
    file: string;
}

class EmailService {
    constructor(private smtp: SmtpConfig) {
        // widzi TYLKO konfiguracje SMTP
    }
}
```

## Sygnały naruszenia ISP

- Implementacje zawierają metody rzucające `NotImplementedError`
- Interfejs ma więcej niż 5-7 metod
- Klasy implementujące interfejs mają wiele pustych metod
- Testy wymagają mockowania metod, których testowany kod nie wywołuje
- Zmiana w interfejsie wymusza zmiany w klasach, które nie korzystają ze zmienionej metody

## ISP a inne zasady SOLID

| Relacja | Powiązanie |
|---------|-----------|
| ISP + SRP | ISP na poziomie interfejsów, SRP na poziomie klas |
| ISP + LSP | Małe interfejsy zmniejszają ryzyko naruszenia LSP |
| ISP + DIP | Małe interfejsy ułatwiają wstrzykiwanie zależności |
| ISP + OCP | Nowe interfejsy rozszerzają system bez modyfikacji istniejących |

## Podsumowanie

- Nie zmuszaj klientów do zależności od metod, których nie używają
- Preferuj wiele małych interfejsów nad jeden duży
- Interfejs powinien być definiowany z perspektywy klienta, nie implementacji
- Adapter pomaga zawęzić zbyt szerokie interfejsy zewnętrznych bibliotek
- ISP poprawia testowalność — mniej mocków, precyzyjniejsze zależności
