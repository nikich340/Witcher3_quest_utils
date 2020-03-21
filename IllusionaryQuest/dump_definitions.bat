@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call _settings_.bat

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
echo -- DUMPING DATA FROM CR2W
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------

%DIR_ENCODER%\w2quest.exe --repo-dir "%DIR_REPO_QUESTS%" --output-dir "%DIR_TMP%" --dump-data "%1" %2

IF %ERRORLEVEL% NEQ 0 GOTO SomeError
exit /B 0

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! Data was NOT dumped
echo.
exit /B 1
