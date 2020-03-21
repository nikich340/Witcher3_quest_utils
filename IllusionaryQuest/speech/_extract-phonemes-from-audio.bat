@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

echo.
echo --------------------------------------------------------------------------
echo -- EXTRACTING PHONEMES FROM AUDIO
echo --------------------------------------------------------------------------
echo.

SET THREADS=1

%DIR_ENCODER%\w3speech-phoneme-extractor.exe --worker-threads "%THREADS%" --data-dir "%DIR_DATA_PHONEME_GENERATION%" --audio-dir "%DIR_AUDIO_WAV%" --strings-file "%DIR_SPEECH%\mod%MODNAME%.speech.csv" --language %language% %loglevel%

:TheEnd
