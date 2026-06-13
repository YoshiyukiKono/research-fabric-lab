# Artifact Storage Operations

## MinIO状態確認

```bash
kubectl get pods -n storage
kubectl get pvc -n storage
kubectl get ingress -n storage
```

## MinIO Console

URL:

https://console.minio.lab.local

認証情報:

```text
User: minio
Password: minio12345
```

## Uploadテスト

```bash
kubectl apply -k deploy/k8s/storage/minio/runtime-upload-example
```

ログ確認:

```bash
kubectl logs -n research job/artifact-upload-example
```

期待結果:

```text
uploaded: s3://research-artifacts/experiment-001/result.json
```

## トラブルシュート

PVCがPendingの場合:

```bash
kubectl describe pvc -n storage minio
```

StorageClass確認:

```bash
kubectl get storageclass
```

ArgoCD UIが利用できない場合:

```bash
kubectl get deploy argocd-server -n argocd -o yaml | grep insecure
```

期待結果:

```text
--insecure
```
