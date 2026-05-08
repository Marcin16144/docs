# Architektura Serverless

## Czym jest Serverless?

Serverless to model architektury, w którym **zarządzanie serwerami jest w pełni delegowane do dostawcy chmury**. Deweloper pisze wyłącznie kod funkcji biznesowych, a infrastruktura (serwery, skalowanie, patching) jest zarządzana automatycznie. Płacisz tylko za faktyczne wykorzystanie zasobów — zero ruchu = zero kosztów.

```
Tradycyjne podejście:                Serverless:

┌──────────────────────┐             ┌──────────────┐
│  Twój serwer 24/7    │             │  Funkcja A   │ ← uruchamiana
│  (płacisz za czas)   │             │  (event)     │   na żądanie
│                      │             └──────────────┘
│  ┌────────────────┐  │             ┌──────────────┐
│  │  Twoja         │  │             │  Funkcja B   │ ← uruchamiana
│  │  aplikacja     │  │             │  (event)     │   na żądanie
│  └────────────────┘  │             └──────────────┘
│                      │             ┌──────────────┐
│  OS, runtime,        │             │  Funkcja C   │ ← uruchamiana
│  patching, scaling   │             │  (event)     │   na żądanie
└──────────────────────┘             └──────────────┘
  Płacisz: zawsze                     Płacisz: per wywołanie
```

## Dwa filary Serverless

### FaaS — Function as a Service
Kod uruchamiany w odpowiedzi na zdarzenia:

```
Zdarzenie ──► [FaaS Platform] ──► Funkcja ──► Wynik

Przykłady platform:
- AWS Lambda
- Azure Functions
- Google Cloud Functions
- Cloudflare Workers
- Vercel Edge Functions
```

### BaaS — Backend as a Service
Gotowe usługi backendowe dostępne przez API:

```
┌─────────────────────────────────────────────┐
│              Backend as a Service            │
│                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │   Auth   │ │ Database │ │  Storage │   │
│  │ (Cognito)│ │(DynamoDB)│ │   (S3)   │   │
│  └──────────┘ └──────────┘ └──────────┘   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │   Push   │ │  Search  │ │   AI/ML  │   │
│  │  (SNS)   │ │(Algolia) │ │(Bedrock) │   │
│  └──────────┘ └──────────┘ └──────────┘   │
└─────────────────────────────────────────────┘
```

## Anatomia funkcji serverless

### AWS Lambda — przykład

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Orders')

def handler(event, context):
    """
    event   — dane wejściowe (request HTTP, message z SQS, etc.)
    context — metadane runtime (timeout, memory, request ID)
    """
    
    # Parsowanie requestu z API Gateway
    body = json.loads(event['body'])
    
    # Logika biznesowa
    order_id = create_order(body)
    
    # Zapis do DynamoDB
    table.put_item(Item={
        'orderId': order_id,
        'customerId': body['customerId'],
        'items': body['items'],
        'status': 'created'
    })
    
    return {
        'statusCode': 201,
        'body': json.dumps({'orderId': order_id}),
        'headers': {'Content-Type': 'application/json'}
    }
```

### Azure Functions — przykład

```csharp
[Function("CreateOrder")]
public async Task<HttpResponseData> CreateOrder(
    [HttpTrigger(AuthorizationLevel.Function, "post")] 
    HttpRequestData req)
{
    var body = await req.ReadFromJsonAsync<CreateOrderRequest>();
    
    var order = new Order(body.CustomerId, body.Items);
    await _orderRepository.Save(order);
    
    var response = req.CreateResponse(HttpStatusCode.Created);
    await response.WriteAsJsonAsync(new { order.Id });
    return response;
}
```

## Cold Start — problem zimnego startu

```
Pierwsze wywołanie (Cold Start):
┌─────────┐  ┌───────────┐  ┌──────────┐  ┌──────────┐
│ Download│→│ Init      │→│ Bootstrap│→│ Execute  │
│ code    │  │ container │  │ runtime  │  │ function │
│ ~50ms   │  │ ~200ms    │  │ ~300ms   │  │ ~100ms   │
└─────────┘  └───────────┘  └──────────┘  └──────────┘
                                          Total: ~650ms

Kolejne wywołania (Warm Start):
                                         ┌──────────┐
                               ────────→│ Execute  │
                                         │ function │
                                         │ ~100ms   │
                                         └──────────┘
                                          Total: ~100ms
```

### Typowe czasy Cold Start

| Runtime | Cold Start | Warm |
|---------|-----------|------|
| Python | 200-500ms | 5-50ms |
| Node.js | 150-400ms | 5-50ms |
| Go | 50-150ms | 1-10ms |
| Java (JVM) | 1-5s | 10-50ms |
| .NET | 500ms-2s | 10-50ms |
| Rust | 30-100ms | 1-5ms |

### Strategie minimalizacji Cold Start
1. **Provisioned Concurrency** (AWS) — instancje zawsze gotowe
2. **Warmup triggers** — cykliczne "pingowanie" funkcji
3. **Mniejsze pakiety** — mniej kodu = szybszy start
4. **Lazy initialization** — inicjalizuj połączenia dopiero gdy potrzebne
5. **SnapStart** (Java/AWS) — snapshot JVM po inicjalizacji
6. **Lekkie runtime'y** — Go, Rust zamiast Java, .NET

## Limity wykonania

```
┌─────────────────────────────────────────────────────┐
│              Typowe limity FaaS                     │
│                                                     │
│  Timeout:           AWS Lambda: max 15 min          │
│                     Azure Functions: max 10 min     │
│                     (Consumption plan)              │
│                                                     │
│  Pamięć:            128 MB — 10 GB (Lambda)         │
│                                                     │
│  Payload:           6 MB sync, 256 KB async (Lambda)│
│                                                     │
│  Concurrent:        1000 domyślnie (Lambda)         │
│                     (zwiększalne przez request)      │
│                                                     │
│  Temp storage:      512 MB — 10 GB (/tmp)           │
│                                                     │
│  Deploy package:    50 MB (zip), 250 MB (unzipped)  │
└─────────────────────────────────────────────────────┘
```

### Implikacje limitów
- **Długie procesy** — nie nadaje się do zadań > 15 min (użyj Step Functions)
- **Duże pliki** — streaming do S3, nie przez Lambda
- **Stanowość** — funkcja jest bezstanowa, stan w DynamoDB/Redis
- **Połączenia DB** — pool connections zarządzany zewnętrznie (RDS Proxy)

## Model kosztów

### Pay-per-use — płacisz za wywołania

```
Koszt = (Liczba wywołań × Cena/wywołanie)
      + (GB-sekundy × Cena/GB-s)

AWS Lambda (przykład):
- $0.20 / milion wywołań
- $0.0000166667 / GB-sekunda

Przykładowe obliczenie:
- 1 mln wywołań / miesiąc
- 256 MB pamięci, 200ms średni czas

Koszt = $0.20 + (1M × 0.256GB × 0.2s × $0.0000166667)
      = $0.20 + $0.85
      = ~$1.05 / miesiąc

vs EC2 t3.micro: ~$7.50 / miesiąc (zawsze włączony)
```

### Kiedy Serverless jest tańszy?

```
Koszt
  ↑
  │        ╱ EC2 / Kontenery
  │       ╱  (stały koszt + rośnie wolniej)
  │      ╱
  │     ╱    ╱ Serverless
  │    ╱    ╱  (brak stałego kosztu, rośnie liniowo)
  │   ╱   ╱
  │  ╱  ╱
  │ ╱ ╱
  │╱╱
  │╱───────────────────────── Ruch
  └─────────────────────────►
  
  Niski ruch: Serverless wygrywa
  Wysoki stały ruch: EC2/kontenery wygrywają
  Punkt przejścia: ~1-5 mln wywołań/miesiąc (zależy od konfiguracji)
```

## Event Triggers — źródła zdarzeń

```
┌──────────────────────────────────────────────────┐
│              Źródła zdarzeń (AWS)                 │
│                                                  │
│  HTTP:        API Gateway → Lambda               │
│  Queue:       SQS → Lambda                       │
│  Stream:      Kinesis / DynamoDB Streams → Lambda │
│  Storage:     S3 (upload/delete) → Lambda         │
│  Schedule:    EventBridge (cron) → Lambda          │
│  Database:    DynamoDB → Lambda                    │
│  Auth:        Cognito triggers → Lambda            │
│  IoT:         IoT Core → Lambda                    │
│  Email:       SES → Lambda                         │
│  CDN:         CloudFront (Lambda@Edge)             │
└──────────────────────────────────────────────────┘
```

### Przykładowe scenariusze

```
1. Przetwarzanie obrazów:
   S3 upload → Lambda (resize) → S3 (thumbnails)

2. Webhook processing:
   API Gateway → Lambda → DynamoDB + SQS

3. Scheduled reports:
   EventBridge (cron: 0 8 * * MON) → Lambda → SES (email)

4. Real-time stream:
   Kinesis → Lambda → Elasticsearch + S3

5. API backend:
   API Gateway → Lambda → DynamoDB
                        → RDS (via RDS Proxy)
```

## Orkiestracja — Step Functions

Dla złożonych workflow'ów przekraczających limity pojedynczej funkcji:

```
┌────────────────────────────────────────────────┐
│            AWS Step Functions (Saga)            │
│                                                │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐   │
│  │ Waliduj │───►│ Pobierz │───►│ Nalicz  │   │
│  │zamówienie│    │ płatność│    │ punkty  │   │
│  └─────────┘    └────┬────┘    └────┬────┘   │
│                      │ fail         │         │
│                 ┌────▼────┐    ┌────▼────┐   │
│                 │ Anuluj  │    │ Wyślij  │   │
│                 │zamówienie│    │ email   │   │
│                 └─────────┘    └─────────┘   │
└────────────────────────────────────────────────┘
```

### Definicja Step Functions (ASL)

```json
{
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:ValidateOrder",
      "Next": "ProcessPayment",
      "Catch": [{
        "ErrorEquals": ["ValidationError"],
        "Next": "OrderFailed"
      }]
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:ProcessPayment",
      "Next": "SendConfirmation",
      "Catch": [{
        "ErrorEquals": ["PaymentError"],
        "Next": "CancelOrder"
      }]
    },
    "SendConfirmation": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:SendEmail",
      "End": true
    },
    "CancelOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:CancelOrder",
      "Next": "OrderFailed"
    },
    "OrderFailed": {
      "Type": "Fail",
      "Error": "OrderProcessingFailed"
    }
  }
}
```

## Vendor Lock-in

### Problem

```
Twój kod ──► AWS Lambda API
                │
                ├── event format (specyficzny dla AWS)
                ├── context object (specyficzny dla AWS)
                ├── IAM permissions (specyficzny dla AWS)
                ├── DynamoDB SDK (specyficzny dla AWS)
                └── S3 integration (specyficzny dla AWS)

Migracja do Azure/GCP = przepisanie znacznej części kodu
```

### Strategie minimalizacji lock-in

1. **Architektura heksagonalna** — izolacja logiki biznesowej od providerów:
```
┌─────────────────────┐
│  Lambda Handler      │  ← adapter (wymienialny)
│  └─ OrderService     │  ← logika biznesowa (przenośna)
│      └─ OrderRepo    │  ← port (interfejs)
│          └─ DynamoDB  │  ← adapter (wymienialny)
└─────────────────────┘
```

2. **Serverless Framework / SST** — abstrakcja nad providerami
3. **Kontenery** — AWS Fargate, Cloud Run jako middle-ground
4. **Standardy** — CloudEvents format dla zdarzeń

### Porównanie platform

| Aspekt | AWS Lambda | Azure Functions | GCP Cloud Functions |
|--------|-----------|----------------|-------------------|
| Runtime'y | Python, Node, Java, Go, .NET, Rust | C#, JS, Python, Java, PowerShell | Node, Python, Go, Java, .NET |
| Max timeout | 15 min | 10 min (Consumption) | 9 min (1st gen), 60 min (2nd gen) |
| Max pamięć | 10 GB | 1.5 GB (Consumption) | 32 GB (2nd gen) |
| Orkiestracja | Step Functions | Durable Functions | Workflows |
| Cold start | Provisioned Concurrency | Premium plan | Min instances |

## Wzorce serverless

### API Backend
```
CloudFront → API Gateway → Lambda → DynamoDB
                                  → RDS Proxy → PostgreSQL
```

### Event Processing Pipeline
```
SQS (queue) → Lambda (process) → DynamoDB (store)
                               → SNS (notify)
                               → S3 (archive)
```

### Scheduled Jobs
```
EventBridge (cron) → Lambda → External API
                            → S3 (raport CSV)
                            → SES (email z raportem)
```

## Zalety i wady

### Zalety
- Zero zarządzania serwerami (OS, patching, scaling)
- Automatyczne skalowanie (od 0 do tysięcy instancji)
- Pay-per-use — brak kosztów przy braku ruchu
- Szybki time-to-market (focus na logice biznesowej)
- Wbudowana odporność i wysoka dostępność

### Wady
- Cold start — opóźnienia przy pierwszym wywołaniu
- Limity wykonania (timeout, pamięć, payload)
- Vendor lock-in — zależność od konkretnego dostawcy
- Trudniejsze testowanie lokalne
- Debugowanie i monitoring wymagają specjalizowanych narzędzi
- Brak długotrwałych połączeń (WebSocket wymaga dodatkowej konfiguracji)

## Kiedy stosować Serverless?

### Idealny dla:
- Nieregularnego ruchu (spiky traffic)
- API z niskim/średnim ruchem
- Przetwarzania zdarzeń (event processing)
- Automatyzacji (scheduled tasks, cron jobs)
- MVP i prototypów (szybki start)
- Microservices z prostą logiką

### Nieodpowiedni dla:
- Stałego, wysokiego ruchu (droższy niż EC2)
- Wymagań ultra-niskiej latencji (cold start)
- Długotrwałych procesów (> 15 min)
- Aplikacji wymagających dużo RAM lub CPU
- Systemów z wymaganiem stałych połączeń (np. WebSocket-heavy)

## Podsumowanie

Serverless to potężny model dla scenariuszy z **nieregularnym ruchem, event processing i szybkim prototypowaniem**. Kluczowe jest zrozumienie limitów (cold start, timeout, vendor lock-in) i świadome projektowanie — izolacja logiki biznesowej od providerów (architektura heksagonalna) znacząco ułatwia przyszłą migrację i testowanie.
