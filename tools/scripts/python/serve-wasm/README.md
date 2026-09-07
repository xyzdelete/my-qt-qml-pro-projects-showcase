# WASM Local Server

Small local HTTP server for testing the Qt WebAssembly build with
WebAssembly threads / pthreads.

## Why this is needed

The Qt WebAssembly application is built with Emscripten pthread support.

Pthread-enabled WebAssembly uses `SharedArrayBuffer`, which requires the
web page to be cross-origin isolated.

Opening the generated HTML directly with `file://` does not provide a
normal HTTP origin and will prevent the application from creating its
Web Workers.

This server adds the required response headers:

- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`

## Usage

First build the WebAssembly application.

Then change to the generated `Release` directory.

Run `python C:\path\to\serve-wasm.py`

Open the application:

http://localhost:8000/index.html
