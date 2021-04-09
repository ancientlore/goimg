FROM golang:1.16 AS builder

RUN apt-get update -y && apt-get upgrade -y && update-ca-certificates

RUN mkdir -p /home/distroless
WORKDIR /home/distroless
RUN mkdir -m 1777 tmp
RUN mkdir -p etc

# Setup root user, group, and folder
RUN echo 'root:x:0:0:root:/root:/sbin/nologin' > ./etc/passwd \
    && echo 'root:x:0:' > ./etc/group \
    && mkdir root \
    && chmod 700 ./root

# Setup nonroot user, group, and folder
RUN echo 'nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin' >> ./etc/passwd \
    && echo 'nonroot:x:65532:' >> ./etc/group \
    && mkdir -p ./home/nonroot \
    && chmod 700 ./home/nonroot \
    && chown 65532:65532 ./home \
    && chown -R 65532:65532 ./home/nonroot

# Build the output image from scratch
FROM scratch
WORKDIR /

# Copy distroless image files
COPY --from=builder /home/distroless /

# Copy SSL certs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy time zone data file for Go
COPY --from=builder /usr/local/go/lib/time/zoneinfo.zip /etc/

# Set time zone environment for Go
ENV ZONEINFO=/etc/zoneinfo.zip

# Default nonroot user
USER nonroot

# Default working dir
WORKDIR /home/nonroot
