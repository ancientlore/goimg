#!/bin/bash

docker run --name gcr gcr.io/distroless/static:nonroot /foo
docker run --name goimg goimg:latest /foo

docker export gcr | tar -tv | cut -b "1-28,49-" > cmp-gcrio-distroless.txt
docker export goimg | tar -tv | cut -b "1-28,49-" > cmp-goimg.txt

docker cp gcr:/etc/passwd gcr-passwd.txt
docker cp gcr:/etc/group gcr-group.txt
docker cp goimg:/etc/passwd goimg-passwd.txt
docker cp goimg:/etc/group goimg-group.txt

docker rm gcr goimg
