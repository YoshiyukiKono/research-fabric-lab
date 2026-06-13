# research-fabric-lab

Research Fabric on Kubernetes is a GitOps-driven reference architecture for running quantum, HPC, OR, and AI-agent assisted research workloads on Kubernetes.

The first milestone is intentionally small:

1. A user describes a research intent in a UI.
2. An AI agent generates a GitHub Pull Request containing an experiment spec.
3. A human reviews and merges it.
4. Argo CD applies the workload to Kubernetes.
5. The experiment runs as a Kubernetes Job and stores results.
6. A report agent may later generate a report Pull Request.

Core principle:

> AI generates PR. Human reviews. GitOps applies.

## Repository map

```text
docs/                     Design notes and architecture documents
infra/harvester/           Harvester VM and cloud-init definitions
deploy/                    Argo CD and Kubernetes manifests
apps/                      Portal/API/agent application skeletons
contracts/                 JSON schemas for Experiment and AgentTask
experiments/               Example experiment definitions
templates/                 Reusable experiment/report templates
scripts/                   Helper scripts
.github/workflows/         CI validation examples
```

## MVP target

- Harvester hosts one lightweight Kubernetes VM for research workloads.
- Existing Rancher VM can manage the cluster.
- Argo CD watches this repository.
- External LLM API is used; no local Ollama/GPU requirement at the beginning.
- Experiment execution starts with simple Kubernetes Jobs.

## Releases

### v0.1.0-bootstrap

Research Fabric Lab の初期ブートストラップ完了版。

このリリースでは、Harvester 上の Rancher/K3s 環境に Argo CD を導入し、GitHub リポジトリから研究ワークロードを同期・実行する最小構成を確認した。

主な成果:

- Harvester 上の Rancher 管理クラスタを利用
- Argo CD 導入
- App of Apps 構成
- `research` / `research-system` namespace 作成
- `Experiment` / `AgentTask` CRD 作成
- サンプル Experiment / AgentTask 同期
- Kubernetes Job 実行
- 結果JSON出力
- GitHub Actions による Runtime Image build
- GHCR への `quantum-python-base` publish
- Runtime Image を使った Job 実行
- `https://argocd.lab.local` による Argo CD UI公開

次の目標:

- `agent-lab-02` を Workload Cluster として構成する
- Rancher へ Import する
- Research Job を Workload Cluster 側で実行する
