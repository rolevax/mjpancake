REM format libsaki

cd libsaki
FOR /F "tokens=* USEBACKQ" %%F IN (`git ls-files -mo --exclude-standard | findstr "\.cpp \.h"`) DO (
  SET FILES=%%F
)
IF NOT %FILES% == "" (
  echo "Format:" %FILES%
  ..\bin\uncrustify.exe -c ..\uncrustify.cfg --no-backup ${FILES}
)
cd ..

REM format client
FOR /F "tokens=* USEBACKQ" %%F IN (`git ls-files -mo --exclude-standard | findstr "\.cpp \.h"`) DO (
  SET FILES=%%F
)
IF NOT %FILES% == "" (
  echo "Format:" %FILES%
  .\bin\uncrustify.exe -c .\uncrustify.cfg --no-backup ${FILES}
)

echo "Haha, formatted!"

