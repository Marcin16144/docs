# Architektura CMS

Ten rozdział wyjaśnia, **jak CMS działa pod maską** — od warstw aplikacji, przez cykl życia żądania, po system pluginów, model danych i cache. Zrozumienie architektury pomaga ocenić wydajność, bezpieczeństwo i możliwości rozbudowy systemu.

## Warstwy CMS (architektura warstwowa)

Większość CMS to aplikacja warstwowa (layered architecture):

```
┌──────────────────────────────────────────────────────────┐
│  WARSTWA PREZENTACJI (Presentation)                       │
│  szablony, motywy, HTML/CSS/JS, panel admina              │
├──────────────────────────────────────────────────────────┤
│  WARSTWA APLIKACJI / LOGIKI (Application)                 │
│  routing, kontrolery, logika biznesowa, hooki, pluginy    │
├──────────────────────────────────────────────────────────┤
│  WARSTWA DOSTĘPU DO DANYCH (Data Access)                  │
│  ORM / query builder, modele, abstrakcja bazy             │
├──────────────────────────────────────────────────────────┤
│  WARSTWA DANYCH (Persistence)                             │
│  baza danych (MySQL/PostgreSQL), pliki, cache, media      │
└──────────────────────────────────────────────────────────┘
```

Rozdzielenie warstw pozwala wymieniać elementy niezależnie (np. inny motyw bez ruszania logiki, inna baza bez zmiany szablonów).

## Cykl życia żądania (request lifecycle)

Co dzieje się od kliknięcia linku do wyświetlenia strony w tradycyjnym CMS:

```
1. Przeglądarka          GET /blog/czym-jest-cms
        │
        ▼
2. Serwer WWW            Nginx/Apache → przekazuje do PHP/Node
        │
        ▼
3. Bootstrap CMS         ładowanie rdzenia, konfiguracji, pluginów
        │
        ▼
4. Routing               dopasowanie URL → "pokaż wpis o slugu X"
        │
        ▼
5. Kontroler / logika    pobierz dane (z cache? z bazy?)
        │
        ▼
6. Zapytanie do bazy     SELECT * FROM posts WHERE slug = '...'
        │
        ▼
7. Renderowanie          szablon + dane → HTML
        │
        ▼
8. Hooki / filtry        pluginy modyfikują wynik (np. dodają meta SEO)
        │
        ▼
9. Cache                 zapis wyniku do bufora na kolejne żądania
        │
        ▼
10. Odpowiedź HTTP       gotowy HTML ──► przeglądarka
```

W headless CMS kroki 7-8 znikają — zamiast HTML serwer zwraca **JSON** przez API, a renderowaniem zajmuje się osobny frontend.

## Model danych (typowy schemat bazy)

Uproszczony model relacyjny (na przykładzie CMS typu WordPress/Drupal):

```
┌──────────────┐        ┌──────────────┐        ┌──────────────┐
│    USERS     │        │    POSTS     │        │  POST_META   │
├──────────────┤        ├──────────────┤        ├──────────────┤
│ id (PK)      │◄──┐    │ id (PK)      │◄───────│ post_id (FK) │
│ login        │   └────│ author_id(FK)│        │ meta_key     │
│ email        │        │ title        │        │ meta_value   │
│ role         │        │ slug         │        └──────────────┘
│ password_hash│        │ content      │
└──────────────┘        │ status       │        ┌──────────────┐
                        │ created_at   │        │    TERMS     │
                        └──────┬───────┘        ├──────────────┤
                               │                │ id (PK)      │
                        ┌──────┴────────┐       │ name         │
                        │ POST_TERMS    │◄──────│ taxonomy     │
                        │ (pivot)       │       │ (kat./tag)   │
                        │ post_id  (FK) │       └──────────────┘
                        │ term_id  (FK) │
                        └───────────────┘
```

- **USERS** — użytkownicy i ich role.
- **POSTS** — treść (wpisy, strony, produkty — często jedna tabela z polem `type`).
- **POST_META** — elastyczne pola dodatkowe (klucz-wartość) bez zmiany schematu.
- **TERMS / POST_TERMS** — taksonomie (kategorie, tagi) i ich powiązania (relacja wiele-do-wielu).

Wzorzec **meta (klucz-wartość)** to typowy sposób na elastyczność: dodajesz nowe pola bez migracji schematu — kosztem wydajności zapytań.

## MVC w CMS

Wiele CMS opiera się na wzorcu **MVC (Model-View-Controller)**:

```
        żądanie
           │
           ▼
   ┌───────────────┐    pobiera/zapisuje    ┌─────────────┐
   │  CONTROLLER   │ ─────────────────────► │    MODEL    │
   │ (logika, co   │                        │ (dane, baza,│
   │  zrobić)      │ ◄───────────────────── │  reguły)    │
   └───────┬───────┘        dane            └─────────────┘
           │
           ▼
   ┌───────────────┐
   │     VIEW      │  ──► HTML ──► użytkownik
   │  (szablon)    │
   └───────────────┘
```

- **Model** — dane i reguły biznesowe (encje: wpis, użytkownik).
- **View** — warstwa prezentacji (szablony renderujące HTML).
- **Controller** — przyjmuje żądanie, koordynuje model i widok.

Przykłady: Drupal (Symfony), Statamic/October (Laravel), Strapi (Koa/Node). WordPress historycznie nie jest czystym MVC, ale realizuje podobny podział.

## System pluginów i hooków (rozszerzalność)

Kluczowy mechanizm: jak rozszerzyć CMS **bez modyfikacji rdzenia**. Najpopularniejszy model to **hooki** (zdarzenia i filtry):

```
RDZEŃ CMS publikuje wpis
        │
        ├── do_action('before_publish')  ◄── Plugin A: sprawdź spam
        │
        ├── [ ZAPIS DO BAZY ]
        │
        ├── apply_filter('post_content')  ◄── Plugin B: dodaj przycisk share
        │                                 ◄── Plugin C: skróć obrazy do WebP
        │
        └── do_action('after_publish')    ◄── Plugin D: wyślij na Slacka
                                          ◄── Plugin E: wyczyść cache
```

- **Actions (akcje)** — „stało się zdarzenie X, wykonaj kod" (nie zwraca wartości).
- **Filters (filtry)** — „przekształć wartość X przed użyciem" (zwraca zmodyfikowaną daną).
- **Events / listeners** — nowocześniejszy odpowiednik (Symfony EventDispatcher, Node EventEmitter).
- **Service container / DI** — wstrzykiwanie zależności w CMS opartych na frameworkach.

Ten wzorzec (Observer / Pub-Sub) sprawia, że ekosystem pluginów może rozwijać się niezależnie od rdzenia. To główny powód sukcesu WordPressa.

## Warstwy cache (wydajność)

Cache to najważniejszy mechanizm wydajnościowy CMS. Im wyżej trafienie, tym szybciej:

```
ŻĄDANIE
   │
   ▼
┌─────────────────┐  trafienie → zwróć gotowy HTML (najszybsze)
│  1. CDN / Edge  │
└────────┬────────┘
         │ pudło
         ▼
┌─────────────────┐  trafienie → zwróć zbuforowaną stronę
│ 2. Page cache   │  (pełny HTML, np. Varnish, WP Super Cache)
└────────┬────────┘
         │ pudło
         ▼
┌─────────────────┐  trafienie → gotowe wyniki zapytań
│ 3. Object cache │  (Redis, Memcached)
└────────┬────────┘
         │ pudło
         ▼
┌─────────────────┐  skompilowany kod PHP w pamięci
│ 4. Opcode cache │  (OPcache)
└────────┬────────┘
         │
         ▼
┌─────────────────┐  ostateczne źródło prawdy (najwolniejsze)
│ 5. Baza danych  │
└─────────────────┘
```

| Warstwa | Co buforuje | Technologia |
|---------|-------------|-------------|
| **CDN** | Statyczne assety i strony, blisko użytkownika | Cloudflare, Fastly |
| **Page cache** | Cały wygenerowany HTML | Varnish, WP Rocket |
| **Object cache** | Wyniki zapytań do bazy | Redis, Memcached |
| **Opcode cache** | Skompilowany bajtkod | OPcache (PHP) |
| **Browser cache** | Assety po stronie klienta | nagłówki HTTP Cache-Control |

## Architektura headless

W headless CMS architektura jest rozdzielona na niezależne usługi:

```
┌────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  HEADLESS CMS  │    │  WARSTWA API     │    │   FRONTEND(Y)    │
│                │    │  REST / GraphQL  │    │                  │
│  treść + admin │───►│  (Content API)   │───►│  Next.js (web)   │
│  baza treści   │    │  + CDN dla API   │    │  Mobile app      │
│                │    │                  │    │  Smart TV        │
└────────────────┘    └──────────────────┘    └──────────────────┘
       ▲                                              │
       │              webhook (treść zmieniona)       │
       └──────────────────────────────────────────────┘
                    (trigger przebudowy SSG)
```

- CMS i frontend skalują się **niezależnie**.
- Webhooki wyzwalają przebudowę statycznej strony (SSG) po zmianie treści.
- API może być chronione kluczem i buforowane na CDN.
- Więcej o headless i renderowaniu — rozdział 06.

## Skalowanie CMS

Gdy ruch rośnie, architektura ewoluuje:

```
MAŁY RUCH                    DUŻY RUCH (wysoka dostępność)
─────────                    ──────────────────────────────
                                      [ CDN ]
                                         │
┌──────────────┐              ┌──────────────────┐
│  1 serwer:   │              │  Load Balancer   │
│  CMS + baza  │              └────────┬─────────┘
└──────────────┘                ┌──────┴──────┐
                                ▼             ▼
                          [ App 1 ]      [ App 2 ]   ... (poziomo)
                                │             │
                          ┌─────┴─────────────┴─────┐
                          ▼                         ▼
                    [ Redis cache ]         [ Baza: master ]
                                            [ + read replicas ]
                                                  │
                                            [ Object storage / S3 ]
                                            (media poza serwerem)
```

- **Skalowanie poziome** — wiele serwerów aplikacji za load balancerem.
- **Read replicas** — repliki bazy do odczytu (CMS czyta dużo, pisze mało).
- **Object storage** — media na S3/zewnętrznym storage, nie na serwerze app.
- **Stateless app** — sesje w Redis, by każdy serwer obsłużył każde żądanie.

## Bezpieczeństwo architektoniczne

- **Separacja warstw** — panel admina za dodatkowym uwierzytelnieniem/VPN.
- **Zasada najmniejszych uprawnień** — konta DB i pliki z minimalnym dostępem.
- **Walidacja i sanityzacja** — ochrona przed SQL injection, XSS, CSRF.
- **WAF** — Web Application Firewall przed aplikacją.
- **Aktualizacje** — rdzeń i pluginy to główny wektor ataku (rozdział 07).
- **Headless jako bonus** — brak publicznego panelu admina na froncie zmniejsza powierzchnię ataku.

## Podsumowanie

Architektura CMS to gra kompromisów: monolit (coupled) jest prosty i szybki w starcie, ale trudniej skalowalny i sztywny; headless jest elastyczny i wydajny, ale wymaga więcej pracy developerskiej. Cache i odpowiedni model danych decydują o wydajności, a system hooków — o możliwościach rozbudowy.
