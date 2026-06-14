# Journal: Workload Cluster to MinIO Connectivity Validation

Date: 2026-06-14

## Summary

Workload Cluster (agent-lab-02) 上の Pod から、
Management Cluster (rancher-mgmt-02) 上の MinIO へ接続できることを確認した。

この検証により、

Research Job
↓
Artifact Upload
↓
MinIO

という v0.4.0 の前提条件が満たされた。

## Background

MinIO は Management Cluster 上に構築されている。

```text
rancher-mgmt-02
├─ Rancher
├─ ArgoCD
└─ MinIO
```

Workload Cluster 側には MinIO は存在しない。

```text
agent-lab-02
├─ Research Portal
└─ Runtime Jobs
```

Runtime Job が Artifact を保存する場合、

```text
agent-lab
↓
MinIO
```

の通信経路が必要になる。

## Initial Failure

Pod から接続確認を実施。

```bash
curl http://minio.lab.local
```

結果:

```text
Could not resolve host: minio.lab.local
```

原因は DNS 解決失敗だった。

## Investigation

IP アドレスを直接指定。

```bash
curl -I -H "Host: minio.lab.local" \
http://192.168.11.18
```

結果:

```text
Server: MinIO
```

ネットワーク自体は正常であることが判明した。

## Resolution

CoreDNS ConfigMap の NodeHosts に追加。

```text
192.168.11.18 minio.lab.local
192.168.11.18 console.minio.lab.local
```

CoreDNS 再起動。

```bash
kubectl -n kube-system rollout restart deployment/coredns
```

## Validation

再度実行。

```bash
curl -I http://minio.lab.local
```

結果:

```text
HTTP/1.1 400 Bad Request
Server: MinIO
```

MinIO に正常到達した。

## Architecture Understanding

MinIO は1つのみ存在する。

```text
Management Cluster
└─ MinIO
```

API:

```text
minio.lab.local
```

Console:

```text
console.minio.lab.local
```

Workload Cluster の Job は
Management Cluster の MinIO を利用する。

## Storage Considerations

現在の MinIO は

```text
PVC
↓
local-path
```

を利用している。

Longhorn は未導入であり、
今回の検証とは別の課題である。

## Significance

Research Fabric Lab は以下を達成した。

```text
Workload Cluster
↓
OpenAI
↓
Experiment Spec
↓
MinIO Connectivity
```

次のステップは、

```text
Experiment Spec
↓
Kubernetes Job
↓
Artifact Upload
```

である。
