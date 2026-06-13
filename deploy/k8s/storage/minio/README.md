# MinIO Artifact Storage

## Purpose

MinIO is used as the first artifact storage layer for Research Fabric Lab.

Runtime Jobs upload experiment outputs such as:

- `result.json`
- logs
- generated datasets
- model checkpoints
- simulation outputs

to the `research-artifacts` bucket.

## DNS assumptions

Add these hostnames to local DNS or `/etc/hosts`:

```text
minio.lab.local
console.minio.lab.local
```

## Credentials

Initial credentials are defined in `values.yaml`.

For lab bootstrap only:

```text
rootUser: minio
rootPassword: minio12345
```

Change them before using this outside a local lab.
