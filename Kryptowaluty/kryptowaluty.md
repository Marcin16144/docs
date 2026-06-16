# Kryptowaluty — od podstaw do kopania (Windows i macOS)

> Kompletny przewodnik: czym są kryptowaluty, jak działa blockchain, na czym polega
> kopanie (mining) i jakim oprogramowaniem kopać na Windows oraz macOS — wraz z praktyczną
> sekcją pod **NVIDIA GeForce RTX 5060 8 GB** (Windows) i osobnym, pełnym **rozdziałem o
> kopaniu na macOS** (Apple Silicon, m.in. Mac Studio — od instalacji po kompilację ze
> źródeł).
>
> Stan wiedzy: **czerwiec 2026**. Dane o opłacalności i kursach zmieniają się codziennie —
> traktuj liczby jako orientacyjne i weryfikuj w kalkulatorach (linki w sekcji *Źródła*).
>
> ⚠️ **To materiał edukacyjny, nie porada inwestycyjna ani podatkowa.** Kryptowaluty są
> bardzo zmienne i ryzykowne. Inwestuj wyłącznie środki, których utratę jesteś w stanie
> zaakceptować.

---

## Spis treści

1. [Część I — Podstawy](#część-i--podstawy)
   - [Czym jest kryptowaluta](#1-czym-jest-kryptowaluta)
   - [Blockchain — jak to działa](#2-blockchain--jak-to-działa)
   - [Bitcoin](#3-bitcoin)
   - [Ethereum i smart kontrakty](#4-ethereum-i-smart-kontrakty)
   - [Altcoiny, tokeny, stablecoiny](#5-altcoiny-tokeny-stablecoiny)
   - [Klucze, adresy i portfele](#6-klucze-adresy-i-portfele)
   - [Jak nabyć kryptowaluty](#7-jak-nabyć-kryptowaluty-giełdy-i-kantory)
   - [Konsensus: PoW vs PoS](#8-mechanizmy-konsensusu-pow-vs-pos)
2. [Część II — Kopanie (mining): teoria](#część-ii--kopanie-mining-teoria)
   - [Czym jest mining](#9-czym-jest-mining-i-po-co-istnieje)
   - [Jak działa kopanie PoW](#10-jak-technicznie-działa-kopanie-pow)
   - [CPU vs GPU vs ASIC](#11-cpu-vs-gpu-vs-asic)
   - [Solo vs pool](#12-kopanie-solo-vs-w-puli-pool)
   - [Algorytmy wydobywcze](#13-algorytmy-wydobywcze)
   - [Co dziś można kopać](#14-co-dziś-realnie-można-kopać-2026)
   - [Opłacalność](#15-opłacalność--od-czego-zależy)
3. [Część III — Oprogramowanie do kopania](#część-iii--oprogramowanie-do-kopania)
   - [Windows](#16-windows)
   - [macOS](#17-macos)
   - [Tabela porównawcza](#18-tabela-porównawcza-minerów)
4. [Część IV — Praktyka: Windows + RTX 5060 8 GB](#część-iv--praktyka-windows--rtx-5060-8-gb)
5. [Część V — Kopanie na macOS (kompletny przewodnik)](#część-v--kopanie-na-macos-kompletny-przewodnik)
6. [Część VI — Bezpieczeństwo](#część-vi--bezpieczeństwo)
7. [Część VII — Prawo i podatki w Polsce](#część-vii--prawo-i-podatki-w-polsce)
8. [Słowniczek](#słowniczek)
9. [Źródła i dalsza lektura](#źródła-i-dalsza-lektura)

---

# Część I — Podstawy

## 1. Czym jest kryptowaluta

**Kryptowaluta** to cyfrowy pieniądz, który działa bez banku ani żadnej centralnej
instytucji. Zamiast zaufania do pośrednika opiera się na:

- **kryptografii** — matematyce zabezpieczającej własność i transakcje,
- **sieci rozproszonej (P2P)** — tysiącach komputerów na całym świecie, które wspólnie
  prowadzą i weryfikują wspólny rejestr,
- **konsensusie** — regułach, dzięki którym wszyscy zgadzają się co do stanu rejestru,
  mimo że nikt nikomu nie ufa.

Najważniejsze cechy:

| Cecha | Co oznacza |
|-------|-----------|
| Decentralizacja | Brak jednego właściciela/serwera; sieć działa, póki działają węzły. |
| Niezmienność | Zatwierdzonej transakcji nie da się cofnąć ani „wymazać". |
| Przejrzystość | Większość łańcuchów jest publiczna — każdy może podejrzeć transakcje. |
| Pseudonimowość | Widać adresy (ciągi znaków), niekoniecznie tożsamość właściciela. |
| Ograniczona podaż | Wiele kryptowalut ma sztywny limit (np. 21 mln BTC). |

## 2. Blockchain — jak to działa

**Blockchain** (łańcuch bloków) to baza danych zbudowana z kolejnych „bloków"
transakcji, połączonych kryptograficznie w łańcuch.

```
Blok N-1            Blok N              Blok N+1
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ hash bloku   │◄───│ hash poprz.  │◄───│ hash poprz.  │
│ N-2          │    │ (= hash N-1) │    │ (= hash N)   │
│ transakcje   │    │ transakcje   │    │ transakcje   │
│ znacznik czasu│   │ znacznik czasu│   │ znacznik czasu│
└──────────────┘    └──────────────┘    └──────────────┘
```

Kluczowe pojęcie to **funkcja skrótu (hash)** — np. SHA-256. To jednokierunkowa
funkcja, która z dowolnych danych tworzy „odcisk palca" o stałej długości:

- ta sama treść → zawsze ten sam hash,
- zmiana jednego znaku → kompletnie inny hash,
- z hasha nie da się odtworzyć danych wejściowych.

Każdy blok zawiera hash bloku poprzedniego. Gdyby ktoś podmienił transakcję w starym
bloku, jego hash by się zmienił — a wraz z nim wszystkie kolejne bloki przestałyby
„pasować". Dlatego historia blockchaina jest praktycznie niezmienna.

## 3. Bitcoin

**Bitcoin (BTC)** — pierwsza kryptowaluta, uruchomiona w styczniu 2009 przez osobę/grupę
o pseudonimie **Satoshi Nakamoto**. Powstał jako „elektroniczna gotówka P2P".

- Podaż ograniczona do **21 milionów** BTC.
- Nowe BTC powstają w procesie **kopania** (mining) jako nagroda za zatwierdzanie bloków.
- Co ~10 minut powstaje nowy blok.
- Co ~4 lata następuje **halving** — nagroda za blok spada o połowę (ostatni halving:
  kwiecień 2024, nagroda 3,125 BTC/blok).
- Algorytm: **SHA-256**, dziś opłacalny do kopania wyłącznie na **ASIC** (specjalne
  układy), nie na GPU.

Bitcoin pełni dziś głównie rolę „cyfrowego złota" — magazynu wartości i punktu
odniesienia dla całego rynku.

## 4. Ethereum i smart kontrakty

**Ethereum (ETH)** — druga co do wielkości kryptowaluta (od 2015). To nie tylko waluta,
ale **programowalna platforma**:

- **Smart kontrakty** — programy działające na blockchainie, wykonujące się automatycznie,
  gdy spełnione są warunki (np. „wyślij środki, gdy obie strony podpiszą").
- Fundament dla **DeFi** (zdecentralizowane finanse), **NFT**, **DAO** i tysięcy tokenów.

> 🔴 **Ważne dla kopania:** we wrześniu 2022 Ethereum przeszło z Proof of Work na
> **Proof of Stake** (wydarzenie zwane *The Merge*). **Od tego czasu ETH NIE da się
> kopać na kartach graficznych.** Wiele poradników w sieci jest nieaktualnych — jeśli
> coś obiecuje „kopanie ETH na GPU", pomiń to.

## 5. Altcoiny, tokeny, stablecoiny

- **Altcoiny** — wszystkie kryptowaluty inne niż Bitcoin (np. Ethereum, Litecoin,
  Monero, Ravencoin).
- **Tokeny** — aktywa cyfrowe wydane na istniejącym blockchainie (np. tokeny ERC-20 na
  Ethereum). Nie mają własnej sieci — „żyją" na cudzym łańcuchu.
- **Stablecoiny** — tokeny utrzymujące stałą wartość względem waluty fiat (np. USDT, USDC
  ≈ 1 USD). Służą do „parkowania" wartości bez wahań kursu.
- **Memecoiny** — monety oparte głównie na społeczności/żartach (np. Dogecoin). Bardzo
  spekulacyjne.

## 6. Klucze, adresy i portfele

Cała własność w krypto sprowadza się do **pary kluczy**:

- **Klucz prywatny** — tajny. Kto go zna, kontroluje środki. Nigdy nikomu go nie ujawniaj.
- **Klucz publiczny / adres** — jawny. Na niego inni wysyłają Ci środki (jak numer konta).

> 🔑 **Zasada numer jeden:** *Not your keys, not your coins* — jeśli nie masz kluczy
> prywatnych (bo trzyma je giełda), to tak naprawdę nie Ty kontrolujesz środki.

**Seed phrase** (fraza odzyskiwania) — 12 lub 24 słowa, z których odtwarza się wszystkie
klucze portfela. Zapisz ją offline (kartka, metal), **nigdy** w telefonie, mailu czy
chmurze.

### Rodzaje portfeli

| Typ | Opis | Bezpieczeństwo | Wygoda |
|-----|------|----------------|--------|
| **Sprzętowy (cold)** | Urządzenie offline (Ledger, Trezor) | ★★★★★ | ★★☆ |
| **Software / desktop / mobile (hot)** | Aplikacja online (MetaMask, Exodus, Trust) | ★★★ | ★★★★ |
| **Giełdowy (custodial)** | Środki trzyma giełda (Binance, Kraken) | ★★ | ★★★★★ |
| **Papierowy** | Klucze wydrukowane/zapisane offline | ★★★★ | ★ |

Zasada: **na giełdzie tylko to, czym aktywnie handlujesz**; oszczędności → portfel
sprzętowy.

## 7. Jak nabyć kryptowaluty (giełdy i kantory)

1. **Giełdy scentralizowane (CEX)** — Binance, Kraken, Coinbase, Bitget, polski Zonda.
   Rejestracja, weryfikacja tożsamości (KYC), zakup za przelew/kartę.
2. **Giełdy zdecentralizowane (DEX)** — Uniswap, PancakeSwap. Handel bezpośrednio z
   portfela, bez pośrednika.
3. **Kantory krypto** — szybka wymiana fiat↔krypto.
4. **Kopanie (mining)** — pozyskiwanie nowych monet pracą sprzętu (temat tego przewodnika).

## 8. Mechanizmy konsensusu: PoW vs PoS

Aby sieć bez centralnego zarządcy zgodziła się, które transakcje są prawdziwe, potrzebny
jest **mechanizm konsensusu**. Dwa główne:

### Proof of Work (PoW) — „dowód pracy"

- Komputery (**górnicy**) rywalizują w rozwiązywaniu trudnego zadania kryptograficznego.
- Kto pierwszy znajdzie rozwiązanie, dodaje blok i dostaje **nagrodę** + opłaty.
- Zużywa dużo energii — to celowy koszt, który zabezpiecza sieć.
- **To właśnie PoW da się „kopać".** Przykłady: Bitcoin, Litecoin, Monero, Ravencoin, Ergo.

### Proof of Stake (PoS) — „dowód stawki”

- Zamiast mocy obliczeniowej liczy się **zastawiona (zablokowana) kwota** monet.
- Sieć losowo wybiera **walidatora**, który dodaje blok — szansa rośnie z wielkością stawki.
- Energooszczędne, ale **nie da się tego kopać** — można jedynie **stakować** (blokować
  monety dla nagród).
- Przykłady: Ethereum (od 2022), Cardano, Solana, Polkadot.

> Podsumowując: **kopać można tylko monety PoW.** PoS = staking, nie mining.

---

# Część II — Kopanie (mining): teoria

## 9. Czym jest mining i po co istnieje

**Mining (kopanie)** to proces, w którym komputery zatwierdzają transakcje i tworzą nowe
bloki w sieci PoW, otrzymując w zamian nowo wyemitowane monety oraz opłaty transakcyjne.

Mining pełni jednocześnie trzy funkcje:

1. **Emituje** nowe monety (kontrolowana inflacja).
2. **Zatwierdza** i porządkuje transakcje.
3. **Zabezpiecza** sieć — atak wymagałby gigantycznej mocy obliczeniowej (>50% sieci).

## 10. Jak technicznie działa kopanie PoW

Uproszczony cykl:

1. Górnik zbiera oczekujące transakcje w kandydujący blok.
2. Do bloku dokłada zmienną liczbę zwaną **nonce**.
3. Liczy **hash** całego bloku.
4. Sprawdza, czy hash jest **mniejszy niż cel (target)** wyznaczony przez **trudność
   (difficulty)** — w praktyce: czy zaczyna się od odpowiedniej liczby zer.
5. Jeśli nie — zmienia nonce i liczy od nowa. Miliardy razy na sekundę.
6. Kto pierwszy trafi pasujący hash, ogłasza blok sieci i zgarnia nagrodę.

```
hash(blok + nonce) < target ?
   nie → nonce++ → licz ponownie  (miliardy prób/s)
   tak → BLOK ZNALEZIONY → nagroda
```

- **Hashrate** — ile hashy na sekundę liczy Twój sprzęt (H/s, MH/s, GH/s, TH/s). Im więcej,
  tym większa szansa na znalezienie bloku.
- **Difficulty** — automatycznie rośnie/spada, by bloki powstawały w stałym tempie,
  niezależnie od mocy całej sieci.

## 11. CPU vs GPU vs ASIC

| Sprzęt | Co to | Mocne strony | Słabe strony | Co się nim kopie |
|--------|-------|--------------|--------------|------------------|
| **CPU** | Procesor komputera | Każdy go ma; algorytmy ASIC-resistant | Niski hashrate | **Monero (RandomX)** |
| **GPU** | Karta graficzna | Uniwersalne, duży hashrate, odsprzedasz | Pobór prądu, ciepło, cena | Ravencoin, Ergo, Nexa, Flux |
| **ASIC** | Układ zaprojektowany pod jeden algorytm | Najwyższy hashrate i efektywność | Drogi, głośny, do jednej monety, szybko traci wartość | Bitcoin (SHA-256), Litecoin (Scrypt), Kaspa |

**Wniosek dla zwykłego użytkownika:** masz do dyspozycji **CPU** (Monero) i **GPU**
(altcoiny PoW). Bitcoina ani Kaspy nie ma już sensu kopać na GPU — wygrywają ASIC-i.

## 12. Kopanie solo vs w puli (pool)

- **Solo mining** — kopiesz sam. Całą nagrodę za blok bierzesz Ty… ale pojedyncza karta
  może szukać bloku latami. Loteria.
- **Pool mining** — łączysz moc z tysiącami górników. Pula znajduje bloki regularnie i
  **dzieli nagrodę proporcjonalnie** do wniesionej mocy. Mniejsze, ale **regularne**
  wypłaty. **To standard dla pojedynczego sprzętu.**

Modele wypłat w pulach: **PPS / PPS+** (stała stawka za udział, przewidywalne),
**PPLNS** (zależne od szczęścia puli, zwykle nieco wyższe długoterminowo). Prowizja puli
to zwykle **0,5–1,5%**.

## 13. Algorytmy wydobywcze

Każda moneta PoW używa konkretnego algorytmu hashującego. To on decyduje, jakim sprzętem
i jakim minerem ją kopiesz:

| Algorytm | Przykładowe monety | Sprzęt |
|----------|--------------------|--------|
| **SHA-256** | Bitcoin, Bitcoin Cash | ASIC |
| **Scrypt** | Litecoin, Dogecoin | ASIC |
| **RandomX** | **Monero (XMR)** | **CPU** |
| **KAWPOW** | **Ravencoin (RVN)**, Neoxa | GPU |
| **Autolykos2** | **Ergo (ERG)** | GPU (mało VRAM) |
| **kHeavyHash** | Kaspa (KAS) | ASIC (kiedyś GPU) |
| **Etchash** | Ethereum Classic (ETC) | GPU (wymaga >5 GB VRAM) |
| **FishHash** | Iron Fish | GPU |
| **NexaPow** | Nexa | GPU |
| **ZelHash/Equihash** | Flux | GPU |

## 14. Co dziś realnie można kopać (2026)

Po przejściu Ethereum na PoS krajobraz GPU-miningu mocno się zmienił. Aktualnie
najpopularniejsze cele dla pojedynczego sprzętu:

- **Monero (XMR)** — algorytm RandomX, **kopiesz CPU** (procesorem). Mocno
  ASIC-odporny, dobry na zwykłym komputerze/laptopie i jedyny sensowny wybór na macOS.
- **Ergo (ERG)** — Autolykos2, GPU, niskie wymagania VRAM (działa nawet na 4–6 GB).
- **Ravencoin (RVN)** — KAWPOW, klasyk GPU-miningu po „śmierci" kopania ETH.
- **Nexa, Neoxa, Flux, Iron Fish** — pomniejsze monety GPU, czasem chwilowo opłacalne.
- **Kaspa (KAS)** — wciąż popularna, ale **zdominowana przez ASIC** — na GPU już słabo.

> 💡 W praktyce zamiast wybierać monetę ręcznie, wielu początkujących korzysta z
> **NiceHash** — sprzedajesz swoją moc obliczeniową, a wypłatę dostajesz w **Bitcoinie**.
> Oprogramowanie samo dobiera najbardziej opłacalny algorytm. Najprostszy start (szczegóły
> w Części IV).

## 15. Opłacalność — od czego zależy

Czy kopanie się opłaca, decyduje kilka zmiennych:

```
Zysk = (przychód z monet) − (koszt prądu) − (prowizje puli/minera) − (zużycie sprzętu)
```

- **Cena prądu** — najważniejszy czynnik. Praktyczna granica opłacalności to zwykle
  **< 0,06 USD/kWh** (~0,24 zł/kWh). W Polsce stawki domowe są **znacznie wyższe**
  (często 0,8–1,2 zł/kWh) — to realnie zabija opłacalność domowego kopania.
- **Hashrate i efektywność** Twojego sprzętu (MH/s na wat).
- **Trudność sieci** — rośnie, gdy dołącza więcej górników → spada Twój udział.
- **Kurs monety** — bardzo zmienny.
- **Halvingi** i zmiany nagrody.

> 📉 **Realistycznie:** pojedyncza karta typu RTX 5060 zarabia dziś rzędu **kilkudziesięciu
> groszy do ~1 USD dziennie „na czysto"** przy tanim prądzie — a przy polskich cenach
> energii często wychodzi **pod kreskę**. Domowe kopanie to dziś bardziej hobby/nauka niż
> sposób na zarobek. Kopanie ma sens głównie przy bardzo tanim prądzie, własnej fotowoltaice
> lub jako element nauki technologii.

---

# Część III — Oprogramowanie do kopania

## 16. Windows

Windows to **najlepiej wspierana platforma** do kopania — działa tu praktycznie każdy
miner i wszystkie sterowniki GPU.

### Najpopularniejsze minery (darmowe)

| Miner | Sprzęt | Główne algorytmy | Prowizja dev | Uwagi |
|-------|--------|------------------|--------------|-------|
| **T-Rex** | NVIDIA | KAWPOW, Autolykos2, Etchash | ~1% | Bardzo wydajny na NVIDII, prosty config, stabilny. |
| **NBMiner** | NVIDIA + AMD | KAWPOW, Autolykos2, Etchash | 1–2% | Uniwersalny, dobre wsparcie nowych kart. |
| **GMiner** | NVIDIA + AMD | wiele (Equihash, KAWPOW, kHeavyHash…) | 0,65–5% | Szeroka obsługa algorytmów. |
| **lolMiner** | AMD + NVIDIA | Autolykos2, FishHash, ZelHash | 0,7–1,5% | Świetny na Ergo i monety AMD. |
| **TeamRedMiner** | AMD | KAWPOW, Autolykos2 | ~0,75% | Najlepszy pod karty AMD. |
| **SRBMiner-MULTI** | AMD + CPU | RandomX, wiele GPU | 0–0,85% | Kopie też Monero CPU. |
| **XMRig** | **CPU** (i część GPU) | **RandomX (Monero)** | 1% | Standard do kopania Monero procesorem. Open-source. |

### Nakładki / „all-in-one” (łatwiejszy start)

- **NiceHash (QuickMiner / NiceHash Miner)** — sprzedajesz moc, dostajesz BTC. Auto-tuning,
  benchmark, GUI. **Najprostszy start dla początkującego.**
- **Awesome Miner**, **minerstat**, **Hive OS** — zarządzanie wieloma koparkami,
  monitoring, zdalna konfiguracja (głównie dla większych farm).

> ⚠️ **Antywirus a minery:** Windows Defender i inne AV **często oznaczają minery jako
> „RiskWare/CoinMiner"** — bo to narzędzia dwojakiego zastosowania (są też używane przez
> malware do cichego kopania na cudzym sprzęcie). Pobieraj minery **wyłącznie z oficjalnych
> repozytoriów GitHub** autorów, sprawdzaj sumy kontrolne i nie wyłączaj AV „w ciemno".

## 17. macOS

macOS to specyficzna platforma: **brak NVIDII**, więc sensowne jest **wyłącznie kopanie CPU
→ Monero (RandomX) przez XMRig**. Apple Silicon (M1–M4) jest w tym zaskakująco dobry, a
kopanie GPU przez Metal pozostaje eksperymentem bez sensu ekonomicznego.

➡️ **Pełny, krok-po-kroku przewodnik o kopaniu na macOS** — dobór Maca, instalacja i
**kompilacja XMRig ze źródeł**, strojenie RandomX, pule i portfele, praca 24/7, termika oraz
bezpieczeństwo — znajdziesz w osobnym rozdziale:
[Część V — Kopanie na macOS](#część-v--kopanie-na-macos-kompletny-przewodnik).

## 18. Tabela porównawcza minerów

| | Windows | macOS (Apple Silicon) | Open source | Typ |
|---|:---:|:---:|:---:|---|
| **XMRig** | ✅ | ✅ (CPU) | ✅ | CPU (Monero) |
| **T-Rex** | ✅ | ❌ | ❌ | GPU NVIDIA |
| **NBMiner** | ✅ | ❌ | ❌ | GPU NVIDIA/AMD |
| **lolMiner** | ✅ | ❌ | ❌ | GPU AMD/NVIDIA |
| **GMiner** | ✅ | ❌ | ❌ | GPU |
| **TeamRedMiner** | ✅ | ❌ | ❌ | GPU AMD |
| **SRBMiner-MULTI** | ✅ | ❌ | ❌ | GPU AMD + CPU |
| **NiceHash** | ✅ | ⚠️ ograniczone | ❌ | All-in-one |

---

# Część IV — Praktyka: Windows + RTX 5060 8 GB

> Praktyczny scenariusz dla **laptopa z NVIDIA GeForce RTX 5060 8 GB** (Windows). Kopanie na
> komputerach Apple ma osobny, pełny rozdział →
> [Część V — Kopanie na macOS](#część-v--kopanie-na-macos-kompletny-przewodnik).

## ⚠️ Najpierw najważniejsze ostrzeżenie: to karta LAPTOPOWA

Kopanie obciąża GPU w **100% przez całą dobę**. Laptop **nie jest** do tego zaprojektowany:

- **Chłodzenie** laptopa jest ciasne — długie 100% obciążenie = wysokie temperatury,
  przyspieszone zużycie pasty, łożysk wentylatorów i ogniw baterii.
- **Termiczne dławienie (throttling)** zbija realny hashrate.
- **Bateria** trzymana stale na 100% przy cieple degraduje się szybciej.
- Producenci laptopów **mogą uznać takie użycie za niezgodne z przeznaczeniem**.

**Rekomendacja:** jeśli chcesz tylko **nauczyć się** procesu — uruchom kopanie na krótko
(minuty/godziny), z **podkładką chłodzącą**, **limitem mocy** i **monitoringiem
temperatury** (cel: < 75–80 °C). Do realnego, ciągłego zarobku laptop się nie nadaje —
od tego są desktopy/koparki.

## Hashrate RTX 5060 wg algorytmu (orientacyjnie)

Dane orientacyjne dla wersji desktopowej (laptopowa będzie **niżej** z powodu limitów
mocy i termiki):

| Algorytm | Moneta | Hashrate | Pobór mocy |
|----------|--------|---------:|-----------:|
| **Autolykos2** | **Ergo (ERG)** | ~120 MH/s | ~110 W |
| **KAWPOW** | **Ravencoin (RVN)** | ~25 MH/s | ~150 W |
| **Etchash** | Eth. Classic (ETC) | ~51 MH/s | ~120 W |
| **NexaPow** | Nexa | ~93 MH/s | ~140 W |

> **8 GB VRAM** to dla tych monet **wystarczająco** — Ergo i Ravencoin nie mają problemu
> rosnącego „DAG" jak dawne ETH/ETC. Najlepszy stosunek wydajność/pobór na tej karcie ma
> zwykle **Ergo (Autolykos2)** — niski pobór mocy.

## Realna opłacalność

Przy cenie prądu ~0,10 USD/kWh kalkulatory pokazują dla RTX 5060 rzędu **0,3–1 USD/dobę
„na czysto"**. Przy **polskich cenach domowych** (~0,8–1,2 zł/kWh ≈ 0,20–0,30 USD/kWh)
**najczęściej wyjdziesz pod kreskę**. Zweryfikuj zawsze na bieżąco:
[WhatToMine](https://whattomine.com/), [minerstat](https://minerstat.com/),
[Kryptex](https://www.kryptex.com/).

## Sposób 1 (najłatwiejszy): NiceHash

1. Załóż konto na [nicehash.com](https://www.nicehash.com/) i podaj adres do wypłat (BTC).
2. Pobierz **NiceHash Miner** (z oficjalnej strony) i zainstaluj.
3. Uruchom **benchmark** — program sam zmierzy wydajność RTX 5060 w różnych algorytmach.
4. Kliknij **Start** — NiceHash sam dobiera najbardziej opłacalny algorytm, a Ty dostajesz
   **Bitcoina**.
5. Obserwuj **temperatury** (zakładka z monitoringiem) i ustaw **limit mocy**.

Zalety: zero konfiguracji portfeli pod konkretne monety, auto-optymalizacja. Wada: prowizja
NiceHash + zwykle nieco niższy przychód niż kopanie wprost do puli.

## Sposób 2 (więcej kontroli): T-Rex + pula, np. Ravencoin

1. Załóż **portfel** dla wybranej monety (np. Ravencoin: oficjalny portfel lub adres na
   giełdzie wspierającej RVN).
2. Pobierz **T-Rex** z oficjalnego GitHuba: `https://github.com/trexminer/T-Rex/releases`.
3. Wybierz pulę, np. **2Miners** lub **HeroMiners** (niskie prowizje 0,5–1%).
4. Skonfiguruj plik `.bat` (Windows):

```bat
t-rex.exe -a kawpow ^
  -o stratum+tcp://rvn.2miners.com:6060 ^
  -u TWÓJ_ADRES_RVN.nazwaKoparki ^
  -p x
```

5. (Ergo zamiast RVN) zmień algorytm i pulę:

```bat
t-rex.exe -a autolykos2 ^
  -o stratum+tcp://erg.2miners.com:8888 ^
  -u TWÓJ_ADRES_ERG.nazwaKoparki ^
  -p x
```

6. Uruchom `.bat`. Po chwili zobaczysz hashrate i akceptowane „shares". Statystyki znajdziesz
   na stronie puli po wpisaniu swojego adresu.

## Strojenie: undervolting / power limit (klucz na laptopie)

Celem jest **więcej MH/s na wat** i **niższa temperatura**:

1. Zainstaluj **MSI Afterburner** (darmowy).
2. Ustaw **Power Limit** np. na 65–75% (mniej ciepła, niewielka strata hashrate).
3. Lekko **podnieś Memory Clock** (algorytmy jak KAWPOW/Autolykos2 lubią szybką pamięć),
   testując stabilność.
4. Ustaw krzywą wentylatora agresywniej (lub użyj zewnętrznego chłodzenia).
5. Monitoruj temperatury rdzenia i **pamięci (VRAM/Memory Junction)** — to często
   najgorętszy punkt.

> Zasada na laptopie: **niższy power limit + lepsze chłodzenie > maksymalny hashrate.**
> Lepiej kopać chłodniej i wolniej niż usmażyć sprzęt.

## Mini-podsumowanie dla RTX 5060

- **Najłatwiej:** NiceHash (wypłata w BTC, auto-algorytm).
- **Najlepszy pojedynczy cel:** zwykle **Ergo (Autolykos2)** — niski pobór mocy.
- **8 GB VRAM** wystarcza dla aktualnych monet GPU.
- **To laptop** — kopanie ciągłe odradzane; do nauki krótkie sesje z limitem mocy i
  kontrolą temperatury.
- **Opłacalność w PL** przy domowym prądzie: zwykle **ujemna** — rób to dla wiedzy, nie
  dla zysku.

---

# Część V — Kopanie na macOS (kompletny przewodnik)

> Kompletny, samodzielny rozdział o kopaniu na komputerach Apple. Zbiera wszystko: realia
> platformy, różnice Apple Silicon vs Intel, dobór sprzętu, co i czym kopać, instalację i
> **kompilację XMRig ze źródeł**, strojenie RandomX, portfele i pule, pracę 24/7 jako usługa,
> termikę, opłacalność, bezpieczeństwo i rozwiązywanie problemów.

## 1. Realia: czego się spodziewać na macOS

macOS to **nietypowa platforma do kopania** i trzeba to powiedzieć wprost:

- **Apple porzuciło NVIDIĘ** — brak sterowników i brak CUDA. Odpada cały najwydajniejszy
  ekosystem GPU-miningu.
- Jedyne sensowne kopanie na Macu to **CPU → Monero (algorytm RandomX)**. Kopanie GPU przez
  **Metal** istnieje wyłącznie eksperymentalnie i nie ma sensu ekonomicznego.
- Dobra wiadomość: **Apple Silicon (M1–M4) jest zaskakująco dobry w RandomX** dzięki dużej
  liczbie wydajnych rdzeni, ogromnej przepustowości pamięci unified i sprzętowemu AES.
- Zła wiadomość: i tak **nie zarobisz fortuny** — to nauka/hobby, ewentualnie „na lekki
  plus" przy bardzo tanim prądzie lub na mocnych układach Ultra.
- Ten rozdział pokazuje, **jak zrobić to dobrze** — żeby wyciągnąć z Maca maksimum i nie
  uszkodzić sprzętu.

## 2. Apple Silicon vs Intel Mac — dwa różne światy

Pierwsza decyzja: jaki masz procesor. Od tego zależy, **którą wersję minera** pobierasz i
czego się spodziewać.

| | **Apple Silicon (M1–M4)** | **Intel Mac (starszy)** |
|---|---|---|
| Architektura | ARM64 (`arm64`) | x86-64 (`x64`) |
| RandomX (Monero) | **Bardzo dobry** (AES + pamięć) | Słabszy, grzeje się mocniej |
| Build XMRig | `*-macos-arm64.tar.gz` | `*-macos-x64.tar.gz` |
| GPU NVIDIA | Brak (nigdy) | Brak (porzucone) |
| GPU AMD / eGPU | Brak (niewspierane) | Możliwe (do ~macOS Ventura), mało opłacalne |
| Efektywność energetyczna | Doskonała | Przeciętna |

- Apple **M1 jest oficjalnie wspierany w XMRig od wersji 6.7.0** — używaj aktualnej wersji.
- Na **Intel Macu z kartą AMD** dało się historycznie kopać GPU przez OpenCL (XMRig obsługuje
  AMD), ale wydajność i opłacalność są słabe — w praktyce i tu zostajesz przy CPU.

## 3. Który Mac nadaje się do kopania?

Kopanie to **100% obciążenia CPU 24/7** — kluczowe jest chłodzenie.

| Model | Chłodzenie | Werdykt |
|-------|-----------|---------|
| **MacBook Air** | Pasywne (bez wentylatora) | ❌ Odradzane — throttling, gorąco. |
| **MacBook Pro** | Aktywne, ale ciasne | ⚠️ Tylko krótkie sesje, na zasilaczu, z podkładką. |
| **Mac mini** | Aktywne, kompaktowe | ✅ Dobre do cichego kopania 24/7. |
| **iMac** | Aktywne | ✅ OK, uważaj na temperatury latem. |
| **Mac Studio** | Bardzo wydajne, ciche | ✅✅ **Najlepszy wybór** — desktop, 24/7 bez throttlingu. |
| **Mac Pro** | Najlepsze, dużo rdzeni | ✅✅ Najwięcej rdzeni = najwyższy hashrate. |

**Wniosek:** desktopy (**Mac Studio**, Mac mini, Mac Pro) nadają się do pracy ciągłej.
Laptopy (zwłaszcza Air) traktuj wyłącznie jako poligon do nauki na krótkie sesje.

## 4. Co realnie można kopać na Macu

| Co | Algorytm | Sprzęt | Sens na Macu |
|----|----------|--------|--------------|
| **Monero (XMR)** | RandomX | **CPU** | ✅ Główny i właściwie jedyny rozsądny wybór. |
| Forki RandomX (Wownero, Salvium…) | RandomX/warianty | CPU | ⚠️ Niszowe, zmienna płynność/opłacalność. |
| Monety GPU (Ravencoin, Ergo…) | KAWPOW, Autolykos2 | GPU | ❌ Brak wydajnych minerów GPU na macOS. |
| Bitcoin, Kaspa… | SHA-256, kHeavyHash | ASIC | ❌ Nie dotyczy Maca. |
| „Metal GPU mining" (eksperyment) | różne | GPU Apple | ❌ Niszowe projekty, ekonomicznie bez sensu. |

**Monero (RandomX)** jest **celowo ASIC-odporne** i zaprojektowane pod zwykłe procesory —
dlatego to ono ma na Macu sens. Resztę pomiń.

## 5. Oprogramowanie do kopania na macOS

| Narzędzie | Co to | Dla kogo |
|-----------|-------|----------|
| **XMRig** | Główny miner RandomX (open-source, `arm64` i `x64`) | Wszyscy — podstawa. |
| **Gupax** | GUI łączące **P2Pool + XMRig** (decentralizacja, 0% prowizji puli) | Kto chce GUI i pul zdecentralizowanych. |
| ~~MinerGate~~, „minery z App Store" | Stare/zamknięte GUI | ❌ Odradzane — przestarzałe, słabe, część to scam. |

- **XMRig** to standard — szybki, konfigurowalny, aktywnie rozwijany. Reszta rozdziału
  skupia się na nim.
- **Gupax** ([gupax-io/gupax](https://github.com/gupax-io/gupax)) to najwygodniejsza droga do
  **P2Pool** — kopania w zdecentralizowanej puli bez prowizji i bez konta; pobiera i spina
  XMRig oraz P2Pool w jednym oknie.

## 6. Hashrate per układ — czego się spodziewać

Orientacyjne wyniki RandomX (XMRig). Realne liczby zależą od **wersji XMRig, podpisu JIT i
chłodzenia** — zawsze weryfikuj na [xmrig.com/benchmark](https://xmrig.com/benchmark).

| Układ | Hashrate (RandomX) |
|-------|-------------------:|
| M1 / M2 (bazowy, 8 rdzeni) | ~1,5–2,5 kH/s |
| M1 / M2 Pro | ~3–4 kH/s |
| **M1 / M2 Max** | ~4,5–5 kH/s |
| **M1 Ultra** | ~6–6,5 kH/s |
| **M2 Ultra** | ~7,5–7,9 kH/s |
| M3 / M4 (Max/Ultra) | wyżej — sprawdź benchmark |
| Intel Core i7/i9 (starsze Maki) | ~1–4 kH/s (więcej ciepła) |

## 7. Szybki start — gotowy XMRig (Wariant 1)

Najszybsza droga, bez kompilacji:

1. Pobierz **właściwy build** z oficjalnego GitHuba
   [github.com/xmrig/xmrig/releases](https://github.com/xmrig/xmrig/releases):
   - Apple Silicon → `*-macos-arm64.tar.gz`
   - Intel → `*-macos-x64.tar.gz`
2. Załóż **portfel Monero** (patrz §11) i zapisz adres (zaczyna się od `4...`).
3. Rozpakuj archiwum i w **Terminalu** wejdź do katalogu z `xmrig`.
4. Uruchom (pula SupportXMR + TLS):

```bash
./xmrig -o pool.supportxmr.com:443 -u TWÓJ_ADRES_MONERO -p mac --tls --donate-level 1
```

5. **Gatekeeper** może zablokować nieznaną aplikację. Zezwól w *Ustawienia systemowe →
   Prywatność i bezpieczeństwo → „Zezwól mimo to"*, albo zdejmij atrybut kwarantanny:

```bash
xattr -dr com.apple.quarantine ./xmrig
```

6. Statystyki sprawdzisz na stronie puli po wpisaniu adresu portfela.

## 8. Budowanie XMRig ze źródeł (Wariant 2 — zalecane)

Kompilacja daje **najświeższą wersję**, natywne optymalizacje pod Apple Silicon i pewność,
co uruchamiasz. Zajmuje kilka minut.

**1. Zależności (Homebrew).** Jeśli nie masz Homebrew, zainstaluj go z
[brew.sh](https://brew.sh/), a następnie:

```bash
xcode-select --install                 # narzędzia kompilatora (jeśli brak)
brew install cmake wget automake libtool autoconf openssl hwloc
```

**2. Pobierz źródła:**

```bash
git clone https://github.com/xmrig/xmrig.git
```

**3. Zbuduj statyczny hwloc** (skrypt dołączony do XMRig):

```bash
mkdir xmrig/build && cd xmrig/scripts
./build.hwloc.sh
cd ../build
```

**4. Konfiguracja CMake i kompilacja** (równolegle na wszystkich rdzeniach):

```bash
cmake .. -DOPENSSL_ROOT_DIR=$(brew --prefix openssl) \
         -DHWLOC_INCLUDE_DIR=../scripts/deps/include \
         -DHWLOC_LIBRARY=../scripts/deps/lib/libhwloc.a
make -j$(sysctl -n hw.logicalcpu)
```

Po sukcesie w katalogu `build/` pojawi się plik wykonywalny `xmrig`. Zależności sprawdzisz
komendą `otool -L xmrig`. Uruchamiasz go identycznie jak w Wariancie 1.

## 9. Klucz wydajności: JIT, W^X i huge pages

To najważniejsza sekcja techniczna — tu kryje się różnica między „działa" a „działa szybko".

### Szybki tryb JIT (codesign z uprawnieniem)

Apple wymusza ochronę pamięci **W^X** (kod nie może być jednocześnie zapisywalny i
wykonywalny). Przez to RandomX potrafi domyślnie działać w **wolniejszym „secure mode".**
Aby pozwolić na szybki JIT, podpisz binarkę **ad-hoc** z odpowiednimi uprawnieniami. Utwórz
plik `jit.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>com.apple.security.cs.allow-jit</key><true/>
  <key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/>
</dict></plist>
```

i podpisz zbudowaną binarkę:

```bash
codesign --entitlements jit.entitlements --force -s - ./xmrig
```

### Czego na macOS NIE ma (obalamy mit)

> ⚠️ Na **ARM macOS huge pages oraz przypięcie rdzeni (CPU affinity) są nieobsługiwane** —
> `sudo` ich **nie odblokuje**. Wiele poradników błędnie radzi „uruchom przez sudo dla huge
> pages" — na Macu to nic nie da. To naturalny sufit wydajności RandomX na Apple Silicon.

### Co działa automatycznie

- **Sprzętowe AES** — Apple Silicon ma rozszerzenia kryptograficzne ARMv8; XMRig korzysta z
  nich sam.
- **Tryb „fast" RandomX** — wymaga ~2,3 GB pamięci na zbiór danych. Każdy Mac z ≥ 8–16 GB RAM
  spokojnie go użyje (XMRig wybiera automatycznie). Dużo RAM = brak problemu.

## 10. Konfiguracja przez `config.json` (wygodniej niż flagi)

Zamiast długiej linii poleceń lepiej użyć pliku `config.json` w katalogu z `xmrig`.
Najprościej wygenerować go kreatorem [xmrig.com/wizard](https://xmrig.com/wizard). Minimalny
przykład:

```json
{
  "autosave": true,
  "cpu": { "enabled": true, "priority": 2 },
  "pools": [
    {
      "url": "pool.supportxmr.com:443",
      "user": "TWÓJ_ADRES_MONERO",
      "pass": "mac",
      "tls": true,
      "keepalive": true
    }
  ]
}
```

Uruchomienie: `./xmrig` (sam wczyta `config.json`). `priority` 0–5 reguluje, jak agresywnie
miner walczy o rdzenie z resztą systemu.

## 11. Portfele i pule

### Portfele Monero

- **Monero GUI / CLI** (oficjalny, [getmonero.org](https://www.getmonero.org/)) — pełny węzeł
  lub tryb lekki.
- **Feather Wallet** — lekki, szybki desktop.
- **Cake Wallet** — wygodny, też mobilny.

Adres odbiorczy XMR zaczyna się od `4...` — to on idzie do `-u` / pola `user`.

### Pule (pool mining)

| Pula | Prowizja | Uwagi |
|------|----------|-------|
| **SupportXMR** | ~0,6% | Popularna, stabilna, przyjazna początkującym. |
| **2Miners (XMR)** | 1% | Dobre serwery w EU/NA/Azji. |
| **HeroMiners** | ~0,9% | Dużo lokalizacji, niskie opóźnienia. |
| **Nanopool** | ~1% | Znana, wieloletnia. |

Modele wypłat to zwykle **PPLNS**. Wybieraj serwer geograficznie blisko siebie i łącz się
po **TLS** (porty typu `:443`/`:8443`).

### P2Pool — kopanie zdecentralizowane (0% prowizji)

**P2Pool** to pula bez operatora i bez prowizji — wypłaty trafiają wprost do Ciebie. Wymaga
działającego węzła Monero (lub trybu uproszczonego). Na macOS najwygodniej uruchomić go
przez **Gupax**, który spina P2Pool + XMRig w jednym GUI. To świetna opcja, jeśli chcesz
wspierać decentralizację sieci.

## 12. Kopanie 24/7 — w tle i jako usługa

### Żeby Mac nie zasnął

```bash
caffeinate -s ./xmrig        # blokuje usypianie na czas pracy minera
```

### Praca w tle (prosto)

Użyj `screen` lub `tmux`, żeby miner działał po zamknięciu okna Terminala:

```bash
brew install tmux
tmux new -s xmr      # uruchom xmrig w środku; odłącz: Ctrl-b, potem d
```

### Autostart przy logowaniu (launchd)

Utwórz plik `~/Library/LaunchAgents/com.user.xmrig.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.user.xmrig</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Users/TWOJ_USER/xmrig/build/xmrig</string>
    <string>--config=/Users/TWOJ_USER/xmrig/build/config.json</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
</dict></plist>
```

Załaduj usługę:

```bash
launchctl load ~/Library/LaunchAgents/com.user.xmrig.plist
```

(`launchctl unload …` wyłącza). Pamiętaj, że binarka musi być **podpisana z uprawnieniem
JIT** z §9, inaczej stracisz wydajność.

## 13. Termika, pobór energii i opłacalność

- **Monitoring:** `sudo powermetrics --samplers smc,cpu_power` (temperatury i pobór) albo
  aplikacje *Stats* / *TG Pro*.
- **Pobór:** Apple Silicon to zwykle **kilkadziesiąt watów** pod pełnym RandomX — bardzo mało
  jak na uzyskiwany hashrate.
- **Termika:** na **Mac Studio / Mac Pro / Mac mini** możesz kopać 24/7 bez throttlingu; na
  laptopach pilnuj temperatur i rób krótkie sesje.
- **Opłacalność:** realnie **grosze–kilkadziesiąt groszy dziennie**. Dzięki niskiemu poborowi
  nawet przy polskim prądzie bilans jest bliski zera; na układach **Ultra** przy tanim prądzie
  bywa „na lekki plus". Weryfikuj w kalkulatorach ([WhatToMine](https://whattomine.com/),
  [Kryptex](https://www.kryptex.com/)).

## 14. Bezpieczeństwo — specyfika macOS

- **Pobieraj XMRig wyłącznie z [github.com/xmrig/xmrig](https://github.com/xmrig/xmrig)** —
  podmienione minery z losowych stron potrafią ukraść Twój adres portfela (kopanie „dla
  kogoś innego").
- **Minery nie są notaryzowane** przez Apple (to narzędzia dwojakiego zastosowania) — dlatego
  Gatekeeper je blokuje. To normalne, ale tym bardziej **ufaj tylko oficjalnemu źródłu**.
- **Aplikacje „Monero miner" z App Store** są zwykle bezużyteczne lub to scam — omijaj.
- **Cryptojacking** — złośliwe oprogramowanie kopiące w tle. Objawy: wentylatory na full,
  spadek wydajności, wysokie zużycie CPU w spoczynku. macOS **XProtect** i antywirusy mogą
  oznaczać nawet legalne minery jako „zagrożenie".
- **Weryfikuj adres portfela** przy konfiguracji — malware potrafi podmienić go w schowku.

## 15. Najczęstsze problemy (troubleshooting)

| Problem | Rozwiązanie |
|---------|-------------|
| „Nie można otworzyć — niezweryfikowany deweloper" | Gatekeeper: *Prywatność i bezpieczeństwo → Zezwól*, lub `xattr -dr com.apple.quarantine ./xmrig`. |
| Niski hashrate | Podpisz binarkę z **JIT** (§9), zwiększ liczbę wątków, sprawdź czy nie ma throttlingu (laptop). |
| Ostrzeżenia o „huge pages / MSR mod" | Normalne na macOS — **nieobsługiwane**, zignoruj. |
| Mac zasypia w trakcie | Uruchamiaj przez `caffeinate -s ./xmrig`. |
| Laptop się przegrzewa | Zmniejsz wątki (`-t`), użyj podkładki chłodzącej, rób krótkie sesje. |
| `cmake`/`make` nie znaleziono | Zainstaluj zależności z §8 (`brew install …`, `xcode-select --install`). |

## 16. TL;DR — macOS w pigułce

- **Kopiesz tylko CPU → Monero (XMRig, RandomX).** GPU/Metal i NVIDIA pomiń.
- Pobierz **właściwy build** (`arm64` dla Apple Silicon, `x64` dla Intela) **albo zbuduj ze
  źródeł** (§8) — kompilacja zalecana.
- **Podpisz binarkę z uprawnieniem JIT** (§9) — to klucz do pełnej wydajności RandomX.
- Na ARM macOS **nie ma huge pages ani CPU affinity** — nie szukaj tam wydajności.
- **Mac Studio / mini / Pro** = kopanie 24/7 bez problemu; **laptopy** = ostrożnie, krótkie
  sesje.
- Wydajność: **Max ~4,5–5 kH/s**, **M1 Ultra ~6,4 kH/s**, **M2 Ultra ~7,5–7,9 kH/s**.
- Opłacalność: energooszczędnie, ale przychód symboliczny — rób to dla **nauki/hobby**.
- GUI + zdecentralizowana pula bez prowizji? → **Gupax (P2Pool + XMRig)**.

---

# Część VI — Bezpieczeństwo

Krypto przyciąga oszustów — zabezpiecz się:

- **Seed phrase offline.** Nigdy nie wpisuj jej na stronach, w mailach, czacie. Żadna
  prawdziwa giełda ani portfel nie poprosi Cię o seed.
- **Włącz 2FA** (najlepiej aplikacja typu Authy/Google Authenticator, nie SMS).
- **Uważaj na cryptojacking** — złośliwe skrypty/aplikacje kopiące krypto na Twoim
  sprzęcie bez wiedzy. Objawy: wentylatory na full, spadek wydajności, wysokie zużycie
  CPU/GPU w spoczynku.
- **Fałszywe minery i „cracki".** Wiele „darmowych minerów" z przypadkowych stron to
  malware podmieniające **adres portfela** na adres przestępcy. Pobieraj tylko z
  oficjalnych GitHubów.
- **Scamy „cloud mining" i „podwajanie krypto".** Obietnice gwarantowanych zysków =
  oszustwo. „Wyślij 1 ETH, dostaniesz 2" to zawsze przekręt.
- **Phishing.** Sprawdzaj dokładnie adresy stron (literówki w domenach), nie klikaj linków
  z maili/DM.
- **Weryfikuj adresy przy przelewach** — malware potrafi podmienić skopiowany adres w
  schowku. Sprawdzaj pierwsze i ostatnie znaki.

---

# Część VII — Prawo i podatki w Polsce

> ⚠️ To ogólne informacje, **nie porada podatkowa**. Przepisy się zmieniają — przed
> rozliczeniem skonsultuj aktualny stan z doradcą podatkowym lub na stronach KAS/Ministerstwa
> Finansów.

Obecne zasady (stan ogólny):

- **Podatek 19%** od dochodu z odpłatnego zbycia kryptowalut (różnica między przychodem ze
  sprzedaży na walutę fiat/towar/usługę a kosztami nabycia).
- Rozliczenie roczne na formularzu **PIT-38**.
- **Wymiana krypto↔krypto jest neutralna podatkowo** — podatek powstaje dopiero przy
  zamianie na walutę tradycyjną (fiat) lub zapłacie za towar/usługę.
- **Kopanie:** monety „wykopane" we własnym zakresie zwykle rozlicza się dopiero przy ich
  **sprzedaży** (jako przychód z kapitałów pieniężnych); koszty (np. prąd, sprzęt) bywają
  trudne do ujęcia — to obszar, gdzie warto dopytać doradcę, zwłaszcza przy większej skali
  (możliwa kwalifikacja jako działalność gospodarcza).
- **Strata** z krypto może obniżać podatek w kolejnych latach (w ramach tego źródła).

---

# Słowniczek

| Pojęcie | Znaczenie |
|---------|-----------|
| **Blockchain** | Łańcuch bloków — rozproszony, niezmienny rejestr transakcji. |
| **Hash** | Kryptograficzny „odcisk palca" danych o stałej długości. |
| **Hashrate** | Liczba hashy na sekundę (moc obliczeniowa koparki). |
| **Difficulty** | Trudność sieci — reguluje tempo powstawania bloków. |
| **Nonce** | Zmienna liczba dobierana przy szukaniu pasującego hasha. |
| **PoW / PoS** | Proof of Work (kopanie) / Proof of Stake (staking). |
| **ASIC** | Układ scalony zaprojektowany pod jeden algorytm. |
| **DAG** | Duży zbiór danych w pamięci GPU (np. Ethash) — rośnie z czasem. |
| **Pool** | Pula górników dzieląca nagrody proporcjonalnie do mocy. |
| **Share** | „Udział" — dowód pracy wysyłany do puli. |
| **Dev fee** | Prowizja autora minera (zwykle 0,5–2%). |
| **Halving** | Cykliczne zmniejszenie nagrody za blok o połowę. |
| **Wallet** | Portfel — przechowuje klucze do Twoich środków. |
| **Seed phrase** | 12/24 słowa do odtworzenia portfela. |
| **Cold / Hot wallet** | Portfel offline (bezpieczny) / online (wygodny). |
| **Staking** | Blokowanie monet PoS dla nagród (nie mylić z kopaniem). |
| **DeFi** | Zdecentralizowane finanse na smart kontraktach. |
| **Cryptojacking** | Nielegalne kopanie na cudzym sprzęcie przez malware. |

---

# Źródła i dalsza lektura

**Kalkulatory opłacalności (zawsze weryfikuj na bieżąco):**
- WhatToMine — https://whattomine.com/
- minerstat (profil RTX 5060) — https://minerstat.com/hardware/nvidia-geforce-rtx-5060
- Kryptex — https://www.kryptex.com/
- NiceHash kalkulator — https://www.nicehash.com/profitability-calculator

**Oprogramowanie (pobieraj tylko z oficjalnych źródeł):**
- T-Rex — https://github.com/trexminer/T-Rex/releases
- NBMiner — https://github.com/NebuTech/NBMiner/releases
- lolMiner — https://github.com/Lolliedieb/lolMiner-releases
- GMiner — https://github.com/develsoftware/GMinerRelease/releases
- TeamRedMiner — https://github.com/todxx/teamredminer/releases
- SRBMiner-MULTI — https://github.com/doktor83/SRBMiner-Multi/releases
- XMRig (CPU/Monero, też macOS ARM64) — https://github.com/xmrig/xmrig/releases
- NiceHash — https://www.nicehash.com/
- MSI Afterburner (strojenie GPU) — https://www.msi.com/Landing/afterburner

**Pule wydobywcze:**
- 2Miners — https://2miners.com/
- HeroMiners — https://herominers.com/
- SupportXMR (Monero) — https://supportxmr.com/

**Wiedza ogólna:**
- Bitcoin whitepaper (Satoshi Nakamoto) — https://bitcoin.org/bitcoin.pdf
- Ethereum — https://ethereum.org/
- Monero — https://www.getmonero.org/

---

*Dokument przygotowany w czerwcu 2026. Rynek kryptowalut i opłacalność kopania zmieniają
się dynamicznie — przed decyzjami finansowymi weryfikuj aktualne dane i przepisy.*
