# Harvester上への Research Fabric Lab 初期構築

## 概要

Research Fabric Lab の最初のマイルストーンとして、Harvester 上で稼働する Rancher 管理クラスタに Argo CD を導入し、GitHub リポジトリから Kubernetes リソースを同期する GitOps 基盤を構築した。

最終的に以下のパスが成立することを確認した。

```text
GitHub
↓
Argo CD
↓
Kubernetes (K3s)
↓
Namespace
↓
CRD
↓
Experiment
↓
AgentTask
↓
Job
```

この構築では、新規 VM を作成せず、既存の Rancher 管理 VM を利用した。

## 構築時点の環境

### Harvester

- Node: `hv-01`
- Memory: 約 31 GiB
- 作業時点の available memory: 約 4.2 GiB

### VM

| VM | 状態 | 用途 |
|---|---|---|
| agent-lab-02 | Running | 既存 Agent 開発環境。8 CPU / 16 GiB |
| rancher-mgmt-02 | Running | Rancher + K3s + Argo CD |

### Kubernetes

`rancher-mgmt-02` 上で K3s が稼働している。

```bash
kubectl get nodes
```

確認結果：

```text
NAME              STATUS   ROLES           VERSION
rancher-mgmt-02   Ready    control-plane   v1.34.3+k3s1
```

## 既存VMの確認

Harvester ノードで VM 一覧を確認した。

```bash
sudo -i
kubectl get vm -A
kubectl get vmi -A
```

実行時点では、以下の2台が Running だった。

```text
agent-lab-02      Running   192.168.11.16
rancher-mgmt-02   Running   192.168.11.18
```

`agent-lab-02` は 16GiB メモリを持つため、新規 Research VM を作成するのではなく、既存の `rancher-mgmt-02` に Argo CD を導入する方針とした。

## Argo CD の導入

namespace を作成する。

```bash
kubectl create namespace argocd
```

最初に通常の `kubectl apply` を試したところ、以下のエラーが発生した。

```text
The CustomResourceDefinition "applicationsets.argoproj.io" is invalid:
metadata.annotations: Too long: may not be more than 262144 bytes
```

これは CRD が大きく、client-side apply の `last-applied-configuration` annotation が上限を超えるために発生する。

対応として server-side apply を利用した。

```bash
kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

導入後、Pod と CRD を確認した。

```bash
kubectl get pods -n argocd
kubectl get crd | grep argoproj
```

確認結果：

```text
applications.argoproj.io
applicationsets.argoproj.io
appprojects.argoproj.io
```

## Argo CD UI へのログイン

初期パスワードを取得した。

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

ポートフォワードで Argo CD UI にアクセスした。

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

ブラウザから以下にアクセスした。

```text
https://localhost:8080
```

ユーザー名は `admin` を利用した。

## GitHubリポジトリ接続

Argo CD UI から GitHub リポジトリを接続した。

```text
Repository URL: https://github.com/YoshiyukiKono/research-fabric-lab.git
```

その後、`research-fabric-bootstrap` Application を作成した。

```text
Application Name: research-fabric-bootstrap
Project: default
Sync Policy: Manual
Repository URL: https://github.com/YoshiyukiKono/research-fabric-lab.git
Revision: HEAD
Path: deploy/argocd
Cluster URL: https://kubernetes.default.svc
Namespace: argocd
```

## App of Apps の同期

`research-fabric-bootstrap` を作成すると、`research-fabric-root` が認識された。

初期状態では `Missing` / `OutOfSync` と表示されたが、これはまだ同期前であり、異常ではなかった。

同期後、`research-fabric-root` が作成された。

```bash
kubectl get applications -n argocd
```

## REPLACE_ME 問題

当初、生成済みマニフェストの `repoURL` にテンプレート値が残っていた。

```text
https://github.com/REPLACE_ME/research-fabric-lab.git
```

このため、子 Application が以下のように `Unknown` となった。

```text
Failed to load target state:
failed to list refs: authentication required: Repository not found.
```

一時的に `kubectl patch` で修正したが、Argo CD の self-heal により GitHub 側の値へ戻された。

この挙動により、GitOps ではクラスタ上の手動修正ではなく、GitHub 側のマニフェスト修正が恒久対応であることを確認した。

最終的に GitHub 側で `REPLACE_ME` をすべて以下に置換した。

```text
https://github.com/YoshiyukiKono/research-fabric-lab.git
```

## Namespace の同期

`research-namespaces` により、以下の namespace が作成された。

```bash
kubectl get ns | grep research
```

確認結果：

```text
research
research-system
```

## CRD の追加

`experiments/` 配下を同期した際、以下のエラーが発生した。

```text
The Kubernetes API could not find research.fabric/Experiment
The Kubernetes API could not find research.fabric/AgentTask
```

これは、`Experiment` と `AgentTask` の CRD がまだクラスタに存在しないためである。

対応として、以下を追加した。

```text
deploy/k8s/crds/
├─ experiment-crd.yaml
└─ agenttask-crd.yaml
```

さらに、Argo CD Application として `research-crds` を追加した。

```text
deploy/argocd/apps/crds.yaml
```

確認：

```bash
kubectl get crd | grep research
```

確認結果：

```text
agenttasks.research.fabric
experiments.research.fabric
```

`research-crds` の Argo CD Health は `Degraded` と表示されたが、CRD 自体は作成されており、同期状態は `Synced` だった。

## Experiment / AgentTask / Job の同期

CRD 追加後、`research-experiments` を再同期した。

確認：

```bash
kubectl get experiment -n research
kubectl get agenttask -n research
kubectl get jobs -n research
```

確認結果：

```text
Experiment:
- ising-netket-001
- qaoa-vrp-001

AgentTask:
- ising-netket-001-report

Job:
- ising-netket-001
```

Job は正常に完了した。

```bash
kubectl logs -n research job/ising-netket-001
```

出力：

```json
{"status":"placeholder","engine":"netket"}
```

## 最終確認

最終的な Application 状態は以下となった。

```text
research-crds               Synced        Degraded
research-experiments        Synced        Healthy
research-fabric-bootstrap   Synced        Healthy
research-fabric-root        Synced        Healthy
research-namespaces         Synced        Healthy
```

`research-crds` の `Degraded` は今後確認するが、CRD 作成と Experiment 同期は成功している。

## 構築結果

以下の GitOps パスが成立した。

```text
GitHub
↓
Argo CD app-of-apps
↓
Namespace
↓
CRD
↓
Experiment / AgentTask
↓
Kubernetes Job
↓
Job Complete
```

これは Research Fabric Lab の Day-1 Bootstrap と位置づける。

## 次のステップ

現在は、`Experiment` と `Job` が並列に定義されている。

```text
Experiment
Job
```

次の段階では、Operator を導入し、`Experiment` から `Job` を生成する。

```text
Experiment
↓
Operator
↓
Job
↓
Result
↓
AgentTask
↓
Report
```

さらに将来的には、AI が自然言語の研究意図から Pull Request を生成し、人間がレビューし、GitOps が適用する流れを実装する。

```text
自然言語
↓
AI generates PR
↓
Human reviews
↓
GitOps applies
↓
Experiment runs
```
