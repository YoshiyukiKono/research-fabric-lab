```bash
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab -n research create secret generic minio-credentials \
  --from-literal=MINIO_ACCESS_KEY='' \
  --from-literal=MINIO_SECRET_KEY=''
secret/minio-credentials created
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ cat > /tmp/ising-1d-demo-job.yaml <<'EOF'
apiVersion: batch/v1
kind: Job
metadata:
  name: ising-1d-demo
  namespace: research
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: experiment
          image: python:3.11-slim
          command:
            - /bin/sh
            - -c
            - |
              pip install numpy minio

              python - <<'PY'
              import json
              import os
              import numpy as np
              from minio import Minio

              n = 4
              J = 1.0
              h = 0.7

              sx = np.array([[0, 1], [1, 0]], dtype=float)
              sz = np.array([[1, 0], [0, -1]], dtype=float)
              I = np.eye(2)

              def kron_all(ops):
                  out = ops[0]
                  for op in ops[1:]:
                      out = np.kron(out, op)
                  return out

EOF               key: MINIO_SECRET_KEYlsket}/{object_name}")",und).real)ps) @ ground).real))
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab apply -f /tmp/ising-1d-demo-job.yaml
job.batch/ising-1d-demo created
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab logs -n research job/ising-1d-demo
Collecting numpy
  Downloading numpy-2.4.6-cp311-cp311-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl.metadata (6.6 kB)
Collecting minio
  Downloading minio-7.2.20-py3-none-any.whl.metadata (6.5 kB)
Collecting argon2-cffi (from minio)
  Downloading argon2_cffi-25.1.0-py3-none-any.whl.metadata (4.1 kB)
Collecting certifi (from minio)
  Downloading certifi-2026.5.20-py3-none-any.whl.metadata (2.5 kB)
Collecting pycryptodome (from minio)
  Downloading pycryptodome-3.23.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (3.4 kB)
Collecting typing-extensions (from minio)
  Downloading typing_extensions-4.15.0-py3-none-any.whl.metadata (3.3 kB)
Collecting urllib3 (from minio)
  Downloading urllib3-2.7.0-py3-none-any.whl.metadata (6.9 kB)
Collecting argon2-cffi-bindings (from argon2-cffi->minio)
  Downloading argon2_cffi_bindings-25.1.0-cp39-abi3-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl.metadata (7.4 kB)
Collecting cffi>=1.0.1 (from argon2-cffi-bindings->argon2-cffi->minio)
  Downloading cffi-2.0.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl.metadata (2.6 kB)
Collecting pycparser (from cffi>=1.0.1->argon2-cffi-bindings->argon2-cffi->minio)
  Downloading pycparser-3.0-py3-none-any.whl.metadata (8.2 kB)
Downloading numpy-2.4.6-cp311-cp311-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl (16.9 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 16.9/16.9 MB 6.8 MB/s eta 0:00:00
Downloading minio-7.2.20-py3-none-any.whl (93 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 93.8/93.8 kB 4.9 MB/s eta 0:00:00
Downloading argon2_cffi-25.1.0-py3-none-any.whl (14 kB)
Downloading certifi-2026.5.20-py3-none-any.whl (134 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 134.1/134.1 kB 6.4 MB/s eta 0:00:00
Downloading pycryptodome-3.23.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.3 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.3/2.3 MB 8.6 MB/s eta 0:00:00
Downloading typing_extensions-4.15.0-py3-none-any.whl (44 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 44.6/44.6 kB 4.2 MB/s eta 0:00:00
Downloading urllib3-2.7.0-py3-none-any.whl (131 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 131.1/131.1 kB 7.1 MB/s eta 0:00:00
Downloading argon2_cffi_bindings-25.1.0-cp39-abi3-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl (87 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 87.1/87.1 kB 7.0 MB/s eta 0:00:00
Downloading cffi-2.0.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl (215 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 215.6/215.6 kB 8.3 MB/s eta 0:00:00
Downloading pycparser-3.0-py3-none-any.whl (48 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 48.2/48.2 kB 5.2 MB/s eta 0:00:00
Installing collected packages: urllib3, typing-extensions, pycryptodome, pycparser, numpy, certifi, cffi, argon2-cffi-bindings, argon2-cffi, minio
Successfully installed argon2-cffi-25.1.0 argon2-cffi-bindings-25.1.0 certifi-2026.5.20 cffi-2.0.0 minio-7.2.20 numpy-2.4.6 pycparser-3.0 pycryptodome-3.23.0 typing-extensions-4.15.0 urllib3-2.7.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

[notice] A new release of pip is available: 24.0 -> 26.1.2
[notice] To update, run: pip install --upgrade pip
uploaded: s3://research-artifacts/ising-1d-demo/result.json
ubuntu@rancher-mgmt-02:~/research-fabric-lab$


```

```json
{
  "model": "1d transverse-field quantum ising",
  "sites": 4,
  "coupling_J": 1.0,
  "field_h": 0.7,
  "boundary": "periodic",
  "ground_energy": -4.5638560652030025,
  "energy_gap": 0.12254494205626187,
  "magnetization_z": [
    5.329070518200751e-15,
    5.2735593669694936e-15,
    5.384581669432009e-15,
    5.218048215738236e-15
  ],
  "zz_correlation_0_1": 0.8317485365275621
}
```
```bash
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab delete job -n research ising-1d-demo
job.batch "ising-1d-demo" deleted from research namespace
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab apply -f deploy/k8s/jobs/ising-1d-demo/job.yaml
job.batch/ising-1d-demo created
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab get pods -n research
NAME                               READY   STATUS      RESTARTS   AGE
ising-1d-demo-pq7r6                0/1     Completed   0          10s
research-portal-578bc646bb-487hb   1/1     Running     0          80m
ubuntu@rancher-mgmt-02:~/research-fabric-lab$ kubectl --context agent-lab logs -n research job/ising-1d-demo
Collecting numpy
  Downloading numpy-2.4.6-cp311-cp311-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl.metadata (6.6 kB)
Collecting minio
  Downloading minio-7.2.20-py3-none-any.whl.metadata (6.5 kB)
Collecting argon2-cffi (from minio)
  Downloading argon2_cffi-25.1.0-py3-none-any.whl.metadata (4.1 kB)
Collecting certifi (from minio)
  Downloading certifi-2026.5.20-py3-none-any.whl.metadata (2.5 kB)
Collecting pycryptodome (from minio)
  Downloading pycryptodome-3.23.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl.metadata (3.4 kB)
Collecting typing-extensions (from minio)
  Downloading typing_extensions-4.15.0-py3-none-any.whl.metadata (3.3 kB)
Collecting urllib3 (from minio)
  Downloading urllib3-2.7.0-py3-none-any.whl.metadata (6.9 kB)
Collecting argon2-cffi-bindings (from argon2-cffi->minio)
  Downloading argon2_cffi_bindings-25.1.0-cp39-abi3-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl.metadata (7.4 kB)
Collecting cffi>=1.0.1 (from argon2-cffi-bindings->argon2-cffi->minio)
  Downloading cffi-2.0.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl.metadata (2.6 kB)
Collecting pycparser (from cffi>=1.0.1->argon2-cffi-bindings->argon2-cffi->minio)
  Downloading pycparser-3.0-py3-none-any.whl.metadata (8.2 kB)
Downloading numpy-2.4.6-cp311-cp311-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl (16.9 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 16.9/16.9 MB 8.7 MB/s eta 0:00:00
Downloading minio-7.2.20-py3-none-any.whl (93 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 93.8/93.8 kB 5.7 MB/s eta 0:00:00
Downloading argon2_cffi-25.1.0-py3-none-any.whl (14 kB)
Downloading certifi-2026.5.20-py3-none-any.whl (134 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 134.1/134.1 kB 7.2 MB/s eta 0:00:00
Downloading pycryptodome-3.23.0-cp37-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (2.3 MB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.3/2.3 MB 9.1 MB/s eta 0:00:00
Downloading typing_extensions-4.15.0-py3-none-any.whl (44 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 44.6/44.6 kB 4.2 MB/s eta 0:00:00
Downloading urllib3-2.7.0-py3-none-any.whl (131 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 131.1/131.1 kB 6.8 MB/s eta 0:00:00
Downloading argon2_cffi_bindings-25.1.0-cp39-abi3-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl (87 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 87.1/87.1 kB 6.0 MB/s eta 0:00:00
Downloading cffi-2.0.0-cp311-cp311-manylinux2014_x86_64.manylinux_2_17_x86_64.whl (215 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 215.6/215.6 kB 8.0 MB/s eta 0:00:00
Downloading pycparser-3.0-py3-none-any.whl (48 kB)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 48.2/48.2 kB 4.6 MB/s eta 0:00:00
Installing collected packages: urllib3, typing-extensions, pycryptodome, pycparser, numpy, certifi, cffi, argon2-cffi-bindings, argon2-cffi, minio
Successfully installed argon2-cffi-25.1.0 argon2-cffi-bindings-25.1.0 certifi-2026.5.20 cffi-2.0.0 minio-7.2.20 numpy-2.4.6 pycparser-3.0 pycryptodome-3.23.0 typing-extensions-4.15.0 urllib3-2.7.0
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv

[notice] A new release of pip is available: 24.0 -> 26.1.2
[notice] To update, run: pip install --upgrade pip
uploaded: s3://research-artifacts/ising-1d-demo/result.json
ubuntu@rancher-mgmt-02:~/research-fabric-lab$
```
