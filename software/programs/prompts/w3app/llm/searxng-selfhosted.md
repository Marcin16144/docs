# SearxNG self-hosted — własna meta-wyszukiwarka dla Console AI

> **Po co?** Public instancje SearxNG (`searx.be`, `searx.tiekoetter.com`, …)
> używane jako fallback w `tcWebSearch()` ([tools_executors.php](../../admin/pages/consoleai/terminal/tools_executors.php))
> są społecznościowe — czasem padają, czasem rate-limitują. Self-hosted SearxNG daje:
>
> - **0 limit** zapytań (Twój serwer, Twoje zasady)
> - **Stabilny URL** — żadnego ryzyka że instancja zniknie
> - **Pełna kontrola** — wybierasz które backendy (Google/Bing/DDG/Brave/Wikipedia/etc.) agregować
> - **Anonimowość** — Twoje zapytania nie wychodzą przez czyjś serwer
> - **Lokalna sieć** — jeśli postawisz w tej samej sieci co PHP, RTT < 5ms

## Wymagania

- VPS / serwer / komputer z Dockerem (Linux / Windows WSL2 / macOS)
- ~256 MB RAM, ~1 GB disk
- Port 8888 (lub inny) dostępny

## Setup w 5 minut (Docker)

### 1. Utwórz katalog dla konfigu

```bash
mkdir -p ~/searxng && cd ~/searxng
```

### 2. Plik `docker-compose.yml`

```yaml
services:
  searxng:
    image: docker.io/searxng/searxng:latest
    container_name: searxng
    restart: unless-stopped
    ports:
      - "8888:8080"
    volumes:
      - ./settings.yml:/etc/searxng/settings.yml:rw
    environment:
      - SEARXNG_BASE_URL=http://localhost:8888/
      - SEARXNG_SECRET_KEY=zmien_to_na_losowy_string_64_znaki
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
```

### 3. Plik `settings.yml` (minimalna konfiguracja z JSON API)

```yaml
use_default_settings: true

general:
  debug: false
  instance_name: "K2 Console AI"

search:
  safe_search: 0
  autocomplete: ""
  default_lang: "auto"
  formats:
    - html
    - json    # ← KLUCZOWE — bez tego nasz tcSearchSearx nie zadziała

server:
  port: 8080
  bind_address: "0.0.0.0"
  secret_key: "zmien_to_na_losowy_string_64_znaki"  # ten sam co w env wyżej
  limiter: false     # wyłącz rate-limiter dla zaufanego klienta (tylko Ty używasz)
  image_proxy: false
  http_protocol_version: "1.0"

ui:
  static_use_hash: true

# Włącz tylko backendy które chcesz używać (komentuj resztę dla szybkości)
engines:
  - name: google
    disabled: false
  - name: bing
    disabled: false
  - name: duckduckgo
    disabled: false
  - name: brave
    disabled: false
  - name: wikipedia
    disabled: false
  - name: youtube
    disabled: true   # niepotrzebne dla LLM
```

### 4. Wygeneruj `secret_key`

```bash
# Linux/macOS:
openssl rand -hex 32

# Windows PowerShell:
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | % {[char]$_})
```

Wklej w obu miejscach (env i settings.yml).

### 5. Start

```bash
docker compose up -d
docker compose logs -f   # sprawdź czy startuje bez błędów
```

### 6. Test

```bash
curl "http://localhost:8888/search?format=json&q=test"
# Powinno zwrócić JSON z polem "results"
```

## Wpięcie do Console AI

Obecnie [tools_executors.php](../../admin/pages/consoleai/terminal/tools_executors.php)
ma hardcoded listę publicznych instancji SearxNG w `tcSearchSearx()`:

```php
$instances = [
    'https://searx.be',
    'https://searx.tiekoetter.com',
    'https://baresearch.org',
    'https://priv.au',
];
```

**Opcja A** — dorzuć swój URL na pierwsze miejsce:

```php
$instances = [
    'http://localhost:8888',          // ← Twój local SearxNG, pierwszeństwo
    'https://searx.be',
    'https://searx.tiekoetter.com',
    'https://baresearch.org',
];
```

**Opcja B** — dodaj pole „SearxNG URL" do Ustawienia → Integracje AI
(jeszcze nie zaimplementowane, ale schema [`def_api_brave`](../../admin/pages/settings/ai/ai_lib.php)
można rozszerzyć analogicznie o `def_api_searx` z polem `SrxUrl`).

## Verify że działa w panelu

1. Restartuj XAMPP/Apache (PHP musi przeładować tools_executors.php)
2. Wejdź **Console AI → Terminal**
3. Wpisz pytanie wymagające internetu, np. „pokaż najnowsze procesory intel"
4. Tryb: **Auto** lub **RAG**
5. W odpowiedzi zobaczysz collapsible „web_search" — kliknij i sprawdź pierwszą linię:
   - `Search results for: "..." (via SearxNG @ localhost:8888)` ← Twoja instancja działa
   - `(via SearxNG @ searx.be)` ← Twoja padła, użyto publicznej fallback

## Najczęstsze problemy

### „HTTP 403 Forbidden" z localhost

SearxNG ma limiter włączony domyślnie — wyłącz w `settings.yml`:
```yaml
server:
  limiter: false
```

### `format=json` zwraca HTML zamiast JSON

`formats:` musi mieć `json` na liście. Restart containera po zmianie:
```bash
docker compose restart
```

### Container zatrzymuje się po starcie

Sprawdź logi: `docker compose logs searxng | tail -30`. Najczęściej:
- `secret_key` puste / domyślne — zmień
- Port 8888 zajęty — zmień na inny (np. 8890)

### Brak wyników z konkretnego enginu

Sprawdź `docker compose logs` — niektóre engine'y wymagają tokenów (np. Bing API).
Wyłącz problematyczne w `settings.yml`:
```yaml
engines:
  - name: nazwa
    disabled: true
```

## Update SearxNG

```bash
cd ~/searxng
docker compose pull
docker compose up -d
```

## Backup konfiguracji

`settings.yml` + `docker-compose.yml` — to wszystko. Zachowaj w git / dropbox.

## Linki

- Oficjalna dokumentacja: <https://docs.searxng.org>
- Lista publicznych instancji + uptime: <https://searx.space>
- Engine list (które backendy można włączyć): <https://docs.searxng.org/admin/engines/configured_engines.html>
- Docker Hub: <https://hub.docker.com/r/searxng/searxng>
