# Use a base image with a suitable C/C++ toolchain. Debian is a good choice.
FROM debian:bullseye-slim

# Install necessary packages.  We'll add curl, wget, git, and build-essential.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        wget \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up WASI SDK.  We download a specific release here, but you should *always*
# check for the LATEST STABLE RELEASE at https://github.com/WebAssembly/wasi-sdk/releases
# and update the URL and version number accordingly.
ARG WASI_SDK_VERSION=20
ARG WASI_SDK_URL=https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VERSION}/wasi-sdk-${WASI_SDK_VERSION}.0-linux.tar.gz

RUN mkdir -p /opt/wasi-sdk && \
    curl -L "${WASI_SDK_URL}" | tar -xzf - -C /opt/wasi-sdk --strip-components=1

# Set environment variables.  These make it easy to use the WASI SDK.
ENV CC=/opt/wasi-sdk/bin/clang
ENV CXX=/opt/wasi-sdk/bin/clang++
ENV AR=/opt/wasi-sdk/bin/llvm-ar
ENV RANLIB=/opt/wasi-sdk/bin/llvm-ranlib
ENV WASI_SDK_PATH=/opt/wasi-sdk
ENV PATH="$PATH:/opt/wasi-sdk/bin"
ENV CFLAGS="--sysroot=/opt/wasi-sdk/share/wasi-sysroot"
ENV CXXFLAGS="$CFLAGS"
ENV LDFLAGS=""

# Install wasmtime (for testing within the container; optional)
# You can comment this out if you'll only be compiling, not running, inside Docker.
RUN curl https://wasmtime.dev/install.sh -sSf | bash
ENV PATH="$PATH:/root/.wasmtime/bin"


# Create a working directory for the build.
WORKDIR /app

# Copy the Edge Impulse source code into the container.
# Assuming your EI source is in a directory named 'edge-impulse-src'.
#COPY edge-impulse-src/ /app/edge-impulse-src/
#COPY  ./ /app

# The build command will be provided when you run the container.

# Example of a build command you might use (inside the container):
#  clang++ --sysroot=/opt/wasi-sdk/share/wasi-sysroot -Wall -Wextra -O3 -I/app/edge-impulse-src/ -o my_model.wasm /app/edge-impulse-src/*.cpp -lm