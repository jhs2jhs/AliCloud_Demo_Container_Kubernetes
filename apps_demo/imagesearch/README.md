


## v1: build jupyter notebook and then create imagesearch services
kubectl create -f v1_jupyternotebook-deployment.yaml --namespace imagesearch

## v2: use secret in jupyter notebook

## v5: pre clone code and mount into jupyter notebook

## v6: initContainer with right code
```
kubectl create namespace imagesearch

kubectl apply -f v6_imagesearch_deployment.ymal --namespace imagesearch

kubectl port-forward pods/jupyter-notebook-57c9988765-x26dj 8888:8888 --namespace imagesearch
# view http://localhost:8888
# git clone https://github.com/jianhuashao/AlibabaCloud_ImageSearch_Demo_py2.git

kubectl delete -f v6_imagesearch_deployment.ymal --namespace imagesearch
```


## jupyter notebook
https://cwienczek.com/2018/05/jupyter-on-kubernetes-the-easy-way/

## git-clone
https://gist.github.com/tallclair/849601a16cebeee581ef2be50c351841


