# Phase 3A: Artifact Storage

## 状態

Planned

想定リリース:

* v0.1.1-artifact-storage

---

## 背景

v0.1.0-bootstrap では、研究ジョブの結果は Kubernetes Job のログとして出力している。

例:

```text
kubectl logs job/ising-python-runtime-001
```

この方式は動作確認には有効であるが、

* 実験結果の永続保存
* グラフ画像
* レポート
* チェックポイント
* 学習済みモデル

などの成果物を管理することはできない。

Research Fabric Lab では、成果物を Artifact として扱う。

---

## 目的

研究成果物を保存するための Artifact Storage を導入する。

対象成果物:

* result.json
* metrics.json
* report.md
* plot.png
* checkpoint
* dataset

---

## Target Architecture

```text
GitHub
 ↓
Argo CD
 ↓
Experiment
 ↓
Runtime Job
 ↓
Artifact
 ↓
MinIO
```

---

## Storage Design

採用:

```text
MinIO
+
PVC
+
Longhorn
```

保存先:

```text
Harvester
 ↓
Longhorn
 ↓
PersistentVolume
 ↓
MinIO
```

Research Fabric Lab では、

成果物の保存先として S3 API 互換ストレージを標準とする。

---

## Namespace

```text
artifact-system
```

---

## Platform Resources

```text
deploy/k8s/platform/minio/
```

想定構成:

```text
deploy/k8s/platform/minio/

├── namespace.yaml
├── pvc.yaml
├── deployment.yaml
├── service.yaml
├── ingress-console.yaml
└── ingress-api.yaml
```

---

## Access

ブラウザ

```text
https://minio-console.lab.local
```

S3 Endpoint

```text
https://minio.lab.local
```

---

## Initial Bucket Design

```text
research-artifacts
```

例:

```text
research-artifacts/

├── ising-netket-001/
│   ├── result.json
│   ├── metrics.json
│   └── report.md
│
└── qaoa-vrp-001/
    ├── result.json
    └── plot.png
```

---

## Experiment Integration

将来の Experiment 仕様例:

```yaml
spec:
  output:
    bucket: research-artifacts
    prefix: ising-netket-001
```

Job 完了後に成果物をアップロードする。

---

## Success Criteria

以下を満たした時点で完了とする。

* MinIO Pod 起動
* PVC 作成
* Longhorn 永続化確認
* Browser から Console 接続
* research-artifacts Bucket 作成
* Job から result.json Upload 成功
* Browser から Artifact 確認

---

## Future Integration

Phase 3A 完了後、

```text
Experiment
 ↓
Runtime
 ↓
Artifact
```

という研究実行基盤の基本構成が完成する。

その後、

* Phase 3B Workload Cluster
* Phase 4 Research Portal
* Phase 5 Experiment Operator

へ進む。
