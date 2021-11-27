#!/usr/bin/env bash
set -Eeuo pipefail

# indicate DOCKER PROJ version
PROJ_VERSION=8.1.1
PYPROJ_VERSION=3.3.0
TAG="crs-explorer:$PROJ_VERSION"

# prepare destination
DIRNAME=`dirname $(readlink -f $0)`
mkdir -p $DIRNAME/dist
test "$(ls -A $DIRNAME/dist/)" && rm -r $DIRNAME/dist/*

# build container
docker build --build-arg VERSION=$PROJ_VERSION --build-arg PYPROJ_VERSION=$PYPROJ_VERSION --tag $TAG $DIRNAME

# execute container
docker run --user $(id -u):$(id -g) --rm -v "$DIRNAME/dist:/home/dist" $TAG

# copy to root location
cp $DIRNAME/dist/crslist.json $DIRNAME/..
cp $DIRNAME/dist/metadata.txt $DIRNAME/..
sed -i -E "s/(<span id=\"proj_version\">).*?(<\/span>)/\1${PROJ_VERSION}\2/" $DIRNAME/../index.html
