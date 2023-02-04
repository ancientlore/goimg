#!/bin/bash

GO_VERSION=$(go env GOVERSION | cut -b "3-")
VERSION=$(cut -d '.' -f 1,2 <<< "$GO_VERSION")

echo
echo Go version is $GO_VERSION, major version is $VERSION

echo
echo Building ancientlore/goimg:$GO_VERSION
docker build --build-arg GO_VERSION=$GO_VERSION -t ancientlore/goimg:$GO_VERSION . || return 1

if [ "$GO_VERSION" != "$VERSION" ]; then
    echo
    echo Tagging ancientlore/goimg:$VERSION
    docker tag ancientlore/goimg:$GO_VERSION ancientlore/goimg:$VERSION || return 1
fi

echo
echo Tagging ancientlore/goimg:latest
docker tag ancientlore/goimg:$GO_VERSION ancientlore/goimg:latest || return 1

echo
echo Building test image goimgtest:$VERSION
docker build --build-arg GO_VERSION=$GO_VERSION -t goimgtest:$VERSION -f Dockerfile.test . || return 1

echo
echo Running test image goimgtest:$VERSION
docker run -it --rm goimgtest:$VERSION || return 1

echo
echo Pushing ancientlore/goimg:$GO_VERSION
docker push ancientlore/goimg:$GO_VERSION

if [ "$GO_VERSION" != "$VERSION" ]; then
    echo
    echo Pushing ancientlore/goimg:$VERSION 
    docker push ancientlore/goimg:$VERSION
fi

echo
echo Pushing ancientlore/goimg:latest
docker push ancientlore/goimg:latest
