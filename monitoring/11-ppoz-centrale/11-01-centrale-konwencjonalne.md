# Centrale SAP konwencjonalne

## Architektura konwencjonalna

System SAP konwencjonalny opiera się na podziale obiektu na **linie dozorowe** (zwane też pętlami konwencjonalnymi, choć nie są to prawdziwe pętle adresowalne). Każda linia to dwużyłowy obwód, do którego podłączonych jest równolegle do 32 czujek punktowych (typowo: kabel YnTKSY 1×2×1,4 mm² lub HTKSH).

```
Centrala
  ├── Linia 1 ──○─○─○─○─○──[R 4k7]   (sypialnie, korytarz)
  ├── Linia 2 ──○─○─○──[R 4k7]       (salon, kuchnia, łazienka)
  ├── Linia 3 ──○─○─○─○──[R 4k7]     (piwnica, garaż)
  └── Linia 4 ──[ROP][ROP]──[R 4k7]  (ręczne ostrzegacze)
```

**Działanie:**

- centrala zasila linię stałym napięciem (~24 V DC) i mierzy prąd spoczynkowy,
- na końcu linii **rezystor końca linii (EOL)** typowo 4,7 kΩ — pozwala centrali wykryć przerwę,
- czujka w stanie czuwania pobiera ~50 µA (mikroprąd),
- czujka w alarmie zwiera linię (~10 mA) → centrala wykrywa skok prądu na danej linii,
- centrala wie tylko, że **na linii X coś zadziałało** — nie wie która czujka.

## Stany linii dozorowej

| Stan | Prąd na linii | Co oznacza |
|---|---|---|
| **DOZÓR** | ~5 mA (przez 4,7 kΩ EOL) | stan normalny, wszystkie czujki OK |
| **ALARM** | ~10–20 mA | jedna lub więcej czujek w alarmie |
| **USZKODZENIE — przerwa** | 0 mA | przerwany kabel lub uszkodzony EOL |
| **USZKODZENIE — zwarcie** | >50 mA | zwarcie kabla / zalanie |

## Strefa pożarowa vs linia dozorowa

Pojęcia często mylone:

- **strefa pożarowa** — obszar oddzielony ścianami i drzwiami o odpowiedniej odporności ogniowej (REI 60/120/240). To pojęcie z dziedziny ochrony przeciwpożarowej budynku.
- **linia dozorowa (strefa dozorowa)** — obwód elektryczny SAP. To pojęcie ze sterowania i sygnalizacji.

Zasada: **jedna linia dozorowa = jedna strefa pożarowa** (lub fragment, jeśli strefa duża). Nie wolno na jednej linii mieć czujek z dwóch różnych stref pożarowych.

## Typowe wielkości central konwencjonalnych

| Liczba linii | Maks. czujek | Obiekt | Cena (przybl.) |
|---|---|---|---|
| 2 linie | 64 czujek | sklep, gabinet, mały warsztat | 1 200–2 500 zł |
| 4 linie | 128 czujek | mały hotel, dom kultury, przedszkole | 2 500–4 500 zł |
| 8 linii | 256 czujek | średnia szkoła, biurowiec piętrowy | 4 500–8 000 zł |
| 16 linii | 512 czujek | maks. zalecane (nad to → adresowalna) | 8 000–15 000 zł |

## Sygnał wyjściowy z centrali

Każda centrala SAP ma co najmniej:

- **wyjście syren** (1–4 linie sygnalizacyjne) — uruchamia sygnalizatory akustyczno-optyczne,
- **wyjście do monitoringu** (przekaźnik bezpotencjałowy NC/NO) — do nadajnika transmisji ATS / GSM,
- **wyjście awarii** (przekaźnik) — sygnalizuje uszkodzenie systemu,
- **wyjścia programowalne** (PGM) — sterowanie wentylacją, oddymianiem, klapami przeciwpożarowymi.

## Centrale Polon-Alfa POLON 4xxx

Najpopularniejsza polska seria konwencjonalna (zastąpiła starsze CSP-30, CSP-40):

| Model | Liczba linii | Akumulator | Cechy |
|---|---|---|---|
| POLON 4100 | 1 | 2× 7 Ah | mała, do gabinetów |
| POLON 4200 | 2 | 2× 7 Ah | standard sklep / kawiarnia |
| POLON 4400 | 4 | 2× 17 Ah | mały hotel, przychodnia |
| POLON 4800 | 8 | 2× 17 Ah | średnia szkoła |

Wszystkie posiadają certyfikat **CNBOP-PIB** (Centrum Naukowo-Badawcze Ochrony Przeciwpożarowej), zgodność z PN-EN 54-2 (centrale) i PN-EN 54-4 (zasilacze).

## Inne marki konwencjonalne

- **Bosch FPC-500** — 2/4/8 linii, kompatybilny z czujkami Bosch FCH-200/FCP-O,
- **Inim PREVIDIA C100/C200** — włoska centrala 2/4/8 linii, certyfikat CPR,
- **Hochiki HCV-2/4/8** — kompatybilna z czujkami Hochiki SLR-E (najwyższa jakość czujników),
- **Notifier ID3000** — wersja konwencjonalna,
- **ZITON ZP1** — UK, populare w hotelach,
- **Cooper / Eaton CF2000** — 2/4/6/8 linii.

## Zalety i wady konwencjonalnych

| Zalety | Wady |
|---|---|
| tania centrala (od 1200 zł) | brak dokładnej lokalizacji (tylko linia) |
| tanie czujki (60–150 zł) | czujki niewymienne między producentami |
| prosty montaż i serwis | limit 16 linii — duże obiekty wymagają wielu central |
| nie wymaga komputera do konfiguracji | brak komunikacji z BMS / SCADA |
| technika sprawdzona od dziesięcioleci | trudne rozbudowy (kable po linii) |

## Kiedy wybrać konwencjonalną

- obiekt do **~500 m²** (lub do 4 stref pożarowych),
- budżet ograniczony,
- brak wymagania integracji z BMS / systemem zarządzania budynkiem,
- prosty układ przestrzenny (łatwo zlokalizować zagrożenie wzrokowo po dotarciu na linię),
- brak ROZP. dot. SUG (stałych urządzeń gaszących), które najczęściej wymagają lokalizacji adresowej.

> **Uwaga prawna:** w Polsce projekt systemu SAP w obiektach z obowiązkiem SAP (np. budynki użyteczności publicznej powyżej określonych metraży, hotele, szpitale) sporządza **rzeczoznawca ds. zabezpieczeń przeciwpożarowych**. Wykonawstwo i konserwacja — firma z personelem przeszkolonym przez producenta, posiadająca uprawnienia (zaświadczenie SEP D+E, świadectwo kwalifikacji ppoż).

## Programowanie i konfiguracja

Większość central konwencjonalnych konfigurowana jest **z klawiatury obudowy** (LCD + przyciski). Zakres ustawień:

- etykiety linii (np. „Sala konferencyjna", „Kuchnia"),
- opóźnienia alarmu (0–600 s) — czas na sprawdzenie przez obsługę przed wyjściem alarmu na zewnątrz,
- tryby tłumienia nocnego (sztab obsługi reaguje wolniej w nocy → wyższe progi),
- scenariusze: linia 5 alarm → wyjście PGM 2 → zamknięcie zaworu gazu kuchni,
- logi zdarzeń (~1000 wpisów ostatnich alarmów / awarii).

## Co dalej

➡ [Centrale adresowalne](11-02-centrale-adresowalne.md)
