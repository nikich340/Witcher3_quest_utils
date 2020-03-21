@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

echo.
echo --------------------------------------------------------------------------
echo -- GENERATING PHONEMES FROM TEXT STRINGS
echo --------------------------------------------------------------------------
echo.

%DIR_ENCODER%\w3speech-phoneme-extractor.exe --data-dir "%DIR_DATA_PHONEME_GENERATION%" --generate-from-text-only --strings-file "%DIR_SPEECH%\mod%MODNAME%.speech.csv" --output-dir "%DIR_PHONEMES%" --language %language% %loglevel%
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

echo.
echo --------------------------------------------------------------------------
echo -- GENERATING PLACEHOLDER AUDIO
echo --------------------------------------------------------------------------
echo.

%DIR_ENCODER%\w3speech-lipsync-creator.exe --create-lipsync "%DIR_PHONEMES%\*.phonemes" --output-dir "%DIR_AUDIO_WEM%" --repo-dir "%DIR_REPO_LIPSYNC%" --generate-placeholder-audio "%DIR_ENCODER%\template.wem-silence/-stringid-[0.1].silence.wem" %loglevel%
IF %ERRORLEVEL% NEQ 0 GOTO SomeError

:TheEnd
EXIT /B %ERRORLEVEL%

rem ---------------------------------------------------
rem error
:SomeError
echo.
echo ERROR! Something went WRONG! Please check above output.
echo.
EXIT /B 1
