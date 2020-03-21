rem ---------------------------------------------------
rem --- check for settings
rem ---------------------------------------------------
IF %SETTINGS_LOADED% EQU 1 goto :SettingsLoaded

echo ERROR! Settings not loaded! - do not start this file directly!
EXIT /B 1
rem ---------------------------------------------------
:SettingsLoaded

rem ---------------------------------------------------
rem --- process all worlds
setlocal enableDelayedExpansion

rem ---------------------------------------------------
set WORLDPATH_WILDCARD=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels\*
set WORLDPATH=%DIR_DLC_GAMEPATH%\levels\

for /D %%f in (%WORLDPATH_WILDCARD%) do (
  set WORLDNAME=%%~nxf
  if exist %DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels\!WORLDNAME!\!WORLDNAME!.w2w (
    echo.
    echo --------------------------------------------------------------------------
    echo -- WCC_LITE: GENERATE OCCLUSIONDATA FOR !WORLDNAME!
    echo --------------------------------------------------------------------------
    echo.
    PUSHD "%DIR_MODKIT_BIN%"
    %WCC_LITE% cookocclusion -world=%WORLDPATH%!WORLDNAME!\!WORLDNAME!.w2w %WCC_VERBOSE%
    POPD
    IF %INTERACTIVE_BUILD% EQU 1 PAUSE
    IF /I "!ERRORLEVEL!" NEQ "0" GOTO:SomeError

    rem remove intermediate resuls
    rem rd /s /q "%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels\!WORLDNAME!\occlusion_tiles\intermediate_results"
  )
)
echo.

rem ---------------------------------------------------
rem END
:TheEnd

EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! Occlusiondata was NOT GENERATED!
echo.
exit /B 1
