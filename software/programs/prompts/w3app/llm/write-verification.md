# Write verification — 7 checków dla `write_file`

> Wprowadzone w `0.7.26` (2026-05-31). Wzorowane na praktykach popularnych VS Code
> agentów: Cline, Continue, Aider, Cody, Roo. Plik:
> [`helpers/write_verify.php`](../../admin/pages/consoleai/terminal/helpers/write_verify.php).

## Po co

LLM-y w trybie agentowym popełniają charakterystyczne błędy podczas modyfikacji
plików:

- **Blind overwrite** — model emituje `write_file` bez wcześniejszego `read_file`,
  zgadując treść.
- **Fragment-as-full** — model pisze tylko sekcję która się zmieniła, myśląc że
  `write_file` patch'uje. W rzeczywistości overwrite'uje cały plik → reszta kodu
  znika.
- **Złamana składnia** — model wypluwa kod z `Parse error` / niezbalansowanymi
  brackets.
- **Style drift** — losowo zmienia tabs↔spaces / LF↔CRLF, plik traci spójność.

Te checki wpięte są **przed faktycznym zapisem** w `tcWsWriteFile`. Pierwsze 4
blokują zapis (write_file zwraca `ERROR`), 5 jest tylko warning'iem, 6 zachowuje
backup, 7 podpowiada następny krok.

## Checki

### 1. Read-before-write enforcement (BLOCK)

Per-turn tracker plików już odczytanych — `wvNoteRead($path)` w `read_file`,
`wvWasRead($path)` w `write_file`. Sesja: `$_SESSION['console_ai_turn_ctx']['read']`.
Reset na początku każdej tury (`wvResetTurnContext()` w `console_ai_send`).

**Reguła:** jeśli plik istnieje i NIE został odczytany w tej turze → BLOCK.
**Wyjątek:** nowe pliki (file doesn't exist yet) — OK bez read.

Komunikat dla modelu:
> BLIND OVERWRITE BLOCKED: you are about to overwrite an EXISTING file that you
> have NOT read_file in this turn. FIRST call `read_file` to see the current state,
> then merge your changes into the FULL content, then `write_file`.

### 2. File-size delta sanity (BLOCK)

**Reguła:** jeśli stary plik ma >500 B i nowy <50% rozmiaru → BLOCK.
**Wyjątek:** drobne pliki (<500 B) — pomijane.

Łapie najczęstszy bug DS-Coder: pisanie tylko zmienionej sekcji zamiast całej
zawartości.

### 3. Auto-syntax check (BLOCK / 4. Auto-revert)

Per extension uruchamia się walidator:

| Ext | Walidator | Implementacja |
|---|---|---|
| `.php` | `php -l` | Zapis tmp → `proc_open` → analiza stderr |
| `.json` | `json_decode` strict | `json_last_error()` |
| `.xml`/`.html`/`.svg` | DOMDocument | `libxml_get_errors()` |
| `.yaml`/`.yml` | `yaml_parse` lub heurystyka | mixed tab/space detection |

Pomijamy: `.cs`/`.ts`/`.py`/`.go`/`.rs` (wolne, wymagają zewnętrznych narzędzi —
te są weryfikowane przez `csharp_build.php` post-process buildu).

**Auto-revert:** check 3 uruchamiany PRZED `file_put_contents`, więc nie ma czego
przywracać — write_file po prostu zwraca błąd i plik na dysku zostaje w starym
stanie.

### 5. Indent/EOL preservation (WARNING)

- **EOL detection:** licznik `\r\n` vs `\n` w treści, większość wygrywa.
- **Indent detection:** próbka pierwszych 100 linii z indentem, tabs vs spaces (≥2),
  większość wygrywa.

Mismatch nie blokuje (model może legitymalnie konwertować) — tylko warning w
return value `write_file`.

### 6. Backup ring (N=3 wersji)

Przed `file_put_contents`:
```
<sys_get_temp_dir>/console_ai_backup/<sha256[16]>/<YmdHis>_<hex4>.bak
```

- Max **512 KB per backup** (większe pliki pomijane — overhead disk)
- Max **3 backupów per plik** (rotate najstarszych)
- `wvBackupRestoreLatest($path)` → string content z najnowszego backupu

W przyszłości można dodać UI „rewert" — `wvBackupList($path)` zwraca listę
z mtime+size dla wyboru.

### 7. Post-write build hint

Po pomyślnym `write_file` dla rozszerzeń kodu, dokleja do return value:

| Ext | Marker projektu | Sugerowana komenda |
|---|---|---|
| `.cs`/`.fs`/`.vb` | `*.sln` / `*.csproj` | `dotnet build` |
| `.ts`/`.tsx` | `package.json` + `tsconfig.json` | `npx --no-install tsc --noEmit` |
| `.rs` | `Cargo.toml` | `cargo check --quiet` |
| `.go` | `go.mod` | `go vet ./...` |

NIE odpalamy buildu automatycznie (byłoby za wolne dla N plików w sub-loopie) —
tylko hint dla modelu w `NEXT-STEP HINT: …`. Model decyduje czy zawołać
`run_command`.

## Przykładowy output `write_file`

### Sukces
```
File overwritten successfully.
Path: src/Program.cs
Bytes: 1247
Working folder: W:/App/AppTerminal/K2Terminal

NEXT-STEP HINT: You changed a .NET source file. Verify the change compiles by
calling `run_command` with `dotnet build` (or `dotnet build --no-restore` if
packages are already restored). The output will be auto-parsed for CS-errors.
```

### Sukces ze stylem
```
File overwritten successfully.
Path: utils/helpers.ts
Bytes: 845
Working folder: W:/App/AppTerminal

WARNING: STYLE CHANGE: indent style changed from tabs to spaces. Make sure this
is intentional — otherwise re-write with the original style.

NEXT-STEP HINT: You changed a TypeScript source file. Verify the change
type-checks by calling `run_command` with `npx --no-install tsc --noEmit`.
```

### Blokada — read-before-write
```
ERROR: BLIND OVERWRITE BLOCKED: you are about to overwrite an EXISTING file
("MainForm.cs") that you have NOT read_file in this turn. This usually means you
are guessing the new content based on assumptions. FIRST call `read_file` to see
the current state, then merge your changes into the FULL content, then
`write_file` with the COMPLETE new body.
```

### Blokada — size delta
```
ERROR: SUSPICIOUS SIZE SHRINK (78%): the existing file has 5240 bytes, you want
to write only 1153 bytes (78% smaller). write_file OVERWRITES the entire file —
if you intended to only modify part of it, you must include the COMPLETE new
content (all the unchanged parts too).
```

### Blokada — syntax
```
ERROR: PHP syntax error: PHP Parse error: syntax error, unexpected end of file in
<file> on line 12. — fix the syntax error and retry write_file. write_file was
NOT performed (file unchanged).
```

## API publiczne

```php
// W kodzie aplikacji nigdy nie wołasz tych bezpośrednio — wpięte w tcWsWriteFile.
// Jeśli chcesz dodać własną weryfikację, dodaj funkcję do wvRunAllChecks().

wvRunAllChecks($absPath, $newContent, $existed, $oldContent): array  // ['ok' => bool, 'error'?, 'warning'?]
wvNoteRead($absPath): void              // wołane z read_file
wvWasRead($absPath): bool
wvResetTurnContext($turnId): void       // wołane z console_ai_send
wvBackupSnapshot($absPath, $oldContent): void
wvBackupRestoreLatest($absPath): ?string
wvBackupList($absPath): array
wvPostWriteBuildHint($absPath, $workdir): string
```

## Testy (zielone na 0.7.26)

| Check | Wynik |
|---|---|
| 1 — read-before-write enforcement | 3/3 OK |
| 2 — size delta sanity (3 case'y) | 3/3 OK |
| 3 — syntax check (PHP/JSON/XML, valid + broken) | 6/6 OK |
| 5 — indent/EOL preservation (tabs→spaces, CRLF→LF, same style) | 3/3 OK |
| 6 — backup ring (rotate N=3 + restore) | OK |
| 7 — post-write build hint (.cs w .NET / .txt no hint) | 2/2 OK |
