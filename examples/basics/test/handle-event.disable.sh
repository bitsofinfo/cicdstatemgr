#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# disable/enable
#-----------------

OUTPUT=$(cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event test=another-event 2>&1)
echo "$OUTPUT"
if [[ "$OUTPUT" != *"notify enabled:False skipping"* ]]; then
    echo
    echo "FAIL: HANDLE_EVENT [enabled test]: output != ... notify enabled:False skipping ..."
    echo
    exit 1
else
    echo
    echo "OK: HANDLE_EVENT [enabled test]: success"
    echo
fi

