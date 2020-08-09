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
echo -- ENCODING STRINGS %PATCHING%
echo --------------------------------------------------------------------------
echo.

rem ---------------------------------------------------
setlocal enableDelayedExpansion

rem ---------------------------------------------------
if not exist "%DIR_OUTPUT_STRINGS%" mkdir "%DIR_OUTPUT_STRINGS%"
if not exist "%DIR_DLC_CONTENT%" mkdir "%DIR_DLC_CONTENT%"

rem ---------------------------------------------------
rem --- collect snippets into one csv file

set STRINGS_FILE_COMBINED=%DIR_STRINGS%\all.en.strings.csv
set W3_STRINGS_FILE=%STRINGS_FILE_COMBINED%.w3strings

if exist %STRINGS_FILE_COMBINED% del %STRINGS_FILE_COMBINED%
rem ---------------------------------------------------
set STRINGS_PART_WILDCARD=%DIR_STRINGS%\%STRINGS_PART_PREFIX%*.csv

echo  ^> merging strings.csv parts...
echo.
for %%f in (%STRINGS_PART_WILDCARD%) do (
  set FILENAME=%%~ff
    echo  ^>^> merging: %%~nxf
    type !FILENAME! >> %STRINGS_FILE_COMBINED%
)
echo.

rem ---------------------------------------------------
rem --- encode csv to w3strings
if NOT exist "%STRINGS_FILE_COMBINED%" GOTO NoStrings

echo  ^> encoding to w3strings...
echo.
%DIR_ENCODER%\w3strings.exe --encode "%STRINGS_FILE_COMBINED%" --id-space %IDSPACE% --auto-generate-missing-ids %LOG_LEVEL%

IF %ERRORLEVEL% NEQ 0 GOTO TheEnd

if NOT exist "%W3_STRINGS_FILE%" GOTO NoStrings

echo.
echo -- COPYING W3STRINGS INTO DLC FOLDER
echo.
FOR %%i IN ("%W3_STRINGS_FILE%") DO (set W3_STRINGS_FILENAME=%%~nxi)
echo  ^> copying %W3_STRINGS_FILENAME% to "%DIR_DLC_CONTENT%\en.w3strings"
copy "%W3_STRINGS_FILE%" "%DIR_DLC_CONTENT%\en.w3strings"

IF %ERRORLEVEL% NEQ 0 GOTO SomeError

rem ---------------------------------------------------
rem cleanup
:Cleanup
if exist "%W3_STRINGS_FILE%" del "%W3_STRINGS_FILE%"
if exist "%W3_STRINGS_FILE%.ws" del "%W3_STRINGS_FILE%.ws"
GOTO TheEnd

rem ---------------------------------------------------
rem error
:SomeError
echo.
echo ERROR! Something went WRONG! Please check above output. Strings were NOT ENCODED!
echo.
pause
GOTO Cleanup

:NoStrings
echo  ^>^> no strings found. nothing to do.
echo.
EXIT /B 0

rem ---------------------------------------------------
rem END
:TheEnd
endlocal

EXIT /B %ERRORLEVEL%
