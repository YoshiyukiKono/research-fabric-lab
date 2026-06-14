# Storage Troubleshooting Guide

## 症状

Pod が Pending のまま起動しない。

```text
0/1 Pending
```

## 調査フロー

```text
Pod
↓
PVC
↓
StorageClass
↓
Provisioner
↓
PV
```

## Pod確認

```bash
kubectl get pods -A
kubectl describe pod <pod>
```

## PVC確認

```bash
kubectl get pvc -A
kubectl describe pvc <name> -n <namespace>
```

## StorageClass確認

```bash
kubectl get storageclass
```

## 実際の事例

Manifest:

```yaml
storageClass: longhorn
```

Cluster:

```text
local-path (default)
```

結果:

```text
PVC Pending
Pod Pending
```

## 解決

```yaml
storageClass: local-path
```

へ修正。

## MinIO導入時の教訓

MinIO問題に見えても、実際はStorageClass問題であることが多い。
