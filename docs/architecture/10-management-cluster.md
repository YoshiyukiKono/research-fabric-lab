

# Management Cluster

## Purpose

Management Cluster は Research Fabric Lab 全体を管理する中枢である。

研究ジョブの実行ではなく、

管理・制御・保存を担当する。

---

## Current Node

```text
rancher-mgmt-02
```

Platform

```text
Harvester
 └ rancher-mgmt-02
```

---

## Responsibilities

### Rancher

マルチクラスタ管理

### ArgoCD

GitOps管理

### Research Resources

* Experiment CRD
* AgentTask CRD

### Artifact Storage

MinIO

### Runtime Catalog

実験実行用コンテナイメージ

---

## Current Flow

```text
GitHub
 ↓
ArgoCD
 ↓
Kubernetes Resources
```

---

## Storage

Current:

```text
local-path
```

Future:

```text
Longhorn
```

---

## Design Decision

管理クラスタは計算を行わない。

役割は以下に限定する。

* Control Plane
* GitOps
* Artifact Storage
* Metadata
