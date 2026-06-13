# ターゲットアーキテクチャ

## 全体像

```text
GitHub Repository
├─ deploy/
│  ├─ argocd/
│  └─ k8s/
├─ experiments/
├─ apps/
├─ agents/
└─ docs/

        ↓

Argo CD
        ↓
Kubernetes Cluster on Harvester
        ↓
Namespace / CRD / Experiment / AgentTask / Job
```

## レイヤー

### 1. GitOps Layer

GitHub を唯一の宣言的状態として扱う。Argo CD は GitHub リポジトリを監視し、クラスタ状態を同期する。

### 2. Research Abstraction Layer

`Experiment` と `AgentTask` を研究ワークロードの抽象表現として扱う。

### 3. Execution Layer

初期段階では Kubernetes Job を直接利用する。将来的には Operator が `Experiment` から Job / Workflow を生成する。

### 4. AI Assistance Layer

AI は以下を支援する。

- Experiment YAML の生成
- AgentTask の生成
- レポート草稿の作成
- 結果解釈
- Pull Request 作成

AI はクラスタへ直接変更を加えない。
