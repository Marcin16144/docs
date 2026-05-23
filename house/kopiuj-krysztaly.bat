@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "BASE=%~dp0"
set "SRC=!BASE!krysztaly"

echo.
echo  ============================================
echo    Kopiowanie Kompendium Krysztalow
echo  ============================================
echo.

if not exist "!SRC!\" (
    echo  BLAD: Nie znaleziono folderu krysztaly w:
    echo  !BASE!
    echo.
    pause
    exit /b 1
)

set /p "NAZWA=  Podaj nazwe folderu docelowego: "
echo.

if "!NAZWA!"=="" (
    echo  Nie podano nazwy. Anulowano.
    pause
    exit /b 0
)

rem  Ustal pelna sciezke: jesli uzytkownik podal litera dysku (np. C:\...) -- uzyj
rem  wprost, w przeciwnym razie umiesc folder obok skryptu.
set "DRUGI=!NAZWA:~1,1!"
if "!DRUGI!"==":" (
    set "CEL=!NAZWA!"
) else (
    set "CEL=!BASE!!NAZWA!"
)

rem  Usun ewentualny koncowy backslash
if "!CEL:~-1!"=="\" set "CEL=!CEL:~0,-1!"

echo  Zrodlo:    !SRC!
echo  Docelowy:  !CEL!
echo.

if exist "!CEL!\" (
    echo  Folder "!NAZWA!" juz istnieje.
    set /p "CONF=  Nadpisac istniejace pliki? [T/N]: "
    echo.
    if /i not "!CONF!"=="T" (
        echo  Anulowano.
        pause
        exit /b 0
    )
)

echo  Kopiowanie plikow...
echo.

rem  -------------------------------------------------------
rem  Robocopy: kopiuj cale drzewo krysztaly/
rem   /E         = z podfolderami (rowniez pustymi)
rem   /XF        = wyklucz pliki: CLAUDE.md, *.ps1, *.bat
rem   /XD        = wyklucz katalog: .claude
rem   /NP        = bez paska procentowego
rem   /NFL       = bez listy plikow
rem   /NDL       = bez listy folderow
rem  -------------------------------------------------------
robocopy "!SRC!" "!CEL!\krysztaly" /E ^
    /XF CLAUDE.md "*.ps1" "*.bat" ^
    /XD ".claude" ^
    /NP /NFL /NDL

rem  Robocopy zwraca 0-7 przy sukcesie (>= 8 to blad)
if !errorlevel! geq 8 (
    echo.
    echo  BLAD podczas kopiowania! Kod: !errorlevel!
    pause
    exit /b !errorlevel!
)

echo  [krysztaly\]  skopiowano.

rem  Skopiuj rowniez skrot Krysztaly.html (jesli istnieje obok skryptu)
if exist "!BASE!Krysztaly.html" (
    copy /Y "!BASE!Krysztaly.html" "!CEL!\Krysztaly.html" >nul
    echo  [Krysztaly.html]  skopiowano.
)

echo.
echo  ============================================
echo    Gotowe!
echo    Lokalizacja: !CEL!
echo  ============================================
echo.
pause
