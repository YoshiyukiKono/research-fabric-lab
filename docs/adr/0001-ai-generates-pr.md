# ADR 0001: AI generates PR, human reviews, GitOps applies

## Status

Accepted for MVP.

## Context

The project uses AI to generate research workload specifications. Directly allowing AI to apply Kubernetes resources would make review, reproducibility, and rollback weaker.

## Decision

AI output is committed to a Git branch and submitted as a Pull Request. A human reviews the diff. After merge, Argo CD applies the desired state to Kubernetes.

## Consequences

- All AI-generated changes are reviewable.
- Git is the audit log.
- GitOps remains the deployment authority.
- The UI is a PR generator, not an execution console.
