@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

SET INTERACTIVE_BUILD=0
:: no navdata, no collision cache generation
SET PATCH_MODE=1

SET DEPLOY_SCRIPTS=1

SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
