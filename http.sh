import "tcp@0.0.2"

SERVER="$(print=1 import "./server.sh")"
chmod +x "$SERVER"

http_server() {
  tcp_server "$SERVER" "$@"
}
