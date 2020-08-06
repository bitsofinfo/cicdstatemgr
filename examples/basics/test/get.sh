#!/bin/bash

#-----------------
# GET.md
#-----------------

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=value1"

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set 'state.templateTest={{tmplctx.prop1}}'

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1)
if [ "$VALUE" != "value1" ]; then
    echo
    echo "FAIL: GET: state.templateTest != value1"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest success"
    echo
fi

cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --set "state.key1=yet a new value"

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=state.key1)
if [ "$VALUE" != "yet a new value" ]; then
    echo
    echo "FAIL: GET: state.templateTest != yet a new value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest update yet a new value success"
    echo
fi


VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest" \
    --tmpl-ctx-var tmplctx.prop1=just-a-literal-value)
if [ "$VALUE" != "just-a-literal-value" ]; then
    echo
    echo "FAIL: GET: state.templateTest != just-a-literal-value"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest update just-a-literal-value success"
    echo
fi
 

VALUE=$(cicdstatemgr \
    --config config.yaml  \
    --secrets secrets.yaml \
    --id "context-data-id-1" \
    --get "state.templateTest") 
if [ "$VALUE" != '<jinja2 parse error> {{tmplctx.prop1}}' ]; then
    echo
    echo "FAIL: GET: state.templateTest != <jinja2 parse error> {{tmplctx.prop1}}"
    echo
    exit 1
else
    echo
    echo "OK: GET: state.templateTest invalid template success"
    echo
fi

