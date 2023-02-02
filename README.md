# goimg

Small Go image to use when CGO isn't needed.

* Runs as a non-root user by default.
* CA certificates are pulled from the [Common CA Database](https://www.ccadb.org/).
* Time Zone database is pulled from the Go image (`zoneinfo.zip`).
* Less than 1MB.
* Home and temp directories are available.
* You must use `CGO_ENABLED=0` to build, because no OS libraries are present.

## Use the Image

The image is tagged with the major Go version because that indicates which `zoneinfo.zip` is included.

    docker pull ancientlore/goimg:1.20

Presumably you would put your Go binary into `/usr/bin` or `/bin`. A sample Dockerfile might be:

    FROM golang:1.20 as builder
    COPY . /go/test
    WORKDIR /go/test
    RUN CGO_ENABLED=0 go build -o /go/bin/test

    FROM ancientlore/goimg:1.20
    COPY --from=builder /go/bin/test /usr/bin/test
    CMD [ "/usr/bin/test"]

## Groups

| ID    | Name    |
|-------|---------|
| 0     | root    |
| 65532 | nonroot |

## Users

| ID    | Name    | Default |
|-------|---------|---------|
| 0     | root    | No      |
| 65532 | nonroot | Yes     |

## File System

| Mode         | Group | User  | Size   | Path                              |
|--------------|-------|-------|--------|-----------------------------------|
| `drwxr-xr-x` | 0     | 0     |      0 | bin/                              |
| `drwxr-xr-x` | 0     | 0     |      0 | etc/                              |
| `-rw-r--r--` | 0     | 0     |     27 | etc/group                         |
| `-rw-r--r--` | 0     | 0     |     91 | etc/passwd                        |
| `drwxr-xr-x` | 0     | 0     |      0 | etc/ssl/                          |
| `drwxr-xr-x` | 0     | 0     |      0 | etc/ssl/certs/                    |
| `-rw-r--r--` | 0     | 0     | 227161 | etc/ssl/certs/ca-certificates.crt |
| `-rw-r--r--` | 0     | 0     | 425884 | etc/zoneinfo.zip                  |
| `drwx------` | 65532 | 65532 |      0 | home/                             |
| `drwx------` | 0     | 0     |      0 | root/                             |
| `drwxrwxrwt` | 0     | 0     |      0 | tmp/                              |
| `drwxr-xr-x` | 0     | 0     |      0 | usr/                              |
| `drwxr-xr-x` | 0     | 0     |      0 | usr/bin/                          |

## Environment

| Key      | Value             |
|----------|-------------------|
| PATH     | /usr/bin:/bin     |
| ZONEINFO | /etc/zoneinfo.zip |
| HOME     | /home             |
