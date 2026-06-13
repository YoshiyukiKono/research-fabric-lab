# Argo CD Project Operations Cheat Sheet

Research Fabric Lab Notes

Version: 1.0

---

# 1. Argo CD とは何か

一言で言うと、

> Git Repository を Kubernetes の Desired State として維持するシステム

である。

Argo CD は Kubernetes を直接管理するのではなく、

Git を管理する。

```text
Git
 ↓
Argo CD
 ↓
Kubernetes
```

---

# 2. Argo CD の基本オブジェクト

理解すべきものは4つだけ。

```text
Repository
Application
Project
Cluster
```

---

## Repository

Git Repository

例:

```text
github.com/YoshiyukiKono/research-fabric-lab
```

Argo CD はここを参照する。

---

## Application

最重要オブジェクト。

Application は

```text
Gitのどこを
どのクラスタへ
同期するか
```

を表す。

例:

```yaml
spec:
  source:
    path: deploy/k8s/platform

  destination:
    namespace: default
```

---

## Project

Application を束ねる論理グループ。

例:

```text
research
platform
monitoring
```

大規模環境で利用。

小規模環境では default のままでもよい。

---

## Cluster

同期先 Kubernetes Cluster。

```text
local
worker-01
gpu-cluster
edge-factory-a
```

など。

---

# 3. GitOps の本質

Argo CD の世界では

```text
Git
=
Desired State
```

である。

つまり

```bash
kubectl apply
```

よりも

```bash
git commit
git push
```

が重要。

---

# 4. Repository 構造

推奨構成

```text
deploy/
├── argocd/
│   └── apps/
│
└── k8s/
    ├── namespaces/
    ├── platform/
    ├── monitoring/
    └── workloads/
```

考え方:

```text
apps/
↓
目次

k8s/
↓
本文
```

---

# 5. App of Apps

最重要パターン。

```text
root
│
├── namespaces
├── platform
├── monitoring
└── workloads
```

Application が Application を管理する。

メリット:

* 構造化
* 拡張容易
* Git Repository と対応

---

# 6. Typical Project Layout

```text
research-fabric-root

├── research-namespaces
├── research-platform
├── research-crds
├── research-monitoring
└── research-experiments
```

---

# 7. Sync Status の意味

## Synced

理想状態と一致

```text
Git
=
Cluster
```

---

## OutOfSync

差分あり

```text
Git
≠
Cluster
```

---

## Unknown

取得失敗

例:

* Repository Error
* Authentication Error

---

# 8. Health Status

## Healthy

正常

---

## Progressing

適用中

---

## Missing

リソース未作成

---

## Degraded

異常状態

Pod CrashLoop など。

---

# 9. Manual Change の扱い

例:

```bash
kubectl patch
```

できる。

しかし推奨ではない。

理由:

```text
Git
≠
Cluster
```

になる。

原則:

```text
修正
↓
Gitへ反映
↓
ArgoCD Sync
```

---

# 10. Namespace → CRD → Resource

依存関係の基本。

```text
Namespace
 ↓
CRD
 ↓
Custom Resource
```

順番を間違えると同期失敗。

---

# 11. Platform Resources

研究ワークロードと分離する。

例:

```text
platform/

argocd-ingress
grafana-ingress
cert-manager
```

---

# 12. Workloads

研究ジョブ。

例:

```text
experiments/

ising
qaoa
netket
```

---

# 13. Multi Cluster

推奨構成。

```text
Management Cluster

Rancher
Argo CD
```

↓

```text
Workload Cluster

CPU
GPU
HPC
```

Argo CD は複数クラスタを管理可能。

---

# 14. Runtime Image

Kubernetes にライブラリを入れない。

代わりに

```text
Runtime Image
```

を使う。

例:

```text
quantum-python-base
netket-runtime
qiskit-runtime
```

---

# 15. Argo CD 運用の原則

## Principle 1

Git が真実

---

## Principle 2

Application を小さく保つ

---

## Principle 3

App of Apps を利用

---

## Principle 4

Platform と Workload を分離

---

## Principle 5

Management と Worker を分離

---

# 16. Research Fabric Lab における位置付け

```text
GitHub
 ↓
Argo CD
 ↓
Experiment
 ↓
Runtime Image
 ↓
Job
 ↓
Result
```

Argo CD は

研究を実行する仕組みではない。

研究基盤全体を Desired State として管理する仕組みである。
