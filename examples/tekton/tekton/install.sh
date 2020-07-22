#!/bin/bash

# start
minikube start

# switch to context
kubectl config use-context minikube

# ensure namespace
kubectl create namespace tekton-pipelines

# force default NS to tekton-pipelines for this context
kubectl config set-context --current --namespace=tekton-pipelines

# install pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.14.2/release.yaml

# install pipelines customizations (configmaps)
# - feature-flags 
# - config-artifact-pvc (disk size)
kubectl apply -f tekton-pipelines-mods.yaml

# install triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/previous/v0.6.1/release.yaml

# install dashboard
kubectl apply --filename https://github.com/tektoncd/dashboard/releases/download/v0.8.0/tekton-dashboard-release.yaml

# install git clone task and apply it
git clone https://github.com/tektoncd/catalog.git
kubectl apply -f catalog/task/git-clone/0.1/git-clone.yaml -n tekton-pipelines

# RBAC perms for the tekton-triggers-admin service account
kubectl apply -f tekton-triggers-rbac.yaml

# Custom Tekton trigger interceptor that converts Slack's payload=[urlencodeddata]
# into plain JSON before handing off to our EventListener see: versions/[vN]/event-listener.yaml
# https://github.com/bitsofinfo/slack-payload-handler
kubectl apply -f slack-payload-handler.yaml

# These are the k8s serviceaccounts that the various PipelineRuns execute as
# when triggered by triggers in versions/[vN]/pipelines/[name]/trigger.yaml
kubectl apply -f tekton-service-accounts.yaml

# The redis instance that is used as the primary datastore for cicdstatemgr
# https://github.com/bitsofinfo/cicdstatemgr
kubectl apply -f redis.yaml

# a Docker registry instance that resides in the cluster that Kaniko uses 
# for its cache. https://github.com/GoogleContainerTools/kaniko
kubectl apply -f image-registry-cache.yaml

