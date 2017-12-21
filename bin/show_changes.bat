@echo OFF
git ls-files -mo --exclude-standard | findstr "\.cpp \.h"



