# MinIO Operations

## ログイン

Console:

```text
http://console.minio.lab.local
```

## 初期設定

values.yaml

```yaml
rootUser: minio
rootPassword: ******
```

## Bucket確認

```text
research-artifacts
```

## 動作確認

Artifact Upload Job実行。

結果:

```text
uploaded:
s3://research-artifacts/experiment-001/result.json
```

## 役割

Research Fabric Lab における成果物保存基盤。
