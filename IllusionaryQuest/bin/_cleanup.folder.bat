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
echo -- CLEANUP OF UNCOOKED, COOKED, DLC TARGET FOLDERS pm: "%PATCH_MODE%"
echo ---------------------------------------------------------------------------
echo.

SET RD_OPTIONS=/s
if "%auto_delete_mod%"=="YES" SET RD_OPTIONS=/s /q

if exist "%DIR_UNCOOKED%" (
  echo ^>^> deleting: "%DIR_UNCOOKED%"
  rd %RD_OPTIONS% "%DIR_UNCOOKED%"
)
if not exist "%DIR_UNCOOKED%" mkdir "%DIR_UNCOOKED%"

if exist "%DIR_COOKED_DLC%" (
  echo ^>^> deleting: "%DIR_COOKED_DLC%"
  rd %RD_OPTIONS% "%DIR_COOKED_DLC%"
)
if not exist "%DIR_COOKED_DLC%" mkdir "%DIR_COOKED_DLC%"

if exist "%DIR_DLC%" (
  echo ^>^> deleting: "%DIR_DLC%"
  rd %RD_OPTIONS% "%DIR_DLC%"
)
if not exist "%DIR_DLC%" mkdir "%DIR_DLC%"

if exist "%DIR_MOD%" (
  echo ^>^> deleting: "%DIR_MOD%"
  rd %RD_OPTIONS% "%DIR_MOD%"
)
if not exist "%DIR_MOD%" mkdir "%DIR_MOD%"

if exist "%DIR_TMP%" (
  echo ^>^> deleting: "%DIR_TMP%"
  rd %RD_OPTIONS% "%DIR_TMP%"
)
if not exist "%DIR_TMP%" mkdir "%DIR_TMP%"

::TODO clear csv snippet files in strings folder

EXIT /B %ERRORLEVEL%
