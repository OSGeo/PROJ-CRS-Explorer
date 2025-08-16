#!/usr/bin/env bash
set -Eeuo pipefail

TZ=Europe/Berlin
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

if [ -f "/home/.python-version" ]; then
    python_version=`cat /home/.python-version`
else
    python_version=3
fi
# install missing packages
PACKAGE_LIST=/home/apt-packages.txt
if [ -f "$PACKAGE_LIST" ]; then
    apt-get update -qq > /dev/null
    apt-get -qq --yes install software-properties-common
    add-apt-repository --yes ppa:deadsnakes/ppa  # for different python versions
    apt-get update -qq > /dev/null

    apt-get \
        -qq --yes \
        --allow-remove-essential \
        --allow-change-held-packages \
        --no-install-recommends \
        install \
        `cat $PACKAGE_LIST | sed "s/\\${python_version}/${python_version}/p"` > /dev/null
fi

# setup python environment
mkdir -p $VIRTUAL_ENV
python${python_version} -m venv $VIRTUAL_ENV
. $VIRTUAL_ENV/bin/activate

python3 --version

# install pyproj
python3 -m pip install -q --upgrade pip
python3 -m pip install -q git+https://github.com/pyproj4/pyproj.git@$PYPROJ_VERSION
# do not use this, it may include PROJ: python3.8 -m pip install pyproj==$PYPROJ_VERSION

# cleaning
apt-get clean
apt-get autoremove

# create dest folder
mkdir -p $DEST_DIR
