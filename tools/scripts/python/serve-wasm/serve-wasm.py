from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self) -> None:
        self.send_header(
            "Cross-Origin-Opener-Policy",
            "same-origin",
        )
        self.send_header(
            "Cross-Origin-Embedder-Policy",
            "require-corp",
        )
        super().end_headers()

def main() -> None:
    server = ThreadingHTTPServer(("localhost", 8000), Handler)

    print("Serving WASM app at http://localhost:8000")
    print("Press Ctrl+C to stop.")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
    finally:
        server.server_close()

if __name__ == "__main__":
    main()