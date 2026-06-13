# Phase 3: Workload Cluster

## 状態

Planned

想定リリース:

* v0.2.0-workload-cluster

---

## 背景

v0.1.0-bootstrap では、管理系コンポーネントと研究ワークロードの実行を同一 Kubernetes クラスタ上で実施している。

現在の構成:

```text
Harvester
│
└── rancher-mgmt-02
    ├── Rancher
    ├── Argo CD
    ├── Experiment
    ├── AgentTask
    └── Research Job
```

この構成は初期検証には有効であるが、研究ワークロードの増加に伴い、管理系と実行系を分離する必要がある。

---

## 目的

Research Fabric Lab において、

* 管理系クラスタ
* 実行系クラスタ

を分離する。

これにより、量子計算、HPC、AI、最適化ワークロードを独立して実行できる基盤を構築する。

---

## Target Architecture

```text
Harvester
│
├── rancher-mgmt-02
│   (Management Cluster)
│
│   ├── Rancher
│   ├── Argo CD
│   ├── Research CRDs
│   ├── Experiment
│   └── AgentTask
│
└── agent-lab-02
    (Workload Cluster)
    
    ├── K3s
    ├── Runtime Images
    ├── Research Jobs
    ├── NetKet
    ├── Qiskit
    └── HPC Workloads
```

---

## Candidate Workload Node

初期 Workload Cluster として以下を利用する。

VM:

```text
agent-lab-02
```

現在の用途:

* Agent Fabric Lab 開発環境

将来的には以下を兼ねる。

* Research Worker Node
* Runtime Image 検証環境
* Operator 開発環境

---

## Phase 3 Tasks

### Task 1

agent-lab-02 の現状調査

確認項目:

* CPU
* Memory
* Disk
* Docker
* Kubernetes
* Git Repository

---

### Task 2

K3s 導入

目的:

Workload Cluster 化

想定構成:

```text
Single Node K3s
```

---

### Task 3

Rancher Import

目的:

Management Cluster から管理する。

完成後:

```text
Rancher
↓
Local Cluster

Rancher
↓
Research Worker Cluster
```

の 2 クラスタ構成となる。

---

### Task 4

Runtime Image 動作確認

対象:

```text
quantum-python-base
```

確認内容:

* Image Pull
* Job 実行
* JSON 出力

---

### Task 5

Experiment 実行先分離

将来的に Experiment は実行先クラスタを選択可能とする。

イメージ:

```yaml
spec:
  runtime:
    cluster: local
```

または

```yaml
spec:
  runtime:
    cluster: research-worker
```

---

## Success Criteria

以下を満たした時点で Phase 3 完了とする。

* agent-lab-02 に K3s 導入完了
* Rancher Import 完了
* Runtime Image Pull 成功
* Research Job 実行成功
* 結果 JSON 出力成功

---

## Relationship to Future Phases

Phase 3 完了後、

Research Fabric Lab は以下の構成となる。

```text
GitHub
↓
Argo CD
↓
Experiment

Experiment
↓
Workload Cluster
↓
Runtime Image
↓
Research Job
↓
Result
```

この構成を基盤として、

Phase 4 Research Portal

および

Phase 5 Experiment Operator

へ進む。
