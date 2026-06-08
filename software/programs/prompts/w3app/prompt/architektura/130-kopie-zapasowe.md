# Prompt 130: Kopie zapasowe — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [120 Galeria i media](120-galeria-i-media.md) · Następny: [140 Bezpieczeństwo](140-bezpieczenstwo.md) →

Buduje **warstwę kopii zapasowych** panelu: trzy tryby (db / full / media), wykrywanie metody archiwizacji (`detectArchiver()` → ZipArchive lub PharData→tar.gz), sygnatury integralności SHA-256 (sidecar `.sha256`), opcjonalne szyfrowanie AES-256-CBC dumpów SQL oraz niezawodną na Windows iteracyjną archiwizację katalogów. Wymaga gotowego `Core\Config`, `Core\Connection`, `Core\Log\Logger` oraz struktury `media/` z [120 Galeria i media](120-galeria-i-media.md).

## Jak używać
1. Upewnij się, że istnieje rdzeń `Config`/`Connection`/`Logger` i katalog `media/`.
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Asystent wygeneruje funkcje backupu (PHP, do `admin/pages/system/backup/admbackup.php`) i `.gitignore`.
4. Zweryfikuj tworzenie/odtwarzanie kopii wg sekcji **Weryfikacja**.

---

## PROMPT
```
Jesteś inżynierem PHP odtwarzającym warstwę kopii zapasowych panelu K2 CMS.
Wygeneruj funkcje backupu oraz zabezpieczenie katalogu kopii w gicie.

## KONTEKST PROJEKTU

- PHP 8.1+, MySQL 8 (główna BD) i SQLite (alternatywna). Wielodomenowość.
- Dostępne globalnie: `Core\Config::get($key, $default?)`, `Core\Connection::get(): PDO`,
  `Core\Log\Logger::get('Backup')->warn(...)`, stała `ROOT`.
- Archiwizacja: ext-zip (ZipArchive) jako preferowana, ext-phar (PharData) jako fallback
  na tar.gz — wbudowane w PHP core, działa nawet bez ext-zip. ext-openssl opcjonalne (szyfrowanie).
- Funkcje trafiają do `admin/pages/system/backup/admbackup.php`.

## ŚCIEŻKI

- admin/pages/system/backup/admbackup.php — funkcje backupu + obsługa akcji POST/GET
- var/backups/                            — pliki kopii (NIE wersjonowane)
- var/backups/.gitignore                  — reguła: * / !.gitignore / !.gitkeep

## TRYBY KOPII (akcja POST create_backup, pole backup_type)

  db    → .sql (lub .sql.enc gdy szyfrowanie)  — dump SQL wszystkich tabel
  full  → .zip lub .tar.gz                     — database.sql + media/originals/ + media/cache/
  media → .zip lub .tar.gz                     — tylko media/originals/ + media/cache/

## WYKRYWANIE METODY ARCHIWIZACJI — detectArchiver(): string

  if (class_exists('ZipArchive'))                          return 'zip';
  if (class_exists('PharData') && defined('Phar::GZ'))     return 'tar_gz';
  return 'none';   // archiwa mediów niedostępne — pozostaje tylko dump SQL (tryb db)

## KONWENCJA NAZW PLIKÓW (var/backups/)

  $stamp = date('Y-m-d_H-i-s');   // np. 2026-05-24_14-30-00
  backup_<STAMP>_<driver>.sql            dump (driver = mysql | sqlite)
  backup_<STAMP>_<driver>.sql.enc        dump zaszyfrowany (AES-256-CBC)
  backup_<STAMP>_<driver>_full.zip|.tar.gz   pełna kopia
  backup_<STAMP>_media.zip|.tar.gz           tylko media
  backup_<STAMP>_*.sha256                sygnatura integralności (sidecar)

  Pobieranie/usuwanie/odtwarzanie waliduje nazwę ścisłym regexem (path traversal
  niemożliwy: basename() + wzorzec), np.:
    ^backup_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_((mysql|sqlite)(_full\.(zip|tar\.gz)|\.sql(\.enc)?)|media\.(zip|tar\.gz))$

## INTEGRALNOŚĆ — SHA-256 sidecar

  backupSign($backupPath): void
    - hash_file('sha256', $backupPath)
    - zapis do $backupPath.'.sha256' formatu: "<hex>  <basename>\n" (zgodny z sha256sum), LOCK_EX.
    - Wołane po KAŻDYM utworzonym pliku kopii.

  backupVerify($backupPath): void
    - Gdy brak .sha256 → Logger::get('Backup')->warn(...) i return (NIE blokuje — stare kopie).
    - Inaczej: porównanie hash_equals(expected, hash_file('sha256', ...)); niezgodność → RuntimeException.
    - Wołane przed odtworzeniem (blokujące) i przy pobieraniu (ostrzeżenie).

## SZYFROWANIE — AES-256-CBC (tylko dump SQL)

  backupEncryptionKey(): ?string
    - Config::get('backup_encryption_key', ''); format 'base64:<32B>' (preferowany) lub surowe 32B.
    - Zwraca 32-bajtowy klucz binarny lub null (szyfrowanie wyłączone).

  backupEncrypt($sqlPath): string   // format: [4B magic "K2BC"][16B IV][cipher]
    - Gdy klucz null → zwróć $sqlPath bez zmian.
    - $iv = random_bytes(16); $cipher = openssl_encrypt($plain,'AES-256-CBC',$key,OPENSSL_RAW_DATA,$iv).
    - Zapis: file_put_contents($sqlPath.'.enc', 'K2BC'.$iv.$cipher, LOCK_EX); unlink($sqlPath); zwróć .enc.

  backupDecrypt($encPath): string
    - Gdy klucz null lub plik nie kończy się '.enc' → zwróć $encPath.
    - Sprawdź magic 'K2BC' (4B) → RuntimeException przy niezgodności; IV = bajty 4..20; reszta = cipher.
    - openssl_decrypt(...); zapis do pliku tmp (sys_get_temp_dir()); zwróć ścieżkę tmp (kasuje wołający).

  Archiwa ZIP/TAR.GZ NIE są szyfrowane — szyfrowanie dotyczy wyłącznie kopii SQL.

## ARCHIWIZACJA KATALOGÓW (niezawodna na Windows)

  addDirToZip(\ZipArchive $zip, string $dir, string $zipPrefix): int
  addDirToPhar(\PharData $phar, string $dir, string $pharPrefix): int

  Obie używają iteratywnego STOSU opartego na scandir() (NIE RecursiveIteratorIterator —
  unika konfliktu uchwytów SPL + ZipArchive na Windows):

    if (!is_dir($dir)) return 0;
    $realDir = realpath($dir); if ($realDir === false) return 0;
    $count = 0; $dirLen = strlen($realDir); $stack = [$realDir];
    while (!empty($stack)) {
        $current = array_pop($stack);
        $entries = @scandir($current); if ($entries === false) continue;
        foreach ($entries as $entry) {
            if (in_array($entry, ['.', '..', '.gitignore', '.gitkeep'], true)) continue;
            $fullPath = $current . DIRECTORY_SEPARATOR . $entry;
            $relative = str_replace('\\', '/', substr($fullPath, $dirLen + 1)); // ZIP/TAR wymaga "/"
            $arcPath  = $prefix . '/' . $relative;
            if (is_dir($fullPath))  { $zip->addEmptyDir($arcPath); $stack[] = $fullPath; }
            elseif (is_file($fullPath)) { $zip->addFile($fullPath, $arcPath); $count++; }
        }
    }
    return $count;

  createMediaArchive($basePath, $method, array $strings, array $dirs): string
    - $strings: ['nazwa/w/archiwum' => $treść] (np. 'database.sql' => $dump).
    - $dirs: [['dir' => '/abs', 'prefix' => 'media/originals'], ...].
    - method 'zip':    new ZipArchive; open(CREATE|OVERWRITE); addFromString() dla stringów;
                       addDirToZip() dla katalogów; close(); zwróć $basePath.'.zip'.
    - method 'tar_gz': new PharData($basePath.'.tar'); addFromString(); addDirToPhar();
                       $phar->compress(\Phar::GZ); unset($phar); unlink .tar; zwróć '.tar.gz'.
    - inny method → RuntimeException.

## LISTA KOPII — listBackupFiles(): array

  glob backup_*.sql + backup_*.sql.enc + backup_*.zip + backup_*.tar.gz; dla każdej:
  name, path, size, mtime, encrypted (kończy się .enc),
  type ('full' gdy _full.(zip|tar.gz); 'media' gdy _media.(zip|tar.gz); inaczej 'db').
  Sortowanie malejąco po mtime.

## ZADANIE

1. Odtwórz backupDir(): string (ROOT.'/var/backups', mkdir 0750 gdy brak).
2. Odtwórz detectArchiver(): string wg priorytetu ZipArchive → PharData(GZ) → 'none'.
3. Odtwórz backupSign()/backupVerify() (sidecar .sha256; verify blokuje przy niezgodności,
   ostrzega przy braku sygnatury).
4. Odtwórz backupEncryptionKey()/backupEncrypt()/backupDecrypt() (AES-256-CBC, magic "K2BC"+IV;
   tylko dump SQL).
5. Odtwórz addDirToZip()/addDirToPhar() (iteracyjny scandir-stack, pomijanie .gitignore/.gitkeep,
   separatory "/") oraz createMediaArchive() (zip i tar_gz).
6. Odtwórz listBackupFiles() (klasyfikacja typu db/full/media, sort po mtime malejąco).
7. Odtwórz tworzenie kopii dla trzech trybów (db/full/media) z konwencją nazw, podpisem
   SHA-256 każdego pliku i opcjonalnym szyfrowaniem dla trybu db.
8. Utwórz var/backups/.gitignore (* / !.gitignore / !.gitkeep) + .gitkeep.

Zwróć tylko pliki/kod, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `detectArchiver()` zwraca `'zip'` gdy jest ZipArchive, w przeciwnym razie `'tar_gz'` gdy PharData+GZ, inaczej `'none'`.
- [ ] Tryb `db` tworzy `backup_<STAMP>_<driver>.sql`; przy skonfigurowanym kluczu — `.sql.enc` (oryginalny `.sql` usunięty).
- [ ] Plik `.enc` zaczyna się od 4 bajtów `K2BC`, potem 16 bajtów IV, potem szyfrogram AES-256-CBC.
- [ ] Każdy utworzony plik kopii ma sidecar `.sha256` w formacie `<hex>  <basename>`; `backupVerify()` blokuje odtworzenie przy niezgodności i tylko ostrzega gdy brak sygnatury.
- [ ] `addDirToZip()`/`addDirToPhar()` używają iteracyjnego stosu `scandir()` (nie `RecursiveIteratorIterator`), pomijają `.gitignore`/`.gitkeep` i normalizują separatory do `/`.
- [ ] Tryby `full`/`media` produkują `.zip` lub `.tar.gz` (zależnie od `detectArchiver()`); `full` zawiera `database.sql` + `media/originals/` + `media/cache/`.
- [ ] `listBackupFiles()` poprawnie klasyfikuje `type` (db/full/media), ustawia `encrypted` i sortuje malejąco po `mtime`.
- [ ] `var/backups/.gitignore` ma regułę `* / !.gitignore / !.gitkeep` — pliki kopii nie trafiają do gita.

## Powiązane
- [060 Logger](060-logger.md) — kanał `Backup` (ostrzeżenia o braku sygnatury, błędy archiwizacji).
- [120 Galeria i media](120-galeria-i-media.md) — katalogi `media/originals/` i `media/cache/` archiwizowane w trybach full/media.
- [140 Bezpieczeństwo](140-bezpieczenstwo.md) — walidacja nazw plików (path traversal), uprawnienia do sekcji backup.
- [Architektura §8 (System kopii zapasowych)](../../architektura/architektura.md).
