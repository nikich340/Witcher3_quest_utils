rem --------------------------------------------------------------------------------------------------------------
rem --------------------------------------------------------------------------------------------------------------
rem --- the following settings do not need to be adjusted
rem --------------------------------------------------------------------------------------------------------------
rem --------------------------------------------------------------------------------------------------------------

rem --- settings for modkit
set DIR_MODKIT_BIN=%DIR_MODKIT%\bin\x64
set DIR_MODKIT_DEPOT=%DIR_MODKIT%\r4data

rem --- settings for encoders
rem path to repository files of encoder
set dir_repo_quests=%dir_encoder%\repo.quests
set dir_repo_worlds=%dir_encoder%\repo.worlds
set dir_repo_scenes=%dir_encoder%\repo.scenes
set dir_repo_lipsync=%dir_encoder%\repo.lipsync

rem path to data directory for phoneme extraction/generation
set dir_data_phoneme_generation=%dir_encoder%\data

rem ---------------------------------------------------
rem --- some environment settings

rem dir where all building batch files are located
set DIR_PROJECT_BIN=%DIR_PROJECT_BASE%\bin

rem path to folder hosting cooked dlc and cooked mod folders
set DIR_RESOURCES=%DIR_PROJECT_BASE%\resources\

rem lowercased modname is required for cooking with trimdir
set MODNAME_LC=%MODNAME%
call :ToLowerCase MODNAME_LC

rem ---------------------------------------------------
rem --- output directories

rem --- encode -> uncooked -> cooked -> dlc

rem tmp directory for seed files, cook db etc. will be deleted and recreated on cleanup
set DIR_TMP=%DIR_PROJECT_BASE%\_tmp

rem target root directory for all encoded files to be cooked
set DIR_UNCOOKED=%DIR_PROJECT_BASE%\uncooked

rem target root directory for all encoded mod files
set DIR_COOKED_MOD=%dir_resources%\mod%MODNAME_LC%\files

rem target root directory for all encoded dlc files
set DIR_COOKED_DLC=%dir_resources%\dlc%MODNAME_LC%\files

rem target root directory for all encoded dlc files
set DIR_COOKED_DB=%dir_tmp%\cook.db

rem game relative dlc path
SET DIR_DLC_GAMEPATH=dlc\dlc%MODNAME_LC%

rem target directory for encoded quest file
set DIR_OUTPUT_QUEST=%DIR_UNCOOKED%

rem target directory for encoded w2scene file
set DIR_OUTPUT_SCENES=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\data\scenes

rem target directory for encoded w2scene file
set DIR_OUTPUT_WORLD=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\levels

rem target directory for encoded env files
set DIR_OUTPUT_ENVS=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\data\envs

rem target directory for imported models
SET DIR_OUTPUT_MESHES=%DIR_UNCOOKED%\%DIR_DLC_GAMEPATH%\data\entities\meshes

rem path of final dlc mod
set DIR_DLC=%DIR_W3%\dlc\dlc%MODNAME%

rem path of final mod-part
set DIR_MOD=%DIR_W3%\mods\mod%MODNAME%

rem path of final tmp-mod-part
set DIR_TMP_MOD=%DIR_W3%\mods\mod%MODNAME%_tmp

rem content directory of final dlc
set DIR_DLC_CONTENT=%DIR_DLC%\content

rem content directory of final mod
set DIR_MOD_CONTENT=%DIR_MOD%\content

rem content directory of final tmp mod
set DIR_TMP_MOD_CONTENT=%DIR_TMP_MOD%\content

rem ---------------------------------------------------
rem --- script src dirs

SET DIR_MOD_SCRIPTS=%DIR_PROJECT_BASE%\mod.scripts

SET DIR_TMP_MOD_SCRIPTS=%DIR_PROJECT_BASE%\mod.scripts-tmp

rem ---------------------------------------------------
rem --- w3strings settings

rem target directory for generated strings.csv parts
set DIR_STRINGS=%DIR_PROJECT_BASE%\strings

rem prefix for generated strings.csv files which are
rem concatenated before encoding final w3strings file
set STRINGS_PART_PREFIX=strings.

set ENCODE_STRINGS=%DIR_STRINGS%\_reencode-strings.bat

rem ---------------------------------------------------
rem --- w2scene settings

rem dir with quest definition
set DIR_DEF_SCENES=%DIR_PROJECT_BASE%\definition.scenes

rem prefix used to autodetect scene yml definition
set SCENE_DEF_PREFIX=scene.

rem ---------------------------------------------------
rem --- w2quest settings

rem dir with quest definition
set DIR_DEF_QUEST=%DIR_PROJECT_BASE%\definition.quest

rem prefix for seed files
set SEEDFILE_PREFIX=seed.

rem ---------------------------------------------------
rem --- w3speech settings

rem default language
if "%language%" == "" set language=en

rem ---------------------------------------------------
rem --- w3world settings

rem dir with world definition
set DIR_DEF_WORLD=%DIR_PROJECT_BASE%\definition.world

rem prefix used to autodetect world yml definition
set WORLD_DEF_PREFIX=world.

rem ---------------------------------------------------
rem --- w3envs settings

rem dir with world definition
set DIR_DEF_ENVS=%DIR_PROJECT_BASE%\definition.envs

rem prefix used to autodetect env yml definition
set ENV_DEF_PREFIX=env.

rem ---------------------------------------------------
rem --- model import settings

rem dir with fbx models
set DIR_MODEL_FBX=%DIR_PROJECT_BASE%\models

rem prefix used to autodetect models to be imported
set MODEL_PREFIX=model.

rem ---------------------------------------------------
rem ---------------------------------------------------
rem set WCC_LITE="%DIR_MODKIT_BIN%\wcc_lite.exe"
set WCC_LITE=call "%DIR_PROJECT_BIN%\wcc_lite.bat"

rem game relative path to worlds for scanning depot
set DIR_WCC_DEPOT_WORLDS=%DIR_DLC_GAMEPATH%\levels
rem ---------------------------------------------------
rem --- default flags for build steps: do nothing
SET PATCH_MODE=1
SET FULL_REBUILD=0

SET ENCODE_WORLD=0
SET ENCODE_ENVS=0
SET ENCODE_SCENES=0
SET ENCODE_QUEST=0
SET ENCODE_STRINGS=0
SET ENCODE_SPEECH=0
SET WCC_IMPORT_MODELS=0
SET WCC_SEEDFILES=
SET WCC_COOK=0
SET WCC_OCCLUSIONDATA=0
SET WCC_NAVDATA=0
SET WCC_COLLISIONCACHE=0
rem SET WCC_SHADERCACHE=0
rem SET WCC_DEPCACHE=0
SET WCC_ANALYZE=0
SET WCC_ANALYZE_WORLD=0
SET WCC_REPACK_DLC=0
SET WCC_REPACK_MOD=0
SET DEPLOY_SCRIPTS=0
SET DEPLOY_TMP_SCRIPTS=0
SET START_GAME=0

SET COPY_TEXTURE_CACHE=0

SET ENVID=
SET SCENEID=
SET MODELNAME=

SET SETTINGS_LOADED=1
rem ---------------------------------------------------
rem reset errorlevel
exit /B 0

rem ---------------------------------------------------
:ToLowerCase
rem http://www.robvanderwoude.com/battech_convertcase.php
rem Subroutine to convert a variable VALUE to all lower case.
rem The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
exit /B 0
