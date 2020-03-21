@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

:: a specific scene can be encoded if sceneid is specified (filename without
:: "scene." prefix and extension, e.g. SCENEID=1.examine.corpse for the
:: file "scene.1.examine.corpse.yml"
:: an empty sceneid is identical to SCENEID=scene.*.yml wildcard and will encode
:: all scenes matching
SET SCENEID=

SET INTERACTIVE_BUILD=0
:: auto execution of every step that is needed (strings, etc)
SET PATCH_MODE=1

SET ENCODE_STRINGS=1
SET WCC_REPACK_DLC=1

SET ENCODE_SCENES=1
SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
