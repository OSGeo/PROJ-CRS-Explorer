#!/usr/bin/env bash
set -Eeuo pipefail

# indicate DOCKER PROJ version
PROJ_VERSION=8.2.0
TAG="crs-explorer:$PROJ_VERSION"

# prepare destination
DIRNAME=`dirname $(readlink -f $0)`
mkdir -p $DIRNAME/dist
touch $DIRNAME/dist/crslist.json

# build container
docker build --build-arg VERSION=$PROJ_VERSION --tag $TAG $DIRNAME

# execute container
docker run --rm -v "$DIRNAME/dist:/home/dist" $TAG

# copy to root location
cp $DIRNAME/dist/crslist.json $DIRNAME/..
sed -i -E "s/(<span id=\"proj_version\">).*?(<\/span>)/\1${PROJ_VERSION}\2/" $DIRNAME/../index.html
