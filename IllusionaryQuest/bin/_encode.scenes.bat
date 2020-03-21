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
echo -- ENCODING SCENES %PATCHING%
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------
setlocal enableDelayedExpansion

rem ---------------------------------------------------
rem automatically find yml file be naming convention
rem ---------------------------------------------------

if not exist "%DIR_OUTPUT_SCENES%" mkdir "%DIR_OUTPUT_SCENES%"
set SCENE_WILDCARD=%DIR_DEF_SCENES%\%SCENE_DEF_PREFIX%*.yml

rem overwrite wildcard with specific id if provided
if "%SCENEID%" NEQ "" (
  SET SCENE_WILDCARD=%DIR_DEF_SCENES%\%SCENE_DEF_PREFIX%%SCENEID%.yml
)

if "%SCENE_TIMELINE_START%" NEQ "" (
  SET SCENE_TIMELINE_START=--timeline-start %SCENE_TIMELINE_START%
)
if "%SCENE_TIMELINE_END%" NEQ "" (
  SET SCENE_TIMELINE_END=--timeline-end %SCENE_TIMELINE_END%
)
if "%SCENE_TIMELINE_ZOOM%" NEQ "" (
  SET SCENE_TIMELINE_ZOOM=--timeline-zoom %SCENE_TIMELINE_ZOOM%
)

set COUNT=0
for %%f in (%SCENE_WILDCARD%) do (
  set FILENAME=%%~nf
  set SCENEID=!FILENAME:%SCENE_DEF_PREFIX%=!
  echo --------------------------------------------------------------------------
  echo  ^>^> found scene: !SCENEID!
  echo --------------------------------------------------------------------------

  set SCENENAME=!FILENAME!
  PUSHD %DIR_DEF_SCENES%
  %DIR_ENCODER%\w2scene.exe %SCENE_TIMELINE_START% %SCENE_TIMELINE_END% %SCENE_TIMELINE_ZOOM% --repo-dir "%DIR_REPO_SCENES%" --output-dir "%DIR_OUTPUT_SCENES%" --encode !SCENENAME! %LOG_LEVEL%
  POPD
  set /A COUNT+=1
  IF /I "!ERRORLEVEL!" NEQ "0" GOTO:SomeError

  rem ---------------------------------------------------
  rem --- rename scene.<sceneid>.w2scene to <sceneid>.w2scene
  echo.
  echo  ^>^> renaming scene to !SCENEID!.w2scene
  set GENERATED_SCENE_FILE=%DIR_OUTPUT_SCENES%\!SCENENAME!.w2scene
  move !GENERATED_SCENE_FILE! %DIR_OUTPUT_SCENES%\!SCENEID!.w2scene
  echo.

  rem ---------------------------------------------------
  rem --- put generated strings into strings dir for later concatenation

  set GENERATED_STRINGS_CSV=%DIR_OUTPUT_SCENES%\!SCENENAME!.w3strings-csv
  set STRINGS_PART_CSV=%DIR_STRINGS%\%STRINGS_PART_PREFIX%scene-!SCENEID!.csv

  if NOT exist !GENERATED_STRINGS_CSV! GOTO :SomeError
  type !GENERATED_STRINGS_CSV! > !STRINGS_PART_CSV!
  del !GENERATED_STRINGS_CSV!
  rem ---------------------------------------------------
  if exist "!GENERATED_STRINGS_CSV!.ws" del "!GENERATED_STRINGS_CSV!.ws"
)
echo.

if %COUNT% == 0 GOTO NoneFound

rem ---------------------------------------------------
rem -- at least one scene was encoded, setup followup flags

endlocal
if /I "%PATCH_MODE%" EQU "0" (
  :: full set of dependencies
  SET ENCODE_STRINGS=1
  SET WCC_COOK=1
  SET WCC_REPACK_DLC=1
)
EXIT /B 0

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! Scenes were NOT ENCODED!
echo.
exit /B 1

rem ---------------------------------------------------
:NoneFound
echo no scene processed. (file must be named: "%SCENE_DEF_PREFIX%<some name>.yml")
echo.
exit /B 0
