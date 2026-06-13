# Architecture overview

## Concept

Research workloads are treated as declarative, reviewable GitOps artifacts.

```text
Human / Researcher
  |
  v
Research Portal UI
  |
  v
AI Draft Generator
  |
  v
GitHub Branch / Pull Request
  |
  v
Human Review
  |
  v
Argo CD Sync
  |
  v
Kubernetes Job / Workflow
  |
  v
Results and Reports
```

## Design rule

AI must not directly apply Kubernetes resources.

```text
Avoid: AI -> kubectl apply
Prefer: AI -> Pull Request -> Human Review -> GitOps Apply
```

## Main abstractions

| Abstraction | Purpose |
|---|---|
| Experiment | Deterministic research workload specification |
| AgentTask | AI-assisted generation, interpretation, or reporting task |
| Workflow | Kubernetes execution plan derived from an Experiment |

## Initial runtime choices

| Component | MVP choice | Later option |
|---|---|---|
| Kubernetes | K3s | RKE2 |
| GitOps | Argo CD | Fleet + Argo CD |
| AI | External LLM API | Local Ollama / vLLM |
| Execution | Kubernetes Job | Argo Workflows / RayJob / MPIJob |
| Storage | PVC | MinIO / S3 |

# docs/architecture/00-overview.md

# Research Fabric Lab Architecture

## Vision

Research Fabric Lab は、GitOps を中心とした研究・実験基盤である。

研究対象は量子コンピューティングに限定されず、

* Quantum Computing
* AI / ML
* Optimization
* HPC
* Distributed Simulation

などの計算実験全般を対象とする。

---

## Design Principles

### Git as Source of Truth

すべての構成は GitHub 上で管理する。

```text
GitHub
 ↓
ArgoCD
 ↓
Kubernetes
```

### Infrastructure as Research Platform

Kubernetes を単なる実行基盤ではなく、

研究活動そのものを支えるプラットフォームとして扱う。

### Reproducible Research

研究実行環境を宣言的に管理し、

同じ実験を再現可能な状態で保持する。

### Artifact First

実験結果は必ず永続化する。

```text
Experiment
 ↓
Runtime
 ↓
Artifact
 ↓
Storage
```

---

## Current Architecture

```text
GitHub
 ↓
ArgoCD
 ↓
Management Cluster
 ↓
Workload Cluster
 ↓
Artifact Storage
```

---

## Release Status

### v0.1.0-bootstrap

* Harvester
* Rancher
* ArgoCD
* App of Apps

### v0.2.0-artifact-storage

* MinIO
* Artifact Upload
* Persistent Research Results

### v0.3.x (Planned)

* Multi Cluster Runtime
* Workload Execution
* Cluster Separation

### v0.4.x (Planned)

* Experiment Operator

### v0.5.x (Planned)

* GPU / HPC Runtime
* Distributed Simulation
* NetKet / Tensor Network

