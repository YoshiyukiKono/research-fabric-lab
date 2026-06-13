# Argo CD App-of-Apps Design

Research Fabric Lab uses an app-of-apps pattern.

```text
research-fabric-bootstrap
  └─ research-fabric-root
       ├─ research-namespaces
       ├─ research-crds
       └─ research-experiments
```

## Application roles

### research-fabric-bootstrap

This is the first Application created manually from the Argo CD UI or CLI. It points to `deploy/argocd` and creates `research-fabric-root`.

### research-fabric-root

This Application points to `deploy/argocd/apps` and creates child Applications.

### research-namespaces

Creates base namespaces:

- `research`
- `research-system`

### research-crds

Installs custom resource definitions:

- `experiments.research.fabric`
- `agenttasks.research.fabric`

### research-experiments

Applies experiment definitions under `experiments/`. It depends on namespaces and CRDs being present.

## Important lesson

Do not permanently patch generated child Applications in the cluster. If `selfHeal` is enabled, Argo CD will reconcile them back to the Git state. Fix the Git repository instead.

A temporary patch is useful for debugging, but the durable fix must be committed to Git.

## Expected healthy state

```bash
kubectl get applications -n argocd
```

Expected:

```text
research-fabric-bootstrap   Synced   Healthy
research-fabric-root        Synced   Healthy
research-namespaces         Synced   Healthy
research-crds               Synced   Degraded  # acceptable for now; CRD health customization can be added later
research-experiments        Synced   Healthy
```

`research-crds` may appear as `Degraded` because Argo CD does not always assign a useful built-in health status to CRDs. The decisive check is:

```bash
kubectl get crd | grep research
```
