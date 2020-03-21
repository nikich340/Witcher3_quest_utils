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
echo -- ENCODING SPEECH %PATCHING%
echo --------------------------------------------------------------------------
echo.
echo  ^>^> GENERATING LIPSYNC ANIMATIONS
echo.

%DIR_ENCODER%\w3speech-lipsync-creator.exe --create-lipsync "%DIR_PHONEMES%\*.phonemes" --output-dir "%DIR_AUDIO_WEM%" --repo-dir "%DIR_REPO_LIPSYNC%" %loglevel%

IF %ERRORLEVEL% NEQ 0 GOTO SomeError

echo --------------------------------------------------------------------------
echo  ^>^> ENCODING LIPSYNC ANIMATIONS TO CR2W
echo.

%DIR_ENCODER%\w3speech.exe --encode-cr2w "%DIR_AUDIO_WEM%" %loglevel%

IF %ERRORLEVEL% NEQ 0 GOTO SomeError

echo --------------------------------------------------------------------------
echo  ^>^> CREATING W3SPEECH FILE
echo.

%DIR_ENCODER%\w3speech.exe --pack-w3speech "%DIR_AUDIO_WEM%" --output-dir "%DIR_DLC_CONTENT%" --script-prefix "%MODNAME_LC%" --script-output-dir "%DIR_TMP_MOD_SCRIPTS%\local" --strings-file "%DIR_STRINGS%\all.en.strings.csv" --language %language% %loglevel%

IF %ERRORLEVEL% NEQ 0 GOTO SomeError

echo --------------------------------------------------------------------------
echo ^>^> UPDATING DLC W3SPEECH FILE
echo.

rem name of the final speech file
set w3speech_file=%language%pc.w3speech

set speech_packed_file=%DIR_DLC_CONTENT%\speech.%language%.w3speech.packed
set speech_final_file=%DIR_DLC_CONTENT%\%w3speech_file%

if exist "%speech_final_file%" del "%speech_final_file%"
rename "%speech_packed_file%" "%w3speech_file%"

exit /b 0

rem ---------------------------------------------------
:SomeError
echo.
echo ERROR! Something went WRONG! Speech files were NOT ENCODED!
echo.
exit /B 1
