@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

SET PATCH_MODE=0

SET ENCODE_STRINGS=1
SET START_GAME=0

call %DIR_PROJECT_BIN%\build.bat
