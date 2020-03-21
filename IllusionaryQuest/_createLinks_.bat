@echo off
rem Creates linked folders in r4data directory.
echo --------------------------------------------------------------------------
echo -- LINKING PROJECT to MODKIT DEPOT
echo --------------------------------------------------------------------------
echo.
if not exist ".\_settings_.bat" (
	echo ERROR! _settings_.bat was not found!
	echo.
	echo 1. rename _settings_.bat-template from project template to _settings_.bat
	echo 2. make sure _settings_.bat is in the root folder of the new project
	echo 3. adjust the paths in the _settings_.bat
	echo 4. run this script again
	echo.
	pause
	EXIT /b
)
call _settings_.bat
echo.

if exist ".\_settings_.bat" (
	echo --------------------------------------------------------------------------
	echo Should the following paths be linked?
	echo.
	echo 1. "%DIR_MODKIT_DEPOT%\dlc\dlc%MODNAME%"
	echo  to
	echo    "%DIR_UNCOOKED%\dlc\dlc%MODNAME%"
	echo.
	echo and
	echo.
	echo 2. "%DIR_MODKIT_DEPOT%\scripts\dlc%MODNAME%"
	echo  to
	echo    "%DIR_MOD_SCRIPTS%"
	echo.
	echo --------------------------------------------------------------------------
	CHOICE
)

SET input=%ERRORLEVEL%
IF %input% EQU 1 (
	:CreateLinks
	mklink /J "%DIR_MODKIT_DEPOT%\dlc\dlc%MODNAME%" "%DIR_UNCOOKED%\dlc\dlc%MODNAME%"
	echo.

	mklink /J "%DIR_MODKIT_DEPOT%\scripts\dlc%MODNAME%" "%DIR_MOD_SCRIPTS%"
	echo.
	echo links successfully created.
	echo.
	pause
	EXIT /b
)
IF %input% EQU 2 (
	echo.
	echo link creation canceled.
	echo.
	pause
	EXIT /b
)

