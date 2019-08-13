
# knowledge [todo]
## kubeflow
## arena

----
# demo 2: mvp london event 2019-08-14

[K8S_Machine_Learning_DEMO.ipynb](apps_demo/arena-demo-mvp/K8S_Machine_Learning_DEMO.ipynb)


----

# demo 1: purpose:
using arena to create a jupyter notebook and then run tensorflow code over gpu

#### steps

```bash

## step 1: (optional) create namespace for arena-notebook
$ kubectl create namespace arena-nb-ns

## step 2: (optional) create a PV/PVC. pvc name is arena-training-data, and make sure you buy storage package
#   1. https://github.com/jianhuashao/AliCloud_Demo_Container_Kubernetes/blob/master/pvc/arena_nas.md
#   2. https://www.alibabacloud.com/help/doc-detail/88940.htm

## step 3: (optional) you can tag a node if you want jupyter notebook pod to be deployed in a specific node. 
# go to node lists for the cluster
# select specific node and then add tag
# key=app, value=arena-nb-demo-notebook
# arena-demo-nodebook is given by bellow yaml

## step 4: create "arena-installer" pod: it will install as a kube-system pod
$ curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/install_arena.sh | \
    bash -s -- \
    --prometheus

## step 5: setup secret, jupyter notebook is running on https and require ssl
# setup domain for ssl certificate, please replace to your own domain
$ export domain="arena.cloudfoundry.top"
# setup ssl certificate according to given domain
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ./secret/tls.key \
    -out ./secret/tls.crt \
    -subj "/CN=$domain/O=$domain"
# create secret in cluster
$ kubectl create secret tls arena-nb-secret \
    --key ./secret/tls.key \
    --cert ./secret/tls.crt \
    --namespace arena-nb-ns

## step 6: setup arena jupyter notebook service
$ curl -s https://raw.githubusercontent.com/shuwei-yin/ai-starter/master/scripts/install_notebook.sh | \
    bash -s -- \
    --notebook-name arena-nb-demo \
    --namespace arena-nb-ns \
    --ingress --ingress-domain $domain \
    --ingress-secret arena-nb-secret \
    --pvc-name arena-training-data
# pvc name come from step 2

## step 7: get notebook access token
$ curl -s https://raw.githubusercontent.com/AliyunContainerService/ai-starter/master/scripts/print_notebook.sh | \
    bash -s -- \
    --notebook-name arena-nb-demo \
    --namespace arena-nb-ns

## step 8: (option) set service or ingress to exposure ip access 
# 1. config ingress
# 2. config service

## steps 100: (optional) house keeping to remove all resource
$ kubectl delete statefulsets arena-nb-demo-notebook -n arena-nb-ns
$ kubectl delete pods arena-nb-demo-notebook-0 -n arena-nb-ns
$ kubectl delete secret arena-nb-secret -n arena-nb-ns
$ kubectl delete namespace arena-nb-ns ## very carefully on using this
$ # delete pvc


```