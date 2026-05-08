# Ochrona kodu C++ przed kradzieżą

## Punkt wyjścia: C++ jest natywny — i to już jest ochrona

W przeciwieństwie do PHP (interpretowany) i C# / .NET (IL bytecode), **C++ kompiluje się do natywnego machine code** — instrukcji procesora dla konkretnej architektury (x86_64, ARM64).

```
C++ source (.cpp/.h)
   ↓ preprocessing (#include, #define)
.cpp expanded
   ↓ compilation (g++/clang++/cl.exe)
.o (object file) — assembly + symbols
   ↓ linking
.exe / .so / .dll — native machine code
```

**Już to daje znaczną ochronę:**
- Brak metadanych typu IL (CLR) lub readable bytecode
- Disassembly daje assembly (czytelne tylko dla reverse engineers)
- Brak nazw zmiennych, funkcji (stripped symbols)
- Optymalizacje kompilatora (inlining, loop unrolling) zaciemniają strukturę

**Ale:** doświadczeni reverse engineers (z IDA Pro, Ghidra, Binary Ninja) wciąż mogą zrozumieć i modyfikować Twój kod. Dlatego dla komercyjnych aplikacji wciąż stosuje się dodatkowe warstwy.

## Hierarchia ochrony

```
Layer 1: Stripped symbols + release build         (free, baseline)
Layer 2: Compiler hardening flags                  (free, easy)
Layer 3: Anti-debug / anti-tamper basics           (custom code)
Layer 4: Commercial protector (VMProtect/Themida)  ($-$$$)
Layer 5: Code virtualization                       (premium feature)
Layer 6: License server + online validation        (custom)
Layer 7: Hardware fingerprinting                   (custom)
Layer 8: Cloud-based critical logic (SaaS hybrid)  (architecture)
Layer 9: Code signing certificate                  ($300/yr)
Layer 10: Legal protection (EULA, watermarking)    (legal)
```

## Komercyjne protektory (state-of-the-art 2026)

### VMProtect — gold standard

**VMProtect** (rosyjska firma, popularna globalnie) to **najsilniejszy** komercyjny protector dla natywnych binaries. Używany przez wiele AAA games, anti-cheat, premium software.

**Core features:**
- **Code virtualization** — przekształca x86 instructions w custom VM bytecode (custom opcodes per build)
- **Mutation** — zmienia logikę zachowując semantykę
- **Anti-debug** — wykrywa OllyDbg, x64dbg, IDA, dnSpy w pamięci
- **Anti-dump** — utrudnia memory dump
- **VM machine** unique per build — można crackować jeden build, ale nie skali
- **Trial / license management** built-in
- **Hardware ID locking**

**Wersje:**
- **Personal** — €490 (wystarczy dla większości)
- **Professional** — €890 (advanced features, bigger projects)
- **Ultimate** — €1490 (bulk licenses, custom builds)

**Workflow:**
```cpp
// 1. Mark functions to virtualize
#include "VMProtectSDK.h"

void critical_function() {
    VMProtectBeginUltra("CriticalCheck");

    // Twoja krytyczna logika
    if (!validate_license()) {
        exit(1);
    }

    VMProtectEnd();
}

// 2. Build normalnie (Visual Studio, GCC)
// 3. Run VMProtect na .exe
//    GUI lub CLI:
//    VMProtect_Con.exe MyApp.exe MyApp.protected.exe project.vmp
```

**Trade-off:** kod virtualizowany jest **30-1000× wolniejszy**. Stosuj tylko na critical paths (license check, anti-cheat, krytyczne algorytmy IP), nie na hot loops gameplay.

**Crackowalność:** VMProtect 3.x był crackowany dla popularnych gier (przy ogromnym wysiłku, miesiące pracy zespołów). VMProtect 4 (2024+) wzmocnił obronę. Dla większości komercyjnego software wystarcza.

### Themida — sztywny konkurent VMProtect

**Themida** (Oreans Technologies) — alternatywa, popularna w gaming i utility software.

**Plusy:**
- Bardzo agresywny anti-debug i anti-VM (wykrywa nawet sandbox)
- Code virtualization (różne VM "machines" do wyboru)
- Mutation engine
- Łatwiejszy w użyciu niż VMProtect (mniej manual annotations)
- License management
- Watermark engine

**Minusy:**
- Czasem fałszywie wykrywany jako malware (wpływa na user experience)
- Cena: $1495 podstawowa, $1995 z VM machines
- Niektóre AV blokują Themida-protected binaries
- Mniej regularnych updates niż VMProtect

**Workflow:**
```
1. Build Twoja aplikacja normalnie
2. Otwórz Themida GUI
3. Wybierz .exe
4. Wybierz protection options (VM machine, anti-debug, etc.)
5. Wygeneruj protected .exe
```

**Brak SDK markers** — Themida protectje całe binary (oraz wybrane funkcje przez external markers).

### Enigma Protector

**Enigma Protector** — środkowy segment cenowy, popular dla SaaS desktop apps i SMB software.

**Plusy:**
- Świetny **license management** (online + offline, trial, hardware lock)
- VFS (Virtual File System) — embedded resources w jednym .exe (anti-tampering)
- Plugin system (custom checks)
- Cena: $129 (Personal) - $299 (Business) - $1499 (Studio)
- **Świetny ROI** dla SMB

**Minusy:**
- Mniej silne VM niż VMProtect/Themida
- Mniej updatów

**Bardzo popular wśród developerów Delphi i mid-range tools.**

### WinLicense (Oreans)

Razem z Themida (ten sam producent). Focus na **license management** zamiast obfuskacji.

- Trial periods, hardware locking, online activation
- Często łączony z Themida (Themida + WinLicense = $1995-$2495)

### .NET Reactor for Native (legacy)
Specyficzny — Eziriz ma też produkt dla natywnych. Niszowy.

### ASProtect (legacy)
Stary protector, **wykrywany przez nowoczesne AV jako malicious**, nie używaj w 2026.

## Open source / free alternatywy

### UPX (Ultimate Packer for eXecutables)
**UPX** to compressor + basic packer. Zmniejsza rozmiar binary i daje minimalną obfuskację.

**Plusy:** Free, open source, prosty
**Minusy:** Trywialny do unpack (`upx -d`), nie liczy się jako prawdziwa ochrona

```bash
upx --best MyApp.exe
# Lub: upx -9 MyApp.exe
```

**Realny use case:** zmniejszenie rozmiaru binary do dystrybucji, NIE ochrona kodu.

### Tigress (academic)
Source-to-source obfuscator dla C (działa też na C++ z niektórymi kawałkami).

```bash
tigress --Transform=Virtualize --Functions=critical_function source.c -o output.c
```

**Plusy:** Free, source-level transformation, advanced techniques
**Minusy:** Niedoskonały dla full C++ (template, modern features), trudny w użyciu

### LLVM Obfuscator (O-LLVM)
Fork LLVM dodający passes obfuskacji (control flow flattening, bogus control flow, instructions substitution).

**Plusy:** Free, integruje się z compilation pipeline
**Minusy:** Niemodyfikowany od dawna, wymaga build własnego LLVM

```bash
clang -mllvm -fla -mllvm -bcf -mllvm -sub source.cpp -o output
# fla = control flow flattening
# bcf = bogus control flow
# sub = instructions substitution
```

### Hikari (modern OLLVM fork)
Open source LLVM-based obfuscator, lepiej utrzymywany niż OLLVM.

## Compiler hardening — ZAWSZE rób

Niezależnie od wyboru protectora, użyj **hardening flags**:

### MSVC (Visual Studio)
```
/GS              # Buffer security check (stack canary)
/guard:cf        # Control Flow Guard (CFG)
/guard:ehcont    # Exception handler continuation guard
/Qspectre        # Spectre mitigation
/sdl             # Additional security checks
/CETCOMPAT       # Hardware-enforced stack protection (CET)
/DYNAMICBASE     # ASLR
/HIGHENTROPYVA   # 64-bit ASLR
/NXCOMPAT        # DEP
/wbrachstr       # Hardening warnings
```

W Visual Studio: Project → Properties → Configuration Properties → C/C++ → Code Generation → Security Check = `/GS` (default ON).

### GCC / Clang (Linux)
```bash
g++ \
    -O2 \
    -D_FORTIFY_SOURCE=3 \
    -fstack-protector-strong \
    -fstack-clash-protection \
    -fcf-protection=full \
    -Wformat \
    -Wformat-security \
    -Werror=format-security \
    -fPIE -pie \
    -Wl,-z,relro,-z,now \
    -Wl,-z,noexecstack \
    -fsanitize=cfi \
    source.cpp -o output
```

**Co robi:**
- `_FORTIFY_SOURCE=3` — runtime checks dla buffer overflows
- `-fstack-protector-strong` — stack canaries
- `-fcf-protection=full` — Intel CET (Control-flow Enforcement Technology)
- `-fPIE -pie` — Position Independent Executable (ASLR)
- `-Wl,-z,relro,-z,now` — Read-only relocations
- `-fsanitize=cfi` — Control Flow Integrity

### Strip symbols
Po build — usuń symbol info (debug, function names):

**Linux:**
```bash
strip --strip-all MyApp
strip --strip-debug MyApp
# Lub: objcopy --strip-all MyApp
```

**Windows:**
- Build w **Release**, nie Debug
- Properties → Linker → Debugging → Generate Debug Info = **No**
- Lub: `editbin /STRIPLIBPATH MyApp.exe` (stara opcja)
- Modern: separate PDB, ship binary bez PDB

## Anti-debugging w C++

```cpp
#include <windows.h>

bool is_debugger_attached() {
    // Windows API
    if (IsDebuggerPresent()) return true;

    BOOL remote = FALSE;
    CheckRemoteDebuggerPresent(GetCurrentProcess(), &remote);
    if (remote) return true;

    // Check PEB (Process Environment Block)
    #ifdef _WIN64
    auto peb = (PPEB)__readgsqword(0x60);
    #else
    auto peb = (PPEB)__readfsdword(0x30);
    #endif

    if (peb->BeingDebugged) return true;
    if (peb->NtGlobalFlag & 0x70) return true;

    // Heap flags
    DWORD heap_flags;
    NtQueryInformationProcess(/* ... */, &heap_flags);
    if (heap_flags & (HEAP_GROWABLE | HEAP_TAIL_CHECKING_ENABLED)) return true;

    // Hardware breakpoints (DR0-DR7)
    CONTEXT ctx = {};
    ctx.ContextFlags = CONTEXT_DEBUG_REGISTERS;
    GetThreadContext(GetCurrentThread(), &ctx);
    if (ctx.Dr0 || ctx.Dr1 || ctx.Dr2 || ctx.Dr3) return true;

    // Timing attack — debugger spowalnia execution
    auto t1 = std::chrono::high_resolution_clock::now();
    Sleep(1);
    auto t2 = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1);
    if (duration.count() > 50) return true;  // suspicious

    return false;
}

int main() {
    if (is_debugger_attached()) {
        // Crash, exit silently, lub fake behavior
        std::abort();
    }
    // Normal execution
}
```

**Linux equivalent:**
```cpp
#include <sys/ptrace.h>

bool is_being_traced() {
    // Try to ptrace ourselves — fails if already traced
    if (ptrace(PTRACE_TRACEME, 0, NULL, 0) == -1) {
        return true;
    }
    ptrace(PTRACE_DETACH, 0, NULL, 0);

    // Check /proc/self/status for TracerPid
    std::ifstream status("/proc/self/status");
    std::string line;
    while (std::getline(status, line)) {
        if (line.find("TracerPid:") == 0) {
            int tracer_pid = std::stoi(line.substr(11));
            return tracer_pid != 0;
        }
    }
    return false;
}
```

**Uwaga:** anti-debug to **wojna ciągła** — reverse engineers piszą bypassy. Stosuj wiele technik, niech łatwo nie być zatrzymanym.

## Anti-tampering (integrity check)

```cpp
#include <windows.h>
#include <wincrypt.h>

bool verify_self_integrity() {
    char path[MAX_PATH];
    GetModuleFileNameA(NULL, path, MAX_PATH);

    HANDLE file = CreateFileA(path, GENERIC_READ, FILE_SHARE_READ, NULL,
                              OPEN_EXISTING, 0, NULL);
    if (file == INVALID_HANDLE_VALUE) return false;

    // Compute SHA-256 of binary
    HCRYPTPROV provider;
    HCRYPTHASH hash;
    CryptAcquireContextA(&provider, NULL, NULL, PROV_RSA_AES, CRYPT_VERIFYCONTEXT);
    CryptCreateHash(provider, CALG_SHA_256, 0, 0, &hash);

    BYTE buffer[4096];
    DWORD bytes_read;
    while (ReadFile(file, buffer, sizeof(buffer), &bytes_read, NULL) && bytes_read > 0) {
        CryptHashData(hash, buffer, bytes_read, 0);
    }

    BYTE computed[32];
    DWORD len = 32;
    CryptGetHashParam(hash, HP_HASHVAL, computed, &len, 0);

    CryptDestroyHash(hash);
    CryptReleaseContext(provider, 0);
    CloseHandle(file);

    // Compare with embedded expected hash (POST-BUILD set!)
    BYTE expected[32] = { 0xA1, 0xF3, /* ... */ };  // post-build patch
    return memcmp(computed, expected, 32) == 0;
}
```

**Trick:** expected hash jest **patchowany post-build** (po obliczeniu finalnego hash całego binary). Atakujący który zmodyfikuje 1 bajt → integrity fails.

## License management

### Online validation (call home)

```cpp
#include <httplib.h>  // cpp-httplib
#include <nlohmann/json.hpp>

class LicenseManager {
    const std::string api_url = "https://api.mycompany.com";

public:
    struct LicenseInfo {
        bool valid;
        std::string customer_id;
        std::chrono::system_clock::time_point expires_at;
    };

    LicenseInfo verify(const std::string& license_key) {
        httplib::Client client(api_url);

        nlohmann::json request = {
            {"key", license_key},
            {"hardware_id", get_hardware_id()},
            {"product_version", "2.4.1"}
        };

        auto response = client.Post("/license/verify",
            request.dump(), "application/json");

        if (!response || response->status != 200) {
            return {false, "", {}};
        }

        auto json = nlohmann::json::parse(response->body);
        return {
            json["valid"].get<bool>(),
            json["customer_id"].get<std::string>(),
            std::chrono::system_clock::from_time_t(json["expires_at"].get<int64_t>())
        };
    }

    std::string get_hardware_id() {
        // Combine: CPU ID + motherboard serial + MAC
        // Hash for unique fingerprint
        return sha256(get_cpu_id() + get_motherboard_serial() + get_first_mac());
    }
};
```

### Offline JWT validation

```cpp
#include <jwt-cpp/jwt.h>

class OfflineLicenseValidator {
    std::string public_key;  // Embedded w binary

public:
    bool validate(const std::string& jwt_token) {
        try {
            auto decoded = jwt::decode(jwt_token);

            auto verifier = jwt::verify()
                .allow_algorithm(jwt::algorithm::rs256(public_key))
                .with_issuer("mycompany.com")
                .expires_at_leeway(0);

            verifier.verify(decoded);

            return true;
        } catch (const jwt::error::token_verification_exception&) {
            return false;
        }
    }
};
```

### Komercyjne biblioteki license:
- **Cryptolens C++ SDK** — popular, multi-platform, free tier
- **LicenseSpring** — managed
- **Keygen.sh** — open source server, paid SaaS
- **CodeMeter (Wibu Systems)** — premium, hardware tokens
- **HASP / Sentinel (Thales)** — premium, hardware dongles

## Code virtualization — kiedy ma sens

Code virtualization (VMProtect, Themida, custom):
- ✅ License check function (1-2 funkcje, krytyczne)
- ✅ Authentication / cryptographic functions
- ✅ Anti-cheat checks (gaming)
- ✅ Custom proprietary algorithms (np. unique compression, ML inference dla edge AI)
- ✅ DRM / protected content decoding
- ❌ Hot loops gameplay (1000× slowdown niedopuszczalne)
- ❌ Real-time audio/video processing
- ❌ Performance-critical scientific computing

**Praktyka:** virtualizuj **5-20 funkcji** w aplikacji 100k+ LOC. Reszta — normal compilation z hardening.

## Anti-cheat (specjalny przypadek)

Dla gier — własna kategoria. Poza VMProtect/Themida:

- **EasyAntiCheat** (Epic) — używane w Fortnite, Apex Legends
- **BattlEye** — używane w PUBG, Rainbow Six
- **Vanguard** (Riot) — kernel-level, bardzo agresywny
- **Denuvo Anti-Cheat** — premium, drogie
- **Roblox Hyperion** — proprietary

**Common techniques:**
- Kernel-mode driver (anti-cheat ring 0)
- Behavioral analysis (server-side)
- Hardware bans (HWID)
- Memory integrity scans
- Code injection detection

## Strategie dla różnych use cases

### "Gra single-player premium ($30-60)"
```
Layer 1: Compiler hardening
Layer 2: VMProtect na license check + critical algorithms
Layer 3: License manager (online activation)
Layer 4: Steam/Epic DRM (jeśli store)
Cena: VMProtect Personal €490
```

### "Gra multiplayer competitive (Free-to-play)"
```
Anti-cheat: EasyAntiCheat lub BattlEye
Server-authoritative architecture (klient nie cheat)
Behavior analytics (anti-bot)
HWID bans
Custom kernel driver (advanced)
```

### "Premium business software ($500-5000)"
```
Layer 1: Compiler hardening
Layer 2: VMProtect Pro (€890) lub Themida + WinLicense ($1995)
Layer 3: Online license server z hardware fingerprinting
Layer 4: Critical features w cloud (SaaS hybrid)
Layer 5: Code signing certificate (EV $400/yr)
Layer 6: Watermarking per-customer
```

### "Driver / kernel module"
```
Hardware ID locking
Code signing certificate (EV obligatoryjne dla kernel)
Microsoft attestation (kernel mode)
Custom protector (kernel-aware)
Minimal commercial protectors działają (większość user-mode)
```

### "Open source z paid features"
```
Free tier: GitHub source
Pro tier: separate VMProtect-protected DLL
License key validation w protected DLL
```

### "Niche tool / utility ($20-200)"
```
Enigma Protector ($129) lub Themida ($1495 jeśli stać)
Online license activation
Code signing cert (Standard $300/yr)
```

## Code signing — niezbędne dla Windows

Bez signed binary:
- Microsoft SmartScreen blokuje "unrecognized publisher"
- Niektóre AV agresywniej skanują unsigned
- Klient nie ufa Twojej aplikacji

```bash
# Sign w Windows
signtool sign /f cert.pfx /p password \
    /tr http://timestamp.digicert.com /td sha256 /fd sha256 \
    MyApp.exe

# Verify
signtool verify /pa MyApp.exe
```

**Cena code signing certs:**
- **Standard:** $200-400/yr (Sectigo, Comodo, GlobalSign)
- **EV (Extended Validation):** $400-800/yr — instant SmartScreen reputation
- Od 2023: **EV wymaga hardware token** (USB key)
- **OV (organization validated)** — middle ground

**Apple notarization** (macOS) — wymagane dla apps poza App Store.

## Reverse engineering tools (od strony atakującego)

Aby projektować obronę, znaj atak:

### Disassemblers / decompilers:
- **IDA Pro** — gold standard, drogi (~$3000+), używany przez profesjonalistów
- **Ghidra** (NSA) — free, open source, doskonała alternatywa do IDA
- **Binary Ninja** — modern, $300-1500
- **Radare2** / **Cutter** — free, open source, CLI/GUI
- **Hopper** — Mac/Linux, $99

### Debuggers:
- **x64dbg** — open source, nowoczesny Windows debugger
- **WinDbg** — Microsoft, kernel-mode debugging
- **OllyDbg** (legacy) — wciąż popular dla 32-bit
- **GDB** — Linux standard
- **LLDB** — modern alternative

### Memory tools:
- **Cheat Engine** — popular dla games, też dla utility
- **Process Hacker** — process inspection
- **Volatility** — memory forensics

### Specialized:
- **Frida** — dynamic instrumentation
- **Themida unpacker** plugins
- **VMProtect deobfuscator** experiments (rzadkie working)

### Typical attack flow:
```
1. Open binary in IDA/Ghidra
2. Find string "Invalid license" → cross-reference
3. Trace back to license check function
4. Patch JZ to JMP (skip check)
5. Save modified binary
6. Distribute "cracked" version
```

**Cel obrony:** każdy krok kosztowny. VMProtect virtualization → reverse engineer musi pisać custom VM emulator dla each build.

## Obfuscation źródłowy (compile-time)

Czasem chcemy obfuskować na poziomie source przed compile:

### String obfuscation (constexpr)

```cpp
#include <array>
#include <utility>

template<size_t N>
struct ObfuscatedString {
    std::array<char, N> data;

    consteval ObfuscatedString(const char (&str)[N]) {
        for (size_t i = 0; i < N; ++i) {
            data[i] = str[i] ^ 0x55;  // XOR przy compile time
        }
    }

    std::string decrypt() const {
        std::string result(N - 1, 0);
        for (size_t i = 0; i < N - 1; ++i) {
            result[i] = data[i] ^ 0x55;
        }
        return result;
    }
};

#define OBFUSCATED(s) ObfuscatedString<sizeof(s)>(s)

// Usage:
auto api_key = OBFUSCATED("sk-secret-12345");
// W binary widać: 0xF4 0xE9 0x67 ... (zamiast "sk-secret")
auto plain = api_key.decrypt();  // runtime decrypt
```

**Dostępne biblioteki:**
- **xorstr** (jowenkov) — lightweight string obfuscation
- **obfuscate-c++** — header-only
- **andrivet/ADVobfuscator** — comprehensive C++ obfuscation library

### Control flow obfuscation (manual)

```cpp
// Zamiast prostego if:
if (license_valid) {
    proceed();
} else {
    exit(1);
}

// Użyj computed gotos / state machine:
int state = compute_state(license_key);
switch (state) {
    case 0xA1: goto check_a;
    case 0xB2: goto check_b;
    // ...
}
check_a:
    if (validate_part_a()) state = 0xC3; else goto fail;
    goto next;
check_b:
    // ...
fail:
    exit(1);
```

LLVM pass (Hikari/OLLVM) zrobi to automatycznie.

## Watermarking per customer

```cpp
// W build pipeline (CI/CD), inject unique watermark per customer
const char* CUSTOMER_ID = "CUST_8a4f2c";  // patched per build
const char* BUILD_HASH = "BUILD_d2e9f1";

// Embed multiple times (różne miejsca, hard to remove all):
__attribute__((used))
static const char* watermark1 = "MyApp v2.4 © 2026 CUST_8a4f2c";

class HiddenWatermark {
    const char* mark = "[CUST_8a4f2c]";
public:
    HiddenWatermark() {
        // Use mark in some side-effect (prevent dead-code elimination)
        if (mark[0] == 0xFF) std::abort();  // never true, prevents removal
    }
};
```

Jeśli leak na piracie torrencie → znajdziesz po watermarku.

## Tools, biblioteki, frameworki

### Komercyjne protectory:
- VMProtect: vmpsoft.com — €490-1490
- Themida + WinLicense: oreans.com — $1495-2495
- Enigma Protector: enigmaprotector.com — $129-1499
- CodeMeter (Wibu): wibu.com — premium hardware-based

### License management:
- Cryptolens: cryptolens.io — free tier + paid
- LicenseSpring: licensespring.com
- Keygen.sh: keygen.sh — open source server
- 10Duke: 10duke.com — enterprise

### Open source:
- Hikari: github.com/HikariObfuscator/Hikari
- ADVobfuscator: github.com/andrivet/ADVobfuscator
- xorstr: github.com/JustasMasiulis/xorstr
- LLVM Obfuscator: github.com/obfuscator-llvm/obfuscator (legacy)

### Compiler hardening:
- Lista flags: gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html
- MSVC: docs.microsoft.com/cpp/build/reference/

### Anti-debug snippets:
- AntiDBG: github.com/HackOvert/AntiDBG
- Themida-equivalent OSS: rare

## Przykład: kompletny CMake project z protection

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(SecureApp CXX)

set(CMAKE_CXX_STANDARD 23)

# Hardening flags
if(MSVC)
    add_compile_options(/GS /guard:cf /sdl /Qspectre)
    add_link_options(/DYNAMICBASE /HIGHENTROPYVA /NXCOMPAT /CETCOMPAT)
else()
    add_compile_options(
        -O2
        -D_FORTIFY_SOURCE=3
        -fstack-protector-strong
        -fcf-protection=full
        -fPIE
    )
    add_link_options(-pie -Wl,-z,relro,-z,now -Wl,-z,noexecstack)
endif()

# Strip release symbols
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    if(NOT MSVC)
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_STRIP} --strip-all $<TARGET_FILE:${PROJECT_NAME}>)
    endif()
endif()

add_executable(SecureApp main.cpp license.cpp anti_debug.cpp)

# Post-build: VMProtect
if(CMAKE_BUILD_TYPE STREQUAL "Release" AND VMPROTECT_PATH)
    add_custom_command(TARGET SecureApp POST_BUILD
        COMMAND ${VMPROTECT_PATH}/VMProtect_Con.exe
            $<TARGET_FILE:SecureApp>
            $<TARGET_FILE_DIR:SecureApp>/SecureApp_protected.exe
            ${CMAKE_SOURCE_DIR}/protection.vmp)
endif()

# Post-build: Code signing
if(CMAKE_BUILD_TYPE STREQUAL "Release" AND SIGN_CERT_PATH)
    add_custom_command(TARGET SecureApp POST_BUILD
        COMMAND signtool sign
            /f ${SIGN_CERT_PATH}
            /p ${SIGN_CERT_PASS}
            /tr http://timestamp.digicert.com
            /td sha256 /fd sha256
            $<TARGET_FILE:SecureApp>)
endif()
```

## Co NIE robić (anti-patterns)

### ❌ "Kompilacja w release wystarczy"
Release jest stripped i optimized, ale wciąż reverse'able. Bez dodatkowej ochrony — IDA pokazuje czytelny pseudo-code.

### ❌ Hardcoded license key
```cpp
const char* MASTER_KEY = "ABCD-1234-EFGH-5678";
```
Strings łatwo wyciągnąć z binary (`strings myapp.exe`).

### ❌ Custom encryption własny algorytm
Roll-your-own crypto słabsze niż AES/RSA. Use OpenSSL, libsodium.

### ❌ Polegać na pojedynczej obronie
Tylko VMProtect → cracker pisze custom devirtualizer dla Twojej VM.
Wiele warstw → musi crackować wszystkie.

### ❌ Brak code signing
Bez signing — Windows SmartScreen blokuje, klient porzuca instalację.

### ❌ Sharing protector key wśród firm
Custom VM machine per build = unique. Sharing eliminuje benefit.

### ❌ Encrypted strings z embedded key
```cpp
auto key = std::string("MYKEY123");
auto decrypted = aes_decrypt(encrypted_data, key);
```
Reverse engineer znajdzie `MYKEY123` w binary jako string lub hex bytes.

## Wydajność: koszt ochrony

| Technique | Overhead | Comments |
|-----------|----------|----------|
| Hardening flags (MSVC/GCC) | 1-3% | Zawsze użyj |
| Stripped symbols | 0% (wymaga release build) | Free benefit |
| Anti-debug checks | 0-1% | Sporadic checks |
| Anti-tamper integrity | 5-50ms startup | One-time cost |
| String obfuscation (xorstr) | 0-1% | Negligible |
| VMProtect (per function) | 30-1000× **dla virtualizowanych funkcji** | Use sparingly |
| Themida full binary | 5-20% startup, 1-5% runtime | Acceptable |
| LLVM obfuscator (full) | 20-100% | Often too expensive |
| Code signing | 0% | Free win |
| License online check | 100-500ms (one-time) | Cache result |

**Praktyka:** Hardening + code signing dla całości, VMProtect tylko critical 5-10 functions.

## Monitoring kradzieży

### Telemetry (z poszanowaniem privacy)
```cpp
void send_anonymous_telemetry() {
    httplib::Client client("https://telemetry.mycompany.com");

    nlohmann::json data = {
        {"version", APP_VERSION},
        {"hardware_id", hash_hwid()},  // hashed!
        {"license_key_hash", hash(license_key)},  // not the key
        {"binary_hash", compute_self_hash()},
        {"os", get_os_info()}
        // BEZ: PII, file content, browsing data
    };

    client.Post("/event/startup", data.dump(), "application/json");
}
```

### Detect cracked versions:
- Anomalous hardware IDs (same key wide use)
- Binary hash mismatch (modified)
- Geolocation patterns (mass usage in unexpected regions)
- License key reuse

### Tools:
- **Sentry** — error tracking, can detect crackers' modifications
- **Bugsnag** — similar
- **Custom telemetry server**

## Aspekty prawne

### Copyright
C++ source code automatycznie chroniony copyright od momentu utworzenia.
**Rejestracja** (US Copyright Office, ZAIKS w PL) wzmacnia legal position.

### EULA must-haves:
- Zakaz reverse engineering / disassembly
- Zakaz dystrybucji
- Zakaz modyfikacji
- Limit na liczbę instalacji / urządzeń
- Term & renewal
- Liability limitation
- Governing law (jurisdiction)

### DMCA / European equivalents
Ktoś dystrybuuje cracked → DMCA takedown notice (US) lub odpowiednik EU.

### Trade Secret
Critical algorithms — chroń jako trade secret. NDA z pracownikami i kontraktorami.

## Decision tree

```
Czy software premium ($100+)?
├─ TAK
│  ├─ Czy gaming?
│  │  ├─ Multiplayer? → EasyAntiCheat / BattlEye + server-authoritative
│  │  └─ Single-player? → VMProtect Personal + Steam DRM
│  ├─ Czy enterprise B2B ($1000+)?
│  │  → Themida + WinLicense + cloud architecture
│  └─ SMB tool ($100-500)?
│     → Enigma Protector + license server
└─ NIE (utility, $5-20)?
   → Hardening + code signing + EULA
   → Optional: simple license key check (online)
```

## Linki i zasoby

- **VMProtect**: vmpsoft.com
- **Themida / WinLicense**: oreans.com
- **Enigma Protector**: enigmaprotector.com
- **CodeMeter (Wibu)**: wibu.com
- **Cryptolens C++**: cryptolens.io
- **Hikari**: github.com/HikariObfuscator/Hikari
- **ADVobfuscator**: github.com/andrivet/ADVobfuscator
- **xorstr**: github.com/JustasMasiulis/xorstr
- **OWASP C++ Cheat Sheet**: cheatsheetseries.owasp.org
- **Compiler hardening guide**: best-practices.dev (sample)

## Następne kroki

- **Rozdział 04** — bezpieczeństwo aplikacji C++ (memory safety, RAII, sanitizers)
- **Rozdział 06** — narzędzia i deployment (CMake, Conan)
- W folderze **architektura/08-bezpieczenstwo** — fundamenty bezpieczeństwa
