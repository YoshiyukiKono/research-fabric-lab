# ADR 0002: Use Argo CD App-of-Apps for Research Fabric Lab

## Status

Accepted

## Context

Research Fabric Lab needs to manage multiple layers:

- namespaces,
- CRDs,
- experiment resources,
- future controllers,
- future UI/API components.

The project should remain GitOps-first and understandable for learning purposes.

## Decision

Use Argo CD app-of-apps.

```text
research-fabric-bootstrap
  └─ research-fabric-root
       ├─ research-namespaces
       ├─ research-crds
       └─ research-experiments
```

## Consequences

Positive:

- The Git repository is the source of truth.
- The bootstrap process is explicit.
- Child Applications can be added incrementally.
- It is easy to explain and reproduce.

Tradeoffs:

- Temporary cluster-side patches are reverted by self-heal.
- Ordering must be considered: namespaces and CRDs must precede custom resources.
- CRD health may require later Argo CD health customization.

## Notes

The first successful end-to-end sync proved the pattern:

```text
GitHub → Argo CD → CRD → Experiment / AgentTask → Job
```
