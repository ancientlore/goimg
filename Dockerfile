FROM golang:1.16 AS builder

# Print version of Go
RUN go version

# Build test program
COPY . /go/test
WORKDIR /go/test
RUN CGO_ENABLED=0 go build -o /go/bin/test

# Setup folders
RUN mkdir -p /home/distroless
WORKDIR /home/distroless
RUN mkdir 0 65532
RUN mkdir -m 1777 0/tmp
RUN mkdir -p 0/etc

# Setup root user, group, and folder
RUN echo 'root:x:0:0:root:/root:/sbin/nologin' > ./0/etc/passwd \
    && echo 'root:x:0:' > ./0/etc/group \
    && mkdir 0/root \
    && chmod 700 ./0/root

# Setup nonroot user, group, and folder
RUN echo 'nonroot:x:65532:65532:nonroot:/home/nonroot:/sbin/nologin' >> ./0/etc/passwd \
    && echo 'nonroot:x:65532:' >> ./0/etc/group \
    && mkdir -p ./65532/home/nonroot \
    && chmod 700 ./65532/home/nonroot \
    && chown 65532:65532 ./65532/home \
    && chown -R 65532:65532 ./65532/home/nonroot

# Fetch CCADB Root CA trust bundle into the first location Go likes
RUN mkdir -p ./0/etc/ssl/certs/ && curl -L https://ccadb-public.secure.force.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites > ./0/etc/ssl/certs/ca-certificates.crt

# Copy time zone data file for Go
RUN cp /usr/local/go/lib/time/zoneinfo.zip ./0/etc/

# At this point the /home/distroless folder has all the files we need.

# Build the test image from scratch
FROM scratch as testimg
WORKDIR /

# Copy test program
COPY --from=builder /go/bin/test /usr/bin/testimg

# Copy distroless image files (make sure passwd and group land first)
COPY --from=builder /home/distroless/0 /
COPY --from=builder --chown=nonroot:nonroot /home/distroless/65532 /

# Set time zone environment for Go
ENV ZONEINFO=/etc/zoneinfo.zip

# Default nonroot user
USER nonroot

# Default working dir
WORKDIR /home/nonroot

# Run the test
RUN ["/usr/bin/testimg"]

# Build the output image from scratch
FROM scratch as final
WORKDIR /

# Refer to the test image so that Docker runs it
COPY --from=testimg /root /

# Copy distroless image files (make sure passwd and group land first)
COPY --from=builder /home/distroless/0 /
COPY --from=builder --chown=nonroot:nonroot /home/distroless/65532 /

# Set time zone environment for Go
ENV ZONEINFO=/etc/zoneinfo.zip

# Default nonroot user
USER nonroot

# Default working dir
WORKDIR /home/nonroot
