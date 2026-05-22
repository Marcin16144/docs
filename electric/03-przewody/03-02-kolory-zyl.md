# Kolory żył

## Aktualna norma — PN-EN 60446 (od 2007)

Norma harmonizowana, obowiązująca w całej UE, jednoznacznie przypisuje funkcje przewodów do kolorów izolacji.

| Funkcja | Symbol | Kolor żyły | Uwagi |
|---|---|---|---|
| Faza L1 (jedyna w 1-faz) | L, L1 | **brązowy** | główna faza w 1-faz |
| Faza L2 | L2 | **czarny** | |
| Faza L3 | L3 | **szary** | |
| Neutralny | N | **niebieski jasny** | jasnoniebieski, nie ciemny |
| Ochronny | PE | **żółto-zielony** | wyłącznie do PE, nigdzie indziej |
| PEN (TN-C) | PEN | żółto-zielony z niebieskim oznaczeniem na końcach | przewód ochronno-neutralny |

## Reguła — co wolno, a czego nie

- **Żółto-zielony jest święty** — może pełnić wyłącznie funkcję PE. Nie wolno użyć go jako fazy ani jako N, nawet w awaryjnym przypadku.
- **Niebieski jasny** może być użyty jako neutralny N albo (rzadziej, w obwodach bez N) jako przewód sterujący, ale **musi być wtedy oznaczony** na końcach inną barwą (zwykle brązową taśmą).
- **Brązowy / czarny / szary** — fazy w dowolnym układzie kolejności (ale konsekwentnie w obrębie instalacji).

## Kolory historyczne (instalacje sprzed 2007)

W instalacjach starszych — i nadal spotykanych — obowiązywała inna konwencja:

| Funkcja | Stary kolor (do ~1990) | Pośredni (1990-2007) | Aktualny |
|---|---|---|---|
| Faza | **czerwony** (lub czarny) | czarny, brązowy | brązowy |
| Neutralny | **niebieski** (jasny lub ciemny) | niebieski | niebieski jasny |
| Ochronny PE | **żółty** lub żółto-zielony | żółto-zielony | żółto-zielony |
| Zero (PEN — TN-C) | **żółto-zielony z niebieskimi paskami** | żółto-zielony | żółto-zielony z niebieskim na końcach |

## Co robić w starej instalacji z niezgodnymi kolorami

Sytuacja typowa: rozbudowa starej instalacji, gdzie czerwony to fazowy, a zielony to PE.

1. **Sprawdź mierniki / próbnik** — nigdy nie ufaj kolorom w starej instalacji ślepo. Zmierz napięcie L-N i L-PE.
2. **Oznacz końcówki** — jeśli żyła nie ma standardowego koloru (np. dawniej cała 3-żyłowa instalacja czarna), nałóż na końce **kolorową koszulkę termokurczliwą** albo **taśmę izolacyjną**: brązową na fazę, niebieską na N, żółto-zieloną na PE.
3. **Przemalowanie żyły** — w przypadku PEN przekładanego na osobne PE i N: na końcach żyły żółto-zielonej dodaj niebieskie oznaczenie tam, gdzie zachowuje funkcję N (przy rozdziale PEN → PE + N).
4. **Nigdy nie zmieniaj funkcji żółto-zielonej** — nawet jeśli historycznie pełniła inną rolę. Lepiej przeprowadź nową żyłę.

## Łączniki i przyciski — kolory żył sterujących

W obwodach łączników świecznikowych, schodowych i krzyżowych pojawiają się przewody sterujące, które **nie są fazą roboczą L** ani neutralnym N.

| Funkcja w obwodzie łącznika | Sugerowany kolor | Uwaga |
|---|---|---|
| zasilanie fazą do łącznika | brązowy | wchodzi do styku wejściowego |
| powrót do oprawy (po włączeniu) | czarny lub szary | tzw. „przewód powrotny" |
| przewód między łącznikami schodowymi | czarny / szary | dwa przewody korespondujące |
| neutralny w oprawie | niebieski | nie może iść przez łącznik |
| ochronny do metalowej obudowy oprawy | żółto-zielony | obowiązkowy w I klasie izolacji |

## Kolory w kablach 5-żyłowych (3-faz)

Typowy układ żył w kablu YDY 5×2,5 dla obwodu 3-fazowego:

```
brązowy (L1) + czarny (L2) + szary (L3) + niebieski (N) + żółto-zielony (PE)
```

W kablach przemysłowych OWY 4-żyłowych bez N: brązowy, czarny, szary, żółto-zielony — system 3-fazowy bez przewodu neutralnego (silniki).

## Praktyczne wskazówki

- **Tulejka kolorowa** na końcach żyły linkowej (LgY) pomaga rozpoznać funkcję żyły w gęsto zabudowanej rozdzielnicy.
- W rozdzielnicy zachowaj **konsekwencję**: jeśli L1 idzie brązowym kolorem na pierwszej szynie, na wszystkich kolejnych też brązowym.
- **Etykiety + opisy** w rozdzielnicy — kolor + numer obwodu, np. „L1/B16 — oświetlenie kuchnia".

## Co dalej

➡ [Dobór przekroju przewodu](03-03-dobor-przekroju.md)
