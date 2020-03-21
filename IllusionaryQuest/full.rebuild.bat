@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call _settings_.bat

rem ---------------------------------------------------

SET INTERACTIVE_BUILD=0
SET PATCH_MODE=0
SET FULL_REBUILD=1
SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
