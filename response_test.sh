#!/bin/bash
set -euo pipefail
. "$(which import)"
import "assert@2.1.3"
. "./response.sh"


assert_equal "$(http_response_code 201)" $'\1'"C201"
assert_equal "$(http_response_code 404)" $'\1'"C404"


assert_equal "$(http_response_header "X-Foo:bar:baz")" $'\1'"HX-Foo bar:baz"
assert_equal "$(http_response_header "X-Foo: bar:baz")" $'\1'"HX-Foo bar:baz"
assert_equal "$(http_response_header "X-Foo" "bar:baz")" $'\1'"HX-Foo bar:baz"
assert_equal "$(http_response_header "X-Foo" "bar" "baz")" $'\1'"HX-Foo bar baz"


GATEWAY_INTERFACE=CGI/1.1
HTTPS=on
HTTP_ACCEPT=text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
HTTP_ACCEPT_ENCODING=gzip
HTTP_ACCEPT_LANGUAGE=en-US,en;q=0.5
HTTP_CONNECTION=Keep-Alive
HTTP_HOST=example.com
HTTP_UPGRADE_INSECURE_REQUESTS=1
HTTP_CONTENT_LENGTH=6
HTTP_USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:63.0) Gecko/20100101 Firefox/63.0"
HTTP_X_FORWARDED_PROTO=https
LD_LIBRARY_PATH=/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
PATH=/usr/local/bin:/usr/bin/:/bin:/opt/bin
PATH_INFO=/
PWD=/var/task
QUERY_STRING=
REMOTE_ADDR=
REMOTE_HOST=
REQUEST_METHOD=GET
REQUEST_URI=/
SCRIPT_NAME=/env.sh
SERVER_NAME=
SERVER_PORT=443
SERVER_PROTOCOL=HTTP/1.1
SERVER_SOFTWARE=import/http

serve() {
  http_response_code 201
  http_response_header "X-Foo: bar baz"
  echo hi
}

echo input | http_response_parse_body | serve | http_response_flush
