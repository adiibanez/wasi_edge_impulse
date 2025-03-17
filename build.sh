'''
https://forum.edgeimpulse.com/t/wasm-standalone-inference-targeting-wasmtime-runtime/13574/3
Having looked at the options of building wasm with C++ I would like to suggest a wasi deployment target. Including some function to expose 
https://docs.edgeimpulse.com/reference/python-sdk/overview
https://github.com/WebAssembly/wasi-nn

'''


docker build -t wasi_builder .
docker run --rm -v "$(pwd):/app" wasi_builder \
bash -c "g++ --sysroot=/opt/wasi-sdk/share/wasi-sysroot -Wall -Wextra -O3  -I/app/tutorial_-continuous-motion-recognition-v63/ -o edge-impulse-standalone.wasm /app/tutorial_-continuous-motion-recognition-v63/*.cpp /app/tutorial_-continuous-motion-recognition-v63/*.c -lm  && wasmtime edge-impulse-standalone.wasm"