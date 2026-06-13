# Harvester VM sizing template

## research-fabric-vm

- Image: Ubuntu Server or SLE Micro image supported in your lab
- vCPU: 4-6
- Memory: 16 GiB
- Disk: 150 GiB
- Network: management or lab VLAN
- Cloud-init: use files under `infra/harvester/cloud-init/`

## Optional future nodes

| VM | Purpose | Suggested size |
|---|---|---|
| research-worker-cpu-01 | CPU-only experiment worker | 4 vCPU / 8 GiB |
| research-worker-gpu-01 | GPU experiment worker | depends on GPU |
| minio-vm | external artifact storage | 2 vCPU / 4 GiB |
