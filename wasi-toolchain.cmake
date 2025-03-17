set(CMAKE_SYSTEM_NAME WASI)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

if(DEFINED ENV{WASI_SDK_PATH})
    set(WASI_SDK_PATH "$ENV{WASI_SDK_PATH}")
else()
    set(WASI_SDK_PATH "/opt/wasi-sdk")
endif()

set(CMAKE_C_COMPILER ${WASI_SDK_PATH}/bin/clang)
set(CMAKE_CXX_COMPILER ${WASI_SDK_PATH}/bin/clang++)
set(CMAKE_AR ${WASI_SDK_PATH}/bin/llvm-ar)
set(CMAKE_RANLIB ${WASI_SDK_PATH}/bin/llvm-ranlib)
set(CMAKE_C_COMPILER_TARGET wasm32-wasi)
set(CMAKE_CXX_COMPILER_TARGET wasm32-wasi)

# Don't look in the sysroot for executables to run during the build
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# Only look in the sysroot (not in the host paths) for libraries and headers
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -v")
