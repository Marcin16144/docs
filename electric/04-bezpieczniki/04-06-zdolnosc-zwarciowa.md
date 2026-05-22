# Zdolność zwarciowa Icn

## Definicja

**Icn** (rated short-circuit breaking capacity) — maksymalny prąd zwarciowy, jaki dane urządzenie ochronne potrafi **wyłączyć bez uszkodzenia siebie samego**. Wyrażana w **kA** (kiloamperach).

Symbol na obudowie MCB: w prostokącie liczba w kA — np. **6000** (6 kA), **10000** (10 kA).

## Dlaczego Icn ma znaczenie

Przy zwarciu prąd L-N (lub L-PE) ograniczony jest tylko przez:
- impedancję sieci OSD (transformator, kable średniego napięcia)
- impedancję przyłącza
- impedancję przewodów wewnętrznych

Wartości typowe Ik (prąd zwarcia symetryczny) na zaciskach rozdzielnicy domowej:

| Lokalizacja | Typowy Ik |
|---|---|
| Mieszkanie w bloku, daleko od stacji trafo | **0,5 - 2 kA** |
| Mieszkanie w bloku blisko stacji | **2 - 4 kA** |
| Dom jednorodzinny, długie przyłącze (50 m) | **1 - 3 kA** |
| Dom jednorodzinny obok stacji trafo (20 m) | **5 - 10 kA** |
| Mały przemysł / warsztat | **10 - 25 kA** |
| Duża stacja trafo / przemysł | **25 - 50 kA** |

## Standardowe wartości Icn

| Icn | Klasa | Gdzie |
|---|---|---|
| **3 kA** | budżetowa | tylko obwody odgałęzione, niedopuszczalna jako główna |
| **6 kA** | **domowa standardowa** | typowe mieszkania, mniejsze domy |
| **10 kA** | przemysłowa lekka / domowa premium | domy blisko stacji, duże instalacje domowe |
| **15 / 20 / 25 kA** | przemysłowa | warsztaty, małe zakłady |
| **50 / 65 / 100 kA** | przemysłowa ciężka | rozdzielnice główne stacji |

W kategorii produktów: ABB **S201** (6 kA) vs S201**M** (10 kA) vs S201**P** (25 kA). Schneider iC60**N** (6 kA) vs iC60**H** (10 kA) vs iC60**L** (15 kA).

## Co decyduje o Ik na zaciskach instalacji

Im **bliżej** stacji transformatorowej i im **grubsze** przyłącze — tym większy Ik.

Wzór uproszczony:

```
Ik = Un / Z_pętli
```

Gdzie Z_pętli to suma impedancji wszystkich elementów od trafo do zacisków:

- transformator (np. 400 kVA, uk = 4 %) → ~25 mΩ
- przyłącze średniego napięcia (krótkie) → ~5 mΩ
- przyłącze nN do złącza (50 m, 70 mm² Al) → ~30 mΩ
- WLZ do rozdzielnicy (30 m, 10 mm² Cu) → ~55 mΩ

```
Z_pętli ≈ 115 mΩ
Ik ≈ 230 / 0,115 = 2 kA
```

## Konsekwencje przekroczenia Icn

Jeśli MCB ma Icn = 6 kA, a w obwodzie wystąpi zwarcie z Ik = 12 kA, mogą wystąpić:

1. **Spawanie się styków** — MCB nie odłączy obwodu, prąd dalej płynie
2. **Eksplozja obudowy** — wewnętrzne rozprężenie łuku rozsadza obudowę bakelitową
3. **Wyrzut iskier / plazmy** — niebezpieczeństwo pożaru, uszkodzenia sąsiednich aparatów
4. **Pożar rozdzielnicy** — bo łuk się nie ugasł

Dlatego dobór Icn nie jest luksusem — to fundament bezpieczeństwa.

## Współpraca kaskadowa (cascade)

Producenci podają tabele **filiation** / **cascade** — wskazują, że jeśli za małym MCB znajduje się większy **zabezpieczający** aparat, mniejszy może być stosowany w obwodzie o większym Ik niż jego własna Icn.

Przykład (ABB):
```
W rozdzielnicy główny S203-C40 (Icn = 6 kA)
  ↓
S201-B16 (Icn = 6 kA) ale kaskadowo dozwolony do 10 kA dzięki głównemu
```

Wytłumaczenie: główny szybko ograniczy prąd zwarciowy (otworzy się przy ~5 ms), więc dolny MCB nie zobaczy pełnego Ik — tylko zredukowany.

**Uwaga:** kaskada wymaga zgodności tej samej linii produktów tego samego producenta. Tabele kaskadowe — w katalogach producenta.

## Selektywność a kaskada — różnica

Te dwa pojęcia są często mylone:

| Cecha | Selektywność | Kaskada |
|---|---|---|
| Cel | wyłącza się tylko dolny | dolny wytrzymuje większe Ik dzięki górnemu |
| Sprzeczne? | tak — przy zwarciu o dużym Ik | są kompromisem |
| Wymagania | duża różnica In / czasowa S | bliska koordynacja producenta |

Czasem trzeba wybrać: selektywność (czyli komfort) vs kaskada (mniejsze MCB, taniej, ale wyłączy się też górny).

## Klasy filtracji aparatu (klasa 1, 2, 3)

W przemysłowej klasyfikacji rozdzielnic spotyka się **klasę filtracji** wkładek przemysłowych — odporność konstrukcji na pylenie i wibracje. Klasa 3 — przemysł ciężki. Dla domu zwykle klasa 1 wystarcza.

## Jak sprawdzić Ik w istniejącej instalacji

1. **Miernik pętli zwarcia (Loop Tester)** — np. Sonel MIC-2510, Metrel MI 3125 — zmierzy Zs i Ik na każdym gniazdku.
2. **Obliczenia z dokumentacji OSD** — Tauron, PGE itp. mają na żądanie wartości Ik w punkcie przyłączenia.
3. **Tabele orientacyjne** w katalogach Hager, Schneider — szacunki dla typowych przyłączy.

## Czy zawsze 6 kA wystarczy?

- **W mieszkaniu w bloku** — prawie zawsze tak.
- **W nowym domu blisko stacji trafo** — sprawdź, może być potrzebne 10 kA.
- **W warsztacie z silnym przyłączem (np. 63 A 3-faz, blisko trafo)** — koniecznie 10 kA, czasem nawet 15-25 kA dla głównego MCB.
- **Wybór konserwatywny** dla nowych instalacji: **MCB 10 kA** dla głównego, 6 kA dla obwodów odgałęzionych w kaskadzie.

## Podsumowanie

Icn to liczba, na którą warto patrzeć **przed** kupnem MCB. Tania wkładka 3 kA z marketu pasuje tylko jako lampa stołowa — w rozdzielnicy mieszkania bywa za mała. Standardem jest 6 kA, a w nowoczesnych domach z dużym przyłączem — 10 kA.

## Co dalej

Sekcja bezpieczników zakończona. Następna — [05 Instalacja domowa](../05-instalacja-domowa/index.html) z obwodami, rozmieszczeniem gniazd i schematami.
