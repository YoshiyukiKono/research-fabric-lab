# Runbook: Research Fabric Lab Bootstrap

## 1. Ubuntu Jump Host
- Git導入
- kubectl導入
- KUBECONFIG取得
- GitHub clone

```
git clone https://github.com/YoshiyukiKono/agent-fabric-lab.git
git clone https://github.com/YoshiyukiKono/research-fabric-lab.git
```

## 2. KUBECONFIG

```
mkdir -p ~/.kube
scp suse@<k3s-server>:~/workload-k3s.yaml ~/.kube/
export KUBECONFIG=~/.kube/workload-k3s.yaml
kubectl get nodes
```

## 3. Agent Fabric Lab
- Docker build
- k3s image import
- namespace
- ollama
- agents
- orchestrator
- NodePort確認

## 4. Research Fabric Lab
- Argo CD(server-side apply)
- root-app適用
- CRD確認
- Namespace確認
- Applications確認

## 5. MinIO
- storage namespace
- PVC
- Ingress
- bucket: research-artifacts

## 6. Research Portal

```
kubectl apply -k deploy/k8s/workload/research-portal
kubectl rollout status deployment/research-portal -n research
```

## 7. CoreDNS

NodeHostsへ追加

```
10.110.1.211 rancher.demo.local
10.110.1.212 k3s-server
10.110.1.212 minio.lab.local
10.110.1.212 console.minio.lab.local
10.110.1.212 portal.agent.lab.local
```

```
kubectl -n kube-system rollout restart deployment coredns
```

DNS確認

```
kubectl run -n research dns-test --rm -it --image=python:3.11-slim --restart=Never -- python -c "import socket;print(socket.gethostbyname('minio.lab.local'))"
```

## 8. Portal実行
- Job生成
- kubectl get jobs,pods -n research
- kubectl logs job/<job>

## 9. トラブルシュート
- CreateContainerConfigError → Secret確認
- NameResolutionError → CoreDNS NodeHosts確認
