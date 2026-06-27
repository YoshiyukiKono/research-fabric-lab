# Runbook: Full Bootstrap from Git Clone

This runbook starts from an Ubuntu Jump Host and assumes the workload K3s cluster already exists.

## 0. Environment

Expected IPs:

```text
rancher-mgmt  10.110.1.211
k3s-server    10.110.1.212
jump-host     10.110.1.213
```

Expected hostnames:

```text
rancher.demo.local
minio.lab.local
console.minio.lab.local
portal.agent.lab.local
```

## 1. Install basic tools on Jump Host

```bash
sudo apt update
sudo apt install -y git curl jq vim unzip docker.io
sudo systemctl enable --now docker
```

Install kubectl, for example:

```bash
sudo snap install kubectl --classic
kubectl version --client
```

## 2. Clone repositories

```bash
cd ~
git clone https://github.com/YoshiyukiKono/agent-fabric-lab.git
git clone https://github.com/YoshiyukiKono/research-fabric-lab.git
```

## 3. Configure kubeconfig

On the K3s server, create an external kubeconfig:

```bash
cp ~/.kube/config ~/workload-k3s.yaml
sed -i 's/127.0.0.1/10.110.1.212/' ~/workload-k3s.yaml
```

On Jump Host:

```bash
mkdir -p ~/.kube
scp suse@10.110.1.212:~/workload-k3s.yaml ~/.kube/
chmod 600 ~/.kube/workload-k3s.yaml
export KUBECONFIG=~/.kube/workload-k3s.yaml
kubectl get nodes
```

## 4. Deploy Agent Fabric Lab

```bash
cd ~/agent-fabric-lab
sudo docker build -t agent-blueprint-agent:local images/agent
sudo docker build -t agent-blueprint-orchestrator:local images/orchestrator

sudo docker save agent-blueprint-agent:local -o /tmp/agent-blueprint-agent.tar
sudo docker save agent-blueprint-orchestrator:local -o /tmp/agent-blueprint-orchestrator.tar

sudo chmod 644 /tmp/agent-blueprint-agent.tar /tmp/agent-blueprint-orchestrator.tar

scp /tmp/agent-blueprint-agent.tar suse@10.110.1.212:/tmp/
scp /tmp/agent-blueprint-orchestrator.tar suse@10.110.1.212:/tmp/
```

On K3s server:

```bash
sudo k3s ctr images import /tmp/agent-blueprint-agent.tar
sudo k3s ctr images import /tmp/agent-blueprint-orchestrator.tar
```

Back on Jump Host:

```bash
cd ~/agent-fabric-lab
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/ollama.yaml
kubectl rollout status deployment/ollama -n agents

kubectl exec -n agents deployment/ollama -- ollama pull llama3.2:1b

kubectl apply -f k8s/agents.yaml
kubectl apply -f k8s/orchestrator.yaml

kubectl get pods,svc -n agents
```

Access Orchestrator:

```bash
kubectl get svc orchestrator -n agents
```

Open:

```text
http://10.110.1.212:<NodePort>/
```

## 5. Install Argo CD

```bash
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply --server-side -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n argocd rollout status deploy/argocd-server
```

## 6. Deploy Research Fabric Lab App of Apps

```bash
cd ~/research-fabric-lab
kubectl apply -f deploy/argocd/root-app.yaml

kubectl get applications -n argocd
kubectl get ns | grep research
kubectl get crd | grep -E 'experiment|agenttask'
```

Expected:

```text
research-crds        Synced Healthy
research-experiments Synced Healthy
research-fabric-root Synced Healthy
research-namespaces  Synced Healthy
research-storage     Synced Healthy
```

## 7. Deploy Research Portal

```bash
kubectl apply -k deploy/k8s/workload/research-portal
kubectl rollout status deployment/research-portal -n research
kubectl get pods,svc,ingress -n research | grep portal
```

Expected ingress:

```text
portal.agent.lab.local
```

Add to Mac `/etc/hosts`:

```text
10.110.1.212 portal.agent.lab.local
```

Open:

```text
http://portal.agent.lab.local/
```

## 8. Configure MinIO credentials for runtime Jobs

```bash
kubectl create secret generic minio-credentials \
  -n research \
  --from-literal=MINIO_ACCESS_KEY=minio \
  --from-literal=MINIO_SECRET_KEY=minio12345 \
  --from-literal=MINIO_ENDPOINT=http://minio.storage.svc.cluster.local:9000
```

## 9. Configure CoreDNS NodeHosts

Edit CoreDNS:

```bash
kubectl -n kube-system edit configmap coredns
```

Set:

```yaml
NodeHosts: |
  10.110.1.211 rancher.demo.local
  10.110.1.212 k3s-server
  10.110.1.212 minio.lab.local
  10.110.1.212 console.minio.lab.local
  10.110.1.212 portal.agent.lab.local
```

Restart CoreDNS:

```bash
kubectl -n kube-system rollout restart deployment coredns
kubectl -n kube-system rollout status deployment coredns
```

Verify from a Pod:

```bash
kubectl run -n research dns-test --rm -it \
  --image=python:3.11-slim \
  --restart=Never -- \
  python -c "import socket; print(socket.gethostbyname('minio.lab.local'))"
```

Expected:

```text
10.110.1.212
```

## 10. Run a Portal Job

From browser, open:

```text
http://portal.agent.lab.local/
```

Create a Job.

Check:

```bash
kubectl get jobs,pods -n research | grep ising-1d-demo
kubectl logs -n research job/<job-name>
```

Expected artifact:

```text
s3://research-artifacts/ising-1d-demo/runs/<run_id>/result.json
```

## 11. Check MinIO

Mac `/etc/hosts`:

```text
10.110.1.212 minio.lab.local
10.110.1.212 console.minio.lab.local
```

Open:

```text
http://console.minio.lab.local/
```

Credentials:

```text
minio / minio12345
```
