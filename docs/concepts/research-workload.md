# Research Workload

## 定義

Research Fabric Lab では、研究ワークロードを以下のように定義する。

```text
研究ワークロード = パラメータ化された再現可能な計算処理
```

## 例

- NetKet による Ising model の基底状態推定
- QUBO 生成と最適化
- Tensor Network 実験
- Hamiltonian Learning
- Qiskit / CUDA-Q による量子回路シミュレーション

## Kubernetesとの対応

初期段階では、研究ワークロードは Kubernetes Job として実行する。

将来的には、Argo Workflows、RayJob、MPIJob なども実行対象にする。

## GitOpsとの対応

研究ワークロードは GitHub 上の YAML として管理する。

```text
experiments/
├─ ising-netket-001/
└─ qaoa-vrp-001/
```

GitHub に merge された実験定義は、Argo CD により Kubernetes に同期される。
