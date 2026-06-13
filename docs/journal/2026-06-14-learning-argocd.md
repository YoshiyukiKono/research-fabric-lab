# Argo CD を初めて本格的に触って分かったこと 〜 GitOps は「デプロイツール」ではなく「状態管理モデル」だった

## はじめに

最近、Harvester 上に構築した Rancher 管理クラスタへ Argo CD を導入し、自作の Research Fabric Lab を構築している。

最初は、

「GitHub の YAML を Kubernetes に同期するツール」

くらいの理解だった。

しかし実際に、

* Argo CD 導入
* App of Apps 構成
* CRD 管理
* Runtime Image 管理
* GitHub Actions 連携
* Ingress 公開

まで行った結果、Argo CD は単なるデプロイツールではなく、

> Kubernetes クラスタの状態を Git を基準として維持する仕組み

であることが理解できた。

この記事では、その過程で得た知見を整理する。

---

# 最初の誤解

導入前の認識は、

```text
GitHub
↓
ArgoCD
↓
kubectl apply
```

だった。

つまり、

「自動 kubectl apply」

のようなものだと思っていた。

しかし実際には違った。

Argo CD が管理しているのは、

```text
Desired State
```

である。

Git に書かれている状態を、

クラスタの理想状態として扱う。

---

# App of Apps が理解の転換点だった

最初に戸惑ったのは App of Apps だった。

構成は次のようになった。

```text
research-fabric-bootstrap
│
└── research-fabric-root
    │
    ├── research-namespaces
    ├── research-crds
    ├── research-platform
    └── research-experiments
```

最初は、

「なぜ Application の中に Application があるのか」

が分からなかった。

しかし実際には、

Argo CD 自身が管理対象を持つことで、

構成全体を階層化できる。

結果として、

GitHub リポジトリの構造と

Kubernetes クラスタの構造が対応する。

---

# Application は目次だった

途中でようやく整理できた。

例えば、

```text
deploy/argocd/apps/platform.yaml
```

は Kubernetes リソースではない。

これは

```text
Argo CD がどこを同期するか
```

を定義している。

一方、

```text
deploy/k8s/platform/
```

には実際の Kubernetes リソースが存在する。

つまり、

```text
deploy/argocd/apps/
```

は目次。

```text
deploy/k8s/
```

は本文。

という構造になる。

この理解は非常に重要だった。

---

# GitOps の本質

途中で何度も

```bash
kubectl patch
```

を実行した。

例えば、

```bash
kubectl patch application ...
```

や

```bash
kubectl patch configmap ...
```

である。

ここで気付いた。

GitOps の本質は、

「クラスタを変更すること」

ではない。

本質は、

```text
Git Repository
=
Cluster State
```

を維持することである。

手動変更はできる。

しかし、

最終的には Git に戻す必要がある。

---

# CRD 管理が面白かった

今回、

Experiment

および

AgentTask

という独自 CRD を作成した。

最初は、

```text
Experiment
↓
Job
```

の関係を YAML だけで表現していた。

すると、

Argo CD が

```text
CRDが存在しない
```

と怒る。

当然である。

ここで、

```text
Namespace
↓
CRD
↓
Custom Resource
```

の順序が必要であることを学んだ。

Kubernetes らしい依存関係が見えてきた。

---

# Runtime Image と GitOps

今回最も面白かったのは Runtime Image だった。

GitHub Actions で

```text
quantum-python-base
```

をビルドし、

GHCR に公開した。

そして、

Kubernetes Job から利用した。

構成としては、

```text
GitHub
↓
Actions
↓
GHCR
↓
Kubernetes Job
```

となる。

ここで、

研究コードそのものを Kubernetes に入れるのではなく、

Runtime Image として管理する考え方が見えてきた。

---

# Argo CD を公開する

最初は

```bash
kubectl port-forward
```

で利用していた。

しかし、

```text
https://argocd.lab.local
```

でアクセスしたくなった。

Ingress を作成したが、

最初は

```text
Internal Server Error
```

になった。

原因は

```text
Traefik
↓ HTTPS
ArgoCD
```

の TLS 処理だった。

最終的には、

Argo CD を insecure mode にし、

```text
Traefik
↓ HTTP
ArgoCD
```

で解決した。

この経験で、

Ingress と Backend Service の関係も理解が深まった。

---



## OutOfSync の原因調査

research-experiments Application が OutOfSync になった。

Argo CD UI の DIFF を確認すると、

以下の Job が表示された。

- ising-netket-001
- ising-python-result-001

DIFF では、

左側に Job 定義全体が表示され、
右側は空白となっていた。

これは、

「Cluster に存在するが、Git 上の Desired State に存在しない」

ことを意味していた。

### 原因

調査の結果、

以下のファイル名にタイポが存在した。

```text
job-bootstrap-placeholder.yam
````

本来は

```text
job-bootstrap-placeholder.yaml
```

である。

Argo CD は `.yaml` を Kubernetes Manifest として解釈するが、

`.yam`

は同期対象として認識されない。

その結果、

Argo CD の Desired State から Job が消えた状態となった。

一方、

クラスタ上には以前作成された Job が残っていたため、

```text
Git
≠
Cluster
```

となり OutOfSync が発生した。

### 修正

ファイル名を修正。

```text
job-bootstrap-placeholder.yam
↓
job-bootstrap-placeholder.yaml
```

その後、

```bash
kubectl annotate application research-experiments -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

を実行。

OutOfSync が解消された。

### 学び

Argo CD は

「Git にファイルが存在するか」

ではなく、

「Git から生成される Kubernetes Manifest が何であるか」

を管理している。

ファイル名の拡張子やディレクトリ構造の変化は、

Desired State の変化として扱われる。


ArgoCDはファイルを見ているのではなく、生成されたManifestを見ている。










# Argo CD は Kubernetes の学習装置でもある

今回強く感じたのは、

Argo CD を使うと Kubernetes を深く理解せざるを得ないということだった。

* Namespace
* CRD
* Application
* Ingress
* Service
* Job
* Image Registry

がすべて繋がる。

結果として、

Argo CD を学んだというより、

Kubernetes 全体の構造理解が進んだ。

---

# 今後

Research Fabric Lab では次に、

```text
Management Cluster
```

と

```text
Workload Cluster
```

を分離する予定である。

```text
rancher-mgmt-02
```

を管理クラスタ、

```text
agent-lab-02
```

を実行クラスタとして利用する。

その上で、

* Research Portal
* Experiment Operator
* AI Generated PR

へ発展させたいと考えている。

---

# おわりに

今回の経験を一言で表すなら、

> Argo CD はデプロイツールではなく、クラスタの状態管理モデルだった

ということになる。

GitOps は単なる自動化ではない。

Git を単一の真実の源泉（Single Source of Truth）として扱う運用モデルそのものである。

そして Argo CD は、そのモデルを Kubernetes 上で実現するための非常に強力な実装である。
