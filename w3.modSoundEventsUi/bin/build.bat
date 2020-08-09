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
  SET ENCODE_STRINGS=1
  SET DEPLOY_SCRIPTS=1
  SET WCC_REPACK_DLC=1
)

rem ---------------------------------------------------
rem -- CLEAR/PREPARE FOLDERS FOR FULL REBUILD

IF %FULL_REBUILD% EQU 1 CALL %DIR_PROJECT_BIN%\_cleanup.folder.bat
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem -- MOD: COPY mod scripts + resources

IF %DEPLOY_SCRIPTS% EQU 1 if exist "%DIR_MOD_SCRIPTS%" CALL %DIR_PROJECT_BIN%\_deploy.mod.scripts.bat
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
rem -- STARTING GAME

IF %START_GAME% EQU 1 CALL:startGame
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem END
:TheEnd
call :printHeader DONE.
EXIT /B 0

rem ---------------------------------------------------------------------------
rem function block
rem ---------------------------------------------------------------------------

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

rem ---------------------------------------------------
rem error
:SomeError
echo.
echo ERROR! Something went WRONG! Please check above output.
echo.
cd /D "%DIR_EXECUTION_START%"
pause
EXIT /B 1
