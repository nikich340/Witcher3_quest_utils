@echo off
rem ---------------------------------------------------
rem --- settings
rem ---------------------------------------------------
call _settings_.bat

rem ---------------------------------------------------

if not exist "%DIR_TMP%" mkdir "%DIR_TMP%"
%DIR_ENCODER%\logfilter.exe --log-file "%USERPROFILE%\Documents\The Witcher 3\scriptslog.txt" --output-dir "%DIR_TMP%" --conf-file "%DIR_PROJECT_BIN%\logfilter-scriptlog-config.toml"
