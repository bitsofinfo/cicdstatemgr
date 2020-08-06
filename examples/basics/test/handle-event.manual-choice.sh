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

