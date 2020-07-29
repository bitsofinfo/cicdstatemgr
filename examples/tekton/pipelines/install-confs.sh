#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


NGROK_URL=$1
TEKTON_DASHBOARD_URL=$2
SLACK_ORG_URL="https://bitsofinfo.slack.com/"

SED_OPTIONS=""
SED_VERSION=$(sed --version)
if [ "$?" == "1" ]; then
  SED_OPTIONS=" -e "
fi

cp confs/cicdstatemgr-config.yaml confs/cicdstatemgr-config.yaml.tmp
sed -i $SED_OPTIONS "s|@NGROK_URL@|${NGROK_URL}|g" confs/cicdstatemgr-config.yaml.tmp
sed -i $SED_OPTIONS "s|@TEKTON_DASHBOARD_URL@|${TEKTON_DASHBOARD_URL}|g" confs/cicdstatemgr-config.yaml.tmp
sed -i $SED_OPTIONS "s|@SLACK_ORG_URL@|${SLACK_ORG_URL}|g" confs/cicdstatemgr-config.yaml.tmp


kubectl delete configmap cicdstatemgr-configs

kubectl create configmap cicdstatemgr-configs \
  --from-file=cicdstatemgr-config.yaml=$SCRIPTPATH/confs/cicdstatemgr-config.yaml.tmp \
  --from-file=$SCRIPTPATH/bases/core.yaml \
  --from-file=$SCRIPTPATH/bases/dev.yaml \
  --from-file=$SCRIPTPATH/bases/prod.yaml \
  -n tekton-pipelines

kubectl delete secret cicdstatemgr-secrets

# replace 
SLACK_BEARER_TOKEN=$(cat secrets/slack-bearer-token)
cp confs/cicdstatemgr-secrets.yaml confs/cicdstatemgr-secrets.yaml.tmp
sed -i "s|@SLACK_BEARER_TOKEN@|${SLACK_BEARER_TOKEN}|g" confs/cicdstatemgr-secrets.yaml.tmp

kubectl create secret generic cicdstatemgr-secrets \
  --from-file=cicdstatemgr-secrets.yaml=$SCRIPTPATH/confs/cicdstatemgr-secrets.yaml.tmp \
  -n tekton-pipelines