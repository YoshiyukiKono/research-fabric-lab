# Architecture overview

## Concept

Research workloads are treated as declarative, reviewable GitOps artifacts.

```text
Human / Researcher
  |
  v
Research Portal UI
  |
  v
AI Draft Generator
  |
  v
GitHub Branch / Pull Request
  |
  v
Human Review
  |
  v
Argo CD Sync
  |
  v
Kubernetes Job / Workflow
  |
  v
Results and Reports
```

## Design rule

AI must not directly apply Kubernetes resources.

```text
Avoid: AI -> kubectl apply
Prefer: AI -> Pull Request -> Human Review -> GitOps Apply
```

## Main abstractions

| Abstraction | Purpose |
|---|---|
| Experiment | Deterministic research workload specification |
| AgentTask | AI-assisted generation, interpretation, or reporting task |
| Workflow | Kubernetes execution plan derived from an Experiment |

## Initial runtime choices

| Component | MVP choice | Later option |
|---|---|---|
| Kubernetes | K3s | RKE2 |
| GitOps | Argo CD | Fleet + Argo CD |
| AI | External LLM API | Local Ollama / vLLM |
| Execution | Kubernetes Job | Argo Workflows / RayJob / MPIJob |
| Storage | PVC | MinIO / S3 |
