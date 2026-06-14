

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



# Research Portal

URL

http://portal.agent.lab.local

Technology

- Streamlit
- Kubernetes Deployment
- Service
- Traefik Ingress

Purpose

Research UI for Experiment Definition

## Current Workloads

### Research Fabric Lab

- research-portal

## Existing Cluster Context

agent-lab-02 は既存のK3sクラスタである。

Research Fabric Lab では、このクラスタ上に `research` namespace を作成し、Research Portal を配置する。

既存の他namespaceや別プロジェクトのワークロードには依存しない。
