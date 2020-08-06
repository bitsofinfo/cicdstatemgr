#!/bin/bash

#-----------------
# LOAD.md
#-----------------
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

rm -rf $SCRIPTPATH/localdata/*

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --load

VALUE=$(cat localdata/cicdContextData.json | jq -r .'state.key1')
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: LOAD: localdata/cicdContextData.json invalid"
    echo
    exit 1
else
    echo
    echo "OK: LOAD: localdata/cicdContextData.json"
    echo
fi



cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --load \
     --set state.key1=valuechanged \
     --set state.testHeader2Value="myvalueforheader2" \
     --set state.triggerAutoArg1=99999 \
     --handle-event build=testEvent

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.triggerAutoArg1")
if [ "$VALUE" != "99999" ]; then
    echo
    echo "FAIL: LOAD: state.triggerAutoArg1 != 99999"
    echo
    exit 1
else
    echo
    echo "OK: LOAD: state.triggerAutoArg1 success"
    echo
fi