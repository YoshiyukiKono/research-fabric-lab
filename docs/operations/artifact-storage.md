# Artifact Storage Operations

## Check MinIO

```bash
kubectl get all -n storage
kubectl get pvc -n storage
kubectl get ingress -n storage
```

## Port-forward console

```bash
kubectl port-forward -n storage svc/minio-console 9001:9001
```

Then open:

```text
http://localhost:9001
```

## Credentials

Lab default:

```text
User: minio
Password: minio12345
```

## Run upload validation

```bash
kubectl apply -k research-platform/storage/minio/runtime-upload-example
kubectl logs -n research-experiments job/artifact-upload-example
```

## Cleanup validation job

```bash
kubectl delete -k research-platform/storage/minio/runtime-upload-example
```
