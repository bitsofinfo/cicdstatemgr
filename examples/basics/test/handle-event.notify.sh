#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# notify
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testNotifyEvent


LAST_POSTED_ID=$(cat localdata/cicdContextData.yaml | yq r - state.lastPostedDataRandomId)
VALUE=$(cat localdata/cicdContextData.yaml | yq r - state.postedData.${LAST_POSTED_ID}.body.message)
if [ "$VALUE" != "This is basicMacro! msg = build is successful" ]; then
    echo
    echo "FAIL: HANDLE_EVENT [notify]: state.postedData.${LAST_POSTED_ID}.body.message != This is basicMacro! msg = build is successful"
    echo
    exit 1
else
    echo
    echo "OK: HANDLE_EVENT [notify]: state.postedData.${LAST_POSTED_ID}.body.message success"
    echo
fi


#-----------------
# HANDLE_EVENT.md
# testEmbeddedJsonEvent
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testEmbeddedJsonEvent


LAST_POSTED_ID=$(cat localdata/cicdContextData.yaml | yq r - state.lastPostedDataRandomId)
VALUE=$(cat localdata/cicdContextData.yaml | yq r - state.postedData.${LAST_POSTED_ID}.body.message)
if [ "$VALUE" != "Here is some JSON from c:\windowspath\test and \"quotes\" { \"dog\":\"beagle\" }" ]; then
    echo
    echo "FAIL: HANDLE_EVENT [notify]: state.postedData.${LAST_POSTED_ID}.body.message != Here is some JSON from c:\windowspath\test and \"quotes\" { \"dog\":\"beagle\" }"
    echo
    exit 1
else
    echo
    echo "OK: HANDLE_EVENT [notify]: state.postedData.${LAST_POSTED_ID}.body.message success"
    echo
fi
