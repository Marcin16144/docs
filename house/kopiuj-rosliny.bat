@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "BASE=%~dp0"
set "SRC=!BASE!rosliny"

echo.
echo  ============================================
echo    Kopiowanie Przewodnika Roslinnego
echo  ============================================
echo.

if not exist "!SRC!\" (
    echo  BLAD: Nie znaleziono folderu rosliny w:
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
    echo  Folder [!NAZWA!] juz istnieje -- nadpisuje zmienione pliki.
    echo.
)

echo  Kopiowanie...
echo.

rem  Robocopy: /E = z podfolderami, bez /PURGE i /MIR -- nie kasuje
rem  niczego w folderze docelowym, tylko nadpisuje zmienione pliki.
robocopy "!SRC!" "!CEL!\rosliny" /E /XF CLAUDE.md *.ps1 *.bat /XD .claude /NP /NFL /NDL
set "RC=%ERRORLEVEL%"

rem  Robocopy zwraca 0-7 przy sukcesie (>= 8 to blad)
if %RC% geq 8 (
    echo.
    echo  BLAD robocopy (kod %RC%). Sprawdz czy sciezka jest poprawna.
    pause
    exit /b %RC%
)

echo  [rosliny\]  skopiowano.

rem  Skopiuj rowniez skrot Rosliny.html (jesli istnieje obok skryptu)
if exist "!BASE!Rosliny.html" (
    copy /Y "!BASE!Rosliny.html" "!CEL!\Rosliny.html" >nul
    echo  [Rosliny.html]  skopiowano.
)

echo.
echo  ============================================
echo    Gotowe!
echo    Lokalizacja: !CEL!
echo  ============================================
echo.
pause
