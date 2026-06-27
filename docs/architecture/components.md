# Component Architecture

## Harvester

Harvester provides the VM layer.

VMs:

| VM | OS | Purpose |
|---|---|---|
| `rancher-mgmt` | SLE Micro | Rancher Manager |
| `k3s-server` | SLE Micro | workload K3s cluster |
| `jump-host` | Ubuntu | Git/Kubernetes operations |

## Rancher

Rancher runs on `rancher-mgmt` and imports `workload-k3s`.

## workload-k3s

The application runtime cluster. It hosts:

- Agent Fabric Lab
- Research Fabric Lab
- Argo CD
- MinIO
- Research Portal
- Experiment runtime Jobs

## Jump Host

The operational entry point.

Installed or used tools:

- `git`
- `kubectl`
- `docker`
- `scp`
- cloned repositories:
  - `agent-fabric-lab`
  - `research-fabric-lab`

## Agent Fabric Lab

Runs:

- Ollama
- Researcher
- Architect
- Reviewer
- Orchestrator

The Orchestrator UI is exposed by NodePort.

## Research Fabric Lab

Runs:

- Argo CD App of Apps
- `Experiment` CRD
- `AgentTask` CRD
- MinIO artifact storage
- Research Portal
- runtime Jobs

## MinIO

Used for artifact storage.

Bucket:

```text
research-artifacts
```

Credentials used in the lab:

```text
rootUser: minio
rootPassword: minio12345
```

## Research Portal

Streamlit-based UI deployed to the `research` namespace.

It creates Kubernetes Jobs and displays the expected artifact path.
