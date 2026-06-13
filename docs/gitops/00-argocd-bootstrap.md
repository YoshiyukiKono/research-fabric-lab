# Argo CD bootstrap

## MVP approach

Install Argo CD into the `argocd` namespace, then create an app-of-apps pointing at this repository.

## Manual install example

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## App of apps

Apply:

```bash
kubectl apply -f deploy/argocd/root-app.yaml
```

The root app points Argo CD at:

```text
deploy/argocd/apps/
```

Each child app then deploys platform components, namespaces, and workloads.
