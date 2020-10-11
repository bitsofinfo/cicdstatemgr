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
    sudobrew install yq
  fi
else
  sudo snap install yq
fi

# jq
if [[ `uname` == 'Darwin' ]]; then
  if [ -z "$(which jq)" ]; then
    brew install jq
  fi
else
  sudo snap install yq
fi

# setup python venv
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install --requirement requirements.txt


# run the scripts
$SCRIPTPATH/init-new.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/get.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/set.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/load.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.notify.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.trigger-pipeline.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.manual-choice.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.set-values.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.respond.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/handle-event.disable.sh
if [ "$?" != "0" ]; then exit 1; fi

$SCRIPTPATH/generate.sh
if [ "$?" != "0" ]; then exit 1; fi
