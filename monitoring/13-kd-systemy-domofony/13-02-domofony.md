# Domofony analogowe i cyfrowe

**Sekcja:** 13 Kontrola dostępu i domofony · **Aktualizacja:** 2026-05

Systemy okablowania: 4+n (klasyczny, osobne żyły), 2-żyłowy (cyfrowy, magistrala), bezprzewodowy. Panel zewnętrzny, unifon, zasilacz, elektrozaczep i zwora elektromagnetyczna. Dwustronny intercom. Domofony wielolokatorowe do bloków. Marki: Vidos, Eura, Commax, Aco, Laskomex.

## Domofon vs wideodomofon

**Domofon** to system głosowej komunikacji dwukierunkowej między panelem przy wejściu a unifonem wewnątrz, połączony ze zdalnym otwieraniem zamka. **Wideodomofon** to ten sam zestaw rozszerzony o *obraz* — kamera w panelu zewnętrznym i monitor wewnątrz.

| Cecha | Domofon (audio) | Wideodomofon |
| --- | --- | --- |
| Komunikacja | tylko głos (rozmowa) | głos + obraz gościa |
| Panel zewnętrzny | kaseta z głośnikiem/mikrofonem | kaseta z kamerą, mikrofonem, podświetleniem |
| Urządzenie wewnętrzne | unifon (słuchawka) | monitor LCD (głośnomówiący lub ze słuchawką) |
| Bezpieczeństwo | brak weryfikacji wizualnej | widać kto dzwoni przed otwarciem |
| Cena bazowa | niższa | wyższa (kamera + monitor) |

Ten rozdział skupia się na **okablowaniu i elementach wykonawczych** wspólnych dla obu rodzajów. Wideodomofony IP omawia osobno rozdział 13-03.

## Systemy okablowania

### 4+n (klasyczny analogowy)

Najstarszy, prosty system. **4 żyły wspólne** (zasilanie, masa, audio do panelu, audio z panelu / sterowanie zaczepem) + **n żył dodatkowych** — po jednej na każdy unifon (sygnał wywołania danego mieszkania/lokalu). Stąd nazwa: dla 6 lokali potrzeba 4+6 = 10 żył w pionie.

- **Zalety:** tani sprzęt, łatwa diagnostyka (każdy obwód osobno), brak adresowania cyfrowego.
- **Wady:** grube wiązki kabli, słabo skalowalny (każdy unifon = osobna żyła), w blokach niepraktyczny powyżej kilkunastu lokali.
- **Zastosowanie:** domy jednorodzinne, małe budynki 2–8 lokali.

### 2-żyłowy (cyfrowy, magistralowy)

Nowoczesny standard. **Tylko 2 żyły** (magistrala) prowadzą jednocześnie zasilanie, audio, wideo (w wideodomofonach) i dane cyfrowe — adresowanie konkretnych monitorów/unifonów odbywa się *cyfrowo* (każde urządzenie ma adres). Topologia magistrali/szyny lub gwiazdy (zależnie od producenta).

- **Zalety:** minimalna ilość kabla (idealny do modernizacji starych pionów 4+n — można wykorzystać 2 istniejące żyły), łatwa rozbudowa, brak polaryzacji u wielu producentów.
- **Wady:** droższe urządzenia, wymóg zgodności sprzętu w obrębie jednego systemu/producenta (magistrala jest „firmowa").
- **Zastosowanie:** bloki, budynki wielorodzinne, modernizacje.

Przy **modernizacji bloku** z systemu 4+n na 2-żyłowy często udaje się wykorzystać istniejący pion (2 z dawnych żył jako nowa magistrala), co radykalnie obniża koszt — nie trzeba kuć klatki schodowej.

### Bezprzewodowy (radiowy)

Panel i monitor komunikują się drogą radiową (zwykle 2,4 GHz). Brak okablowania sygnałowego między nimi — panel zasilany z sieci lub baterii/akumulatora, monitor przenośny (jak słuchawka bezprzewodowa).

- **Zalety:** montaż bez kucia, idealny do wynajmu/obiektów zabytkowych.
- **Wady:** ograniczony zasięg (ściany, beton), opóźnienia/zakłócenia, konieczność ładowania, zwykle 1 panel ↔ kilka monitorów.
- **Zastosowanie:** domy gdzie kabel jest niemożliwy, tymczasowe instalacje.

| Kryterium | 4+n | 2-żyłowy | Bezprzewodowy |
| --- | --- | --- | --- |
| Ilość kabla | duża (4+n) | minimalna (2) | brak sygnałowego |
| Skalowalność | słaba | bardzo dobra | słaba |
| Modernizacja | trudna | łatwa (reużycie żył) | najłatwiejsza |
| Koszt sprzętu | niski | średni/wyższy | średni |
| Najlepsze do | dom 1-rodzinny | bloki, wielolokal. | brak możliwości kabla |

## Elementy systemu

| Element | Opis |
| --- | --- |
| **Panel zewnętrzny (kaseta)** | montowany przy wejściu/furtce: przycisk(i) wywołania, głośnik+mikrofon, w wideo: kamera i podświetlenie. Wykonania natynkowe/podtynkowe, wandaloodporne (metal, IK). |
| **Unifon wewnętrzny** | słuchawka audio z przyciskiem otwarcia zamka (i czasem światła). Tani, niezawodny. |
| **Zasilacz** | transformator/zasilacz dedykowany do systemu — patrz sekcja zasilanie. Często z osobnym wyjściem AC do elektrozaczepu. |
| **Elektrozaczep / zwora** | element wykonawczy zwalniający drzwi/furtkę — szczegóły niżej. |
| **Samozamykacz** | mechanizm zamykający drzwi po przejściu (warunek poprawnej pracy zaczepu/zwory). |

## Elementy wykonawcze — elektrozaczep i zwora

### Elektrozaczep

Elektrozaczep zastępuje stały blaszany zaczep w ościeżnicy ruchomym ryglem sterowanym elektrycznie. Dwa podstawowe rodzaje:

| Rodzaj | Stan spoczynkowy (bez napięcia) | Działanie | Tryb bezpieczeństwa |
| --- | --- | --- | --- |
| **Zwykły (standardowy, NO)** | drzwi **zamknięte** | podanie napięcia zwalnia rygiel → otwarcie | *fail-secure* |
| **Rewersyjny (NC)** | drzwi **otwarte** (rygiel zwolniony bez napięcia) | napięcie blokuje rygiel; zanik napięcia = otwarcie | *fail-safe* |

Zaczep zwykły zasilany jest zwykle **napięciem AC „dzwonkowym"** (charakterystyczny brzęczący dźwięk podczas otwierania). Zaczep rewersyjny i wersje „z pamięcią" (przytrzymują zwolnienie do otwarcia drzwi) zasila się DC.

### Zwora elektromagnetyczna (elektromagnes)

Elektromagnes trzymający stalową płytę (kotwę) na skrzydle drzwi siłą pola magnetycznego. Z natury **fail-safe** — bez napięcia nie trzyma (drzwi się otwierają). Kluczowy parametr to **siła trzymania**:

| Siła trzymania | Zastosowanie |
| --- | --- |
| **180 kg** | lekkie drzwi wewnętrzne, furtki |
| **280 kg** | standardowe drzwi wejściowe, biura |
| **380–500 kg** | drzwi o podwyższonej odporności, główne wejścia |

**PPOŻ i droga ewakuacyjna:** na drodze ewakuacji stosuj *fail-safe* (zwora lub zaczep rewersyjny), aby zanik prądu i alarm pożarowy odblokowały przejście. Wymagany jest też przycisk awaryjnego zwolnienia (break-glass). Elektrozaczep *zwykły (fail-secure)* na jedynym wyjściu ewakuacyjnym jest niezgodny z przepisami — uwięziłby ludzi przy braku zasilania.

Do każdych drzwi z zaczepem/zworą montuj **samozamykacz** — inaczej po przejściu drzwi pozostaną uchylone i system „nie domknie" obwodu, a zaczep zwykły po zaniku napięcia musi trafić ryglem w otwór zaczepowy.

## Domofony wielolokatorowe (bloki)

W budynkach wielorodzinnych stosuje się systemy z **centralą cyfrową** i panelem wejściowym z możliwością wywołania dowolnego z wielu lokali. Dwa warianty paneli:

- **Panel z przyciskami** — fizyczny przycisk dla każdego mieszkania (rozbudowywany modułami).
- **Panel cyfrowy z listą lokatorów** — wyświetlacz i klawiatura; gość wybiera numer lokalu lub przewija listę nazwisk. Często z wbudowanym zamkiem szyfrowym (kod) i czytnikiem zbliżeniowym dla mieszkańców (otwarcie bez wywoływania).

Polskim standardem w blokach są systemy cyfrowe z magistralą, z możliwością integracji z *elektrozaczepem furtki + bramy* i podłączenia listy lokatorów. Często czytnik kart/breloków dla mieszkańców łączy funkcję domofonu z prostą kontrolą dostępu do klatki.

## Marki — przykłady i ceny

| Marka | Charakterystyka | Przykładowy produkt | Cena (2026) |
| --- | --- | --- | --- |
| **Vidos** | polska marka, szeroka oferta domofonów i wideodomofonów, dobre wsparcie | Vidos M270 (zestaw audio jednorodzinny) | ~330 zł |
| **Eura** (Eura-Tech) | budżetowa, popularna w marketach i online | Eura ADP-31A3 zestaw domofonowy 1-rodzinny | ~250 zł |
| **Commax** | koreański producent, klasyk audio/wideo, niezawodne unifony | Commax DP-2S unifon | ~120 zł |
| **Aco** | polski producent specjalizujący się w systemach wielolokatorowych (bloki) | Aco CDN-240GR panel cyfrowy z listą lokatorów | ~1100 zł |
| **Laskomex** | polski lider domofonów cyfrowych do bloków (centrale CD) | Laskomex CD-3100 centrala cyfrowa wielolokatorowa | ~900 zł |

| Element uzupełniający | Cena orientacyjna (2026) |
| --- | --- |
| Elektrozaczep zwykły (np. Bira, Lockpol R3/R4) | ~40–90 zł |
| Elektrozaczep rewersyjny z pamięcią | ~90–160 zł |
| Zwora elektromagnetyczna 280 kg | ~130–220 zł |
| Samozamykacz drzwiowy | ~120–250 zł |
| Zasilacz domofonowy AC/DC | ~60–150 zł |

## Zasilanie i okablowanie

Domofony analogowe zasila się najczęściej **napięciem przemiennym (AC) 12–15 V** z transformatora — to samo napięcie „dzwonkowe" zasila elektrozaczep zwykły. Systemy cyfrowe i wideodomofony częściej używają **DC** (stabilizowane). Zawsze stosuj zasilacz dedykowany do danego systemu.

### Przekrój przewodów i maksymalna długość

Najczęstszą usterką jest **spadek napięcia** na długiej linii — objawia się cichym dźwiękiem, słabym otwieraniem zaczepu lub „brakiem reakcji" panelu. Dobór przekroju zależy od odległości panel↔zasilacz↔unifon:

| Długość linii (panel – zasilacz) | Zalecany przekrój żyły |
| --- | --- |
| do ~30 m | 0,5 mm² (drut Ø0,8) |
| 30–80 m | 0,75–1,0 mm² |
| powyżej 80–100 m | 1,0–1,5 mm² lub zasilanie lokalne / repeater (zależnie od systemu) |

Do **elektrozaczepu** prowadź osobną parę przewodów o większym przekroju (zaczep pobiera duży prąd w momencie zwalniania) — najlepiej z osobnego wyjścia zasilacza. Zbyt cienka żyła do zaczepu = brzęczy, ale nie zwalnia rygla.

Dla systemów **2-żyłowych cyfrowych** stosuj kabel zalecany przez producenta (często skrętka lub dedykowany przewód domofonowy). Niewłaściwy kabel (pojemność, przekrój) degraduje obraz w wideodomofonie i zasięg magistrali.
