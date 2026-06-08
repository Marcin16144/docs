# Panel administracyjny K2 CMS

Panel zarządzania serwisem — logowanie, konta użytkowników, diagnostyka systemu.
Zbudowany na szablonie **AdminLTE 3** (zwendorowanym lokalnie, działa offline).

---

## 1. Dostęp — sekretny adres

Panel **nie** jest dostępny pod `/admin/`. Działa wyłącznie pod adresem:

```
https://<dowolna-domena>/admin/{admin_code}/
```

gdzie `{admin_code}` to wartość klucza **`admin_code`** z konfiguracji systemowej
[configs/_default.php](../configs/_default.php) (domyślnie `panel1`).

**Panel jest jeden i zawsze działa na `_default.php`, niezależnie od domeny** —
[admin/index.php](../admin/index.php) woła `Config::load('_default')`, a nie ładuje
konfiguracji per domena. Dlatego ten sam adres panelu otwiera się z **każdej** domeny
wskazującej na serwer (`localhost`, `127.0.0.1`, `klient1.localhost`, …), o ile użyto
sekretnego kodu z `_default.php`.

Każda inna ścieżka — w tym samo `/admin/`, `/admin/index.php` oraz **dowolny inny kod**
(np. `admin_code` innego tenanta) — zwraca **404**. Kod porównywany jest przez
`hash_equals()` (odporność na atak czasowy), a strona 404 nie zdradza, że panel istnieje.

> **Zmień `admin_code` na własny, trudny do odgadnięcia ciąg.** Kod trafia do
> pliku konfiguracyjnego — jest tak tajny, jak repozytorium. Do publicznych
> wdrożeń rozważ trzymanie go w `.env`.

Routing realizuje [admin/.htaccess](../admin/.htaccess): cały ruch pod `admin/`
trafia do `index.php` (poza statycznymi plikami `assets/`). Ta sama `.htaccess`
obsługuje wszystkie domeny — sekret weryfikuje PHP, nie reguły Apache.

### Konfiguracja per domena (front-end vs panel)

Publiczne strony (front-end) są **multi-tenant po nazwie domeny**, a panel — nie:

- `Config::load($_SERVER['HTTP_HOST'])` w [core/Config.php](../core/Config.php) skanuje
  `configs/*.php` i wybiera plik, którego pole **`website`** pokrywa się z domeną żądania
  (port pomijany). `website` może być stringiem lub listą aliasów,
  np. `['localhost', '127.0.0.1']`.
- Brak pasującego `website` → **404** (front-end), a w CLI (`bin/migrate`) → wyjątek.
- `_default.php` jest zawsze bazą scalania (`array_replace_recursive`); plik konkretnej
  strony nadpisuje tylko swoje klucze (`db`, `tenant.prefix`, `theme`, `admin_code`, …).

Czyli **nowa strona = nowy plik `configs/<cokolwiek>.php` z polem `website`** — bez zmian
w Apache (jeden, „łapie wszystko" VirtualHost). Wyjątek to **panel**, który zawsze działa
na `_default.php` (patrz wyżej), niezależnie od tego, z jakiej domeny wejdziesz.

---

## 2. Uwierzytelnianie

Logowanie sprawdza konta dwuetapowo:

1. **Konto serwisowe `admin`** — wbudowane w kod, hasło `admin` + bieżący rok
   (np. `admin2026`). Działa **wyłącznie, gdy tabela kont jest pusta** — to
   awaryjny bootstrap dostępu na świeżym wdrożeniu.
2. **Konta z bazy** — tabela `<tenant>_users` (np. `def_users`). Wyszukanie po
   `UseLogin`, weryfikacja hasła przez `password_verify()`, warunek
   `UseIsActive = 1`; po udanym logowaniu zapis `UseLastLogin`.

### Automatyczne konto admin

Przy logowaniu, gdy tabela `<tenant>_users` jest pusta, panel **sam zakłada konto
`admin`** z hasłem `admin` + bieżący rok (zahashowanym). Konsekwencja:

| Stan tabeli kont | Logowanie `admin` / `admin{rok}` |
|---|---|
| pusta | działa — i zakłada konto `admin` w bazie |
| niepusta | konto serwisowe wyłączone; działają tylko konta z bazy |

Rok pochodzi z zegara serwera (`date('Y')`) i wpływa na hasło **tylko w momencie
zakładania konta**. Aby zresetować konto admin do nowego roku — usuń wszystkie
konta w panelu; przy następnym logowaniu zostanie odtworzone.

---

## 3. Strony panelu

Routing przez parametr `?page=`:

| Strona | `?page=` | Zawartość |
|---|---|---|
| **Pulpit** | `dashboard` (domyślna) | Strona startowa (placeholder). |
| **Uprawnienia** | `permissions` | Zarządzanie kontami użytkowników. |
| **Grupy** | `groups` | Grupy uprawnień (role) — lista z liczbą kont. |
| **Domeny** | `domains` | Definicje stron internetowych zarządzanych z CMS-a. |
| **Menu nawigacyjne — zestawy** | `navigation` | Lista zestawów menu wybranej witryny (`&id=<DomID>`). |
| **Menu nawigacyjne — drzewo** | `navigation` | Edytor drzewa wybranego zestawu (`&id=<DomID>&menu=<MenuID>`). |
| **System** | `system` | Diagnostyka: status bazy, komponenty, raport migracji. |
| **Integracje AI** | `ai` | Konfiguracja providerów AI (Claude / Ollama / Groq) + search-providerów (Brave) + **Menedżer promptów** (zakładka „Wstawki prompta": grupy, drag&drop kolejności, aktywacja, historia zmian). |
| **Console AI** | `terminal` | Terminal AI z function calling, web search chain, RAG, save_file tool, **biblioteka „Wstaw prompt"** (wstawki + tryb edycji inline) i **kolejka wątków** (rozbijanie/dopisywanie zadań). |
| **Wtyczka Muzyka — YouTube** | `ext&plugin=music&sub=videos` | Lista i edycja SEO filmów własnego kanału YouTube (zob. niżej). |

W menu bocznym strony Uprawnienia, Grupy i Domeny są w rozwijanej sekcji **Ustawienia**.

Każda zdefiniowana domena pojawia się dodatkowo jako **osobna, rozwijana zakładka
główna** w menu bocznym (między Pulpitem a Ustawieniami), nazwana wartością pola
„Nazwa w CMS". Zakładki domen widzą wszystkie zalogowane konta; w rozwinięciu
znajdują się podstrony obszaru roboczego witryny — pierwszą jest **Menu
nawigacyjne** (`?page=navigation&id=<DomID>`). Nieznany identyfikator domeny →
przekierowanie na Pulpit.

### Menu nawigacyjne — zestawy i drzewa

Każda strona może mieć **wiele niezależnych zestawów menu** (np. główne, stopka,
mobilne). Nawigacja panelu jest dwupoziomowa:

1. **Lista zestawów** (`?page=navigation&id=<DomID>`) — tabela zestawów domeny:
   nazwa, kod menu, liczba pozycji, akcje (otwórz, edytuj, usuń). Formularze
   dodawania i edycji zestawu w modalach; kod menu generowany automatycznie z nazwy
   (JS). Usunięcie **jedynego** zestawu domeny jest blokowane.
2. **Edytor drzewa** (`?page=navigation&id=<DomID>&menu=<MenuID>`) — pełny
   edytor drzewa wybranego zestawu z przyciskiem „← Zestawy menu" w nagłówku.

Każda pozycja to **folder** (kontener na podpozycje) albo **strona** (liść z
opcjonalną ścieżką URL). Dane w tabelach `<tenant>_navigation` (model
[NavigationModel](../app/Appdb/Models/NavigationModel.php)) i
`<tenant>_navigation_menus` (model
[NavigationMenusModel](../app/Appdb/Models/NavigationMenusModel.php)).

- **Dodaj pozycję** — przycisk w nagłówku drzewa (root) albo „+" przy folderze.
- **Edytuj** — ikona ołówka per pozycja: typ, tytuł, ścieżka URL, SEO
  (tytuł / opis / słowa kluczowe), rodzic. Walidacja zapobiega cyklom.
- **Usuń** — ikona kosza per pozycja; usunięcie folderu kaskadowo usuwa wszystkich
  potomków.
- **Historia migawkowa** — snapshot stanu drzewa tworzony automatycznie przed
  każdą modyfikacją; panel umożliwia podgląd i przywrócenie wersji archiwalnej.
  Historia scopowana per-zestaw menu (`NavHistMenuID`).

**Migracja istniejących danych:** przy pierwszym otwarciu obszaru nawigacyjnego
funkcja `getOrCreateDefaultMenu()` zakłada zestaw „Menu główne" (kod menu `main`)
i przypisuje do niego wszystkie pozycje bez przypisanego zestawu.

Usunięcie domeny **automatycznie kasuje** całe jej drzewo menu oraz wszystkie
zestawy (cascade w `deleteDomain()`). Operacje odnotowane w dzienniku zdarzeń
(kanał `Nawigacja`).

> **Kontrola dostępu** — sekcje **Uprawnienia**, **Grupy** i **Domeny** są dostępne
> tylko dla kont z grupy **Administrator** (oraz konta serwisowego `admin`). Konta
> z grupy Użytkownik nie widzą sekcji Ustawienia; bezpośrednie wejście na
> `?page=permissions`, `?page=groups` lub `?page=domains` jest blokowane
> (przekierowanie na Pulpit) i odnotowane w dzienniku zdarzeń (WARN, kanał `Auth`).

### Uprawnienia — zarządzanie kontami

Strona pokazuje wyłącznie **listę kont** (login, e-mail, status, ostatnie
logowanie, data utworzenia). Operacje:

- **Dodaj** — przycisk w nagłówku listy → formularz nowego konta
  (`?page=permissions&new`): login, hasło wpisywane **dwukrotnie** (z walidacją
  zgodności), e-mail (opcjonalnie), **grupa uprawnień**.
- **Edytuj** — ikona w kolumnie *Akcje* → formularz edycji
  (`?page=permissions&edit=<UseID>`): login, e-mail, **grupa uprawnień**, status
  aktywności oraz **usunięcie konta**. Hasło zmienia się osobno — przyciskiem
  **Zmień hasło** (okno modalne); przy edycji **własnego** konta wymagane jest
  podanie aktualnego hasła.

Konto serwisowe **`admin` jest chronione** — nie można zmienić jego grupy,
dezaktywować go ani usunąć (blokada w formularzu edycji i w backendzie).

Hasła zapisywane wyłącznie jako hash (`password_hash()`); zapytania na prepared
statements. Akcje działają w schemacie POST→Redirect→GET — odświeżenie strony
nie powtarza operacji.

### System

Migracje (`MigrationRunner::runPending()`) uruchamiane są **przy wejściu na tę
stronę** — Pulpit i Uprawnienia ładują się bez dotykania migratora. Przycisk
*Wymuś migrację* kasuje lock-pliki i uruchamia migrator od nowa.

---

## 4. Struktura plików

Każda podstrona panelu to **osobna para plików**: backend `adm<strona>.php`
(obsługa akcji, przygotowanie danych) i widok `adm<strona>.view.php` (szablon
HTML — tylko prezentacja). `index.php` jest plikiem startowym.

### Pliki wspólne (`admin/`)

| Plik | Rola |
|---|---|
| [admin/index.php](../admin/index.php) | **Punkt startowy** — bootstrap, kontrola kodu dostępu, uwierzytelnianie, routing podstron. |
| [admin/admcore.php](../admin/admcore.php) | **Rdzeń** — wspólne funkcje (konta, grupy, domeny, połączenie z bazą). |
| [admin/admlayout.view.php](../admin/admlayout.view.php) | **Powłoka** — wspólny szablon AdminLTE (topbar, menu, stopka); osadza widok podstrony. |
| [admin/admlogin.view.php](../admin/admlogin.view.php) | **Widok logowania** — ekran logowania (gdy brak sesji). |
| [admin/index.css](../admin/index.css) | **Style** — wspólne dla logowania i panelu. Plik statyczny. |
| [admin/index.js](../admin/index.js) | **Skrypt** — przełączniki motywu i dostępności. |
| [admin/.htaccess](../admin/.htaccess) | Routing ruchu pod `admin/` do `index.php`. |
| [admin/assets/](../admin/assets/) | Zwendorowane biblioteki front-endu (AdminLTE, Bootstrap, jQuery, Font Awesome) + obrazy. |

### Podstrony (`admin/pages/<sekcja>/`)

Pliki podstron leżą w `admin/pages/`, pogrupowane w katalogi sekcji:

| Katalog | Podstrona | Pliki |
|---|---|---|
| `pages/desktop/` | Pulpit | `admpulpit.php` + `admpulpit.view.php` |
| `pages/settings/` | Uprawnienia | `admuprawnienia.php` + `admuprawnienia.view.php` |
| `pages/settings/` | Grupy | `admgrupy.php` + `admgrupy.view.php` |
| `pages/settings/` | Domeny | `admdomeny.php` + `admdomeny.view.php` |
| `pages/navigation/menu/` | Menu nawigacyjne — zestawy | `admmenu.php` + `admmenus.view.php` |
| `pages/navigation/menu/` | Menu nawigacyjne — drzewo | `admmenu.php` + `admmenu.view.php` |
| `pages/navigation/menu/` | Menu nawigacyjne — edycja pozycji | `admmenuedit.php` + `admmenuedit.view.php` |
| `pages/system/` | System | `admsystem.php` + `admsystem.view.php` |

Katalog `pages/settings/` skupia podstrony zakładki **Ustawienia**;
`pages/navigation/menu/` to obszar roboczy menu wybranej witryny — `?id=` wskazuje
domenę, `&menu=` wskazuje konkretny zestaw menu.

### Przebieg żądania

1. `index.php` — bootstrap, weryfikacja kodu dostępu, sesja, uwierzytelnianie.
2. Brak sesji → `admlogin.view.php` (ekran logowania) i koniec.
3. Sesja jest → routing: `?page=` mapowany na ścieżkę `pages/<sekcja>/adm<strona>`.
4. `require` backendu podstrony (`adm<strona>.php`) — obsługa akcji, przygotowanie danych.
5. `require` powłoki `admlayout.view.php`, która osadza widok podstrony (`adm<strona>.view.php`).

Backend przygotowuje wszystkie dane; widok wyłącznie je renderuje — bez zapytań
do bazy i logiki biznesowej.

### Ochrona plików

Z poziomu przeglądarki dostępny jest wyłącznie `index.php`. Pozostałe pliki PHP
panelu są niewywoływalne bezpośrednio — w dwóch warstwach:

- **`admin/.htaccess`** — reguła `RewriteRule ^adm.*\.php$ - [F]` blokuje pliki
  `adm*.php` w katalogu `admin/` (rdzeń, powłoka, logowanie) → 403.
- **`admin/pages/.htaccess`** — `Require all denied` blokuje cały katalog
  podstron → 403.
- **strażnik `if (!defined('ROOT'))`** na początku każdego pliku → 404, gdyby
  plik mimo wszystko trafił do interpretera.

---

## 5. Zasoby offline

Panel **nie zależy od sieci**. Wszystkie biblioteki front-endu są zwendorowane
w [admin/assets/](../admin/assets/): AdminLTE 3.2, Bootstrap 4.6, jQuery 3.6,
Font Awesome 6.5 (z webfontami). Żadnych linków CDN.

Każdą nową zależność CSS/JS/font/obraz pobiera się do `admin/assets/` i wskazuje
ścieżką względną. Pochodzenie i licencje pobranych mediów odnotowuje się
w [docs/media/README.md](media/README.md).

---

## 6. Motyw — jasny / ciemny / WCAG

Panel i ekran logowania mają trzy tryby motywu oraz dodatkowe opcje
dostępności. Przełączają je cztery ikony:

- ☀ / 🌙 (`#theme-toggle`) — motyw **jasny ↔ ciemny**,
- ♿ (`#wcag-toggle`) — tryb **WCAG** (wysoki kontrast),
- A (`#font-toggle`) — rozmiar tekstu **A / A+ / A++**,
- ◐ (`#gray-toggle`) — **skala szarości**.

Umiejscowienie ikon:

- **ekran logowania** — prawy górny róg strony,
- **panel** — topbar, po prawej stronie (obok nazwy użytkownika).

| Tryb | Klasa `<body>` | Opis |
|---|---|---|
| jasny | — | Domyślny. |
| ciemny | `dark-mode` | Tryb ciemny AdminLTE (panel) + własne reguły ciemne (logowanie). |
| WCAG | `wcag-mode` | Wysoki kontrast wg **WCAG 2.2**. |

Wybór zapamiętywany jest w ciasteczku `k2_theme` (`light` / `dark` / `wcag`).
Klasę motywu na `<body>` ustawia serwer już przy renderowaniu strony — motyw nie
„mignie" przy ładowaniu. Przełączanie w locie obsługuje [admin/index.js](../admin/index.js).

### Tryb WCAG

Wysoki kontrast zgodny z aktualnym **WCAG 2.2**:

- czarne tło, biały tekst, żółte elementy interaktywne (przyciski, odnośniki),
- odnośniki dodatkowo **podkreślone** (rozróżnialność nie tylko kolorem — WCAG 1.4.1),
- wyraźny, zawsze widoczny **fokus** (`outline` żółty — WCAG 2.4.7 / 2.4.11),
- obrazy dekoracyjne (tło logowania) ukryte.

Reguły trybu — sekcja *Tryb WCAG* w [admin/index.css](../admin/index.css); działają
zarówno na ekranie logowania, jak i na wszystkich stronach panelu (nadpisania
AdminLTE). Aby objąć trybem także panel, `index.css` jest dołączany również
w widoku panelu.

### Opcje dostępności

Niezależnie od wybranego motywu dostępne są dwie dodatkowe opcje (przyciski
`#font-toggle` i `#gray-toggle`):

- **Rozmiar tekstu** — trzy poziomy: A / A+ / A++ (`html.font-lg` / `html.font-xl`).
  Skalują `font-size` na `<html>`, więc cały interfejs (oparty o `rem`) powiększa
  się proporcjonalnie. Zgodne z WCAG 1.4.4 (Resize Text).
- **Skala szarości** — `html.grayscale` nakłada filtr `grayscale(1)` na całą
  stronę. Pomaga osobom wrażliwym na kolor i przy weryfikacji kontrastu.

Stan zapamiętywany jest w ciasteczkach `k2_font` (`0` / `1` / `2`) oraz `k2_gray`
(`0` / `1`). Klasy są ustawiane na `<html>` (nie `<body>`), żeby skalowanie `rem`
i filtr objęły całą stronę.

---

## 7. Dziennik zdarzeń (audyt)

Panel zapisuje zdarzenia do dziennika przez mechanizm logowania
([core/Log/Logger.php](../core/Log/Logger.php) — opis: [docs/logowanie.md](logowanie.md)).
Wpisy trafiają do tabeli `<tenant>_logs`.

Rejestrowane zdarzenia:

| Kanał | Zdarzenie | Poziom |
|---|---|---|
| `Auth` | Udane logowanie | INFO |
| `Auth` | Nieudana próba logowania | WARN |
| `Auth` | Wylogowanie | INFO |
| `Konta` | Utworzenie / edycja / zmiana statusu konta | INFO |
| `Konta` | Usunięcie konta | WARN |
| `Nawigacja` | Dodanie / edycja pozycji menu | INFO |
| `Nawigacja` | Usunięcie pozycji (z kaskadą potomków) | WARN |
| `Nawigacja` | Dodanie / edycja / usunięcie zestawu menu | INFO |
| `Nawigacja` | Przywrócenie snapshotu historii | INFO |

ID zalogowanego konta trafia do kolumny `LogUserID`. Panel włącza też globalne
przechwytywanie błędów (`Logger::registerHandlers()`) — nieobsłużone wyjątki
i błędy PHP są automatycznie logowane.

---

## 11. Wtyczka Muzyka — moduł YouTube

Wtyczka [admin/ext/music/](../admin/ext/music/) ma trzy podstrony:

| Podstrona | URL | Zawartość |
|---|---|---|
| **Utwory** | `?page=ext&plugin=music&sub=tracks` | Magazyn utworów audio + edycja metadanych + AI sugestie. Selektor widoku **SoundCloud / Mixcloud**: SC — lista lokalna z sync (wsadowy + pojedynczy utwór z kebaba), sortowanie kolumn (utwór/czas/data/statystyki); Mixcloud — jedna zintegrowana tabela utworów (status + statystyki cloudcasta inline, upload, osobny edytor metadanych). |
| **YouTube** | `?page=ext&plugin=music&sub=videos` | Lista filmów własnego kanału z YT API + bulk SEO editing offline-first. |
| **Integracje API** | `?page=ext&plugin=music&sub=api` | Zakładki konfiguracji integracji: SoundCloud, YouTube, Spotify, Deezer, Last.fm, MusicBrainz, **Mixcloud** (Public API + OAuth, upload), **Audius** (Public API read-only, host discovery + `app_name`). |

### 11.1 Setup YouTube (Integracje API → YouTube)

1. **Google Cloud Console** ([console.cloud.google.com](https://console.cloud.google.com/)) → nowy projekt.
2. *APIs & Services → Library* → włącz **YouTube Data API v3**.
3. *APIs & Services → OAuth consent screen*:
   - **Audience: External** (jeśli nie masz Google Workspace).
   - **Test users**: dodaj swój email + każde inne konto YouTube którym chcesz zarządzać (max 100).
   - Scope: `https://www.googleapis.com/auth/youtube.force-ssl` (pełen read+write na własnych filmach).
4. *APIs & Services → Credentials* → **Create OAuth 2.0 Client ID** (typ: Web application).
   - Pomiń *Authorized JavaScript origins* (server-side flow).
   - W *Authorized redirect URIs* wklej **dokładnie** URL z ramki w panelu
     (typowo `http://<host>/music/youtube/`).
5. Skopiuj Client ID i Client Secret do panelu → *Zapisz konfigurację* → *Autoryzuj w Google / YouTube*.

W trybie Testing Google **wygasza refresh_token po 7 dniach** — co tydzień klik *Autoryzuj ponownie*. Pozbycie się tego wymaga *Push to production* + audytu Google (~kilka tygodni).

### 11.2 Lista filmów (Muzyka → YouTube)

Lista pobierana z YT API (uploads playlist + batch /videos) i zapisywana lokalnie do `def_m_videos`:

- **Pierwsze wejście** (lokalna baza pusta): auto-sync (~3 jedn. quoty).
- **Kolejne wejścia**: czytane z lokalnej bazy — działa **offline**.
- **Klik *Odśwież z YouTube***: ręczna re-synchronizacja (UPSERT z protekcją `VidHasPending=0`).

**Toolbar nad tabelą**:
- Counter `X z N filmów` (zmienia się po filtrowaniu).
- Dropdown *Sortuj*: Najnowsze (default) / Najstarsze / Najwięcej wyświetleń / Najwięcej polubień / Najwięcej komentarzy / Tytuł A→Z / Tytuł Z→A / Niezsync. najpierw.
- Search input *Filtruj po tytule / tagach…* — client-side, real-time, Esc czyści.

**Kolumny tabeli**: Miniaturka (lokalna kopia z `/music/media/yt-thumbs/`) · Tytuł + tagi + ewentualny badge `niezsync.` · Statystyki (👁/👍/💬) · Data publikacji · Status (Publiczny/Niepubliczny/Prywatny) · Akcje (link YouTube w nazwanym oknie `yt-preview` + edycja).

### 11.3 Modal edycji SEO

4 zakładki:

1. **Podstawowe** — tytuł (max 100), opis (max 5000) z licznikami znaków.
2. **Metadane / SEO** — tagi (suma ≤500 znaków), kategoria (dropdown 15 najpopularniejszych), `defaultLanguage` i `defaultAudioLanguage` (ISO 639-1).
3. **AI** — generator przez Claude/Groq/Ollama z 4 operacjami (3 tytuły / opis SEO / 10–15 tagów / komplet TYTUL+OPIS+TAGI). Custom prompt z podglądem. *Wklej do pól* parsuje wynik i wkłada w odpowiednie inputy.
4. **Historia** — wszystkie zmiany SEO per film z `def_m_video_history` (przed/po, kto, kiedy, status sync ☁️↑ / ☁️✓).

### 11.4 Workflow zapisu (offline-first)

Klik *Wyślij do YouTube*:

1. **Zapis lokalny** + wpis w historii per zmienione pole (zawsze, niezależnie od stanu sieci).
2. **PUT `/videos?part=snippet`** do YT API (50 jedn. quoty).
3. **Sukces** → mark wpisów historii jako `synced` + update pristine `VidYt*` + reset `VidHasPending=0`.
4. **Fail** (offline, 401, rate-limit) → lokalne zmiany pozostają z `VidHasPending=1`, badge `niezsync.` widoczny w liście, można spróbować ponownie po odzyskaniu sieci.

Quota dziennie 10000 jedn. → ~200 zapisów (50 jedn./req) + ~3000 odświeżeń listy (3 jedn./req).

### 11.5 AI generator (zakładka *AI*)

- **Providery**: Claude (Anthropic API), Groq (free tier z 16 modelami), Ollama (lokalny, offline AI).
- **System prompt**: `Jesteś asystentem SEO dla kanału YouTube. Twórz krótkie, zwięzłe, naturalnie brzmiące propozycje w języku polskim. Nie używaj emoji.`
- **Operations**:
  - `title` — 3 alternatywne tytuły (max 70 znaków każdy, SEO-friendly).
  - `description` — opis 1500–3000 znaków, pierwsze 150 = preview.
  - `tags` — 10–15 tagów, suma ≤500 znaków.
  - `all` — pełen format `TYTUL:`/`OPIS:`/`TAGI:` (parsowany regexem przy *Wklej do pól*).
- **Historia**: wszystkie wywołania (sukces + błąd) zapisywane w `def_m_video_ai_history`, indeksowane per YouTube video ID.

Bez ograniczeń AI quoty (poza limitami providera).
