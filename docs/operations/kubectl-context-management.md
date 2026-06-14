# kubectl Context Management

## 背景

Management Cluster から Workload Cluster を操作する。

## Context確認

```bash
kubectl config get-contexts
```

例:

```text
default
agent-lab
```

## Context指定

```bash
kubectl --context agent-lab get pods -A
```

## 推奨

常に context を明示する。

理由:

将来

- management
- agent-lab
- gpu-lab
- prod

など複数クラスタになるため。
