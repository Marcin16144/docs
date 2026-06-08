# 05 — Alerty e-mail przy zdarzeniach bezpieczeństwa

**Priorytet:** 🟠 Średni · **Trudność implementacji:** Mała

---

## Problem

Wszystkie zdarzenia bezpieczeństwa są logowane do bazy (`<tenant>_logs`, kanał `Auth`),
ale nikt nie jest o nich aktywnie powiadamiany. Atak może trwać godzinami — administrator
dowie się o nim dopiero przeglądając logi.

---

## Rozwiązanie

Wysyłanie e-maila do administratora przy zdarzeniach wysokiego ryzyka:

| Zdarzenie | Próg | Priorytet alertu |
|---|---|---|
| Honeypot wypełniony | 1 zdarzenie | Niski (digest) |
| Nieudane logowania z jednego IP | 5 prób | Średni |
| Rate limit aktywowany | pierwsze trafienie | Średni |
| Udane logowanie z nowego IP | każde | Wysoki |
| CSRF mismatch | 1 zdarzenie | Wysoki |
| Dostęp do sekcji bez uprawnień | 1 zdarzenie | Średni |

---

## Implementacja

### Konfiguracja (configs/_default.php)

```php
'security_alert_email'   => '',              // '' = wyłączone
'security_alert_from'    => 'cms@example.pl',
'security_alert_subject' => '[K2 CMS] Alert bezpieczeństwa',
```

### Funkcja wysyłania alertu (admcore.php)

```php
/**
 * Wysyła e-mail z alertem bezpieczeństwa jeśli skonfigurowany.
 * Fail-silently — błąd wysyłki nie może zatrzymać aplikacji.
 */
function securityAlert(string $event, array $context = []): void
{
    $to = (string)Config::get('security_alert_email', '');
    if ($to === '') {
        return;   // wyłączone
    }

    $from    = (string)Config::get('security_alert_from', 'cms@localhost');
    $subject = (string)Config::get('security_alert_subject', '[K2 CMS] Alert');
    $host    = (string)($_SERVER['HTTP_HOST'] ?? 'unknown');
    $time    = date('Y-m-d H:i:s');

    $body  = "K2 CMS — alert bezpieczeństwa\n";
    $body .= str_repeat('─', 40) . "\n\n";
    $body .= "Zdarzenie: {$event}\n";
    $body .= "Czas:      {$time}\n";
    $body .= "Host:      {$host}\n";
    foreach ($context as $k => $v) {
        $body .= ucfirst($k) . ': ' . $v . "\n";
    }

    $headers = implode("\r\n", [
        "From: {$from}",
        'Content-Type: text/plain; charset=utf-8',
        'X-Mailer: K2CMS-SecurityAlert',
    ]);

    try {
        mail($to, $subject . " — {$event}", $body, $headers);
    } catch (\Throwable) {
        // Fail-silently
    }
}
```

### Użycie w index.php

```php
// Honeypot
if (($_POST['hp_phone'] ?? '') !== '') {
    Logger::get('Auth')->warn('Honeypot — bot', …);
    securityAlert('Honeypot wypełniony', ['ip' => $clientIp, 'login' => $login]);
    $loginError = …;
}

// Rate limit
if (loginIsBlocked($clientIp)) {
    Logger::get('Auth')->warn('Rate limit', …);
    securityAlert('Rate limit aktywowany', ['ip' => $clientIp]);
    $loginError = …;
}

// CSRF mismatch (w csrfVerify())
securityAlert('CSRF mismatch', ['ip' => $clientIp, 'uri' => $uri, 'action' => $action]);
```

---

## Zabezpieczenia przed spamem alertów

Problem: masowy atak → tysiące e-maili w ciągu minut.

### Throttling: max 1 alert per zdarzenie per 15 min

```php
function securityAlertThrottled(string $event, array $context = []): void
{
    $key = 'alert_' . md5($event . ($context['ip'] ?? ''));
    if (!empty($_SESSION[$key]) && (time() - (int)$_SESSION[$key]) < 900) {
        return;   // Alert dla tego zdarzenia z tego IP już wysłany
    }
    $_SESSION[$key] = time();
    securityAlert($event, $context);
}
```

### Digest zamiast alertów natychmiastowych

Dla zdarzeń niskiego priorytetu (honeypot, nieudane logowania) — zamiast wysyłać
każdy alert osobno, agreguj i wysyłaj raport raz na godzinę:

```
Cron: php artisan security:digest --interval=60
lub: cron-job wywołujący endpoint wewnętrzny
```

---

## Opcja: webhook (Slack / Teams / Ntfy)

```php
function securityWebhook(string $event, array $context = []): void
{
    $url = (string)Config::get('security_webhook_url', '');
    if ($url === '') {
        return;
    }
    $payload = json_encode([
        'text' => "🚨 *{$event}*\n```" . print_r($context, true) . "```",
    ]);
    $ctx = stream_context_create(['http' => [
        'method'  => 'POST',
        'header'  => 'Content-Type: application/json',
        'content' => $payload,
        'timeout' => 3,
    ]]);
    @file_get_contents($url, false, $ctx);   // @ — fail-silently
}
```

---

## Uwagi

- `mail()` wymaga skonfigurowanego MTA na serwerze (Sendmail, Postfix).
  Dla niezawodności rozważ zewnętrzny SMTP (przez socket lub bibliotekę `symfony/mailer`).
- Adres `security_alert_email` powinien trafiać do skrzynki **aktywnie monitorowanej**,
  nie do catch-all.
- Alerty o udanym logowaniu z nowego IP wymagają zapamiętywania znanych IP per użytkownik
  (tabela `<tenant>_known_ips` lub w `<tenant>_sessions`).
