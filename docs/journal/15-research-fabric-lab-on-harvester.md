# Journal: Research Fabric Lab on Harvester

## Date

2026-06-27

## Goal

Build a small but working research platform on Harvester using:

- Rancher
- workload K3s
- Ubuntu Jump Host
- Agent Fabric Lab
- Research Fabric Lab
- Argo CD
- MinIO
- Streamlit Research Portal

## Summary

The lab successfully reached the point where:

- Rancher can manage the workload K3s cluster.
- Jump Host can operate workload K3s via kubeconfig.
- Agent Fabric Lab runs Ollama, agents, and orchestrator UI.
- Research Fabric Lab is synced by Argo CD.
- Experiment and AgentTask CRDs are installed.
- MinIO is running with a 100Gi local-path PVC.
- Research Portal is accessible by browser.
- Portal can create runtime Jobs.
- Runtime Jobs can write artifacts to MinIO after DNS/Secret fixes.

## Key steps

### 1. Rancher and workload K3s

Two SLE Micro VMs were used:

```text
rancher-mgmt  10.110.1.211
k3s-server    10.110.1.212
```

The workload cluster was imported into Rancher and became Active.

### 2. Ubuntu Jump Host

Ubuntu VM:

```text
jump-host  10.110.1.213
```

It was used for:

- Git clone
- kubectl
- Docker build
- scp image tar files
- deployment operations

### 3. Agent Fabric Lab

Repository:

```text
https://github.com/YoshiyukiKono/agent-fabric-lab
```

Images were built on Jump Host, copied to K3s VM, imported into K3s containerd, and deployed.

Confirmed:

- Ollama running
- agents running
- orchestrator running
- UI accessible

### 4. Research Fabric Lab

Repository:

```text
https://github.com/YoshiyukiKono/research-fabric-lab
```

Argo CD was installed with server-side apply because normal apply hit the large CRD annotation limit.

```bash
kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Then:

```bash
kubectl apply -f deploy/argocd/root-app.yaml
```

Applications reached `Synced / Healthy`.

### 5. MinIO

MinIO deployed in namespace:

```text
storage
```

Services:

```text
minio           9000
minio-console   9001
```

Ingress:

```text
minio.lab.local
console.minio.lab.local
```

Bucket:

```text
research-artifacts
```

### 6. Research Portal

The Streamlit portal existed under:

```text
deploy/k8s/workload/research-portal
```

It was not part of App of Apps, so it was applied directly:

```bash
kubectl apply -k deploy/k8s/workload/research-portal
```

Ingress:

```text
portal.agent.lab.local
```

### 7. Issues and fixes

#### Argo CD CRD annotation too long

Error:

```text
metadata.annotations: Too long
```

Fix:

```bash
kubectl apply --server-side
```

#### research-platform Unknown

Cause:

`deploy/k8s/platform/kustomization.yaml` attempted to patch `argocd-server`, but the Deployment was not in the same Kustomize resource set.

Fix:

Remove the invalid patch from the GitHub repository and force Argo CD refresh.

#### Portal Job CreateContainerConfigError

Cause:

```text
secret "minio-credentials" not found
```

Fix:

Create secret in `research` namespace.

```bash
kubectl create secret generic minio-credentials \
  -n research \
  --from-literal=MINIO_ACCESS_KEY=minio \
  --from-literal=MINIO_SECRET_KEY=minio12345 \
  --from-literal=MINIO_ENDPOINT=http://minio.storage.svc.cluster.local:9000
```

Later we found the Portal-generated Job expected:

```text
MINIO_ACCESS_KEY
MINIO_SECRET_KEY
```

not AWS-style key names.

#### MinIO DNS problem

Portal-generated Jobs used:

```text
minio.lab.local:80
```

Pods could not resolve `minio.lab.local`.

Fix:

Add hostnames to CoreDNS `NodeHosts`:

```text
10.110.1.211 rancher.demo.local
10.110.1.212 k3s-server
10.110.1.212 minio.lab.local
10.110.1.212 console.minio.lab.local
10.110.1.212 portal.agent.lab.local
```

Then restart CoreDNS.

```bash
kubectl -n kube-system rollout restart deployment coredns
kubectl -n kube-system rollout status deployment coredns
```

## Final state

Confirmed:

```text
Rancher: active
workload-k3s: active
Agent Fabric Lab: running
Research Fabric Lab: synced
Argo CD: healthy
MinIO: running
Research Portal: running
Portal-created Job: successful after DNS/Secret fixes
Artifact path: s3://research-artifacts/ising-1d-demo/runs/<run_id>/result.json
```
