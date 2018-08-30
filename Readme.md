# http

An HTTP server written in Bash.


## Example

Launch a "Hello World" HTTP server:

```bash
#!/usr/bin/env import -s bash
import http@0.0.1

http_server echo hello world
```

```
$ curl localhost:3000
hello world
```


## Credits

HTTP server implementation is based off of
[`avleen/bashttpd`](https://github.com/avleen/bashttpd).
