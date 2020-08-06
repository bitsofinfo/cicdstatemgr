#!/bin/bash

# Simple test script that validates the actual 
# `basics` example covered via the docs in order
#
# Should be run from the root of the basics/ dir

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


#-----------------
# INIT_NEW.md
#-----------------


# initialize new context
cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
        \
    --init-new "context-data-id-1" \
    --init-bases-dir bases \
    --init-app-config-file app.yaml \
    --init-cicd-context-name stage \
    \
    --set "state.key1=value1"

VALUE=$(redis-cli --user cicdstatemgr --pass '123$aBcZ' mget context-data-id-1 | yq r - state.key1)
if [ -z "$VALUE" ]; then
    echo
    echo "FAIL: INIT_NEW: state.key1 failed to exist post create"
    echo
    exit 1
else
    echo
    echo "OK: INIT_NEW: state.key1 exists post create"
    echo
fi

VALUE=$(cat localdata/cicdContextData.id)
if [ "$VALUE" != "context-data-id-1" ]; then
    echo
    echo "FAIL: INIT_NEW: localdata/cicdContextData.id invalid"
    echo
    exit 1
else
    echo
    echo "OK: INIT_NEW: localdata/cicdContextData.id"
    echo
fi

VALUE=$(cat localdata/cicdContextData.json | jq -r .'state.key1')
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: INIT_NEW: localdata/cicdContextData.json invalid"
    echo
    exit 1
else
    echo
    echo "OK: INIT_NEW: localdata/cicdContextData.json"
    echo
fi

VALUE=$(cat localdata/cicdContextData.yaml | yq r - 'state.key1')
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: INIT_NEW: localdata/cicdContextData.yaml invalid"
    echo
    exit 1
else
    echo
    echo "OK: INIT_NEW: localdata/cicdContextData.yaml"
    echo
fi

source localdata/cicdContextData.sh
VALUE=$(echo $CICD_state__key1)
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: INIT_NEW: localdata/cicdContextData.sh invalid"
    echo
    exit 1
else
    echo
    echo "OK: INIT_NEW: localdata/cicdContextData.sh"
    echo
fi


#-----------------
# GET.md
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.templateTest={{tmplctx.prop1}}'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1)
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: GET: state.templateTest != value1"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest success"
    echo
fi

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=yet a new value"

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1)
if [ "$VALUE" != "yet a new value" ]; then
    echo
    echo "FAIL: GET: state.templateTest != yet a new value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest update yet a new value success"
    echo
fi


VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=just-a-literal-value)
if [ "$VALUE" != "just-a-literal-value" ]; then
    echo
    echo "FAIL: GET: state.templateTest != just-a-literal-value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest update just-a-literal-value success"
    echo
fi
 

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest") 
if [ "$VALUE" != '<jinja2 parse error> {{tmplctx.prop1}}' ]; then
    echo
    echo "FAIL: GET: state.templateTest != <jinja2 parse error> {{tmplctx.prop1}}"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest invalid template success"
    echo
fi



#-----------------
# SET.md
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1" \
    --set "state.key2=value2"

echo "simple body contents" > set.simple.file

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.file'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody') 
if [ "$VALUE" != 'simple body contents' ]; then
    echo
    echo "FAIL: GET: state.fileBody != simple body contents"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.fileBody"
    echo
fi


echo "[1,2,3]" > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'


VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody[2]') 
if [ "$VALUE" != '3' ]; then
    echo
    echo "GET: state.fileBody[2] != 3"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.fileBody[2]"
    echo
fi



echo '{"dog":"beagle", "bark":{"quality":"high","volume":"loud"}}' > set.simple.json

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.json'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality') 
if [ "$VALUE" != 'high' ]; then
    echo
    echo "GET: json: state.fileBody.bark.quality != high"
    echo
    exit 1
else
    echo
    echo "OK: GET: json: state.fileBody.bark.quality"
    echo
fi



printf "dog: beagle\nbark:\n  quality: high\n  volume: loud\n" > set.simple.yaml

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.fileBody=file://set.simple.yaml'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get 'state.fileBody.bark.quality') 
if [ "$VALUE" != 'high' ]; then
    echo
    echo "GET: yaml: state.fileBody.bark.quality != state.fileBody.bark.quality"
    echo
    exit 1
else
    echo
    echo "OK: GET: yaml: state.fileBody.bark.quality"
    echo
fi