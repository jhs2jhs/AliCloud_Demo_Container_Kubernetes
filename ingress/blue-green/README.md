# What is this?

Use Ingress, we can create blue-green deployment very quickly.

We have already deployed PiggyMetrics in namespace `pm`, let's deploy another lightweight app in the same namespace.

```
kubectl create -f sample-app.yml --namespace pm
```

The above application will create a service called `old-nginx`.

The we modify the Ingress definition to load balance the two apps.

First, we add an extra annotation in `annotations`:

```yaml
nginx.ingress.kubernetes.io/service-weight: 'gateway: 60, old-nginx: 40'
```

Then we add a new back end for the path `/`:

```yaml
- backend:
    serviceName: old-nginx
    servicePort: 80
  path: /
```

The modified file can be found in this repo.

Then we update the YAML file for the Ingress. It can be done both from the command line and from the web console, let's do the later one.

```
kubectl edit ingress ingress-piggy --namespace pm
```

Then let's run some stress test on the new setup and monitor the blue-green Ingress logs.
