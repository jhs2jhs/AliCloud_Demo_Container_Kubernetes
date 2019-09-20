# What is this?

The Log Service integrates with Ingress very well and it's easy to achieve logging and monitoring.

Full [doc](https://www.alibabacloud.com/help/doc-detail/86532.htm).

# Install Log Service component in a K8s cluster

The installation needs three parameters, Alibaba Cloud account ID, K8s cluster ID and the region ID for the cluster.

```
wget https://acs-logging.oss-cn-hangzhou.aliyuncs.com/alicloud-k8s-log-installer.sh -O alicloud-k8s-log-installer.sh; chmod 744 ./alicloud-k8s-log-installer.sh; ./alicloud-k8s-log-installer.sh --cluster-id ${your_k8s_cluster_id} --ali-uid ${your_ali_uid} --region-id ${your_k8s_cluster_region_id}
```

```
kubectl apply -f nginx-ingress.yml
```
