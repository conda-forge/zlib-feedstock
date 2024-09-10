#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -fPIC"
export CXXFLAGS="${CXXFLAGS} -fPIC"

# upstream CMake build has no toggle to _only_ switch off man pages;
# install them in a location that conda-build won't pick up
mkdir -p $RECIPE_DIR/ignored

mkdir build
cd build

if [[ ${cross_target_platform} == emscripten-* ]]; then
    # derived from zlib-recipe in emscripten-forge, see
    # https://github.com/emscripten-forge/recipes/blob/989e8506ffaa3a24dccd49733c4454fadaf34b02/recipes/recipes_emscripten/zlib
    export CMAKE_ARGS="$CMAKE_ARGS -DZLIB_BUILD_EXAMPLES=OFF"
    # https://github.com/emscripten-core/emscripten/issues/15276
    export CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_PROJECT_INCLUDE=$RECIPE_DIR/overwriteProp.cmake"
fi

cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DINSTALL_MAN_DIR=$RECIPE_DIR/ignored \
    -DINSTALL_PKGCONFIG_DIR=$PREFIX/lib/pkgconfig \
    ..

cmake --build .

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" && "${CROSSCOMPILING_EMULATOR}" == "" ]]; then
    ctest --progress --output-on-failure
fi

cmake --install .
