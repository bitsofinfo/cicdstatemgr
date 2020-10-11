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
    --tmpl-ctx-var "ctx.var1=v1val" \
    --tmpl-ctx-var "ctx.var2=v2val" \
    --generate pipelines.build.generators.dockerfile

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd) 

if [ "$VALUE" != './gendockerfile.sh -f alpine:latest -x myapp-alpine-1.5.9 -z v1val -q v2val' ]; then
    echo
    echo "FAIL: GET: state.build.dockerfileInfo.generateDockerfileCmd (alpine) != expected value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.build.dockerfileInfo.generateDockerfileCmd (alpine)"
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
    --tmpl-ctx-var "ctx.var1=v1val" \
    --tmpl-ctx-var "ctx.var2=v2val" \
    --generate pipelines.build.generators.dockerfile

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get state.build.dockerfileInfo.generateDockerfileCmd) 

if [ "$VALUE" != './gendockerfile.sh -f centos:latest -x myapp-centos-1.5.9 -z v1val -q v2val' ]; then
    echo
    echo "FAIL: GET: state.build.dockerfileInfo.generateDockerfileCmd (centos) != expected value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.build.dockerfileInfo.generateDockerfileCmd (centos)"
    echo
fi

