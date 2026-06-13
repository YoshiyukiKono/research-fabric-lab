# 2026-06-13: Argo CD Bootstrap on Harvester / Rancher K3s

## Goal

Set up the first GitOps path for Research Fabric Lab:

```text
GitHub repository
  ↓
Argo CD
  ↓
Kubernetes resources on rancher-mgmt-02
  ↓
Research namespace, CRDs, Experiment, AgentTask, Job
```

This was done on the existing Rancher management VM instead of creating a new VM.

## Starting environment

Harvester node:

```bash
ssh rancher@192.168.11.8
sudo -i
free -h
kubectl get vm -A
kubectl get vmi -A
```

Observed:

```text
Available memory: about 4.2 GiB
Running VMs:
- agent-lab-02      192.168.11.16   8 CPU / 16Gi
- rancher-mgmt-02   192.168.11.18   K3s + Rancher
```

Because memory was tight, a new VM was not created. The existing `rancher-mgmt-02` K3s cluster was used.

Rancher management node:

```bash
ssh ubuntu@192.168.11.18
kubectl get nodes
kubectl get pods -A
```

Observed:

```text
rancher-mgmt-02 Ready control-plane v1.34.3+k3s1
```

Rancher, Fleet, cert-manager, Traefik, and K3s system components were already running.

## Argo CD installation

Namespace:

```bash
kubectl create namespace argocd
```

Initial client-side apply hit a CRD annotation size limit:

```text
The CustomResourceDefinition "applicationsets.argoproj.io" is invalid:
metadata.annotations: Too long: may not be more than 262144 bytes
```

Resolution: use server-side apply.

```bash
kubectl apply --server-side --force-conflicts -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

The `--force-conflicts` flag was acceptable here because the conflict came from the partially-created Argo CD resources from the previous client-side apply attempt.

Validation:

```bash
kubectl get pods -n argocd
kubectl get crd | grep argoproj
```

Observed:

```text
argocd-application-controller       Running
argocd-applicationset-controller    Running
argocd-dex-server                   Running
argocd-notifications-controller     Running
argocd-redis                        Running
argocd-repo-server                  Running
argocd-server                       Running

applications.argoproj.io
applicationsets.argoproj.io
appprojects.argoproj.io
```

## Argo CD UI access

Initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d; echo
```

Port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

From Windows, SSH tunnel can be used as needed:

```powershell
ssh -L 8080:localhost:8080 ubuntu@192.168.11.18
```

Browser:

```text
https://localhost:8080
```

User:

```text
admin
```

## Repository connection

The GitHub repository was connected from Argo CD UI:

```text
Settings → Repositories → Connect Repo
```

Repository URL:

```text
https://github.com/YoshiyukiKono/research-fabric-lab.git
```

## Bootstrap Application

Created from Argo CD UI:

```text
Application Name: research-fabric-bootstrap
Project: default
Sync Policy: Manual
Repository URL: https://github.com/YoshiyukiKono/research-fabric-lab.git
Revision: HEAD / main
Path: deploy/argocd
Cluster URL: https://kubernetes.default.svc
Namespace: argocd
```

After sync, it created:

```text
research-fabric-root
```

## REPLACE_ME issue

The generated repository initially contained placeholder repository URLs:

```text
https://github.com/REPLACE_ME/research-fabric-lab.git
```

This caused child Applications to report:

```text
failed to list refs: authentication required: Repository not found
```

Temporary patch example:

```bash
kubectl patch application research-fabric-root -n argocd --type merge -p '{"spec":{"source":{"repoURL":"https://github.com/YoshiyukiKono/research-fabric-lab.git"}}}'
```

However, Argo CD self-heal reverted patched child Applications back to the Git state. The durable fix was to replace `REPLACE_ME` in Git and commit the change.

Files to check:

```text
deploy/argocd/root-app.yaml
deploy/argocd/apps/*.yaml
```

Refresh after Git commit:

```bash
kubectl annotate application research-fabric-bootstrap -n argocd   argocd.argoproj.io/refresh=hard --overwrite

kubectl annotate application research-fabric-root -n argocd   argocd.argoproj.io/refresh=hard --overwrite
```

## Namespaces

After the repository URL was fixed, `research-namespaces` synced successfully.

Validation:

```bash
kubectl get ns | grep research
```

Observed:

```text
research          Active
research-system   Active
```

## CRDs

Added CRDs:

```text
deploy/k8s/crds/experiment-crd.yaml
deploy/k8s/crds/agenttask-crd.yaml
```

Added Argo CD child Application:

```text
deploy/argocd/apps/research-crds.yaml
```

Validation:

```bash
kubectl get crd | grep research
```

Observed:

```text
agenttasks.research.fabric
experiments.research.fabric
```

Note: `research-crds` may show `Degraded` in Argo CD even when CRDs are installed. For this early phase, this is acceptable.

## Experiments

`research-experiments` initially failed because the `Experiment` and `AgentTask` CRDs did not exist yet:

```text
Make sure the "Experiment" CRD is installed on the destination cluster.
Make sure the "AgentTask" CRD is installed on the destination cluster.
```

After installing CRDs, re-enabled automated sync:

```bash
kubectl patch application research-experiments -n argocd --type merge -p '{"spec":{"syncPolicy":{"automated":{"prune":false,"selfHeal":true}}}}'

kubectl annotate application research-experiments -n argocd   argocd.argoproj.io/refresh=hard --overwrite
```

Validation:

```bash
kubectl get experiment -n research
kubectl get agenttask -n research
kubectl get jobs -n research
kubectl get applications -n argocd
```

Observed:

```text
Experiment:
- ising-netket-001
- qaoa-vrp-001

AgentTask:
- ising-netket-001-report

Job:
- ising-netket-001   Complete
```

Final Application status:

```text
research-crds               Synced   Degraded
research-experiments        Synced   Healthy
research-fabric-bootstrap   Synced   Healthy
research-fabric-root        Synced   Healthy
research-namespaces         Synced   Healthy
```

Job log:

```bash
kubectl logs -n research job/ising-netket-001
```

Observed:

```json
{"status":"placeholder","engine":"netket"}
```

## Result

The first end-to-end GitOps flow succeeded:

```text
GitHub
  ↓
Argo CD app-of-apps
  ↓
Namespace
  ↓
CRD
  ↓
Experiment / AgentTask
  ↓
Kubernetes Job
  ↓
Complete
```

## Lessons learned

- Argo CD is not just a deploy tool; it continuously reconciles cluster state back to Git state.
- Temporary `kubectl patch` is useful for debugging, but durable changes must be committed to Git.
- CRDs must be installed before custom resources are synced.
- For this lab, the existing `rancher-mgmt-02` VM was sufficient. No new VM was needed.
- The first meaningful milestone is not AI or NetKet itself, but GitHub → Argo CD → Kubernetes execution.
