rem ---------------------------------------------------
rem --- check for settings
rem ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1
rem ---------------------------------------------------
:SettingsLoaded

if not exist "%DIR_TMP%" mkdir "%DIR_TMP%"

rem ---------------------------------------------------
rem --- process all worlds IF any world was generated

if %ENCODE_WORLD% EQU 1 GOTO:AnalyzeWorld
if %WCC_ANALYZE_WORLD% EQU 1 GOTO:AnalyzeWorld
GOTO :NextAnalyze

:AnalyzeWorld
setlocal enableDelayedExpansion

rem ---------------------------------------------------
set WORLDPATH_WILDCARD=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels\*
set WORLDPATH=%DIR_DLC_GAMEPATH%\levels\

for /D %%f in (%WORLDPATH_WILDCARD%) do (
  set WORLDNAME=%%~nxf
  if exist %DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels\!WORLDNAME!\!WORLDNAME!.w2w (
    echo.
    echo --------------------------------------------------------------------------
    echo -- WCC_LITE: ANALYZE WORLD FOR !WORLDNAME!
    echo --------------------------------------------------------------------------
    echo.
    PUSHD "%DIR_MODKIT_BIN%"
    %WCC_LITE% analyze world %WORLDPATH%!WORLDNAME!\!WORLDNAME!.w2w -out="%DIR_TMP%\%SEEDFILE_PREFIX%world.!WORLDNAME!.files" %WCC_VERBOSE%
    POPD
    IF %INTERACTIVE_BUILD% EQU 1 PAUSE
    IF /I "!ERRORLEVEL!" NEQ "0" GOTO:SomeError
  )
)
echo.
endlocal

:NextAnalyze
rem ---------------------------------------------------
rem --- process dlc IF something changed
if %ENCODE_QUEST% EQU 1 GOTO:AnalyzeDLC
if %WCC_IMPORT_MODELS% EQU 1 GOTO:AnalyzeDLC
GOTO :TheEnd

:AnalyzeDLC
echo.
echo --------------------------------------------------------------------------
echo -- WCC_LITE: ANALYZE DLC
echo --------------------------------------------------------------------------
echo.
PUSHD "%DIR_MODKIT_BIN%"
%WCC_LITE% analyze r4dlc -dlc="%DIR_DLC_GAMEPATH%\dlc%MODNAME%.reddlc" -out="%DIR_TMP%\%SEEDFILE_PREFIX%dlc%MODNAME%.files"
POPD
echo.

IF %INTERACTIVE_BUILD% EQU 1 PAUSE
IF /I "%ERRORLEVEL%" NEQ "0" GOTO:SomeError

rem ---------------------------------------------------
rem END
:TheEnd

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! one or more seed files were NOT GENERATED!
echo.
exit /B 1
