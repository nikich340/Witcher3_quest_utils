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
echo -- WCC_LITE: IMPORTING MODELS %PATCHING%
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------
setlocal enableDelayedExpansion

rem ---------------------------------------------------
set MODELFILES_WILDCARD=%DIR_MODEL_FBX%\%MODEL_PREFIX%*.fbx

rem overwrite wildcard with specific id if provided
if "%MODELNAME%" NEQ "" (
  SET MODELFILES_WILDCARD=%DIR_MODEL_FBX%\%MODEL_PREFIX%%MODELNAME%.fbx
)

set COUNT=0
for %%f in (%MODELFILES_WILDCARD%) do (
    set FILENAME=%%~nf
    set MODELNAME=!FILENAME:%MODEL_PREFIX%=!

    echo.
    echo --------------------------------------------------------------------------
    echo -- WCC_LITE: IMPORT MODEL FOR !MODELNAME!
    echo --------------------------------------------------------------------------
    echo.

    PUSHD "%DIR_MODKIT_BIN%"
    %WCC_LITE% import -depot="%DIR_MODKIT_DEPOT%" -file="%DIR_MODEL_FBX%\%MODEL_PREFIX%!MODELNAME!.fbx" -out="%DIR_OUTPUT_MESHES%\!MODELNAME!.w2mesh"

    POPD
    IF %INTERACTIVE_BUILD% EQU 1 PAUSE
    set /A COUNT+=1
    IF /I "!ERRORLEVEL!" NEQ "0" GOTO:SomeError
)
echo.

if %COUNT% == 0 GOTO NoneFound

rem ---------------------------------------------------
rem -- at least one model was imported, setup followup flags

endlocal
if /I "%PATCH_MODE%" EQU "0" (
    :: full set of dependencies
    :: check if there is any world to encode
    if EXIST %DIR_DEF_WORLD%\%WORLD_DEF_PREFIX%*.yml (
        SET WCC_NAVDATA=1
        rem SET WCC_OCCLUSIONDATA=1
        rem SET WCC_ANALYZE_WORLD=1
    )
    SET WCC_ANALYZE=1
    SET WCC_COLLISIONCACHE=1
    SET WCC_COOK=1
    SET WCC_REPACK_DLC=1
)
EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! at least one import FAILED!
echo.
exit /B 1

rem ---------------------------------------------------
:NoneFound
echo no models imported. (file must be named: "%MODEL_PREFIX%<some name>.fbx")
echo.
exit /B 0
