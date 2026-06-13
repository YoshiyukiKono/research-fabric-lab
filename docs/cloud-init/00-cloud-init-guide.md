# Cloud-init guide for research-fabric-vm

This project includes a sample cloud-init user-data file for creating a single-node K3s research cluster on a Harvester VM.

## Files

```text
infra/harvester/cloud-init/research-fabric-vm.user-data.yaml
infra/harvester/cloud-init/research-fabric-vm.network-data.yaml
```

## Expected flow

1. Create a Harvester VM.
2. Attach cloud-init user-data and network-data.
3. Boot the VM.
4. SSH into the VM.
5. Confirm K3s status.
6. Install or bootstrap Argo CD.
7. Register the cluster in Rancher if desired.

## Notes

- The sample uses K3s for the first iteration because it is lighter than RKE2.
- For enterprise hardening, replace K3s with RKE2 in a later milestone.
- External LLM API keys should not be stored in Git. Use Kubernetes Secrets or sealed/external secrets later.
