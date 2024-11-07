#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -fPIC"
export CXXFLAGS="${CXXFLAGS} -fPIC"

# upstream CMake build has no toggle to _only_ switch off man pages;
# install them in a location that conda-build won't pick up
mkdir -p $RECIPE_DIR/ignored

mkdir build
cd build

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
