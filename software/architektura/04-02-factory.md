# 04-02: Factory Method i Abstract Factory

## Idea wzorców fabrykujących

Wzorce fabrykujące rozwiązują problem tworzenia obiektów bez konieczności specyfikowania dokładnej klasy. Zamiast wywoływać `new KonkretnaKlasa()` w kodzie klienta, delegujemy decyzję o typie tworzonego obiektu do wyspecjalizowanej fabryki.

## Simple Factory (prosta fabryka)

Najprostsze podejście — statyczna metoda lub klasa, która na podstawie parametru tworzy odpowiedni obiekt. Nie jest formalnym wzorcem GoF, ale jest powszechnie stosowana.

```typescript
interface PaymentProcessor {
    charge(amount: number): Promise<PaymentResult>;
    refund(transactionId: string): Promise<void>;
}

class StripeProcessor implements PaymentProcessor {
    async charge(amount: number) { /* ... */ }
    async refund(transactionId: string) { /* ... */ }
}

class PayPalProcessor implements PaymentProcessor {
    async charge(amount: number) { /* ... */ }
    async refund(transactionId: string) { /* ... */ }
}

// Simple Factory
class PaymentProcessorFactory {
    static create(type: string): PaymentProcessor {
        switch (type) {
            case 'stripe': return new StripeProcessor();
            case 'paypal': return new PayPalProcessor();
            default: throw new Error(`Nieznany procesor: ${type}`);
        }
    }
}

const processor = PaymentProcessorFactory.create('stripe');
```

**Zalety:** prostota, centralizacja logiki tworzenia.
**Wady:** każdy nowy typ wymaga modyfikacji fabryki (łamie Open/Closed Principle).

## Factory Method (metoda fabrykująca)

Definiuje interfejs do tworzenia obiektu, ale pozwala podklasom zdecydować, którą klasę instancjonować. Tworzenie obiektów delegowane jest do podklas.

```typescript
// Abstrakcyjna klasa z metodą fabrykującą
abstract class NotificationService {
    // Factory Method — podklasy decydują co tworzyć
    protected abstract createSender(): NotificationSender;

    async sendNotification(userId: string, message: string): Promise<void> {
        const sender = this.createSender();
        const user = await this.getUser(userId);
        await sender.send(user.contact, message);
        await this.logNotification(userId, message);
    }

    private async getUser(id: string) { /* ... */ }
    private async logNotification(userId: string, msg: string) { /* ... */ }
}

// Konkretne implementacje
class EmailNotificationService extends NotificationService {
    protected createSender(): NotificationSender {
        return new EmailSender(this.smtpConfig);
    }
}

class SmsNotificationService extends NotificationService {
    protected createSender(): NotificationSender {
        return new SmsSender(this.smsGatewayConfig);
    }
}

class PushNotificationService extends NotificationService {
    protected createSender(): NotificationSender {
        return new PushSender(this.firebaseConfig);
    }
}
```

**Kluczowa różnica od Simple Factory:** logika tworzenia jest w podklasach, nie w jednej metodzie z switchem. Dodanie nowego typu = nowa podklasa, bez modyfikacji istniejącego kodu.

## Abstract Factory (fabryka abstrakcyjna)

Zapewnia interfejs do tworzenia rodzin powiązanych obiektów bez specyfikowania ich konkretnych klas. Używana gdy system musi być niezależny od sposobu tworzenia i składania swoich produktów.

```typescript
// Rodzina powiązanych produktów
interface Button { render(): void; onClick(handler: () => void): void; }
interface TextInput { render(): void; getValue(): string; }
interface Modal { open(): void; close(): void; }

// Fabryka abstrakcyjna
interface UIComponentFactory {
    createButton(label: string): Button;
    createTextInput(placeholder: string): TextInput;
    createModal(title: string): Modal;
}

// Konkretna fabryka — Material Design
class MaterialUIFactory implements UIComponentFactory {
    createButton(label: string): Button {
        return new MaterialButton(label);
    }
    createTextInput(placeholder: string): TextInput {
        return new MaterialTextInput(placeholder);
    }
    createModal(title: string): Modal {
        return new MaterialModal(title);
    }
}

// Konkretna fabryka — Bootstrap
class BootstrapUIFactory implements UIComponentFactory {
    createButton(label: string): Button {
        return new BootstrapButton(label);
    }
    createTextInput(placeholder: string): TextInput {
        return new BootstrapTextInput(placeholder);
    }
    createModal(title: string): Modal {
        return new BootstrapModal(title);
    }
}

// Kod klienta — niezależny od konkretnej biblioteki UI
class LoginForm {
    constructor(private uiFactory: UIComponentFactory) {}

    render() {
        const emailInput = this.uiFactory.createTextInput('Email');
        const passwordInput = this.uiFactory.createTextInput('Haslo');
        const submitBtn = this.uiFactory.createButton('Zaloguj');
        // ...
    }
}
```

## System pluginów z fabrykami

Fabryki doskonale sprawdzają się w systemach pluginów, gdzie nowe rozszerzenia mogą być dodawane bez modyfikacji kodu bazowego.

```typescript
// Rejestr pluginów z fabrykami
interface ExportPlugin {
    export(data: ReportData): Buffer;
    mimeType: string;
    fileExtension: string;
}

type PluginFactory = () => ExportPlugin;

class ExportPluginRegistry {
    private factories = new Map<string, PluginFactory>();

    register(format: string, factory: PluginFactory): void {
        this.factories.set(format, factory);
    }

    create(format: string): ExportPlugin {
        const factory = this.factories.get(format);
        if (!factory) {
            throw new Error(`Nieznany format eksportu: ${format}`);
        }
        return factory();
    }

    getAvailableFormats(): string[] {
        return Array.from(this.factories.keys());
    }
}

// Rejestracja pluginów — może być w osobnych modułach
const registry = new ExportPluginRegistry();
registry.register('pdf', () => new PdfExporter());
registry.register('csv', () => new CsvExporter());
registry.register('xlsx', () => new ExcelExporter());

// Nowy plugin nie wymaga zmiany istniejącego kodu
registry.register('parquet', () => new ParquetExporter());
```

## Porównanie trzech podejść

| Cecha | Simple Factory | Factory Method | Abstract Factory |
|-------|---------------|----------------|-----------------|
| Złożoność | Niska | Średnia | Wysoka |
| Open/Closed | Łamie (switch) | Respektuje | Respektuje |
| Liczba produktów | Jeden typ | Jeden typ | Rodzina typów |
| Rozszerzalność | Modyfikacja fabryki | Nowa podklasa | Nowa fabryka |
| Kiedy stosować | Proste przypadki | Jeden produkt, wiele wariantów | Rodziny powiązanych produktów |

## Praktyczne wskazówki

- **Zacznij od Simple Factory** — refaktoruj do Factory Method gdy pojawi się potrzeba rozszerzalności
- **Abstract Factory** stosuj gdy masz rodziny powiązanych obiektów (np. cały zestaw UI, cała konfiguracja środowiska)
- Fabryki dobrze łączą się z **Dependency Injection** — kontener DI sam jest rodzajem fabryki
- Unikaj fabryk dla prostych obiektów — nie każde `new` wymaga fabryki
- Preferuj **kompozycję i interfejsy** nad hierarchię dziedziczenia w fabrykach
