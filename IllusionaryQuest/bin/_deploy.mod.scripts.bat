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
echo -- DEPLOYING MOD %PATCHING%
echo --------------------------------------------------------------------------
echo.

if NOT exist "%DIR_MOD%" GOTO :DeployFiles
rem ---------------------------------------------------
echo  ^> deleting ALL files in "%DIR_MOD_CONTENT%\scripts"
if %auto_delete_mod%==YES goto :DeleteModDir

:Confirmation
set /P c=Are you sure you want to continue[Y/N]?
if /I "%c%" EQU "Y" goto :DeleteModDir
if /I "%c%" EQU "N" goto :Cancel
GOTO :Confirmation

:DeleteModDir
rem DELETES SILENTLY ALL FILES!
rd /s /q "%DIR_MOD_CONTENT%\scripts"
echo .
echo  ^> ALL FILES DELETED
echo .

:DeployFiles
echo  ^> copying files to "%DIR_MOD%"
robocopy "%DIR_MOD_SCRIPTS%" "%DIR_MOD_CONTENT%\scripts" /s /e /NFL /NJH
echo  ^> mod deployed.
echo.

if %ERRORLEVEL% EQU 0 EXIT /B 0
:: One or more files were copied successfully (that is, new files have arrived).
if %ERRORLEVEL% EQU 1 EXIT /B 0
:: Some Extra files or directories were detected.
if %ERRORLEVEL% EQU 2 EXIT /B 0
:: (2+1) Some files were copied. Additional files were present. No failure was encountered.
if %ERRORLEVEL% EQU 3 EXIT /B 0
:: something else happened
EXIT /B %ERRORLEVEL%

:Cancel
echo ^>^> deploy canceled...
exit /B 1
