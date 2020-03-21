@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call ../_settings_.bat

rem ---------------------------------------------------

SET MODELNAME=bridge_only_tri

SET INTERACTIVE_BUILD=0
:: no navdata, no collision cache generation
SET PATCH_MODE=1

if EXIST %DIR_DEF_WORLD%\%WORLD_DEF_PREFIX%*.yml (
  SET WCC_NAVDATA=1
  rem SET WCC_OCCLUSIONDATA=1
  SET WCC_ANALYZE_WORLD=1
)
SET WCC_ANALYZE=1
SET WCC_COOK=1
SET WCC_REPACK_DLC=1
SET WCC_COLLISIONCACHE=1

SET WCC_IMPORT_MODELS=1
SET START_GAME=1

call %DIR_PROJECT_BIN%\build.bat
