@ECHO OFF

REM format libsaki

CD libsaki
SET FILES=
FOR /F %%i IN ('..\bin\show_changes.bat') DO SET FILES=%%i
IF NOT [%FILES%] == [] (
  ECHO Format: %FILES%
  ..\bin\uncrustify.exe -c ..\uncrustify.cfg --no-backup %FILES%
)
CD ..

REM format mjpancake

SET FILES=
FOR /F %%i IN ('.\bin\show_changes.bat') DO SET FILES=%%i
IF NOT [%FILES%] == [] (
  ECHO Format: %FILES%
  .\bin\uncrustify.exe -c .\uncrustify.cfg --no-backup %FILES%
)

ECHO Haha, formatted!

