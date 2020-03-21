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
echo -- PREPARE PACKING: COPY ADDITIONAL DATA
echo ---------------------------------------------------------------------------
echo.

echo  ^> copying files to %DIR_COOKED_DLC%
if EXIST "%DIR_OUTPUT_QUEST%\dlc\*.w3hub" (
  copy "%DIR_OUTPUT_QUEST%\dlc\*.w3hub" "%DIR_COOKED_DLC%\dlc"
)

robocopy "%DIR_PROJECT_BASE%\additional" "%DIR_COOKED_DLC%\%DIR_DLC_GAMEPATH%" /s /NFL /NJH /XX
echo  ^> done.

if %ERRORLEVEL% EQU 0 EXIT /B 0
:: One or more files were copied successfully (that is, new files have arrived).
if %ERRORLEVEL% EQU 1 EXIT /B 0
:: Some Extra files or directories were detected.
if %ERRORLEVEL% EQU 2 EXIT /B 0
:: (2+1) Some files were copied. Additional files were present. No failure was encountered.
if %ERRORLEVEL% EQU 3 EXIT /B 0
:: something else happened
EXIT /B %ERRORLEVEL%
