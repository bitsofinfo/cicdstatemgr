#!/bin/bash

#-----------------
# HANDLE_EVENT.md
# trigger-pipeline
#-----------------

cicdstatemgr    \
     --config config.yaml \
     --secrets secrets.yaml \
     --id "context-data-id-1" \
     --set state.triggerAutoArg1=dummyVal \
     --handle-event build=testTriggerPipelineEvent

# really nothing to validate here

