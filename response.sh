_http_response_control_sequence=$'\1'

bytes_read() {
  local _c
  LANG=C IFS= read -r -d '' -n "$1" _c
  printf "%s" "${_c}"
}

# Set the response status code.
# MUST be called *before* any output is generated by your script.
http_response_status_code() {
  echo "${_http_response_control_sequence}C$1"
}

# Sets a response header.
# MUST be called *before* any output is generated by your script.
http_response_set_header() {
  local header="$1"
  shift
  if [ $# -ne 0 ]; then
    header="$header $*"
  fi
  echo "${_http_response_control_sequence}H${header}"
}

http_response_parse_body() {
  local length
  length="${HTTP_CONTENT_LENGTH-}"
  if [ -n "${length}" ]; then
    #debug "Reading ${length} byte request body"
    bytes_read "${length}"
  else
    local encoding="${HTTP_TRANSFER_ENCODING-}"
    if [ "${encoding}" = "chunked" ]; then
      while IFS='' read -r line; do
        line=${line%%$'\r'}
        #debug "$line"

        length="$(printf "%d" "0x${line%%$'\n'}")"

        if [ "${length}" -gt 0 ]; then
          #debug "Reading ${length} byte chunk"
          bytes_read "${length}"

          # The next two bytes are supposed to be '\r\n'
          #debug "Reading 2 byte end"
          # TODO: add verification
          bytes_read 2 > /dev/null
          #debug "Done with chunk"
        else
          #debug "Done reading chunked body"
          break
        fi
      done
    fi
  fi
}

http_response_flush() {
  # Wait for response code and header "events" from stdin
  local buf
  local name
  local code=200
  declare -A headers
  headers["date"]="$(date +"%a, %d %b %Y %H:%M:%S %Z")"
  while true; do
    buf="$(bytes_read "${#_http_response_control_sequence}")"
    #debug "buf: $(printf "%x " "'${buf}") ${#buf}"
    if [ "${buf}" = "${_http_response_control_sequence}" ]; then
      IFS='' read -r line
      line=${line%%$'\r'}
      #debug "line: ${line}"
      local cmd="${line:0:1}"
      local data="${line:1}"
      case "${cmd}" in
        C)
          code="${data}"
          ;;
        H)
          name="$(echo "$data" | cut -d' ' -f1)"
          headers["$name"]="$(echo "$data" | awk '{$1= ""; print $0}')"
          ;;
      esac
    else
      break
    fi
  done

  # Write the CGI response header
  echo "Status: $code"
  for name in "${!headers[@]}"; do
    echo "$name: ${headers["$name"]}"
  done
  echo

  # Flush any buffer and the rest of stdin as the HTTP response body
  printf "%s" "${buf}"
  cat
}