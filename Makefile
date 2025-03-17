# Check if WASI_SDK_PATH is set
ifndef WASI_SDK_PATH
$(error WASI_SDK_PATH is not set. Please set it to the path of your WASI SDK installation)
endif

# Tool macros
CC = $(WASI_SDK_PATH)/bin/clang
CXX = $(WASI_SDK_PATH)/bin/clang++

# Settings
NAME = app
BUILD_PATH = ./build

# Location of main.cpp (must use C++ compiler for main)
CXXSOURCES = src/main.cpp

# WASI specific flags
CFLAGS += --target=wasm32-wasi
CFLAGS += --sysroot=$(WASI_SDK_PATH)/share/wasi-sysroot

# Search path for header files
CFLAGS += -I.
CFLAGS += -I$(WASI_SDK_PATH)/share/wasi-sysroot/include

# C and C++ Compiler flags
CFLAGS += -Wall						# Include all warnings
CFLAGS += -g						# Generate GDB debugger information
CFLAGS += -Wno-strict-aliasing		# Disable warnings about strict aliasing
CFLAGS += -Os						# Optimize for size
CFLAGS += -DNDEBUG					# Disable assert() macro
CFLAGS += -DEI_CLASSIFIER_ENABLE_DETECTION_POSTPROCESS_OP	# Add TFLite_Detection_PostProcess operation

# C++ only compiler flags
CXXFLAGS += -std=c++14				# Use C++14 standard

# Linker flags
LDFLAGS += -Wl,--no-entry -Wl,--export-all
LDFLAGS += -nostartfiles
LDFLAGS += -Wl,--allow-undefined
LDFLAGS += -lstdc++
LDFLAGS += -Wl,--export=run_model_inference
LDFLAGS += -Wl,--export=get_model_parameters_json
LDFLAGS += -Wl,--export=get_labels

# Include C source code for required libraries
CSOURCES += $(wildcard edge-impulse-sdk/CMSIS/DSP/Source/TransformFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/CommonTables/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/BasicMathFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/ComplexMathFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/FastMathFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/SupportFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/MatrixFunctions/*.c) \
			$(wildcard edge-impulse-sdk/CMSIS/DSP/Source/StatisticsFunctions/*.c)

# Include C++ source code for required libraries
CXXSOURCES += 	$(wildcard tflite-model/*.cpp) \
				$(wildcard edge-impulse-sdk/dsp/kissfft/*.cpp) \
				$(wildcard edge-impulse-sdk/dsp/dct/*.cpp) \
				$(wildcard edge-impulse-sdk/dsp/memory.cpp) \
				$(wildcard edge-impulse-sdk/porting/wasi/*.cpp)

# Use LiteRT (previously Tensorflow Lite) for Microcontrollers (TFLM)
CFLAGS += -DTF_LITE_DISABLE_X86_NEON=1
CSOURCES +=	edge-impulse-sdk/tensorflow/lite/c/common.c
CCSOURCES +=	$(wildcard edge-impulse-sdk/tensorflow/lite/kernels/*.cc) \
				$(wildcard edge-impulse-sdk/tensorflow/lite/kernels/internal/*.cc) \
				$(wildcard edge-impulse-sdk/tensorflow/lite/micro/kernels/*.cc) \
				$(wildcard edge-impulse-sdk/tensorflow/lite/micro/*.cc) \
				$(wildcard edge-impulse-sdk/tensorflow/lite/micro/memory_planner/*.cc) \
				$(wildcard edge-impulse-sdk/tensorflow/lite/core/api/*.cc)

# Generate names for the output object files (*.o)
COBJECTS := $(patsubst %.c,%.o,$(CSOURCES))
CXXOBJECTS := $(patsubst %.cpp,%.o,$(CXXSOURCES))
CCOBJECTS := $(patsubst %.cc,%.o,$(CCSOURCES))

# Default rule
.PHONY: all
all: app

# Compile library source code into object files
$(COBJECTS) : %.o : %.c
$(CXXOBJECTS) : %.o : %.cpp
$(CCOBJECTS) : %.o : %.cc
%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@
%.o: %.cc
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $^ -o $@
%.o: %.cpp
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $^ -o $@

# Build target (must use C++ compiler)
.PHONY: app
app: $(COBJECTS) $(CXXOBJECTS) $(CCOBJECTS)
ifeq ($(OS), Windows_NT)
	if not exist build mkdir build
else
	mkdir -p $(BUILD_PATH)
endif
	$(CXX) $(COBJECTS) $(CXXOBJECTS) $(CCOBJECTS) -o $(BUILD_PATH)/$(NAME) $(LDFLAGS)

# Remove compiled object files
.PHONY: clean
clean:
ifeq ($(OS), Windows_NT)
	del /Q $(subst /,\,$(patsubst %.c,%.o,$(CSOURCES))) >nul 2>&1 || exit 0
	del /Q $(subst /,\,$(patsubst %.cpp,%.o,$(CXXSOURCES))) >nul 2>&1 || exit 0
	del /Q $(subst /,\,$(patsubst %.cc,%.o,$(CCSOURCES))) >nul 2>&1 || exit 0
else
	rm -f $(COBJECTS)
	rm -f $(CCOBJECTS)
	rm -f $(CXXOBJECTS)
endif