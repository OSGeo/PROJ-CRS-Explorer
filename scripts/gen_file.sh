#!/usr/bin/env bash
set -Eeuo pipefail

# indicate DOCKER PROJ version
PROJ_VERSION=9.2.0
PYPROJ_VERSION=3.4.1
TAG="crs-explorer:$PROJ_VERSION"

# prepare destination
DIRNAME=`dirname $(readlink -f $0)`
mkdir -p $DIRNAME/dist
test "$(ls -A $DIRNAME/dist/)" && rm -r $DIRNAME/dist/*

# build container
docker build --build-arg VERSION=$PROJ_VERSION --build-arg PYPROJ_VERSION=$PYPROJ_VERSION --tag $TAG $DIRNAME

# execute container
docker run --user $(id -u):$(id -g) --rm -v "$DIRNAME/dist:/home/dist" $TAG

DEST=$DIRNAME/..
# copy to root location
cp $DIRNAME/dist/crslist.json $DEST
cp $DIRNAME/dist/metadata.txt $DEST
cp $DIRNAME/dist/sitemap.xml $DEST

for wkt in wkt1 wkt2 ; do
    echo remove $wkt
    test "$(ls -A $DEST/$wkt/)" && git rm -r -q $DEST/$wkt
    cp -r $DIRNAME/dist/$wkt $DEST
    git add $DEST/$wkt
done

sed -i -E "s/(<span id=\"proj_version\">).*?(<\/span>)/\1${PROJ_VERSION}\2/" $DIRNAME/../index.html
