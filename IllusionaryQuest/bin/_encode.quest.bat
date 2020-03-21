rem ---------------------------------------------------
rem --- check for settings
rem ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1
rem ---------------------------------------------------
:SettingsLoaded

echo.
echo --------------------------------------------------------------------------
echo -- ENCODING QUEST %PATCHING%
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------
if not exist "%DIR_OUTPUT_QUEST%" mkdir "%DIR_OUTPUT_QUEST%"

%DIR_ENCODER%\w2quest.exe --repo-dir "%DIR_REPO_QUESTS%" --output-dir "%DIR_OUTPUT_QUEST%" --encode "%DIR_DEF_QUEST%/*.yml" %LOG_LEVEL%

IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem --- put generated strings into strings dir for later concatenation

set GENERATED_STRINGS_CSV=%DIR_OUTPUT_QUEST%\queststrings.csv
set STRINGS_PART_CSV=%DIR_STRINGS%\%STRINGS_PART_PREFIX%quest.csv

::TODO check for w2quest file
rem if NOT exist %GENERATED_STRINGS_CSV% GOTO:NoneFound
for /F %%i in ('dir /b /S "%DIR_OUTPUT_QUEST%\*.w2quest"') do (
  goto :QuestEncoded
)
GOTO :NoneFound

:QuestEncoded
echo.
if EXIST %GENERATED_STRINGS_CSV% (
  type %GENERATED_STRINGS_CSV% > %STRINGS_PART_CSV%
  del %GENERATED_STRINGS_CSV%
)

rem ---------------------------------------------------
rem -- quest was encoded, setup followup flags

if /I "%PATCH_MODE%" EQU "1" (
  :: NO dependent steps (e.g. repacking must be toggled by caller)
  echo.
) else (
  :: full set of dependencies
  SET ENCODE_STRINGS=1
  SET WCC_ANALYZE=1
  SET WCC_COOK=1
  SET WCC_REPACK_DLC=1
)
EXIT /B 0

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! Quest was NOT ENCODED!
echo.
exit /B 1

rem ---------------------------------------------------
:NoneFound
echo no quest to process.
echo.
exit /B 0
