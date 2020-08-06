#!/bin/bash

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