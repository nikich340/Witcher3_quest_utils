@echo off
rem ---------------------------------------------------
rem --- check for settings
rem ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1

:SettingsLoaded
IF %ERRORLEVEL% NEQ 0 GOTO SomeError
rem ---------------------------------------------------
set DIR_EXECUTION_START=%cd%

if /I "%PATCH_MODE%" EQU "1" (
  SET PATCHING=(PATCH)
) ELSE (
  SET PATCHING=
)

IF %FULL_REBUILD% EQU 1 (
  SET ENCODE_WORLD=1
  SET ENCODE_ENVS=1
  SET ENCODE_QUEST=1
  SET ENCODE_STRINGS=1
  SET ENCODE_SCENES=1
  SET ENCODE_SPEECH=1
  SET DEPLOY_SCRIPTS=1
  SET DEPLOY_TMP_SCRIPTS=1
  SET WCC_REPACK_DLC=1
  SET WCC_REPACK_MOD=1
  SET WCC_IMPORT_MODELS=1
)

rem ---------------------------------------------------
rem -- CLEAR/PREPARE FOLDERS FOR FULL REBUILD

IF %FULL_REBUILD% EQU 1 CALL %DIR_PROJECT_BIN%\_cleanup.folder.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- CLEAR WCC LOG
IF EXIST "%DIR_PROJECT_BASE%/wcc.log" (
  echo.
  echo ^>^> deleting: previous wcc.log
  del "%DIR_PROJECT_BASE%/wcc.log"
)

rem ---------------------------------------------------
rem -- MOD: COPY mod scripts + resources

IF %DEPLOY_SCRIPTS% EQU 1 if exist "%DIR_MOD_SCRIPTS%" CALL %DIR_PROJECT_BIN%\_deploy.mod.scripts.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- ENCODER: WORLD

IF %ENCODE_WORLD% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.worlds.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- route output to cooked folder if cooking is not flagged

rem using patch mode makes cooking step optional
if %PATCH_MODE% EQU 1 if %WCC_COOK% EQU 0 (
  set DIR_OUTPUT_SCENES=%DIR_COOKED_DLC%\%DIR_DLC_GAMEPATH%\data\scenes
  set DIR_OUTPUT_ENVS=%DIR_COOKED_DLC%\%DIR_DLC_GAMEPATH%\data\envs
)
rem ---------------------------------------------------
rem -- ENCODER: ENVS

IF %ENCODE_ENVS% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.envs.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- ENCODER: SCENES

IF %ENCODE_SCENES% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.scenes.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- ENCODER: QUEST

IF %ENCODE_QUEST% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.quest.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: IMPORT MODELS

IF %WCC_IMPORT_MODELS% EQU 1 CALL %DIR_PROJECT_BIN%\_wcc.import.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: GENERATE NAVDATA

IF %WCC_NAVDATA% EQU 1 CALL:wccGenerateNavData
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: GENERATE OCCLUSIONDATA

IF %WCC_OCCLUSIONDATA% EQU 1 CALL %DIR_PROJECT_BIN%\_wcc.occlusion.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- PREPARE COOKING

IF %WCC_COOK% EQU 1 CALL %DIR_PROJECT_BIN%\_prepare.cooking.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: ANALYZE files

IF %WCC_ANALYZE% EQU 1 CALL %DIR_PROJECT_BIN%\_wcc.analyze.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: COOK

IF %WCC_COOK% EQU 1 CALL :wccCookData
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- PREPARE PACKING

IF %WCC_REPACK_DLC% EQU 1 CALL %DIR_PROJECT_BIN%\_prepare.packaging.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: PACK + METADATASTORE DLC

IF %WCC_REPACK_DLC% EQU 1 if exist "%DIR_COOKED_DLC%" CALL:wccPackDLCAndCreateMetadatastore
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: PACK + METADATASTORE MOD

IF %WCC_REPACK_MOD% EQU 1 if exist "%DIR_COOKED_MOD%" CALL:wccPackMODAndCreateMetadatastore
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- ENCODER: STRINGS

IF %ENCODE_STRINGS% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.strings.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- ENCODER: SPEECH

IF %ENCODE_SPEECH% EQU 1 CALL %DIR_PROJECT_BIN%\_encode.speech.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: GENERATE TEXTURE CACHE

IF %WCC_TEXTURECACHE% EQU 1 CALL:wccGenerateTextureCache
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- WCC_LITE: GENERATE COLLISION CACHE

IF %WCC_COLLISIONCACHE% EQU 1 CALL:wccGenerateCollisionCache
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- MOD: COPY tmp mod scripts

IF %DEPLOY_TMP_SCRIPTS% EQU 1 if exist "%DIR_TMP_MOD_SCRIPTS%" CALL %DIR_PROJECT_BIN%\_deploy.tmp.mod.scripts.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- STARTING GAME

IF %START_GAME% EQU 1 CALL:startGame
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem END
:TheEnd
call :printResult DONE.
EXIT /B 0

rem ---------------------------------------------------------------------------
rem function block
rem ---------------------------------------------------------------------------

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: GENERATE NAVDATA
rem ---------------------------------------------------------------------------
:wccGenerateNavData

call :printHeader WCC_LITE: GENERATE NAVDATA
PUSHD "%DIR_MODKIT_BIN%"

%WCC_LITE% pathlib -rootSearchDir %DIR_WCC_DEPOT_WORLDS%\ *.w2w
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: COOK
rem ---------------------------------------------------------------------------
:wccCookData

call :printHeader WCC_LITE: COOK

rem setup *all* seedfiles for cooking: hubs, dlc
setlocal enableDelayedExpansion
for %%n in ("%DIR_TMP%\%SEEDFILE_PREFIX%*.files") DO (
  set WCC_SEEDFILES=!WCC_SEEDFILES! -seed=%DIR_TMP%\%%~NXn
)
setlocal disabledelayedexpansion
rem endlocal

PUSHD "%DIR_MODKIT_BIN%"

rem Note: trimdir MUST be lowercased!
%WCC_LITE% cook -platform=pc -trimdir="dlc\dlc%MODNAME_LC%" %WCC_SEEDFILES% -outdir="%DIR_COOKED_DLC%"

POPD
if %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

if EXIST %DIR_COOKED_FILES_DB% del %DIR_COOKED_FILES_DB%
:: move to prevent beeing packed into mod
if EXIST %DIR_COOKED_DLC%\cook.db move %DIR_COOKED_DLC%\cook.db %DIR_COOKED_FILES_DB%
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: PACK + METADATASTORE DLC
rem ---------------------------------------------------------------------------
:wccPackDLCAndCreateMetadatastore

call :printHeader WCC_LITE: PACK + METADATASTORE
PUSHD "%DIR_MODKIT_BIN%"

%WCC_LITE% pack -dir="%DIR_COOKED_DLC%" -outdir="%DIR_DLC_CONTENT%"
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

PUSHD "%DIR_MODKIT_BIN%"
%WCC_LITE% metadatastore -path="%DIR_DLC_CONTENT%"
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: PACK + METADATASTORE MOD
rem ---------------------------------------------------------------------------
:wccPackMODAndCreateMetadatastore

call :printHeader WCC_LITE: PACK + METADATASTORE
PUSHD "%DIR_MODKIT_BIN%"

%WCC_LITE% pack -dir="%DIR_COOKED_MOD%" -outdir="%DIR_MOD_CONTENT%"
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

PUSHD "%DIR_MODKIT_BIN%"
%WCC_LITE% metadatastore -path="%DIR_MOD_CONTENT%"
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: GENERATE TEXTURE CACHE
rem ---------------------------------------------------------------------------
:wccGenerateTextureCache

call :printHeader WCC_LITE: GENERATE TEXTURE CACHE
PUSHD "%DIR_MODKIT_BIN%"

if not EXIST "%DIR_UNCOOKED_TEXTURES%\%DIR_DLC_GAMEPATH%" (
  echo WARN: no textures found in "%DIR_UNCOOKED_TEXTURES%\%DIR_DLC_GAMEPATH%"
  EXIT /B 0
)

if EXIST %DIR_COOKED_TEXTURES_DB% del %DIR_COOKED_TEXTURES_DB%
%WCC_LITE% cook -platform=pc -mod="%DIR_UNCOOKED_TEXTURES%" -basedir="%DIR_UNCOOKED_TEXTURES%" -outdir="%DIR_COOKED_DLC%"
:: move so it is separated from "normal" files cook.db
if EXIST %DIR_COOKED_DLC%\cook.db move %DIR_COOKED_DLC%\cook.db %DIR_COOKED_TEXTURES_DB%

%WCC_LITE% buildcache textures -db="%DIR_COOKED_TEXTURES_DB%" -basedir="%DIR_UNCOOKED_TEXTURES%" -out="%DIR_DLC_CONTENT%\texture.cache" -platform=pc
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- WCC_LITE: GENERATE COLLISION CACHE
rem ---------------------------------------------------------------------------
:wccGenerateCollisionCache

call :printHeader WCC_LITE: GENERATE COLLISION CACHE
PUSHD "%DIR_MODKIT_BIN%"

%WCC_LITE% buildcache physics -db="%DIR_COOKED_FILES_DB%" -basedir="%DIR_MODKIT_DEPOT%" -out="%DIR_DLC_CONTENT%\collision.cache" -platform=pc
POPD
IF %INTERACTIVE_BUILD% EQU 1 PAUSE

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------------------------------
rem -- START GAME
rem ---------------------------------------------------------------------------
:startGame

call :printHeader STARTING GAME
PUSHD "%DIR_W3%\bin\x64\"

witcher3.exe -debugscripts

POPD
EXIT /B 0

rem ---------------------------------------------------------------------------
:printHeader
echo.
echo --------------------------------------------------------------------------
echo -- %*
echo --------------------------------------------------------------------------
echo.
EXIT /B 0

rem ---------------------------------------------------------------------------
:printResult
echo.
echo --------------------------------------------------------------------------
echo -- %*
echo --------------------------------------------------------------------------
EXIT /B 0

rem ---------------------------------------------------
rem error
:SomeError
echo.
echo ERROR! Something went WRONG! Please check above output.
echo.
cd /D "%DIR_EXECUTION_START%"
rem pause
EXIT /B 1
