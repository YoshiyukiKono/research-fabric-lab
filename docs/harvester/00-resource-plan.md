# Harvester resource plan

## Starting assumption

Current Harvester node has approximately:

- CPU: about 15 cores
- Memory: about 31 GiB
- Storage: sufficient for lab use
- Existing Rancher VM: 8 GiB RAM
- Existing Ollama or other workload may be stopped for this project

## Recommended MVP layout

```text
Harvester
├─ rancher-mgmt-vm
│  └─ 8 GiB RAM
│
└─ research-fabric-vm
   ├─ 4-6 vCPU
   ├─ 16 GiB RAM
   ├─ 150 GiB disk
   └─ K3s + Argo CD + Research workloads
```

## Why this layout

The first version uses an external LLM API, so the platform does not need GPU memory or a local model runtime. Most memory should be reserved for Kubernetes, Argo CD, the portal/API, and experiment jobs.

## Suggested VM sizing

| VM | vCPU | Memory | Disk | Purpose |
|---|---:|---:|---:|---|
| rancher-mgmt-vm | 2-4 | 8 GiB | 80-100 GiB | Rancher management |
| research-fabric-vm | 4-6 | 16 GiB | 150 GiB | K3s/Argo CD/workloads |

## Expected research-fabric-vm memory usage

| Component | Typical memory |
|---|---:|
| K3s base | 1-2 GiB |
| Argo CD | 2-4 GiB |
| Portal/API/agent | 1-3 GiB |
| Storage services | 1-2 GiB |
| Experiment jobs | 2-8 GiB |

## Operating rule

Keep the MVP small. Stop local Ollama or another 16 GiB VM when running experiment jobs if the node is memory constrained.
