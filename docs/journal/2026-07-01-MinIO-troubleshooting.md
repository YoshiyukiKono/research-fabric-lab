# 2026-07-01 Portal Job の MinIO 接続障害の調査

## 概要

Research Portal から実行した `ising-1d-demo` Job が MinIO に成果物を書き込めなくなった。

症状としては Job 自体は起動するものの、成果物 (`result.json`) が MinIO の `research-artifacts` Bucket に作成されなかった。

---

## 症状

Job のログより

```
urllib3.exceptions.MaxRetryError:
HTTPConnectionPool(host='minio.lab.local', port=80)
...
Failed to resolve 'minio.lab.local'
```

Job は

```
MINIO_ENDPOINT=minio.lab.local:80
```

を使用していた。

---

## 切り分け

### 1. MinIO の稼働確認

```
kubectl get svc -A | grep minio
```

```
storage   minio           ClusterIP   10.43.121.94   9000/TCP
storage   minio-console   ClusterIP   10.43.249.227  9001/TCP
```

Service は正常。

---

### 2. Kubernetes DNS の確認

research namespace に一時 Pod を起動。

```bash
kubectl -n research run dns-test \
  --rm -it \
  --restart=Never \
  --image=busybox:1.36 \
  -- sh
```

DNS確認

```sh
nslookup minio.storage.svc.cluster.local
```

結果

```
Name: minio.storage.svc.cluster.local
Address: 10.43.121.94
```

名前解決成功。

---

### 3. HTTP 疎通確認

```sh
wget -S -O- \
http://minio.storage.svc.cluster.local:9000/minio/health/live
```

結果

```
HTTP/1.1 200 OK
```

MinIO API まで正常到達。

---

## 原因調査

Portal が生成した Job を確認。

```
kubectl -n research get job <job-name> -o yaml
```

```
MINIO_ENDPOINT=minio.lab.local:80
```

となっていた。

一方、

```
deploy/k8s/jobs/ising-1d-demo/job.yaml
```

を修正しても改善しなかった。

---

## Argo CD の確認

Application の管理対象を確認。

```
kubectl -n argocd get applications
```

調査結果

| Application | 管理対象 |
|-------------|---------|
| research-platform | deploy/k8s/platform |
| research-storage | deploy/k8s/storage/minio |
| research-experiments | experiments |

Portal の ConfigMap

```
deploy/k8s/workload/research-portal/configmap-app.yaml
```

は **Argo CD の管理対象外** であることが判明。

---

## 真の原因

Portal が Job を生成する際、

```
deploy/k8s/workload/research-portal/configmap-app.yaml
```

内で

```python
client.V1EnvVar(
    name="MINIO_ENDPOINT",
    value="minio.lab.local:80"
)
```

を埋め込んでいた。

Job はこの値を使用していた。

---

## 修正

```
minio.lab.local:80
```

↓

```
minio.storage.svc.cluster.local:9000
```

へ変更。

GitHubへコミット。

その後

```bash
kubectl apply \
-f deploy/k8s/workload/research-portal/configmap-app.yaml

kubectl rollout restart deployment \
-n research research-portal
```

を実施。

---

## 確認

Portal から Job を再実行。

生成された成果物

```
research-artifacts/
└── ising-1d-demo/
    └── runs/
        └── 20260701-xxxxxx/
            └── result.json
```

が MinIO 上に正常作成されたことを確認。

---

# 考察

今回の問題は

```
Pod
 ↓
minio.lab.local
 ↓
CoreDNS の NodeHosts に依存
```

という設計だったことに起因する。

以前は CoreDNS の

```
NodeHosts
```

へ

```
minio.lab.local
```

を追加していたが、この設定は Git 管理されておらず、後から消失した。

今回は Kubernetes 標準 Service DNS を利用するよう変更した。

```
Pod
 ↓
minio.storage.svc.cluster.local
 ↓
Service
 ↓
MinIO
```

この構成では

- CoreDNS の独自設定不要
- Kubernetes 標準構成
- GitOps と相性が良い
- クラスタ再構築時にも再現性が高い

という利点がある。

---

## 今後の改善候補

- `deploy/k8s/workload` を Argo CD 管理対象へ追加する。
- ConfigMap の `kubectl apply` を不要にする。
- Portal の Job 定義をテンプレート化し、Job Manifest と二重管理しない構成へ整理する。
