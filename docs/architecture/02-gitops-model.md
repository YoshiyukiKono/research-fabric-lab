# GitOps モデル

## 基本フロー

```text
GitHub
↓
research-fabric-bootstrap
↓
research-fabric-root
↓
research-namespaces
research-crds
research-experiments
```

## App of Apps

Research Fabric Lab では、Argo CD の App of Apps パターンを採用する。

最初に手動で作成する Application は `research-fabric-bootstrap` のみである。

その後、`research-fabric-bootstrap` が `research-fabric-root` を作成し、`research-fabric-root` が子 Application を管理する。

## 現在の Application

| Application | 役割 |
|---|---|
| research-fabric-bootstrap | 入口となる bootstrap Application |
| research-fabric-root | 子 Application を束ねる root Application |
| research-namespaces | namespace を管理 |
| research-crds | Experiment / AgentTask CRD を管理 |
| research-experiments | experiments/ 配下の研究定義を管理 |

## 設計上の注意

クラスタ上の Argo CD Application を手動で patch しても、GitHub 側の定義が正であれば self-heal によって戻される。

そのため、恒久対応は必ず GitHub 側のマニフェストを修正する。
