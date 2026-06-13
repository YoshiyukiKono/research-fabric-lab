# v0.2.0-artifact-storage

This package adds GitOps-managed artifact storage for Research Fabric Lab.

## Goal

Experiment -> Runtime Job -> Artifact -> MinIO

## Components

- `storage` namespace
- MinIO via ArgoCD Application
- Longhorn-backed PVC
- Traefik Ingress
- `research-artifacts` bucket
- Runtime Job upload example

## Intended repository placement

Copy `research-platform/storage/minio` into your `research-fabric-root` repository.

Then add the MinIO Application to the parent App of Apps if needed.
