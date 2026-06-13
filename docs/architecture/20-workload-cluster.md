

# Workload Cluster

## Purpose

Workload Cluster は研究実行環境である。

実験ジョブはここで実行される。

---

## Current Cluster

```text
agent-lab-02
```

Platform

```text
K3s
```

---

## Existing Workloads

Agent Fabric Lab

* architect
* orchestrator
* researcher
* reviewer
* ollama

---

## Future Responsibilities

### Runtime Execution

```text
Experiment
 ↓
Runtime Job
```

### Distributed Workloads

* AI
* Optimization
* Quantum Simulation

### HPC Runtime

将来的なGPUノード追加を想定する。

---

## Target Architecture

```text
Management Cluster

  Rancher
  ArgoCD
  MinIO

        ↓

Workload Cluster

  Runtime
  Experiment
  Simulation
```

---

## Long Term Vision

```text
GPU Cluster
HPC Cluster
Quantum Cluster
```

を Rancher 配下で統合管理する。

Research Fabric Lab は単一クラスタではなく、

Research Fabric そのものを目指す。
