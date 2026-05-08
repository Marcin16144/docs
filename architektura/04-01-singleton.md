# 04-01: Wzorzec Singleton

## Czym jest Singleton?

Singleton to wzorzec kreacyjny, który gwarantuje, że dana klasa ma dokładnie jedną instancję w całej aplikacji i zapewnia globalny punkt dostępu do tej instancji. Jest jednym z najprostszych wzorców projektowych, ale jednocześnie jednym z najczęściej nadużywanych.

## Kiedy stosować Singleton?

Singleton ma sens gdy:
- Zasób jest z natury pojedynczy (np. pula połączeń do bazy danych)
- Tworzenie wielu instancji byłoby kosztowne lub niebezpieczne
- Potrzebujesz centralnego punktu koordynacji (np. logger, konfiguracja)

## Implementacja Lazy (leniwa)

Instancja tworzona dopiero przy pierwszym użyciu. Oszczędza zasoby, ale w środowisku wielowątkowym wymaga dodatkowej synchronizacji.

```typescript
class ConfigManager {
    private static instance: ConfigManager | null = null;
    private settings: Map<string, string> = new Map();

    private constructor() {
        // Prywatny konstruktor blokuje tworzenie przez new
    }

    static getInstance(): ConfigManager {
        if (!ConfigManager.instance) {
            ConfigManager.instance = new ConfigManager();
        }
        return ConfigManager.instance;
    }

    get(key: string): string | undefined {
        return this.settings.get(key);
    }

    set(key: string, value: string): void {
        this.settings.set(key, value);
    }
}
```

## Implementacja Eager (zachłanna)

Instancja tworzona natychmiast przy załadowaniu klasy. Prostsza, bezpieczna wątkowo, ale zużywa zasoby nawet jeśli nigdy nie zostanie użyta.

```typescript
class AppLogger {
    private static readonly instance = new AppLogger();

    private constructor() {}

    static getInstance(): AppLogger {
        return AppLogger.instance;
    }

    log(message: string): void {
        console.log(`[${new Date().toISOString()}] ${message}`);
    }
}
```

## Implementacja Thread-Safe (bezpieczna wątkowo)

W językach z prawdziwą wielowątkowością (Java, C#) leniwy Singleton wymaga synchronizacji. Popularnym rozwiązaniem jest Double-Checked Locking.

```java
public class ConnectionPool {
    private static volatile ConnectionPool instance;

    private ConnectionPool() {
        // Inicjalizacja puli połączeń
    }

    public static ConnectionPool getInstance() {
        if (instance == null) {                    // Pierwszy check (bez locka)
            synchronized (ConnectionPool.class) {
                if (instance == null) {            // Drugi check (z lockiem)
                    instance = new ConnectionPool();
                }
            }
        }
        return instance;
    }
}
```

Słowo kluczowe `volatile` zapobiega problemowi z reorderingiem instrukcji — bez niego inny wątek mógłby zobaczyć częściowo zainicjalizowany obiekt.

## Registry Pattern jako alternatywa

Zamiast tworzyć wiele klas Singleton, można użyć wzorca Registry — centralnego rejestru instancji zarządzanych jako singletony.

```typescript
class ServiceRegistry {
    private static services: Map<string, any> = new Map();

    static register<T>(key: string, instance: T): void {
        if (ServiceRegistry.services.has(key)) {
            throw new Error(`Serwis '${key}' jest już zarejestrowany`);
        }
        ServiceRegistry.services.set(key, instance);
    }

    static resolve<T>(key: string): T {
        const service = ServiceRegistry.services.get(key);
        if (!service) {
            throw new Error(`Serwis '${key}' nie znaleziony`);
        }
        return service as T;
    }
}

// Rejestracja
ServiceRegistry.register('logger', new AppLogger());
ServiceRegistry.register('config', new ConfigManager());

// Użycie
const logger = ServiceRegistry.resolve<AppLogger>('logger');
```

## Dependency Injection vs Singleton

We współczesnych aplikacjach kontenery DI (Dependency Injection) są preferowaną alternatywą dla Singletona. Kontener zarządza cyklem życia obiektów, a klasa nie musi wiedzieć, że jest singletonem.

```typescript
// Singleton przez DI container (np. NestJS, Angular)
@Injectable({ providedIn: 'root' })  // Angular — singleton w scope roota
class UserService {
    // Zwykła klasa — nie wie, że jest singletonem
    constructor(private http: HttpClient) {}

    getUser(id: string): Observable<User> {
        return this.http.get<User>(`/api/users/${id}`);
    }
}
```

| Cecha | Singleton klasyczny | Dependency Injection |
|-------|-------------------|---------------------|
| Kontrola cyklu życia | Klasa sama sobą zarządza | Kontener zarządza |
| Testowalność | Trudna (stan globalny) | Łatwa (wstrzykiwanie mocków) |
| Coupling | Wysoki (klasa zna szczegóły) | Niski (interfejs) |
| Konfiguracja scope | Sztywna (zawsze global) | Elastyczna (request, session, singleton) |

## Problemy z testowaniem

Singleton jest jednym z najtrudniejszych wzorców do testowania, ponieważ:

1. **Stan globalny** — testy wpływają na siebie nawzajem, bo dzielą tę samą instancję
2. **Trudność mockowania** — nie można łatwo podmienić instancji na mock
3. **Ukryte zależności** — klasa korzysta z Singletona wewnętrznie, co nie jest widoczne z zewnątrz
4. **Kolejność testów ma znaczenie** — stan z poprzedniego testu przecieka do następnego

```typescript
// Problem: testy wpływają na siebie
test('test A ustawia config', () => {
    ConfigManager.getInstance().set('mode', 'test');
    // ...
});

test('test B zakłada czysty config', () => {
    // FAIL! 'mode' wciąż jest 'test' z poprzedniego testu
    expect(ConfigManager.getInstance().get('mode')).toBeUndefined();
});

// Rozwiązanie: metoda resetująca (tylko na potrzeby testów)
class ConfigManager {
    // ...
    static resetForTesting(): void {
        ConfigManager.instance = null;
    }
}

// Lub lepiej: użyj DI i wstrzykuj nową instancję w każdym teście
```

## Singleton w kontekście modułów ES

W nowoczesnym JavaScript/TypeScript moduły ES same w sobie działają jak singletony — plik modułu jest wykonywany raz, a eksportowane wartości są współdzielone.

```typescript
// config.ts — "naturalny singleton" dzięki modułom
const config = {
    dbHost: process.env.DB_HOST || 'localhost',
    dbPort: parseInt(process.env.DB_PORT || '5432'),
    logLevel: process.env.LOG_LEVEL || 'info',
};

export default Object.freeze(config);

// Każdy import dostaje tę samą referencję
import config from './config';
```

## Podsumowanie

- Singleton gwarantuje jedną instancję klasy w aplikacji
- Implementacja lazy jest oszczędna, eager jest bezpieczna wątkowo, double-checked łączy obie cechy
- Registry Pattern centralizuje zarządzanie wieloma singletonami
- Dependency Injection jest preferowaną alternatywą w nowoczesnych aplikacjach
- Singleton utrudnia testowanie przez stan globalny i ukryte zależności
- Moduły ES oferują "naturalny singleton" bez potrzeby stosowania wzorca
