cmake_minimum_required(VERSION 3.13.1)
project(wasi_edge_impulse)

# Set C++ standard and flags
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add WASI sysroot include paths
include_directories(SYSTEM 
    ${CMAKE_CURRENT_SOURCE_DIR}/wasi-sdk-20.0/share/wasi-sysroot/include/c++/v1
    ${CMAKE_CURRENT_SOURCE_DIR}/wasi-sdk-20.0/share/wasi-sysroot/include/wasm32-wasi
    ${CMAKE_CURRENT_SOURCE_DIR}/wasi-sdk-20.0/share/wasi-sysroot/include
)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-entry -Wl,--export-all")

add_executable(app)

include(edge-impulse-sdk/cmake/utils.cmake)
add_subdirectory(edge-impulse-sdk/cmake/zephyr)

RECURSIVE_FIND_FILE_APPEND(MODEL_SOURCE "tflite-model" "*.cpp")
target_include_directories(app PRIVATE .)

target_compile_definitions(app PRIVATE
    EI_CLASSIFIER_TFLITE=1
    NDEBUG
    EI_DSP_IMAGE_BUFFER_STATIC_SIZE=128
)

# Add Edge Impulse SDK sources with WASI porting layer
target_sources(app PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/edge-impulse-sdk/porting/wasi/ei_classifier_porting.cpp
)

# Add main sources
target_sources(app PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
    ${MODEL_SOURCE}
)

# Add remaining Edge Impulse SDK sources
RECURSIVE_FIND_FILE_APPEND(EI_SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/edge-impulse-sdk" "*.cpp")
RECURSIVE_FIND_FILE_APPEND(EI_SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/edge-impulse-sdk" "*.cc")
RECURSIVE_FIND_FILE_APPEND(EI_SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/edge-impulse-sdk/CMSIS/NN/Source" "*.c")
LIST(APPEND EI_SOURCE_FILES "${CMAKE_CURRENT_SOURCE_DIR}/edge-impulse-sdk/tensorflow/lite/c/common.c")

target_sources(app PRIVATE ${EI_SOURCE_FILES})