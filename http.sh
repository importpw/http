import tcp@0.0.2

BASHTTPD=$(print=1 import ./bashttpd.sh)
chmod +x "$BASHTTPD"

http_server() {
  tcp_server "$BASHTTPD" "$@"
}
