#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# start (k8s 1.16.x due to minikube dynamic PVC issues)
minikube start --kubernetes-version v1.16.12 --insecure-registry "10.0.0.0/8" --driver=hyperkit
minikube addons enable registry

# https://github.com/kameshsampath/minikube-helpers/tree/master/registry
# hacking to get push/pull against minikube registry to work
git clone https://github.com/kameshsampath/minikube-helpers.git $SCRIPTPATH/minikube-helpers

kubectl apply -n kube-system \
  -f $SCRIPTPATH/registry-aliases-config.yaml \
  -f $SCRIPTPATH/minikube-helpers/registry/node-etc-hosts-update.yaml \
  -f $SCRIPTPATH/minikube-helpers/registry/patch-coredns-job.yaml

# switch to context
kubectl config use-context minikube

# ensure namespace
kubectl create namespace tekton-pipelines

# force default NS to tekton-pipelines for this context
kubectl config set-context --current --namespace=tekton-pipelines

# install pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.16.3/release.yaml

# install pipelines customizations (configmaps)
# - feature-flags 
# - config-artifact-pvc (disk size)
kubectl apply -f $SCRIPTPATH/tekton-pipelines-mods.yaml

# install triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/v0.8.1/release.yaml

# install dashboard
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/download/v0.9.0/tekton-dashboard-release.yaml

# NodePort change
kubectl apply -f $SCRIPTPATH/tekton-dashboard-mods.yaml

# install git clone task and apply it
# https://github.com/tektoncd/catalog/issues/531
git clone https://github.com/tektoncd/catalog.git $SCRIPTPATH/catalog
CDIR=`pwd`; cd $SCRIPTPATH/catalog/; git checkout 5250f30; cd $CDIR
kubectl apply -f $SCRIPTPATH/catalog/task/git-clone/0.1/git-clone.yaml -n tekton-pipelines

# RBAC perms for the tekton-triggers-admin service account
kubectl apply -f $SCRIPTPATH/tekton-triggers-rbac.yaml

# Custom Tekton trigger interceptor that converts Slack's payload=[urlencodeddata]
# into plain JSON before handing off to our EventListener 
# https://github.com/bitsofinfo/slack-payload-handler
kubectl apply -f $SCRIPTPATH/slack-payload-handler.yaml

# These are the k8s serviceaccounts that the various PipelineRuns execute as
# when triggered by triggers 
kubectl apply -f $SCRIPTPATH/tekton-service-accounts.yaml

# The redis instance that is used as the primary datastore for cicdstatemgr
# https://github.com/bitsofinfo/cicdstatemgr
kubectl apply -f $SCRIPTPATH/redis.yaml

# a Docker registry instance that resides in the cluster that Kaniko uses 
# for its cache. https://github.com/GoogleContainerTools/kaniko
kubectl apply -f $SCRIPTPATH/image-registry-cache.yaml
\
# Trivy server
kubectl apply -f $SCRIPTPATH/trivy-server.yaml

# Create secrets for slack oauth token (i.e to verify inbound slack actions)
cat secrets/slack-oauth-token | tr -d '\n' > secrets/slack-oauth-token.tmp; mv secrets/slack-oauth-token.tmp secrets/slack-oauth-token
kubectl create secret generic slack-oauth-token --from-file=slack-oauth-token=secrets/slack-oauth-token 

# setup our namespaces for where the apps will be deployed
# separate ones for dev/prod
kubectl create namespace apps-dev
kubectl create namespace apps-prod

kubectl create clusterrolebinding cicd-tekton-dev \
    --serviceaccount=tekton-pipelines:cicd-tekton \
    --clusterrole=cluster-admin \
    --namespace=apps-dev

kubectl create clusterrolebinding cicd-tekton-prod \
    --serviceaccount=tekton-pipelines:cicd-tekton \
    --clusterrole=cluster-admin \
    --namespace=apps-prod
