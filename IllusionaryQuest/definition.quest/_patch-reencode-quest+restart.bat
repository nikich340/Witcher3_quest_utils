@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

SET INTERACTIVE_BUILD=0
SET PATCH_MODE=1

SET WCC_ANALYZE=1
SET WCC_COOK=1
SET WCC_REPACK_DLC=1

SET ENCODE_STRINGS=1

SET ENCODE_QUEST=1
SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
