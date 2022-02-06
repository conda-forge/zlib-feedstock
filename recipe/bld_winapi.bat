set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%

:: Configure.
:: -DZLIB_WINAPI switches to WINAPI calling convention. See Q7 in DLL_FAQ.txt.
cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_C_FLAGS="-DZLIB_WINAPI " ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build %SRC_DIR% --config Release
if errorlevel 1 exit 1

:: Test.
ctest
if errorlevel 1 exit 1

:: Copy built zlib.dll with the same name provided by http://www.winimage.com/zLibDll/
:: This is needed for example for cuDNN
:: https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#install-zlib-windows
copy "zlib.dll" "%LIBRARY_BIN%\zlibwapi.dll" || exit 1
copy "zlib.lib" "%LIBRARY_LIB%\zlibwapi.lib" || exit 1
