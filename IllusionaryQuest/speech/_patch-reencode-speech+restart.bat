@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

:: auto execution of every step that is needed (strings, etc)
SET PATCH_MODE=1

SET ENCODE_SPEECH=1
SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
