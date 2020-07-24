SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

kubectl delete configmap cicdstatemgr-configs

kubectl create configmap cicdstatemgr-configs \
  --from-file=$SCRIPTPATH/confs/cicdstatemgr-config.yaml \
  --from-file=$SCRIPTPATH/bases/stage.yaml \
  -n tekton-pipelines

kubectl delete secret cicdstatemgr-secrets

kubectl create secret generic cicdstatemgr-secrets \
  --from-file=$SCRIPTPATH/confs/cicdstatemgr-secrets.yaml \
  -n tekton-pipelines


kubectl apply -f triggers.event-listener.yaml

kubectl delete secret github-secret
kubectl create secret generic github-secret --from-literal=secretToken=123

kubectl apply -f build/tasks/build.yaml
kubectl apply -f build/pipelines.yaml
kubectl apply -f build/triggers.yaml


