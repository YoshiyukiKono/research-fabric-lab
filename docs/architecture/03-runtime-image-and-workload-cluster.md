# Runtime Image と Workload Cluster の設計

## 概要

Research Fabric Lab では、量子・HPC・最適化ライブラリを Kubernetes クラスタへ直接インストールしない。

クラスタ側は実行基盤として保ち、ライブラリは Runtime Image に閉じ込める。

```text
Kubernetes Cluster
├─ Argo CD
├─ CRD
├─ Operator / Controller
├─ Namespace / RBAC
└─ Job 実行基盤

Runtime Image
├─ Python
├─ numpy / scipy
├─ NetKet
├─ Qiskit
├─ QuTiP
└─ TeNPy
```

## 基本方針

### クラスタ側に置くもの

- Argo CD
- Namespace
- CRD
- Operator / Controller
- RBAC
- Storage
- Observability

### Runtime Image に置くもの

- Python 実行環境
- 数値計算ライブラリ
- 量子計算ライブラリ
- 実験コード

## なぜ Runtime Image に分けるのか

量子・HPC 系ライブラリは依存関係が重く、バージョン差分も大きい。

これらをクラスタノードへ直接入れると、実験ごとの再現性が失われる。

そのため、Research Fabric Lab では以下の分離を採用する。

```text
クラスタ = 実行基盤
Runtime Image = 実験環境
Experiment = 研究意図
Job = 実行単位
```

## 現在の構成

現時点では、Rancher 管理VM上の K3s クラスタで Argo CD と実験Jobを同居させている。

```text
rancher-mgmt-02
├─ K3s
├─ Rancher
├─ Argo CD
├─ research namespace
└─ Experiment Jobs
```

これは Day 1 / Day 2 の検証構成として妥当である。

## 今後の Workload Cluster 構成

今後、実験実行先として `agent-lab-02` VM を Workload Cluster として利用する。

```text
Management Cluster: rancher-mgmt-02
├─ Rancher
├─ Argo CD
├─ Research Fabric control components
└─ GitOps control

Workload Cluster: agent-lab-02
├─ K3s / RKE2
├─ Experiment Jobs
├─ Runtime Images
└─ Result artifacts
```

この分離により、Rancher / Argo CD / Operator などの管理系と、量子・HPC ジョブの実行系を分けられる。

## Experiment における runtime 指定案

将来的には `Experiment` に runtime 情報を持たせる。

```yaml
spec:
  engine: netket
  runtime:
    image: ghcr.io/yoshiyukikono/research-fabric-lab/netket-runtime:latest
    cluster: agent-lab-02
    resources:
      cpu: "4"
      memory: "8Gi"
```

当面は Operator 未実装のため、Job YAML 側に image を直接指定する。

## Runtime Image の段階

```text
quantum-python-base
↓
netket-runtime
↓
qiskit-runtime
↓
teNPy / tensor-network runtime
↓
GPU対応 runtime
```

最初は `quantum-python-base` を作成し、GHCR に publish する。
