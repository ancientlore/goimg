ARG GO_VERSION=1.23

FROM --platform=${BUILDPLATFORM} golang:${GO_VERSION} AS builder

# Print version of Go
RUN go version

# Setup folders
RUN mkdir -p /home/distroless
WORKDIR /home/distroless
RUN mkdir 0 65532
RUN mkdir -m 1777 0/tmp
RUN mkdir -p 0/etc
RUN mkdir -p 0/bin
RUN mkdir -p 0/usr/bin
RUN mkdir -p 0/usr/local/bin

# Setup root user, group, and folder
RUN echo 'root:x:0:0:root:/root:/sbin/nologin' > ./0/etc/passwd \
    && echo 'root:x:0:' > ./0/etc/group \
    && mkdir 0/root \
    && chmod 700 ./0/root

# Setup nonroot user, group, and folder
RUN echo 'nonroot:x:65532:65532:Nonroot User:/home:/sbin/nologin' >> ./0/etc/passwd \
    && echo 'nonroot:x:65532:' >> ./0/etc/group \
    && mkdir -p ./65532/home \
    && chmod 700 ./65532/home \
    && chown -R 65532:65532 ./65532/home

# Fetch CCADB Root CA trust bundle into the first location Go likes
RUN mkdir -p ./0/etc/ssl/certs/ && curl -L https://ccadb-public.secure.force.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites > ./0/etc/ssl/certs/ca-certificates.crt

# Copy time zone data file for Go
RUN cp /usr/local/go/lib/time/zoneinfo.zip ./0/etc/

# At this point the /home/distroless folder has all the files we need.

# Build the output image from scratch
FROM scratch AS final
WORKDIR /
ENV PATH=/usr/local/bin:/usr/bin:/bin
ENV HOME=/home

# Copy distroless image files (make sure passwd and group land first)
COPY --from=builder /home/distroless/0 /
COPY --from=builder --chown=nonroot:nonroot /home/distroless/65532 /

# Set time zone environment for Go
ENV ZONEINFO=/etc/zoneinfo.zip

# Default nonroot user
USER nonroot

# Default working dir
WORKDIR /home
