# 06-04: Kolejki wiadomości i Pub/Sub

## Komunikacja asynchroniczna — po co?

W architekturze mikroserwisów komunikacja synchroniczna (REST, gRPC) tworzy silne powiązania czasowe — oba serwisy muszą działać jednocześnie. Komunikacja asynchroniczna przez kolejki i Pub/Sub rozwiązuje ten problem, wprowadzając pośrednika (broker), który buforuje wiadomości.

### Korzyści

- **Luźne powiązanie (loose coupling)** — producent nie musi wiedzieć, kto konsumuje wiadomość
- **Buforowanie obciążenia** — broker absorbuje skoki ruchu
- **Niezawodność** — wiadomość nie ginie, gdy konsument jest niedostępny
- **Skalowalność** — można dodawać konsumentów niezależnie
- **Odporność na awarie** — awaria konsumenta nie blokuje producenta

## Message Queue vs Pub/Sub

| Cecha | Message Queue | Pub/Sub |
|-------|--------------|---------|
| Model dostarczania | Punkt-punkt (1 konsument) | Jeden-do-wielu |
| Wiadomość konsumowana przez | Dokładnie jednego konsumenta | Wszystkich subskrybentów |
| Przykład | Zadanie do przetworzenia | Zdarzenie do powiadomienia |
| Narzędzia | RabbitMQ, SQS, ActiveMQ | Kafka, Google Pub/Sub, SNS |

## RabbitMQ

RabbitMQ to popularny broker wiadomości implementujący protokół AMQP (Advanced Message Queuing Protocol).

### Architektura RabbitMQ

```
Producer → Exchange → Binding → Queue → Consumer

[Producer A] --→ [Exchange] --→ [Queue 1] --→ [Consumer X]
[Producer B] --→            --→ [Queue 2] --→ [Consumer Y]
                             --→ [Queue 3] --→ [Consumer Z]
```

### Typy Exchange

#### 1. Direct Exchange

Routuje wiadomość do kolejki po dokładnym dopasowaniu routing key.

```
Producer wysyła z routing_key = "order.created"

Exchange (direct)
  |
  ├── binding key "order.created"  → Queue: order-processing  ✓
  ├── binding key "order.shipped"  → Queue: shipping-notify   ✗
  └── binding key "user.created"   → Queue: welcome-email     ✗
```

#### 2. Fanout Exchange

Wysyła wiadomość do WSZYSTKICH powiązanych kolejek (ignoruje routing key).

```
Producer wysyła wiadomość (routing key ignorowany)

Exchange (fanout)
  |
  ├── Queue: audit-log         ✓
  ├── Queue: notification      ✓
  └── Queue: analytics         ✓
```

#### 3. Topic Exchange

Routuje po wzorcach — `*` (jedno słowo), `#` (zero lub więcej słów).

```
Producer wysyła z routing_key = "order.created.eu"

Exchange (topic)
  |
  ├── binding "order.created.*"   → Queue: order-processing   ✓
  ├── binding "order.#"           → Queue: order-audit         ✓
  ├── binding "*.created.*"       → Queue: creation-log        ✓
  └── binding "user.#"            → Queue: user-events         ✗
```

#### 4. Headers Exchange

Routuje na podstawie nagłówków wiadomości (nie routing key).

### Przykład z RabbitMQ (Python)

```python
import pika

# Producent
connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel = connection.channel()

channel.exchange_declare(exchange='orders', exchange_type='topic')
channel.queue_declare(queue='order-processing', durable=True)
channel.queue_bind(
    exchange='orders',
    queue='order-processing',
    routing_key='order.created.*'
)

# Wysłanie wiadomości
channel.basic_publish(
    exchange='orders',
    routing_key='order.created.eu',
    body='{"orderId": 123, "total": 99.99}',
    properties=pika.BasicProperties(
        delivery_mode=2,  # persistent
        content_type='application/json'
    )
)

# Konsument
def callback(ch, method, properties, body):
    print(f"Otrzymano: {body}")
    # Przetwarzanie zamówienia...
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_qos(prefetch_count=1)
channel.basic_consume(
    queue='order-processing',
    on_message_callback=callback
)
channel.start_consuming()
```

### Potwierdzenia (Acknowledgements)

```
1. Broker → Consumer: dostarcza wiadomość
2. Consumer przetwarza wiadomość
3. Consumer → Broker: ACK (sukces) lub NACK (błąd)

ACK  → Broker usuwa wiadomość z kolejki
NACK → Broker ponawia dostarczenie (requeue=true)
       lub przenosi do Dead Letter Queue (requeue=false)
```

## Apache Kafka

Kafka to rozproszona platforma streamingowa. W przeciwieństwie do tradycyjnych kolejek, Kafka przechowuje wiadomości na dysku i pozwala na wielokrotne czytanie.

### Kluczowe koncepcje

```
Producer → Topic → Partition → Consumer Group → Consumer

Topic: "orders" (3 partycje)
┌─────────────────────────────────────────────┐
│ Partition 0: [msg0] [msg3] [msg6] [msg9]    │
│ Partition 1: [msg1] [msg4] [msg7] [msg10]   │
│ Partition 2: [msg2] [msg5] [msg8] [msg11]   │
└─────────────────────────────────────────────┘
```

### Topics (tematy)

Topic to nazwana kategoria wiadomości. Każdy topic jest podzielony na partycje.

```
Topic: "user-events"     → zdarzenia użytkowników
Topic: "order-events"    → zdarzenia zamówień
Topic: "payment-events"  → zdarzenia płatności
```

### Partitions (partycje)

Partycja to uporządkowany, niezmienny log wiadomości. Każda wiadomość ma unikalny offset (numer sekwencyjny) w ramach partycji.

```
Partition 0:
Offset:  0    1    2    3    4    5    6
       [msg] [msg] [msg] [msg] [msg] [msg] [msg] →

Klucz partycjonowania (partition key):
- Wiadomości z tym samym kluczem trafiają do tej samej partycji
- Gwarantuje kolejność dla danego klucza
- Np. klucz = userId → wszystkie zdarzenia użytkownika w jednej partycji
```

### Consumer Groups (grupy konsumentów)

Grupa konsumentów to mechanizm równoległego przetwarzania — każda partycja jest przypisana do dokładnie jednego konsumenta w grupie.

```
Topic "orders" (3 partycje)

Consumer Group "order-service" (3 konsumenty):
  Consumer A ← Partition 0
  Consumer B ← Partition 1
  Consumer C ← Partition 2

Consumer Group "analytics" (2 konsumenty):
  Consumer X ← Partition 0, Partition 1
  Consumer Y ← Partition 2

Każda grupa czyta WSZYSTKIE wiadomości niezależnie!
```

### Offsets (przesunięcia)

Offset to pozycja konsumenta w partycji. Kafka przechowuje offset per consumer group per partition.

```
Partition 0:  [0] [1] [2] [3] [4] [5] [6] [7] [8] [9]
                                    ^               ^
                        committed offset     latest offset
                        (przetworzone)       (najnowsza)

Consumer może:
- Czytać od committed offset (domyślnie)
- Czytać od początku (earliest)
- Czytać od końca (latest)
- Skakać do dowolnego offsetu
```

### Przykład z Kafka (Java)

```java
// Producent
Properties props = new Properties();
props.put("bootstrap.servers", "localhost:9092");
props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

Producer<String, String> producer = new KafkaProducer<>(props);

// Wysyłanie z kluczem (gwarantuje kolejność per klucz)
producer.send(new ProducerRecord<>(
    "orders",                    // topic
    "user-123",                  // key (partition key)
    "{\"orderId\": 456, \"total\": 99.99}" // value
));

// Konsument
Properties consumerProps = new Properties();
consumerProps.put("bootstrap.servers", "localhost:9092");
consumerProps.put("group.id", "order-service");
consumerProps.put("auto.offset.reset", "earliest");
consumerProps.put("enable.auto.commit", "false");

Consumer<String, String> consumer = new KafkaConsumer<>(consumerProps);
consumer.subscribe(Arrays.asList("orders"));

while (true) {
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
    for (ConsumerRecord<String, String> record : records) {
        System.out.printf("offset=%d, key=%s, value=%s%n",
            record.offset(), record.key(), record.value());
        // Przetwarzanie...
    }
    consumer.commitSync(); // ręczny commit offsetu
}
```

## RabbitMQ vs Kafka — porównanie

| Cecha | RabbitMQ | Kafka |
|-------|----------|-------|
| Model | Broker kolejek (AMQP) | Rozproszony log |
| Przechowywanie | Usuwane po ACK | Przechowywane (retention) |
| Kolejność | W ramach kolejki | W ramach partycji |
| Przepustowość | Tysiące msg/s | Miliony msg/s |
| Routing | Zaawansowany (exchange/binding) | Prosty (topic/partition) |
| Replay | Nie (wiadomość usunięta po ACK) | Tak (dowolny offset) |
| Consumer groups | Competing consumers | Natywne grupy |
| Użycie | Kolejkowanie zadań, RPC | Event streaming, logi |
| Opóźnienie | Bardzo niskie | Niskie (batch) |
| Złożoność operacyjna | Umiarkowana | Wysoka |

### Kiedy co wybrać?

**RabbitMQ** — gdy potrzebujesz:
- Zaawansowanego routingu wiadomości
- Niskiego opóźnienia (per wiadomość)
- Wzorca request-reply
- Priority queues
- Prostszego deploymentu

**Kafka** — gdy potrzebujesz:
- Bardzo wysokiej przepustowości
- Event sourcing / event streaming
- Odtwarzania historii (replay)
- Wielu konsumentów tego samego strumienia
- Długoterminowego przechowywania zdarzeń

## Dead Letter Queue (DLQ)

Kolejka, do której trafiają wiadomości, których nie udało się przetworzyć.

```
Normalna kolejka                Dead Letter Queue
┌──────────────────────┐        ┌──────────────────────┐
│ [msg1] [msg2] [msg3] │  ───→  │ [msg_failed_1]       │
└──────────────────────┘  retry  │ [msg_failed_2]       │
  Consumer przetwarza     limit   └──────────────────────┘
  msg2 → błąd!           reached   DLQ Consumer analizuje
  Retry 1 → błąd                    i naprawia problemy
  Retry 2 → błąd
  Retry 3 → DLQ
```

### Implementacja DLQ w RabbitMQ

```python
# Deklaracja kolejki z DLQ
channel.queue_declare(
    queue='orders',
    durable=True,
    arguments={
        'x-dead-letter-exchange': 'dlx',
        'x-dead-letter-routing-key': 'orders.dlq',
        'x-message-ttl': 60000,       # TTL: 60 sekund
        'x-max-delivery-count': 3      # Max 3 próby
    }
)

# Dead Letter Queue
channel.queue_declare(queue='orders.dlq', durable=True)
channel.queue_bind(
    exchange='dlx',
    queue='orders.dlq',
    routing_key='orders.dlq'
)
```

## Semantyki dostarczania

### At-most-once (co najwyżej raz)

Wiadomość może zostać utracona, ale nigdy zduplikowana.

```
Producer → Broker: wyślij (fire and forget)
Broker → Consumer: dostarcz
Consumer: brak ACK wymagany

Ryzyko: utrata wiadomości
Użycie: metryki, logi (gdzie utrata jest akceptowalna)
```

### At-least-once (co najmniej raz)

Wiadomość nigdy nie zostanie utracona, ale może zostać zduplikowana.

```
Producer → Broker: wyślij + czekaj na potwierdzenie
Broker → Consumer: dostarcz
Consumer → Broker: ACK po przetworzeniu

Ryzyko: duplikaty (Consumer przetworzy, ale ACK się zgubi)
Użycie: większość przypadków (z idempotentnym konsumentem)
```

### Exactly-once (dokładnie raz)

Najtrudniejsza do osiągnięcia — wiadomość dostarczona i przetworzona dokładnie raz.

```
Kafka Transactions:
1. Producer: beginTransaction()
2. Producer: send(msg) → Broker
3. Producer: commitTransaction()

Consumer z read_committed:
- Widzi tylko wiadomości z committed transakcji

Ale "exactly-once" dotyczy tylko Kafka → Kafka.
Dla Kafka → zewnętrzny system potrzebujesz idempotentności.
```

## Gwarancje kolejności

### RabbitMQ

Kolejność gwarantowana w ramach jednej kolejki, jednego producenta, jednego konsumenta. Wiele konsumentów (competing consumers) — brak gwarancji kolejności globalnej.

### Kafka

Kolejność gwarantowana w ramach jednej partycji.

```
Aby zagwarantować kolejność zdarzeń użytkownika:
- Partition key = userId
- Wszystkie zdarzenia user-123 trafiają do tej samej partycji
- Jedna partycja = jeden konsument w grupie
- Kolejność zachowana

UWAGA: Więcej partycji = większa przepustowość, ale kolejność
       gwarantowana TYLKO w ramach jednej partycji
```

## Backpressure (przeciwciśnienie)

Mechanizm ochrony konsumenta przed przeciążeniem.

### Strategie

1. **Prefetch count** (RabbitMQ) — konsument pobiera N wiadomości naraz

```python
channel.basic_qos(prefetch_count=10)
# Konsument przetwarza max 10 wiadomości jednocześnie
# Nowe dopiero po ACK
```

2. **Consumer lag monitoring** (Kafka) — monitoruj opóźnienie konsumenta

```
Consumer lag = latest offset - committed offset
Jeśli lag rośnie → dodaj konsumentów lub zwiększ partycje
```

3. **Rate limiting** — ogranicz prędkość konsumpcji

4. **Buffer/Batch** — zbieraj wiadomości w batch przed przetworzeniem

## Dobre praktyki

1. **Idempotentny konsument** — zawsze, bo duplikaty są nieuniknione
2. **Dead Letter Queue** — zawsze konfiguruj DLQ dla obsługi błędów
3. **Monitoruj lag** — alertuj gdy konsument nie nadąża
4. **Schema Registry** — wersjonuj format wiadomości (Avro, Protobuf)
5. **Retry z backoff** — nie ponawiaj natychmiast, zwiększaj opóźnienie
6. **Tracing** — correlation ID w każdej wiadomości dla debugowania
7. **Wybierz odpowiedni retention** — jak długo Kafka ma trzymać wiadomości
8. **Testuj failure scenarios** — co się stanie, gdy broker/konsument padnie?
