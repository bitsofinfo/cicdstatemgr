#!/bin/bash

# Simple test script that validates the actual 
# `basics` example covered via the docs in order
#
# Should be run from the root of the basics/ dir

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#-----------------
# README.md
#-----------------

# start redis
docker rm -f cicdstatemgr-redis
docker run \
    -d \
    -v `pwd`/redis.conf:/usr/local/etc/redis/redis.conf \
    -p 6379:6379 \
    --name cicdstatemgr-redis redis redis-server /usr/local/etc/redis/redis.conf

# yq
if [[ `uname` == 'Darwin' ]]; then
  if [ -z "$(which yq)" ]; then
    brew install yq
  fi
else
  snap install yq
fi

# jq
if [[ `uname` == 'Darwin' ]]; then
  if [ -z "$(which jq)" ]; then
    brew install jq
  fi
else
  snap install yq
fi

# setup python venv
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install --requirement requirements.txt



$SCRIPTPATH/init-new.sh
$SCRIPTPATH/get.sh
$SCRIPTPATH/set.sh

