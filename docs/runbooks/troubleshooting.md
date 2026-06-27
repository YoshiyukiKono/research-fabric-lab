# Troubleshooting

## kubectl cannot connect

Error:

```text
Unable to connect to the server: dial tcp 10.110.1.212:6443: connect: no route to host
```

Check from Jump Host:

```bash
ping -c 3 10.110.1.212
nc -vz 10.110.1.212 6443
```

Check on K3s server:

```bash
sudo systemctl status k3s --no-pager
sudo ss -lntp | grep 6443
sudo journalctl -u k3s -n 80 --no-pager
```

## Argo CD CRD annotation too long

Use server-side apply:

```bash
kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Argo Application Unknown

Check:

```bash
kubectl describe application <app> -n argocd
```

If Kustomize patch target is missing, fix the repository and hard refresh:

```bash
kubectl annotate application <app> -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

## CreateContainerConfigError

Describe Pod:

```bash
kubectl describe pod -n research <pod>
```

Common cause:

```text
secret "minio-credentials" not found
```

Create:

```bash
kubectl create secret generic minio-credentials \
  -n research \
  --from-literal=MINIO_ACCESS_KEY=minio \
  --from-literal=MINIO_SECRET_KEY=minio12345 \
  --from-literal=MINIO_ENDPOINT=http://minio.storage.svc.cluster.local:9000
```

## Wrong Secret keys

If error says:

```text
couldn't find key MINIO_ACCESS_KEY in Secret research/minio-credentials
```

Ensure the Secret uses:

```text
MINIO_ACCESS_KEY
MINIO_SECRET_KEY
MINIO_ENDPOINT
```

not AWS-style key names.

## NameResolutionError for minio.lab.local

Error:

```text
Failed to resolve 'minio.lab.local'
```

Check CoreDNS:

```bash
kubectl -n kube-system get configmap coredns -o yaml | grep -A10 NodeHosts
```

Expected:

```text
10.110.1.212 minio.lab.local
```

Verify from Pod:

```bash
kubectl run -n research dns-test --rm -it \
  --image=python:3.11-slim \
  --restart=Never -- \
  python -c "import socket; print(socket.gethostbyname('minio.lab.local'))"
```

## Old failed Jobs remain

Delete them:

```bash
kubectl delete job -n research <job-name>
```

List:

```bash
kubectl get jobs,pods -n research | grep ising-1d-demo
```
