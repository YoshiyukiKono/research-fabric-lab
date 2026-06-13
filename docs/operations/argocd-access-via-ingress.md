

# Argo CD Access via Ingress

## Goal

Argo CD を SSH トンネルや port-forward に依存せず、

```text
https://argocd.lab.local
```

からアクセス可能にする。

---

## Initial State

アクセス方法

```bash
kubectl port-forward svc/argocd-server \
  -n argocd \
  8080:443
```

ブラウザ

```text
https://localhost:8080
```

特徴

* 一時的
* セッションごとに実行が必要
* SSH接続依存

---

## Target State

ブラウザ

```text
https://argocd.lab.local
```

アクセス経路

```text
Browser
↓
Traefik Ingress
↓
argocd-server
```

---

## Platform Application

追加した Application

```text
deploy/argocd/apps/platform.yaml
```

目的

```text
deploy/k8s/platform/
```

配下を GitOps 管理する。

---

## First Attempt

Ingress

```yaml
service.serversscheme: https
backend port: 443
```

結果

```text
Internal Server Error
```

ブラウザ表示

```text
Internal Server Error
```

---

## Cause

Traefik から Argo CD への通信を HTTPS のまま転送していた。

```text
Browser
↓ HTTPS
Traefik
↓ HTTPS
Argo CD
```

Argo CD backend の TLS 処理との組み合わせで正常に動作しなかった。

---

## Final Configuration

Argo CD を insecure mode で動作させる。

```bash
kubectl patch configmap argocd-cmd-params-cm \
  -n argocd \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'
```

```bash
kubectl rollout restart deployment argocd-server \
  -n argocd
```

Ingress

```yaml
backend:
  service:
    name: argocd-server
    port:
      number: 80
```

結果

```text
Browser
↓ HTTPS
Traefik
↓ HTTP
Argo CD
```

---

## Host Configuration

Windows

```text
C:\Windows\System32\drivers\etc\hosts
```

追加

```text
192.168.11.18 argocd.lab.local
```

---

## Verification

Argo CD UI

```text
https://argocd.lab.local
```

正常表示確認。

以下不要となった。

* kubectl port-forward
* SSH Tunnel

---

## Lessons Learned

Research Fabric Lab では

```text
rancher.lab.local
argocd.lab.local
```

のように Platform Service を Ingress 公開する。

将来

```text
portal.lab.local
grafana.lab.local
```

も同様の方式を採用する。


## TODO:
ArgoCD自身の設定をGitOps管理へ移行
