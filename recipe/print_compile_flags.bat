:: Compile example that links zlibwapi.lib
cl.exe /I%PREFIX%\Library\include %PREFIX%\Library\lib\zlibwapi.lib /DZLIB_WINAPI print_compile_flags.c
if errorlevel 1 exit 1

:: Run test
.\print_compile_flags.exe
if errorlevel 1 exit 1
