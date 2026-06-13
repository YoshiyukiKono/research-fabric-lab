# Argo CD 運用メモ

## Application一覧

```bash
kubectl get applications -n argocd
```

## Application詳細

```bash
kubectl describe application <name> -n argocd
```

## Hard Refresh

```bash
kubectl annotate application <name> -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
```

## Repo URL確認

```bash
kubectl get application <name> -n argocd \
  -o jsonpath='{.spec.source.repoURL}{"\n"}'
```

## Argo CD UIへのアクセス

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

```text
https://localhost:8080
```

## 初期パスワード取得

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```
