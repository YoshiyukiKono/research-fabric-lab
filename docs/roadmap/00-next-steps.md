# Roadmap and Next Steps

## Current milestone achieved

The first GitOps path is working:

```text
GitHub → Argo CD → Namespace → CRD → Experiment / AgentTask → Job → Logs
```

The placeholder Job returns:

```json
{"status":"placeholder","engine":"netket"}
```

## Near-term plan

### Step 1: Replace placeholder Job with lightweight Python

Before running NetKet, replace the placeholder container command with a small Python script that:

- reads simple parameters from environment variables or a mounted config file,
- performs a small deterministic calculation,
- writes JSON to stdout.

Goal:

```text
Experiment YAML → Job → JSON result
```

### Step 2: Introduce result artifacts

Add a simple output location:

- first: pod logs only,
- next: PVC,
- later: MinIO/S3-compatible object storage.

### Step 3: Improve CRD schemas

The current CRDs preserve unknown fields. This is fine for early exploration, but later versions should define structured OpenAPI schemas for:

- `Experiment.spec.domain`
- `Experiment.spec.engine`
- `Experiment.spec.parameters`
- `Experiment.spec.runtime`
- `AgentTask.spec.role`
- `AgentTask.spec.input`
- `AgentTask.spec.output`

### Step 4: Add a lightweight controller or workflow generator

Current state:

```text
Experiment CR exists, but the Job is still authored separately.
```

Target state:

```text
Experiment CR
  ↓
Controller / Workflow generator
  ↓
Kubernetes Job / Argo Workflow
```

This can be implemented later as:

- a simple Python controller,
- Kopf-based operator,
- Argo Workflows template generator,
- or a GitHub Action that generates Job YAML by PR.

### Step 5: Add Intent-to-PR UI

The UI should not directly apply Kubernetes resources.

Target flow:

```text
Research Portal UI
  ↓
AI Draft Generator
  ↓
GitHub branch / commit
  ↓
Pull Request
  ↓
Human review
  ↓
Argo CD applies after merge
```

Principle:

```text
AI generates PR
Human reviews
GitOps applies
```

### Step 6: Add real research engines

Possible progression:

1. lightweight Python placeholder,
2. QUBO / small OR examples,
3. Qiskit simulator examples,
4. NetKet examples,
5. TeNPy / tensor network examples,
6. JAX / Hamiltonian learning examples.

## Documentation policy

Keep operational notes in `docs/operations/`.

Use dates for build logs:

```text
docs/operations/YYYY-MM-DD-topic.md
```

Use ADRs for durable design decisions:

```text
docs/adr/0001-ai-generates-pr.md
docs/adr/0002-argocd-app-of-apps.md
```

Use `docs/gitops/` for reusable Argo CD concepts and commands.
