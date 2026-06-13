# ADR-0002: App of Apps パターンを採用する

Date: 2026-06-13

## Status

Accepted

## Context

Research Fabric Lab では、namespace、CRD、実験定義、将来のOperatorやPortalなど、複数のKubernetesリソース群を管理する必要がある。

これらを単一のApplicationとして扱うと、責務が曖昧になり、同期順序やトラブルシューティングが難しくなる。

## Decision

Argo CD の App of Apps パターンを採用する。

```text
research-fabric-bootstrap
↓
research-fabric-root
↓
research-namespaces
research-crds
research-experiments
```

## Consequences

- 最初に作成する Application は bootstrap のみでよい。
- 子 Application を Git 管理できる。
- 同期対象を責務ごとに分離できる。
- root Application の定義ミスが子Application全体に影響するため、repoURL や path の管理に注意が必要である。
