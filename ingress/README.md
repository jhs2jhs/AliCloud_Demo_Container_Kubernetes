# Add a simple routing for the app

We have deployed a Spring Cloud app named [PiggyMetrics](../app/piggymetrics/). Now we add an Ingress traffic wrapper around it to have better monitoring of it.

Create a `ingress-pig.yml` file with the following content, you should modify the `host` field accordingly.

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-pig
  namespace: pm
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: piggymetrics.returntrue.cc
    http:
      paths:
      - path: /
        backend:
          serviceName: gateway
          servicePort: 80
```

Create the extension:

```
kubectl create -f ingress-pig.yml
```

Check the Ingress from console or:

```
kubectl get ingress --namespace=pm
```

The results look like this:

```
NAME            HOSTS                        ADDRESS       PORTS   AGE
ingress-piggy   piggymetrics.returntrue.cc   8.208.25.31   80      19m
```

Next we bind the domain name to the Ingress IP address.

Update the DNS or modify the `hosts` file.

```
nano /etc/hosts
```

Add the following to hosts:

```
8.208.24.241  piggymetrics.returntrue.cc
```
