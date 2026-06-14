# Troubleshooting

## CRD annotation too long

### 症状

```text
metadata.annotations: Too long: may not be more than 262144 bytes
```

### 原因

CRD が大きく、client-side apply が付与する `last-applied-configuration` annotation が上限を超える。

### 対応

```bash
kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Repo URL が REPLACE_ME のまま

### 症状

```text
Repository not found
authentication required
```

### 原因

GitHubリポジトリURLがテンプレート値のまま残っている。

### 対応

GitHub 側のマニフェストを修正する。

```text
https://github.com/REPLACE_ME/research-fabric-lab.git
```

を以下に置換する。

```text
https://github.com/YoshiyukiKono/research-fabric-lab.git
```

クラスタ上で patch しても、self-heal により GitHub 側の値へ戻る。

## CRDがない

### 症状

```text
The Kubernetes API could not find research.fabric/Experiment
The Kubernetes API could not find research.fabric/AgentTask
```

### 原因

`Experiment` / `AgentTask` CRD がまだクラスタに存在しない。

### 対応

`research-crds` Application を同期し、CRD を作成する。

```bash
kubectl get crd | grep research
```
