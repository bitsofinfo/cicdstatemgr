#!/bin/bash

#-----------------
# GENERATE.md
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.gitTag=myapp-alpine-1.5.9" \
    --set "state.gitAppName=my-application"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --generate pipelines.build.generators.dockerfile

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd) 

if [ "$VALUE" != './gendockerfile.sh -f alpine:latest -x myapp-alpine-1.5.9' ]; then
    echo
    echo "FAIL: GET: state.build.dockerfileInfo.generateDockerfileCmd != expected value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.build.dockerfileInfo.generateDockerfileCmd"
    echo
fi



cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.gitTag=myapp-centos-1.5.9" \
    --set "state.gitAppName=my-application"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --generate pipelines.build.generators.dockerfile

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd) 

if [ "$VALUE" != './gendockerfile.sh -f centos:latest -x myapp-centos-1.5.9' ]; then
    echo
    echo "FAIL: GET: state.build.dockerfileInfo.generateDockerfileCmd != expected value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.build.dockerfileInfo.generateDockerfileCmd"
    echo
fi

