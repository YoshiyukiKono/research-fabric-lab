# ArgoCD Troubleshooting Guide

## 概要

Research Fabric Lab では App of Apps パターンを利用している。
GitHub 上の変更が ArgoCD に反映されない場合の調査手順をまとめる。

## 典型症状

- GitHubでは修正済み
- ArgoCD UIでは古い値
- Sync済みなのに期待通りにならない

例:

GitHub:
- storageClass: local-path

ArgoCD:
- storageClass: longhorn

## 調査

### Application確認

```bash
kubectl get application -n argocd
```

### Child Application確認

```bash
kubectl get application research-platform-minio -n argocd -o yaml
```

### ArgoCDが保持するManifest確認

```bash
kubectl get application <app> -n argocd -o yaml
```

## 強制更新

```bash
kubectl annotate application <app> -n argocd   argocd.argoproj.io/refresh=hard   --overwrite
```

## Child Application再生成

```bash
kubectl delete application <child-app> -n argocd
```

親Applicationが再生成する。

## Lessons Learned

確認順序:

1. GitHub
2. Parent Application
3. Child Application
4. Live Resource
