rem ---------------------------------------------------
rem --- check for settings
rem ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1
rem ---------------------------------------------------
:SettingsLoaded

echo.
echo ---------------------------------------------------------------------------
echo -- PREPARE COOKING: CLEANUP OF UNCOOKED CONTENT
echo ---------------------------------------------------------------------------
echo.

if not exist "%DIR_TMP%" mkdir "%DIR_TMP%"

:: something else happened
EXIT /B %ERRORLEVEL%
