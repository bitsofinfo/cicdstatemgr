#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# manual-choice
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testManualChoiceEvent

# really nothing to validate here




#-----------------
# HANDLE_EVENT.md
# choiceGeneratorItems test
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.choiceGeneratorItems=file://set.manual-choice-gen-data.json'

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event test2=blah-event


OPTION_3_VALUE=$(cat localdata/cicdContextData.yaml | yq r - state.lastPostedHttpResponseFromManualChoice  | jq -r .data | jq -r .choices[3].options[0].value)
if [ "$OPTION_3_VALUE" != "item-three item3 desc" ]; then
    echo
    echo "FAIL: HANDLE_EVENT [manual-choice]: state.lastPostedHttpResponseFromManualChoice  | jq -r .data | jq -r .choices[3].options[0].value != item-three item3 desc"
    echo
    exit 1
else
    echo
    echo "OK: HANDLE_EVENT [manual-choice]: state.lastPostedHttpResponseFromManualChoice success"
    echo
fi



