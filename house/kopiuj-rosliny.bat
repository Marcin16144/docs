@echo off
setlocal enabledelayedexpansion

set "BASE=%~dp0"
set "SRC=!BASE!rosliny"

echo.
echo  ============================================
echo   Kopiowanie Przewodnika Roslinnego
echo  ============================================
echo.

if not exist "!SRC!\" (
    echo  BLAD: Nie znaleziono folderu rosliny w:
    echo  !BASE!
    echo.
    pause
    exit /b 1
)

set /p "NAZWA=  Nazwa folderu docelowego: "
echo.

if "!NAZWA!"=="" (
    echo  Nie podano nazwy. Anulowano.
    pause
    exit /b 0
)

rem  Jesli podano pelna sciezke (np. D:\backup) -- uzyj wprost,
rem  w przeciwnym razie umiesc folder obok skryptu.
set "DRUGI=!NAZWA:~1,1!"
if "!DRUGI!"==":" (
    set "CEL=!NAZWA!"
) else (
    set "CEL=!BASE!!NAZWA!"
)

rem  Usun koncowy backslash jesli wystepuje
if "!CEL:~-1!"=="\" set "CEL=!CEL:~0,-1!"

echo  Zrodlo:    !SRC!
echo  Docelowy:  !CEL!
echo.

if exist "!CEL!\" (
    echo  Folder [!NAZWA!] juz istnieje.
    set /p "CONF=  Nadpisac istniejace pliki? [T/N]: "
    echo.
    if /i not "!CONF!"=="T" (
        echo  Anulowano.
        pause
        exit /b 0
    )
)

echo  Kopiowanie...
echo.

robocopy "!SRC!" "!CEL!\rosliny" /E /XF CLAUDE.md *.ps1 *.bat /XD .claude /NP /NFL /NDL
set "RC=%ERRORLEVEL%"

if %RC% geq 8 (
    echo.
    echo  BLAD robocopy ^(kod %RC%^). Sprawdz czy sciezka jest poprawna.
    pause
    exit /b %RC%
)

echo  rosliny\ ... OK

if exist "!BASE!Rosliny.html" (
    copy /Y "!BASE!Rosliny.html" "!CEL!\Rosliny.html" >nul
    echo  Rosliny.html ... OK
)

echo.
echo  ============================================
echo   Gotowe!
echo   !CEL!
echo  ============================================
echo.
pause