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

    # apt-get -qq --yes install software-properties-common
    # add-apt-repository --yes ppa:deadsnakes/ppa  # for different python versions

    # Added curl and gnupg to manually handle deadsnakes repository key
    apt-get -qq --yes install software-properties-common curl gnupg
    # Bypass add-apt-repository to avoid connection timeouts with Launchpad API
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xF23C5A6CF475977595C89F51BA6932366A755776" | gpg --dearmor -o /usr/share/keyrings/deadsnakes.gpg
    echo "deb [signed-by=/usr/share/keyrings/deadsnakes.gpg] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/deadsnakes.list

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
