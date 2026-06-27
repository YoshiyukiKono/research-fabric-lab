# GitOps Flow

## Repository roles

```text
agent-fabric-lab
  Agent runtime MVP:
    - Ollama
    - agent containers
    - orchestrator

research-fabric-lab
  Research platform:
    - Argo CD applications
    - CRDs
    - MinIO
    - Research Portal
    - experiment definitions
```

## Argo CD structure

Research Fabric Lab uses App of Apps.

```text
deploy/argocd/root-app.yaml
  |
  +-- research-namespaces
  +-- research-crds
  +-- research-experiments
  +-- research-storage
  +-- research-platform-minio
```

## Manual vs GitOps-managed items

Currently GitOps-managed:

- Research namespaces
- CRDs
- Experiment and AgentTask resources
- MinIO chart via Argo CD
- Storage application

Currently manual or semi-manual:

- K3s installation
- Rancher installation
- workload-k3s import
- CoreDNS NodeHosts customization
- Agent Fabric local image import
- Research Portal direct `kubectl apply -k`

## Future improvement

Move cluster-level bootstrap into a dedicated repository:

```text
cluster-bootstrap
├── coredns/
├── ingress/
├── rancher/
├── storage/
└── jump-host/
```

Then keep application repositories focused on application concerns.
