# Chaos Engineering

## Czym jest Chaos Engineering?

Chaos Engineering to dyscyplina eksperymentowania na systemie produkcyjnym (lub pre-produkcyjnym) w celu zbudowania pewnosci, ze system jest w stanie wytrzymac niestabilne warunki. Zamiast czekac az cos sie zepsuje, celowo wprowadzamy awarie, aby odkryc slabosci zanim znajda je uzytkownicy.

## Dlaczego Chaos Engineering?

```
Tradycyjne podejscie:
  "Mamy testy, monitoring i redundancje — pewnie bedzie OK"
  → Produkcja pada o 3 w nocy
  → 4 godziny diagnostyki
  → Root cause: timeout do bazy, brak retry, brak fallbacku

Chaos Engineering:
  "Sprawdzmy CO SIE STANIE gdy baza bedzie niedostepna"
  → Eksperyment: wylaczymy baze na 30 sekund
  → Odkrycie: brak circuit breakera, kaskadowa awaria
  → Naprawa PRZED incydentem na produkcji
```

## Zasady Chaos Engineering

### 1. Zdefiniuj stan stabilny (Steady State)

Okresl metryki, ktore definiuja normalne dzialanie systemu:

```
Steady State Hypothesis:
  - Czas odpowiedzi API < 200ms (p99)
  - Error rate < 0.1%
  - Throughput > 1000 req/s
  - Wszystkie health checki zielone
  - Zamowienia sa przetwarzane w < 5s
```

### 2. Sformuluj hipoteze

```
"Jesli jeden z trzech Node'ow Kubernetes ulegnie awarii,
 system nadal bedzie obslugiwal ruch z czasem odpowiedzi < 500ms
 i error rate < 1%."
```

### 3. Wprowadz zmienne ze swiata rzeczywistego

Typowe eksperymenty:
- Awaria serwera / poda / kontenera
- Opoznienie sieci (latency injection)
- Utrata pakietow sieciowych
- Awaria bazy danych / cache
- Wyczerpanie zasobow (CPU, memory, disk)
- Awaria zewnetrznej uslugi (payment provider)
- Zmiana zegarow (clock skew)

### 4. Probuj obalic hipoteze

Sprawdz czy steady state jest utrzymany pomimo wprowadzonej awarii.

### 5. Minimalizuj blast radius

Zacznij od malego zakresu — jeden pod, jedno srodowisko, maly % ruchu.

## Steady State Hypothesis

```yaml
# Definicja eksperymentu
experiment:
  name: "Database failover resilience"
  
  steady_state_hypothesis:
    title: "System dziala normalnie"
    probes:
      - name: "API response time"
        type: http
        url: "https://api.example.com/healthz"
        timeout: 5
        expected_status: 200
      
      - name: "Error rate below threshold"
        type: prometheus
        query: "rate(http_errors_total[5m])"
        expected: "< 0.001"
      
      - name: "Orders processing"
        type: prometheus
        query: "rate(orders_completed_total[5m])"
        expected: "> 10"

  method:
    - type: action
      name: "Kill primary database"
      provider:
        type: process
        command: "kubectl delete pod postgres-primary-0"

  rollbacks:
    - type: action
      name: "Restore database"
      provider:
        type: process
        command: "kubectl apply -f postgres-statefulset.yaml"
```

## Narzedzia

### Chaos Monkey (Netflix)

Losowo wylaczy instancje w srodowisku produkcyjnym. Zmusil zespoly Netflix do budowania odpornych systemow.

```
Chaos Monkey:
  Codziennie w godzinach pracy
  Losowo wybiera instancje EC2
  Wylaczy ja
  Zespol musi byc gotowy na takie zdarzenie

Symian Army (rodzina narzedzi Netflix):
  Chaos Monkey    — zabija instancje
  Latency Monkey  — wprowadza opoznienia
  Chaos Gorilla   — symuluje awarie calej strefy AZ
  Chaos Kong      — symuluje awarie calego regionu
```

### Litmus (Kubernetes)

Open-source platforma chaos engineering dla Kubernetes:

```yaml
# litmus-experiment.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: pod-kill-experiment
spec:
  appinfo:
    appns: production
    applabel: "app=order-service"
  chaosServiceAccount: litmus-admin
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: "30"       # 30 sekund
            - name: CHAOS_INTERVAL
              value: "10"       # co 10 sekund
            - name: FORCE
              value: "true"
```

```bash
# Instalacja Litmus
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator.yaml

# Uruchomienie eksperymentu
kubectl apply -f pod-kill-experiment.yaml

# Sprawdzenie wyniku
kubectl get chaosresult pod-kill-experiment -o yaml
```

### Chaos Toolkit

Framework open-source z deklaratywnym JSON/YAML:

```json
{
  "title": "Network latency experiment",
  "description": "Co sie stanie gdy siec do bazy ma 500ms opoznienia?",
  "steady-state-hypothesis": {
    "title": "API responds within SLA",
    "probes": [
      {
        "name": "api-response-time",
        "type": "probe",
        "provider": {
          "type": "http",
          "url": "https://api.example.com/orders",
          "timeout": 3
        },
        "tolerance": {
          "status": 200
        }
      }
    ]
  },
  "method": [
    {
      "type": "action",
      "name": "inject-latency-to-database",
      "provider": {
        "type": "process",
        "path": "tc",
        "arguments": "qdisc add dev eth0 root netem delay 500ms"
      },
      "pauses": {
        "after": 30
      }
    }
  ],
  "rollbacks": [
    {
      "type": "action",
      "name": "remove-latency",
      "provider": {
        "type": "process",
        "path": "tc",
        "arguments": "qdisc del dev eth0 root"
      }
    }
  ]
}
```

## Game Days

Game Day to zaplanowana sesja, podczas ktorej zespol celowo wprowadza awarie i obserwuje jak system (i ludzie) reaguja.

### Przygotowanie Game Day

```
1. PLANOWANIE (1-2 tygodnie przed)
   - Wybierz scenariusz awarii
   - Zdefiniuj steady state hypothesis
   - Okresl blast radius (zakres eksperymentu)
   - Przygotuj rollback plan
   - Poinformuj zespol on-call

2. PRZED EKSPERYMENTEM
   - Sprawdz steady state (wszystko zielone?)
   - Upewnij sie ze rollback dziala
   - Uruchom dodatkowy monitoring
   - Przygotuj kanal komunikacji (Slack)

3. EKSPERYMENT
   - Wprowadz awarie
   - Obserwuj metryki, alerty, logi
   - Dokumentuj zachowanie systemu
   - Jesli blast radius rosnie — rollback

4. PO EKSPERYMENCIE
   - Przywroc normalny stan
   - Retrospektywa: co odkrylismy?
   - Utworz tickety na poprawki
   - Zaplanuj nastepny Game Day
```

### Przykladowe scenariusze Game Day

| Scenariusz | Co testuje | Blast radius |
|-----------|------------|-------------|
| Kill pod order-service | Auto-scaling, health checks | Niski |
| Latency 500ms do bazy | Circuit breaker, timeout, fallback | Sredni |
| Wylacz Redis (cache) | Fallback do bazy, degradacja | Sredni |
| Awaria jednej AZ | Multi-AZ redundancja | Wysoki |
| DNS failure | DNS cache, retry logic | Wysoki |
| Wyczerpanie dysku | Monitoring, alerty, logrotate | Niski |
| Spike ruchu 10x | Auto-scaling, rate limiting | Sredni |

## Blast Radius

Zakres wplywu eksperymentu — kontroluj go starannie:

```
Poziom 1: Development
  - Pelna swoboda eksperymentow
  - Brak wplywu na uzytkownikow

Poziom 2: Staging
  - Realistyczne dane (anonimizowane)
  - Pelna infrastruktura
  - Brak wplywu na uzytkownikow

Poziom 3: Production (canary)
  - Maly % ruchu (1-5%)
  - Monitoring na zywo
  - Natychmiastowy rollback

Poziom 4: Production (pelny)
  - Caly ruch produkcyjny
  - Tylko po sukcesie na nizszych poziomach
  - Tylko w godzinach pracy zespolu
```

## Dojrzalosc Chaos Engineering

```
Poziom 0: Brak
  "Mamy nadzieje ze dziala"

Poziom 1: Ad-hoc
  Reczne eksperymenty, brak automatyzacji
  "Sprawdzmy co sie stanie gdy zabijemy ten pod"

Poziom 2: Powtarzalne
  Zdefiniowane eksperymenty, uruchamiane recznie
  Game Days co kwartal

Poziom 3: Automatyczne
  Eksperymenty w CI/CD pipeline
  Regularne Game Days co miesiac

Poziom 4: Ciagly Chaos
  Chaos Monkey na produkcji 24/7
  Automatyczne odkrywanie slabosci
  Kultura odpornosci w zespole
```

## Kluczowe wnioski

1. **Steady state hypothesis** — zdefiniuj co znaczy "system dziala normalnie"
2. **Zacznij od malego** — dev/staging, jeden pod, niski blast radius
3. **Miej rollback plan** — zawsze mozliwosc natychmiastowego przywrocenia
4. **Game Days** buduja kulture odpornosci — ludzie sa rownie wazni jak systemy
5. **Automatyzuj eksperymenty** — powtarzalne, w CI/CD, regularne
6. **Chaos Engineering odkrywa niewiadome** — problemy, ktorych nie widac w testach jednostkowych
7. **Blast radius** kontroluj starannie — eskaluj powoli od dev do produkcji
