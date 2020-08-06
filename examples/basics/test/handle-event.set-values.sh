#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# set-values
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testSetValuesEvent

VALUE=$(cat localdata/cicdContextData.yaml | yq r - state.lastPostedNotifyMessage)
if [ "$VALUE" != "This is basicMacro! msg = build is successful" ]; then
    echo
    echo "FAIL: HANDLE_EVENT [set-values]: state.lastPostedNotifyMessage != This is basicMacro! msg = build is successful"
    echo
    exit 1
else
    echo
    echo "OK: HANDLE_EVENT [set-values]: state.lastPostedNotifyMessage success"
    echo
fi
