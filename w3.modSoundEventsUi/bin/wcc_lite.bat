echo ^>^> DBG: wcc_lite.exe %*
"%DIR_MODKIT_BIN%\wcc_lite.exe" %* %WCC_GLOBAL_OPTIONS% -silent
SET WCC_ERROR=%ERRORLEVEL%

%DIR_ENCODER%\logfilter.exe --silent --conf-file "%DIR_ENCODER%\logfilter-wcc-config.toml" --dont-watch --log-file "%DIR_MODKIT_BIN%\..\wcc.log" --output-dir "%DIR_PROJECT_BASE%/"

EXIT /B %WCC_ERROR%
