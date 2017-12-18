#!/bin/sh

# format libsaki
cd libsaki
FILES=`git ls-files -mo --exclude-standard | grep "\.cpp\|\.h"`
if [ ! -z ${FILES} ]; then
  echo "Format:" ${FILES}
  ../bin/uncrustify.exe -c ../uncrustify.cfg --no-backup ${FILES}
fi
cd ..

# format client
FILES=`git ls-files -mo --exclude-standard | grep "\.cpp\|\.h"`
if [ ! -z "${FILES}" ]; then
  echo "Format:" ${FILES}
  ./bin/uncrustify.exe -c ./uncrustify.cfg --no-backup ${FILES}
fi

echo "Haha, formatted!"

