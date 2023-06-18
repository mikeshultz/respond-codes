# Devops

## Build Docker Image

Docker image needs to be built and added to the registry.

    ./deploy.sh

## Deploy via Helm

### First Install

#### Prerequisites

You also need to make sure an [ingress controller](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/) and [cert-manager](https://cert-manager.io/docs/installation/helm/) is installed.

#### Install

```bash
helm install --create-namespace -n respond respond devops/kubernetes/charts/respond -f devops/kubernetes/charts/respond/values.yaml -f devops/kubernetes/values/respond.yaml
```

### Upgrade

```bash
helm upgrade -n respond respond devops/kubernetes/charts/respond -f devops/kubernetes/charts/respond/values.yaml -f devops/kubernetes/values/respond.yaml
```
