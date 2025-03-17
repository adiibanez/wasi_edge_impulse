# Use a base image with a suitable C/C++ toolchain
FROM --platform=linux/amd64 debian:bullseye-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        wget \
        git \
        ca-certificates \
        make \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the entire project
COPY . .

# Install WASI SDK
RUN bash get-wasi-sdk.sh && \
    ln -s /app/wasi-sdk-20.0 /app/wasi-sdk-20.0

# Set environment variables for the build
ENV WASI_SDK_PATH=/app/wasi-sdk-20.0

# Build the project
RUN make clean && make

# Install wasmtime for testing
RUN curl https://wasmtime.dev/install.sh -sSf | bash
ENV PATH="$PATH:/root/.wasmtime/bin"

# Default command - you can override this when running the container
CMD ["wasmtime", "build/app.wasm"]