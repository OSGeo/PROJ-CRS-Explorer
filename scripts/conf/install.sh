#!/usr/bin/env bash
set -Eeuo pipefail

TZ=Europe/Berlin
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install missing packages
PACKAGE_LIST=/home/apt-packages.txt
if [ -f "$PACKAGE_LIST" ]; then
    apt-get update -qq > /dev/null

    apt-get \
        -qq --yes \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages \
        install \
        `cat $PACKAGE_LIST` > /dev/null
fi

# setup python environment
mkdir -p $VIRTUAL_ENV
python3 -m venv $VIRTUAL_ENV

# install pyproj
python3 -m pip install -q --upgrade pip
python3 -m pip install -q git+https://github.com/pyproj4/pyproj.git@$PYPROJ_VERSION
# do not use this, it may include PROJ: python3.8 -m pip install pyproj==$PYPROJ_VERSION

# cleaning
apt-get clean
apt-get autoremove

# create dest folder
mkdir -p $DEST_DIR
