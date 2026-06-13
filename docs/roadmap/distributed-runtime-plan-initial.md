HPC / 相互通信まで見据えるなら、Workload Cluster は単なる Job 実行先ではなく、**Research Compute Cluster** として設計した方がよいです。

基本形はこうです。

```text
Management Cluster
 ├─ Rancher
 ├─ ArgoCD
 └─ GitOps / Portal

Workload Cluster
 ├─ Experiment CRD
 ├─ Experiment Operator
 ├─ Batch Scheduler
 ├─ Runtime Jobs
 ├─ Distributed Workloads
 ├─ Shared Storage
 └─ High-speed Network
```

重要なのは、Workload Cluster 内をさらに分けて考えることです。

```text
Workload Cluster
 ├─ control namespace
 │   ├─ Experiment Operator
 │   ├─ AgentTask Operator
 │   └─ Scheduler integration
 │
 ├─ research namespace
 │   ├─ single-node Jobs
 │   ├─ notebooks
 │   └─ small experiments
 │
 ├─ hpc namespace
 │   ├─ MPI Jobs
 │   ├─ Ray clusters
 │   ├─ Dask clusters
 │   └─ GPU distributed jobs
 │
 └─ research-system namespace
     ├─ shared services
     ├─ result collector
     ├─ artifact store
     └─ metadata DB
```

HPC 的には、特にこの3つが必要になります。

```text
1. 複数Podを同時に起動する仕組み
2. Pod間の高速・安定通信
3. 共有データ / 結果保存
```

---

一番自然な進化はこれです。

```text
Experiment
 ↓
Experiment Operator
 ↓
Distributed Job
 ↓
Worker Pods
 ↓
Result
```

たとえば将来の Experiment はこういう形になります。

```yaml
apiVersion: research.fabric/v1alpha1
kind: Experiment
metadata:
  name: mpi-vqe-test
spec:
  runtime:
    image: ghcr.io/.../quantum-python-base
  execution:
    mode: distributed
    backend: mpi
    replicas: 4
  resources:
    cpu: 4
    memory: 8Gi
  network:
    communication: pod-to-pod
  outputs:
    path: /outputs
```

Operator はこれを見て、通常の Kubernetes Job ではなく、

```text
MPIJob
RayCluster
DaskCluster
PyTorchJob
```

のような分散ワークロードに変換するイメージです。

---

クラスタ内通信の構成は、段階的にはこうです。

## Phase 3.5: 通常のPod間通信

まずは普通のKubernetesネットワークで十分です。

```text
Pod A ←→ Pod B
Pod A ←→ Service ←→ Pod B
```

用途:

```text
Agent同士の通信
小規模分散処理
Ray / Daskの試験
Experiment Operatorの検証
```

この段階では CNI は通常構成でよいです。

---

## Phase 4以降: 分散ワークロード

ここで必要になるのが、

```text
Head Pod
Worker Pods
Shared Storage
```

です。

例:

```text
Ray Head
 ├─ Ray Worker 1
 ├─ Ray Worker 2
 └─ Ray Worker 3
```

または

```text
MPI Launcher
 ├─ MPI Worker 1
 ├─ MPI Worker 2
 ├─ MPI Worker 3
 └─ MPI Worker 4
```

この場合、Workload Cluster はこうなります。

```text
agent-lab-02 Workload Cluster
 ├─ Experiment Operator
 ├─ Runtime Image
 ├─ Distributed Job Controller
 ├─ Worker Pods
 ├─ Shared PVC
 └─ Result Store
```

---

## 将来: HPC寄り構成

本格的にHPCへ寄せるなら、さらにこうなります。

```text
Workload Cluster
 ├─ CPU Node Pool
 ├─ GPU Node Pool
 ├─ High-memory Node Pool
 ├─ MPI/Ray/Dask Runtime
 ├─ Gang Scheduler
 ├─ Shared Filesystem
 └─ RDMA / 高速ネットワーク
```

ここで出てくる要素は、

```text
Volcano / Kueue
MPI Operator
Kubeflow Training Operator
Ray Operator
Dask Operator
NFS / Longhorn / Ceph / Lustre
Multus
RDMA
GPU Operator
```

です。

---

私なら Research Fabric Lab のロードマップでは、こう切ります。

```text
v0.2.0-workload-cluster
  Management / Workload分離

v0.2.5-distributed-runtime
  Pod間通信
  Ray or Dask の最小構成

v0.3.0-research-portal-mvp
  Experiment投入画面

v0.4.0-experiment-design
  distributed execution spec追加

v0.5.0-experiment-operator
  Experiment → Job/Ray/MPI 変換

v0.6.0-hpc-runtime
  MPIJob
  Gang Scheduling
  GPU/CPU Node Pool
```

---

現時点の設計判断としては、

**OperatorはWorkload Cluster内に置く。**

ただし、将来のOperatorは単なるJob生成ではなく、

```text
Experiment
 ↓
Execution Backendを選択
 ↓
single job / Ray / Dask / MPI / GPU job
```

を切り替える存在になります。

つまり Research Fabric Lab の中核は、将来的にはこうです。

```text
Experiment Operator
=
Research workload compiler
```

かなり良い方向です。ここまで考えると、単なるKubernetes検証ではなく、ちゃんと「研究計算基盤」になってきます。
