# tekton example

```
cd k8s
./install.sh
```


Fork https://github.com/bitsofinfo/nginx-hello-world

* settings -> webhooks -> add webhook





kubectl run -it --serviceaccount=cicd-tekton --namespace tekton-pipelines  cicd-toolbox --image bitsofinfo/cicd-toolbox:latest /bin/bash 


kubectl get svc registry --output=jsonpath='{.spec.clusterIP}' --namespace=kube-system


https://github.com/kameshsampath/minikube-helpers/blob/master/registry/README.md

https://developers.redhat.com/blog/2019/07/11/deploying-an-internal-container-registry-with-minikube-add-ons/