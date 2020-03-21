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
echo -- ENCODING WORLD %PATCHING%
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------
rem --- encode all worlds
rem ---------------------------------------------------
setlocal enableDelayedExpansion

rem ---------------------------------------------------
if not exist "%DIR_OUTPUT_WORLD%" mkdir "%DIR_OUTPUT_WORLD%"
if not exist "%DIR_TMP%" mkdir "%DIR_TMP%"

set WORLD_WILDCARD=%DIR_DEF_WORLD%\%WORLD_DEF_PREFIX%*.yml

SET SKIP_PARAM=

if "%SKIP_WORLD_GENERATION%" EQU "1" (
  SET SKIP_PARAM=--no-terrain
)

if "%SKIP_FOLIAGE_GENERATION%" EQU "1" (
  SET SKIP_PARAM=%SKIP_PARAM% --no-foliage
)

set COUNT=0
for %%f in (%WORLD_WILDCARD%) do (
  set FILENAME=%%~ff
  echo.
  echo  ^>^> encoding: %%~nxf
  echo.
  %DIR_ENCODER%\w3world.exe --repo-dir "%DIR_REPO_WORLDS%" --output-dir "%DIR_OUTPUT_WORLD%" --foliage-dir %DIR_DEF_WORLD%\foliage %SKIP_PARAM% --encode !FILENAME! %LOG_LEVEL%

  set /A COUNT+=1
  IF /I "!ERRORLEVEL!" NEQ "0" GOTO:SomeError
)
echo.

if %COUNT% == 0 GOTO NoneFound
rem ---------------------------------------------------
rem -- at least one world was encoded, setup followup flags

endlocal
if /I "%PATCH_MODE%" EQU "1" (
  :: NO dependent steps (e.g. creating collisioncache must be toggled by caller)
  rem SET WCC_COOK=1
  rem SET WCC_REPACK_DLC=1
) else (
  :: full set of dependencies
  SET WCC_ANALYZE=1
  SET WCC_ANALYZE_WORLD=1
  SET WCC_COOK=1
  SET WCC_NAVDATA=1
  SET WCC_OCCLUSIONDATA=1
  SET WCC_TEXTURECACHE=1
  SET WCC_COLLISIONCACHE=1
  SET WCC_REPACK_DLC=1
)
EXIT /B 0

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! World and/or terrain tiles were NOT ENCODED!
echo.
exit /B 1

rem ---------------------------------------------------
:NoneFound
echo no worlds to process. (file must be named: "%WORLD_DEF_PREFIX%<some name>.yml")
echo.
exit /B 0
