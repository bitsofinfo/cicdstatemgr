#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

kubectl delete secret github-secret
kubectl create secret generic github-secret --from-literal=secretToken=123

kubectl apply -f triggers.event-listener.yaml

kubectl apply -f common/tasks/handle-event.yaml
kubectl apply -f common/tasks/init.yaml
kubectl apply -f common/conditions/conditions.yaml

kubectl apply -f start/tasks/start.yaml
kubectl apply -f start/pipeline.yaml
kubectl apply -f start/triggers.yaml

kubectl apply -f build/tasks/build.yaml
kubectl apply -f build/pipeline.yaml
kubectl apply -f build/triggers.yaml

kubectl apply -f deploy/tasks/deploy.yaml
kubectl apply -f deploy/pipeline.yaml
kubectl apply -f deploy/triggers.yaml

kubectl apply -f validate/tasks/trivy-scan.yaml
kubectl apply -f validate/pipeline.yaml
kubectl apply -f validate/triggers.yaml

kubectl apply -f test/tasks/test-invoke.yaml
kubectl apply -f test/pipeline.yaml
kubectl apply -f test/triggers.yaml
