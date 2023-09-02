#!/usr/bin/env bash
set -Eeuo pipefail

echo 'Set first argument to "addgit" if you want to add wkt files automatically'

# indicate DOCKER PROJ version
PROJ_VERSION=9.3.0
PYPROJ_VERSION=c77e346d4e0ecc07cdc495fcaefafea09a8dde5c # fixed 3.6.0
TAG="crs-explorer:$PROJ_VERSION"

# prepare destination
DIRNAME=`dirname $(readlink -f $0)`
mkdir -p $DIRNAME/dist
test "$(ls -A $DIRNAME/dist/)" && rm -r $DIRNAME/dist/*

# build container
docker build --pull --build-arg VERSION=$PROJ_VERSION --build-arg PYPROJ_VERSION=$PYPROJ_VERSION --tag $TAG $DIRNAME

# execute container
docker run --user $(id -u):$(id -g) --rm -v "$DIRNAME/dist:/home/dist" $TAG

DEST=$DIRNAME/..
# copy to root location
cp $DIRNAME/dist/crslist.json $DEST
cp $DIRNAME/dist/metadata.txt $DEST
cp $DIRNAME/dist/sitemap.xml $DEST

for wkt in wkt1 wkt2 ; do
    echo remove $wkt
    if [ "${1-}" == "addgit" ] ; then
        test "$(ls -A $DEST/$wkt/)" && git rm -r -q $DEST/$wkt
    else
        rm -r $DEST/$wkt
    fi
    cp -r $DIRNAME/dist/$wkt $DEST
    if [ "${1-}" == "addgit" ] ; then
        git add $DEST/$wkt
    fi
done

sed -i -E "s/(<span id=\"proj_version\">).*?(<\/span>)/\1${PROJ_VERSION}\2/" $DIRNAME/../index.html
