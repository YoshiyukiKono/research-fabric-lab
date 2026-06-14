# Networking Troubleshooting Guide

## 症状

portal.agent.lab.local にアクセスすると

```text
404 Not Found
```

## 調査フロー

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

## Pod

```bash
kubectl get pods -n research
```

## Service

```bash
kubectl get svc -n research
```

## Endpoints

```bash
kubectl get endpoints -n research
```

## Ingress

```bash
kubectl describe ingress -n research research-portal
```

確認ポイント:

```text
Host
Address
Backend
```

## Port Forward確認

```bash
kubectl port-forward -n research svc/research-portal 8080:80
```

```bash
curl http://localhost:8080
```

ここで動けばアプリ本体は正常。

## DNS確認

```bash
getent hosts portal.agent.lab.local
```

## 実際の事例

誤:

```text
192.168.11.18 portal.agent.lab.local
```

正:

```text
192.168.11.16 portal.agent.lab.local
```

Ingress Address と一致させる必要がある。

## Traefik解説

通信経路:

```text
Browser
↓
DNS
↓
Traefik
↓
Ingress
↓
Service
↓
Pod
```

### Traefik

K3s標準のIngress Controller。

### ServiceLB

K3s組み込みLoadBalancer。

```bash
kubectl get pods -n kube-system
```

```text
traefik
svclb-traefik
```
