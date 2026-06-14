# Journal: Workload Cluster Ingress Troubleshooting

Date: 2026-06-14




## Summary

Research Portal のデプロイ後、

```text
http://portal.agent.lab.local
````

へアクセスすると

```text
404 Not Found
```

が表示された。

最終的には DNS 解決先が誤っていたことが原因であると判明した。

本記事では調査手順と Kubernetes Ingress の構造を整理する。

---

## Symptoms

Research Portal は正常起動していた。

```bash
kubectl --context agent-lab get pods -n research
```

Result:

```text
research-portal Running
```

Service も正常だった。

```bash
kubectl --context agent-lab get endpoints -n research
```

Result:

```text
research-portal -> 10.42.x.x:8501
```

しかし、

```bash
curl http://portal.agent.lab.local
```

では

```text
404 Not Found
```

となった。

---

## First Verification

Ingress を確認。

```bash
kubectl --context agent-lab describe ingress -n research research-portal
```

Result:

```text
Host:
portal.agent.lab.local

Address:
192.168.11.16
```

Ingress 自体は正常だった。

---

## Service Verification

直接 Service に接続。

```bash
kubectl --context agent-lab \
port-forward -n research svc/research-portal 8080:80
```

別端末で確認。

```bash
curl http://localhost:8080
```

Result:

```html
Streamlit HTML
```

Portal 本体は正常動作していた。

問題は Service より手前ではなく、
Ingress または名前解決であると判断した。

---

## Root Cause

hosts ファイルを確認。

```bash
getent hosts portal.agent.lab.local
```

Result:

```text
192.168.11.18
```

しかし Ingress が公開していたアドレスは

```text
192.168.11.16
```

だった。

つまり、

```text
portal.agent.lab.local
↓
192.168.11.18
```

へアクセスしていた。

Traefik は

```text
192.168.11.16
```

上で動作していたため、

期待した Ingress に到達していなかった。

---

## Resolution

hosts を修正。

```text
192.168.11.16 portal.agent.lab.local
```

確認。

```bash
getent hosts portal.agent.lab.local
```

Result:

```text
192.168.11.16
```

再確認。

```bash
curl -I http://portal.agent.lab.local
```

Result:

```text
HTTP/1.1 200 OK
```

Portal が正常表示された。

---

## Understanding the Traffic Flow

今回の経路は以下。

```text
Browser
 ↓
portal.agent.lab.local
 ↓
192.168.11.16
 ↓
Traefik
 ↓
Ingress
 ↓
Service
 ↓
Pod
```

---

## Why 404 Happened

Traefik は Host Header によってルーティングする。

今回の Ingress は

```yaml
host: portal.agent.lab.local
```

を持つ。

Traefik に到達できなければ、

その Ingress は利用されない。

その結果、

```text
404 Not Found
```

となる。

---

## About Traefik in K3s

K3s はデフォルトで Traefik をインストールする。

確認:

```bash
kubectl get pods -n kube-system
```

Result:

```text
traefik
svclb-traefik
```

### traefik

Ingress Controller 本体。

### svclb-traefik

K3s ServiceLB。

LoadBalancer Service を実現する。

---

## Service Types

### ClusterIP

クラスタ内部のみ。

```text
Pod
 ↓
Service
```

---

### NodePort

ノードの特定ポートで公開。

例:

```text
192.168.11.16:30080
```

---

### LoadBalancer

K3s ServiceLB がノード IP を利用して公開。

今回はこちら。

```text
192.168.11.16
 ↓
Traefik
```

---

## Useful Troubleshooting Commands

### Pod確認

```bash
kubectl get pods -n research
```

### Service確認

```bash
kubectl get svc -n research
```

### Endpoint確認

```bash
kubectl get endpoints -n research
```

### Ingress確認

```bash
kubectl describe ingress -n research research-portal
```

### DNS確認

```bash
getent hosts portal.agent.lab.local
```

### Service直結確認

```bash
kubectl port-forward -n research svc/research-portal 8080:80
```

### HTTP確認

```bash
curl -I http://portal.agent.lab.local
```

---

## Lessons Learned

Portal が見えない場合は以下の順に確認する。

```text
Pod
 ↓
Service
 ↓
Endpoints
 ↓
Ingress
 ↓
DNS
```

今回の問題は Kubernetes 側ではなく、

```text
DNS / hosts 設定
```

だった。

Kubernetes リソースは正常だった。


---

今回のトラブルは単なる `/etc/hosts` ミスではなく、

```text
Kubernetes Service
Ingress
Traefik
LoadBalancer
Node IP
DNS
```

の関係を理解する教材になった。

しかも将来、

```text
Harvester
↓
Rancher
↓
Workload Cluster
↓
Ingress
↓
Portal
```

を増やしていくと何度も遭遇するタイプの問題。

このジャーナルは、半年後に見返したときかなり価値があるだろう。
今後、

```text
agent-lab-03
gpu-lab-01
research-cluster-01
````

みたいな環境を増やしていく可能性が高いので、

**「Pod→Service→Ingress→DNS」調査パターン**を資産化しておく意味があった。
