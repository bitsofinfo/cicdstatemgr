#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# respond
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --handle-event build=testRespondEvent

# really nothing to validate here


