# Daily Operations

## Set kubeconfig

```bash
export KUBECONFIG=~/.kube/workload-k3s.yaml
kubectl get nodes
```

## Check Rancher imported workload

Use Rancher UI and confirm workload-k3s is Active.

## Check Agent Fabric Lab

```bash
kubectl get pods,svc -n agents
kubectl logs -n agents deployment/orchestrator --tail=100
kubectl logs -n agents deployment/researcher --tail=100
```

## Check Research Fabric Lab

```bash
kubectl get applications -n argocd
kubectl get experiments,agenttasks -n research
kubectl get jobs,pods -n research
```

## Check MinIO

```bash
kubectl get all,pvc,ingress -n storage
```

Browser:

```text
http://console.minio.lab.local/
```

## Check Portal

```bash
kubectl get pods,svc,ingress -n research | grep portal
kubectl logs -n research deployment/research-portal --tail=100
```

Browser:

```text
http://portal.agent.lab.local/
```

## Run test Job from YAML

```bash
kubectl apply -f experiments/ising-netket-001/jobs/job-python-result.yaml
kubectl logs -n research job/ising-python-runtime-001
```

## Run Portal-created Job

Create from UI, then:

```bash
kubectl get jobs,pods -n research | grep ising-1d-demo
kubectl logs -n research job/<job-name>
```
