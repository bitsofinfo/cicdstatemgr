#!/bin/bash


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
