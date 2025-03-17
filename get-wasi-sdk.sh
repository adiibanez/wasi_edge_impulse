#!/bin/bash

# Set the WASI SDK version
WASI_SDK_VERSION=20.0

# Detect the operating system
OS=$(uname -s)
case "$OS" in
    Linux*)     PLATFORM=linux;;
    Darwin*)    PLATFORM=macos;;
    *)          echo "Unsupported platform: $OS" && exit 1;;
esac

# Set the download URL based on the platform
if [ "$PLATFORM" = "linux" ]; then
    DOWNLOAD_URL="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-linux.tar.gz"
else
    DOWNLOAD_URL="https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-20/wasi-sdk-20.0-macos.tar.gz"
fi

# Create wasi-sdk directory if it doesn't exist
mkdir -p wasi-sdk-$WASI_SDK_VERSION

# Download and extract the WASI SDK
echo "Downloading WASI SDK for $PLATFORM..."
curl -L "$DOWNLOAD_URL" | tar xz --strip-components=1 -C wasi-sdk-$WASI_SDK_VERSION

# Make sure the SDK was extracted successfully
if [ ! -d "wasi-sdk-$WASI_SDK_VERSION/bin" ]; then
    echo "Failed to extract WASI SDK"
    exit 1
fi

echo "WASI SDK $WASI_SDK_VERSION installed successfully in wasi-sdk-$WASI_SDK_VERSION/"
