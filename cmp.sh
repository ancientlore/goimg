#!/bin/bash

docker run --name gcr gcr.io/distroless/static:nonroot /foo
docker run --name goimg goimg:latest /foo
docker run --name goimg2 ancientlore/goimg:latest /foo

docker export gcr | tar -tv | cut -b "1-28,49-" > cmp-gcrio-distroless.txt
docker export goimg | tar -tv | cut -b "1-28,49-" > cmp-goimg-local.txt
docker export goimg2 | tar -tv | cut -b "1-28,49-" > cmp-goimg.txt

docker cp gcr:/etc/passwd gcr-passwd.txt
docker cp gcr:/etc/group gcr-group.txt

docker cp goimg:/etc/passwd goimg-local-passwd.txt
docker cp goimg:/etc/group goimg-local-group.txt

docker cp goimg2:/etc/passwd goimg-passwd.txt
docker cp goimg2:/etc/group goimg-group.txt

docker rm gcr goimg goimg2
