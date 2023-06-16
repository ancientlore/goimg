#!/bin/bash

GO_VERSION=$(go env GOVERSION | cut -b "3-")
VERSION=$(cut -d '.' -f 1,2 <<< "$GO_VERSION")

echo
echo Go version is $GO_VERSION, major version is $VERSION

echo
echo Building ancientlore/goimg:$GO_VERSION
docker build --build-arg GO_VERSION=$GO_VERSION -t ancientlore/goimg:$GO_VERSION . || exit 1

if [ "$GO_VERSION" != "$VERSION" ]; then
    echo
    echo Tagging ancientlore/goimg:$VERSION
    docker tag ancientlore/goimg:$GO_VERSION ancientlore/goimg:$VERSION || exit 1
fi

gum confirm "Test?" || exit 1

echo
echo Building test image goimgtest:$VERSION
docker build --build-arg GO_VERSION=$GO_VERSION -t goimgtest:$VERSION -f Dockerfile.test . || exit 1

echo
echo Running test image goimgtest:$VERSION
docker run -it --rm goimgtest:$VERSION || exit 1

gum confirm "Push?" || exit 1

echo
echo Tagging ancientlore/goimg:latest
docker tag ancientlore/goimg:$GO_VERSION ancientlore/goimg:latest || exit 1

echo
echo Pushing ancientlore/goimg:$GO_VERSION
docker push ancientlore/goimg:$GO_VERSION || exit 1

if [ "$GO_VERSION" != "$VERSION" ]; then
    echo
    echo Pushing ancientlore/goimg:$VERSION 
    docker push ancientlore/goimg:$VERSION || exit 1
fi

echo
echo Pushing ancientlore/goimg:latest
docker push ancientlore/goimg:latest || exit 1
