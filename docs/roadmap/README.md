# Roadmap

Research Fabric Lab は、研究ワークロードを GitOps と Kubernetes によって管理・実行する実験基盤である。

## Phase 1: Bootstrap

状態: 完了

目標:

- Harvester 上に管理用 Kubernetes 環境を用意する
- Argo CD を導入する
- GitHub から Kubernetes リソースを同期する
- Experiment / AgentTask CRD を導入する
- 最初の Job を実行する

対応リリース:

- v0.1.0-bootstrap

## Phase 2: Runtime Image

状態: 完了

目標:

- 研究ワークロード用 Runtime Image を定義する
- GitHub Actions で build する
- GHCR に publish する
- Kubernetes Job から Runtime Image を利用する

成果:

- quantum-python-base
- ising-python-runtime-001

## Phase 3: Workload Cluster

状態: 次に着手

目標:

- agent-lab-02 を Workload Cluster として構成する
- K3s を導入する
- Rancher に Import する
- 管理クラスタと実行クラスタを分離する
- Runtime Image を Workload Cluster 側で実行する

想定リリース:

- v0.2.0-workload-cluster

## Phase 4: Research Portal MVP

状態: 計画中

目標:

- UIから Experiment YAML を生成する
- Runtime Image / Engine / Parameters を選択できるようにする
- 生成された YAML を人間が確認できるようにする
- 将来的な AI-generated PR の入口にする

## Phase 5: Experiment Operator

状態: 計画中

目標:

- Experiment CRD を監視する Controller を実装する
- Experiment から Job を自動生成する
- Result / AgentTask との連携を設計する

## Phase 6: AI-generated PR

状態: 将来構想

目標:

- 自然言語から Experiment / AgentTask を生成する
- GitHub Pull Request を作成する
- Human Review 後に GitOps で反映する
