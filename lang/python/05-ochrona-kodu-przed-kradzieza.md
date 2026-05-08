# Ochrona kodu Python przed kradzieżą

## Problem: Python jest najmniej chroniony z popularnych języków

Hierarchia natural protection:
```
C++ (native binary)        ━━━━━━━━━━ najtrudniej (wymaga IDA/Ghidra)
Rust (native binary)       ━━━━━━━━━
Go (native binary)         ━━━━━━━
C# .NET (IL bytecode)      ━━━━ (decompiler dnSpy = łatwo)
Java (JVM bytecode)        ━━━━ (jadx, JD-GUI)
PHP (interpreted source)   ━━ (plain text, czytasz)
Python (interpreted)       ━━ (plain text, czytasz)
JavaScript (interpreted)   ━ (browser source)
```

Python rozwiązanie:
- `.py` files = plain text source
- `.pyc` files = bytecode cache (uncompile-able z `uncompyle6`, `decompyle3`)
- Wszystko czytelne dla każdego z dostępem do plików

**Konsekwencja:** Python jest **świetny dla SaaS** (server-side, klient nie ma kodu) i **trudny dla self-hosted commercial software**.

## Strategie ochrony

### Strategia 1: SaaS (najlepsza)
**Klient nie dostaje kodu.** Tylko API, web UI, thin client. Server jest Twój.

```
┌─────────────────┐         ┌─────────────────┐
│ Client (web/UI) │ ──────> │ Twój Python API │
└─────────────────┘         │ (kod tutaj)     │
                            └─────────────────┘
```

**Plusy:** kod nigdy nie opuszcza Twojej infrastruktury, łatwa monetyzacja (subscription)
**Minusy:** koszty serwerów, wymaga internetu

### Strategia 2: Native compilation (Nuitka, Cython)
Kompiluje Python do **C** lub **natywnego binary**. Source code znika.

### Strategia 3: Bytecode obfuscation (PyArmor)
Komercyjne narzędzie szyfrujące Python bytecode.

### Strategia 4: Hybrid (cloud + local)
Krytyczna logika w cloud, klient ma thin Python wrapper.

## Komercyjne narzędzia

### PyArmor — najpopularniejszy

**PyArmor** (Dashingsoft) — leader rynku obfuskacji Python.

**Plusy:**
- Bardzo silne (zaszyfrowane bytecode + runtime decryption)
- Wsparcie Python 3.7-3.13
- License management built-in (expiry, hardware lock, online activation)
- Cross-platform (Linux, macOS, Windows, Android, iOS via embedded)
- Aktywny rozwój (PyArmor 9 w 2026)

**Minusy:**
- Komercyjny ($69/year Personal, $599 Enterprise)
- Niektóre techniki crackowane (z wysiłkiem)
- AOT mode wymaga PyArmor runtime na docelowej maszynie

**Workflow:**
```bash
pip install pyarmor

# Basic obfuscation
pyarmor gen myapp.py
# Output: dist/myapp.py + pyarmor_runtime/

# Whole project
pyarmor gen --recursive my_project/

# Z license:
pyarmor gen --enable-bcc \
            --license-key "expires=2027-01-01,bind-mac=ON" \
            myapp.py

# RFT (Runtime Function Transformation) — zaawansowane
pyarmor gen --enable-rft myapp.py

# Wymuszanie hardware binding
pyarmor gen --bind-mac AA:BB:CC:DD:EE:FF \
            --bind-cpu "$(wmic cpu get processorid)" \
            myapp.py
```

**Tryby (modes):**
- **Basic** — XOR encryption, fastest
- **BCC (Bytecode Compression Cipher)** — silniejsze
- **RFT (Runtime Function Transformation)** — najsilniejsze, transforms function calls

**Performance overhead:** 10-30% w zależności od trybu.

### Pyobfuscate / pyminifier (legacy)

Stare obfuskatory. **Trywialne do unobfuscate.** Nie używaj w produkcji 2026.

### Sourcedefender

Komercyjny, mniej popularny niż PyArmor. AES-256 encryption, license features.

### Itsdangerous + custom encryption (DIY)

Niektórzy próbują rolować własne. **Nie warto** — PyArmor zrobi to lepiej i taniej niż Twój czas.

## Kompilacja: Cython, Nuitka, mypyc

### Cython — Python → C extension

**Cython** kompiluje `.py` lub `.pyx` (Cython superset) do **C** → binary `.so` / `.pyd`.

```bash
pip install cython

# Plain Python → C → compiled
echo 'def hello(): return "world"' > hello.py
cython --3str hello.py  # generuje hello.c
cc -shared -fPIC -I$(python -c "import sysconfig; print(sysconfig.get_path('include'))") hello.c -o hello.so
```

Lub setup.py:
```python
from setuptools import setup
from Cython.Build import cythonize

setup(ext_modules=cythonize("myapp.py"))
```

```bash
python setup.py build_ext --inplace
```

**Plusy:**
- **Source code znika** (tylko binary)
- 2-100× speedup często (zwłaszcza pętle)
- Free, open source
- Mature (od 2007)

**Minusy:**
- Niektóre dynamic features Pythona nie działają (eval, exec, monkeypatching)
- Build per platform (Windows .pyd, Linux .so, macOS .dylib)
- Dłuższy build time

**W 2026:** popular dla performance + ochrona w jednym.

### Nuitka — Python → standalone binary

**Nuitka** kompiluje cały Python program do single executable.

```bash
pip install nuitka

# Basic
nuitka --standalone myapp.py
# Wynik: myapp.dist/ folder z myapp.exe + dependencies

# One-file (bardziej user-friendly)
nuitka --standalone --onefile myapp.py
# Wynik: myapp.exe (single file, self-extracting)

# Z dodatkowymi opcjami
nuitka --standalone --onefile \
       --windows-icon-from-ico=icon.ico \
       --windows-disable-console \
       --enable-plugin=pyqt6 \
       --include-data-dir=resources=resources \
       --output-dir=dist \
       myapp.py
```

**Plusy:**
- **Compile do native binary** (bez source w resulcie!)
- Działa nawet bez Python na docelowej maszynie
- Lepsze wsparcie dla pełnego Pythona niż Cython
- Open source
- Cross-platform (Linux, macOS, Windows)

**Minusy:**
- Build slow (10-60 minut dla dużych projektów)
- Output size duże (50-200 MB single-file)
- Niektóre packages problematyczne (numpy, torch — wymaga `--include-package`)
- Dynamic imports wymagają explicit declaration

**Nuitka Commercial** ($250+/yr) dodaje:
- Anti-bloat (mniejsze binaries)
- Anti-debugging
- Code obfuscation passes
- Priority support

**W 2026:** **Nuitka to obecnie najlepsza opcja** dla full app distribution z ochroną.

### mypyc

**mypyc** (od mypy team) — kompiluje annotated Python do C extension.

```bash
pip install mypy
mypyc myapp.py
```

**Plusy:**
- Wymaga type annotations (clean code bonus)
- 2-5× speedup
- Clean integration

**Minusy:**
- Mniej popularne niż Cython
- Wymaga full type coverage
- Tylko subset Pythona supported

### PyInstaller (NIE jest ochroną!)

**PyInstaller** pakuje Python + scripts w single .exe. **Ale NIE szyfruje source!**

Każdy może rozpakować PyInstaller bundle:
```bash
pip install pyinstxtractor
python pyinstxtractor.py myapp.exe
# Output: folder z .pyc files → uncompyle6 → source
```

**Wniosek:** PyInstaller bez PyArmor/Nuitka = brak ochrony, tylko convenience packaging.

## .pyc files — czy są ochrone?

**.pyc** to skompilowany Python bytecode. **NIE** to ochrona.

```python
# Python compiles .py to __pycache__/.pyc automatically
# Możesz dystrybuować tylko .pyc bez .py

# Ale: dekompilacja jest TRYWIALNA
pip install uncompyle6  # Python 2.x, 3.0-3.8
pip install decompyle3   # Python 3.7-3.8
# Dla 3.9+: niektóre tools work, niektóre breakdown
```

**Tylko .pyc bez .py:**
```bash
python -O -m compileall myapp.py
# Output: __pycache__/myapp.cpython-313.opt-1.pyc

# Distribute tylko .pyc
# Klient może uruchamiać:
python myapp.cpython-313.pyc

# Ale uncompyle6 → source recovered (90%+ accuracy)
```

**Wniosek:** .pyc daje **iluzję** ochrony. Reverse engineer ma source w 30 sekund.

## Strategia: hybrid Cython + PyArmor

Najsilniejsza ochrona Python:

```bash
# 1. Cython compile critical modules
cython --3str license_manager.py
cc -shared license_manager.c -o license_manager.so

# 2. PyArmor pozostałe
pyarmor gen --recursive --enable-bcc rest_of_app/

# 3. Bundle z Nuitka jako standalone
nuitka --standalone --onefile main.py
```

Każda warstwa wymaga innego ataku → drastycznie zwiększa koszt crackowania.

## License management dla Python

### Online validation

```python
import requests
import hashlib
import platform
import uuid

class LicenseManager:
    API_URL = "https://api.mycompany.com/license/verify"

    def get_hardware_id(self) -> str:
        """Stable per-machine fingerprint."""
        node = uuid.getnode()  # MAC address
        machine = platform.node()
        cpu = platform.processor()
        combined = f"{node}-{machine}-{cpu}"
        return hashlib.sha256(combined.encode()).hexdigest()

    def verify(self, license_key: str) -> bool:
        try:
            response = requests.post(self.API_URL, json={
                "key": license_key,
                "hardware_id": self.get_hardware_id(),
                "version": "2.4.1"
            }, timeout=10)
            data = response.json()
            return data.get("valid") and data.get("expires_at", 0) > time.time()
        except requests.RequestException:
            # Graceful degradation — cache last known status
            return self.check_cached_validity()
```

### Offline JWT validation

```python
import jwt

PUBLIC_KEY = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAA...
-----END PUBLIC KEY-----"""

def validate_offline_license(token: str) -> dict | None:
    try:
        payload = jwt.decode(
            token,
            PUBLIC_KEY,
            algorithms=["RS256"],
            issuer="mycompany.com"
        )
        return payload
    except jwt.InvalidTokenError:
        return None
```

### Komercyjne biblioteki:
- **Cryptolens Python** — popular, free tier
- **LicenseSpring**
- **Keygen.sh** — open source server, paid SaaS
- **Sentinel HASP / CodeMeter** — premium hardware-based

## Anti-debugging w Python

```python
import sys
import gc

def detect_debugger():
    # 1. Check sys.gettrace
    if sys.gettrace() is not None:
        return True

    # 2. Check for pdb / debugpy in modules
    suspicious = ['pdb', 'debugpy', 'ipdb', 'pudb']
    for mod in suspicious:
        if mod in sys.modules:
            return True

    # 3. Check parent process (if Python launched via debugger)
    import psutil
    parent = psutil.Process().parent()
    if parent and parent.name() in ['code.exe', 'pycharm64.exe', 'gdb', 'lldb']:
        return True

    # 4. Timing check
    import time
    t1 = time.time()
    sum(range(1000))  # quick op
    t2 = time.time()
    if (t2 - t1) > 0.01:  # debugger slows down significantly
        return True

    return False

if detect_debugger():
    sys.exit(1)
```

**Uwaga:** atakujący zmodyfikuje to po obfuskacji. Multi-layer.

## Watermarking per customer

```python
# build_for_customer.py — w CI/CD per-customer build
CUSTOMER_ID = os.environ['CUSTOMER_ID']  # np. "CUST_8a4f2c"

# Patch source przed obfuskacja
with open('app/_build_info.py', 'w') as f:
    f.write(f'CUSTOMER_ID = "{CUSTOMER_ID}"\n')
    f.write(f'BUILD_HASH = "{generate_unique_hash()}"\n')

# Następnie PyArmor / Nuitka build
```

W aplikacji:
```python
from app._build_info import CUSTOMER_ID

# Subtle — wystarczy że jest w binary
def _check():
    if not CUSTOMER_ID.startswith('CUST_'):
        raise RuntimeError("Build corrupted")
_check()
```

Jeśli leak → znajdziesz po watermarku.

## Strategie per use case

### "Sprzedaję desktop tool ($50-300)"
```
1. Nuitka --onefile (binary, no source)
2. Optional: PyArmor dla extra layer
3. License key + online check (Cryptolens free tier)
4. Code signing certificate ($300/yr)
```

### "Sprzedaję enterprise app ($1000+)"
```
1. Cython compile critical modules
2. PyArmor Pro dla rest
3. Nuitka Commercial dla bundling
4. License server z hardware fingerprinting
5. Krytyczna logika w cloud (SaaS hybrid)
6. Watermarking per customer
```

### "Wynajmuję ML model"
```
- TylkoSaaS (klient nie dostaje wag/kodu)
- API wzorzec
- Rate limiting + usage analytics
- Możesz Cython compile inference jeśli klient on-prem
```

### "Open source z paid plugins"
```
- Free core: GitHub source
- Paid plugins: PyArmor obfuscated
- License key system w paid plugins
```

### "Skrypt automation za $20"
```
- Po prostu PyArmor Basic (free tier do small projects)
- Lub Nuitka --onefile
- EULA + copyright
```

## Wydajność

| Technique | Overhead | Ochrona |
|-----------|----------|---------|
| `.pyc` only | 0% | None (uncompyle6 trywialne) |
| pyminifier | 0% | Minimal |
| PyArmor Basic | 5-15% | Decent |
| PyArmor BCC | 10-25% | Strong |
| PyArmor RFT | 20-40% | Very strong |
| Cython compile | -50 do +500% (zwykle szybciej!) | Strong |
| Nuitka standalone | 0-30% | Strong |
| Nuitka + PyArmor | 30-50% | Very strong |

**Najlepszy ROI 2026:** Nuitka --onefile (free) + license key check.

## Co NIE działa

### ❌ Tylko `.pyc` files
Trywialne do dekompilacji.

### ❌ Custom XOR / encryption
```python
encrypted_code = "..."
exec(decrypt(encrypted_code, KEY))
```
Klucz jest w kodzie → atakujący odpala debugger przed `exec` → ma plain code.

### ❌ PyInstaller alone
Bundle ≠ ochrona. Zawsze kombinuj z PyArmor lub Nuitka.

### ❌ Polegać na obfuskacji nazw
Renaming variables nie chroni — logika wciąż czytelna.

### ❌ Nadmierna dynamic Pythona
Jeśli używasz `eval`, `exec`, monkeypatching — Cython i Nuitka mogą nie działać.

## Tools quick reference

```
Komercyjne:
- PyArmor (Dashingsoft) — ~$69-599/yr, najpopularniejszy
- Nuitka Commercial — ~$250/yr, native compilation
- Sourcedefender — alternatywa PyArmor

Open source:
- Cython — Python → C → binary
- Nuitka — Python → standalone binary (free version)
- mypyc — typed Python → C extension
- pyminifier — minimal obfuscation (legacy)

License management:
- Cryptolens — free tier, popular
- LicenseSpring — managed
- Keygen.sh — OSS server

Decompilers (do testów):
- uncompyle6 — Python 2-3.8
- decompyle3 — Python 3.7-3.8
- pycdc — newer (3.9+)
- pyinstxtractor — PyInstaller bundles
```

## Code signing dla Python apps

Po Nuitka build:

**Windows:**
```bash
signtool sign /f cert.pfx /p password \
    /tr http://timestamp.digicert.com /td sha256 /fd sha256 \
    myapp.exe
```

**macOS:**
```bash
codesign --deep --force --verify --verbose \
    --sign "Developer ID Application: Your Name" \
    --options runtime \
    myapp.app

# Notarization (required dla apps poza App Store)
xcrun notarytool submit myapp.zip \
    --apple-id you@example.com \
    --team-id ABC123XYZ \
    --password app-specific-password \
    --wait
```

**Linux:** brak natywnego signing, ale możesz GPG sign installer.

## Aspekty prawne

Identycznie jak w innych językach:
- Copyright automatycznie od creation
- EULA z zakazem reverse engineering
- DMCA / European equivalents jeśli leak
- Trade secret protection dla algorytmów

## Linki

- **PyArmor**: pyarmor.dashingsoft.com
- **Nuitka**: nuitka.net
- **Cython**: cython.org
- **mypyc**: mypyc.readthedocs.io
- **Cryptolens Python**: cryptolens.io
- **Sourcedefender**: sourcedefender.co.uk

## Następne kroki

- **Rozdział 04** — bezpieczeństwo aplikacji (OWASP, supply chain)
- **Rozdział 06** — Python dla AI/ML
- W folderze **architektura/08-bezpieczenstwo** — fundamenty
