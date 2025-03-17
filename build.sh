#!/bin/bash
set -e

# Set WASI SDK path
export WASI_SDK_PATH="$(pwd)/wasi-sdk-20.0"

# Create build directory
rm -rf build
mkdir -p build
cd build

# Configure with CMake using the WASI toolchain
cmake -DCMAKE_TOOLCHAIN_FILE=../wasi-toolchain.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      ..

# Build
cmake --build . -j$(nproc)

echo "Build complete! WebAssembly binary is at: build/edge_impulse.wasm"