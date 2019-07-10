# Intro

[PiggyMetrics}(https://github.com/sqshq/piggymetrics) is great to demonstrate Microservice Architecture with Spring Boot, Spring Cloud and Docker.

# Demo

This guide will deploy PiggyMetrics to ACK.

Prerequisites:
1. A working Kubernetes cluster
2. A valid kubectl [installation](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [configured](https://www.alibabacloud.com/help/doc-detail/86494.htm)
3. [Kompose](http://kompose.io/installation/) and [HELM](https://helm.sh/docs/using_helm/#installing-helm)

## Step 1: prepare the Docker Compose files

PiggyMetrics uses Docker Compose files for definitions, to deploy it to ACK, we will use [Kompose](http://kompose.io) to translate them to Kubernetes deployment files.

PiggyMetrics uses two Docker Compose files:

```
docker-compose.yml
docker-compose.dev.yml
```

1. For both files, change the Docker compose version from `2.1` to `2` as Kompose doesn't support 2.1.

```JSON
version: '2'
```

2. For `docker-compose.yml`, modify the unsupported syntax

Replace the following from

```YAML
depends_on:
  config:
    condition: service_healthy  #condition is not supported
```

to

```YAML
depends_on:
  - config
labels:
  kompose.service.type: loadbalancer
```

3. For `docker-compose.dev.yml`, fix the MongoDB exposed ports

The MongoDB external ports don't match with the required ports defined in each application, we will fix those. There are a total of four MongoDB definitions:

```YAML
auth-mongodb
account-mongodb
statistics-mongodb
notification-mongodb
```

Modify the exposed ports to `27017`, e.g. for `auth-mongodb`, it should be changed to below:

```YAML
auth-mongodb:
  build: mongodb
  ports:
    - 27017:27017
```

## Step 2: generate the HELM installation file

1. Export variables

```
export NOTIFICATION_SERVICE_PASSWORD=passw0rd
export CONFIG_SERVICE_PASSWORD=passw0rd
export STATISTICS_SERVICE_PASSWORD=passw0rd
export ACCOUNT_SERVICE_PASSWORD=passw0rd
export MONGODB_PASSWORD=passw0rd
```

2. Generate HELM deployment files using Kompose

Use Kompose to convert the Docker Compose files to Kubernetes configuration files. Please beware that we will take two inputs together.

```
kompose convert -f docker-compose.yml -f docker-compose.dev.yml -o piggymetrics -c
```

## Step 3: install with HELM

The following will install the application to namespace `pm`, and name the deployment `piggy`.

```
helm install --namespace pm --name piggy piggymetrics/
```

> Note: fix HELM version mismatch

You may encounter the following error, this is due to client and server version mismatch.

```
Error: incompatible versions client[v2.14.1] server[v2.11.0]
```

If you are using macOS, please try the following to get HELM v2.11.0.

```
brew unlink kubernetes-helm
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/ee94af74778e48ae103a9fb080e26a6a2f62d32c/Formula/kubernetes-helm.rb
```

## Step 4: view and clean up

You can now access app via the `gateway` service address.

Use the following to remove PiggyMetrics:

```
helm delete --purge piggy
```
