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

del /f /q CMakeCache.txt

:: Now build regular zlib.
:: Configure.
cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      %SRC_DIR%
if errorlevel 1 exit 1

type CMakeCache.txt

:: Build.
cmake --build %SRC_DIR% --target INSTALL --config Release --clean-first
if errorlevel 1 exit 1

:: Test.
ctest
if errorlevel 1 exit 1

:: Some OSS libraries are happier if z.lib exists, even though it's not typical on Windows.
copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\z.lib || exit 1

:: Qt in particular goes looking for this one (as of 4.8.7).
copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\zdll.lib || exit 1

:: Copy license file to the source directory so conda-build can find it.
copy %RECIPE_DIR%\license.txt %SRC_DIR%\license.txt || exit 1

:: python>=3.10 depend on this being at %PREFIX%
copy %LIBRARY_BIN%\zlib.dll %PREFIX%\zlib.dll || exit 1
