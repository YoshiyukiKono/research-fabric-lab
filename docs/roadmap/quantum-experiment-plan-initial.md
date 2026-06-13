いいですね。量子らしさを入れるなら、**「量子計算そのもの」より先に「量子実験を扱う研究基盤」**として設計すると自然です。

中核イメージはこれです。

```text
Research Question
 ↓
Quantum Experiment
 ↓
Execution Backend
 ├─ local simulator
 ├─ HPC simulator
 ├─ GPU simulator
 ├─ quantum-inspired optimizer
 └─ real QPU / cloud QPU
 ↓
Result / Metrics / Artifacts
```

CRDも将来こう拡張できます。

```yaml
kind: QuantumExperiment
spec:
  algorithm: vqe
  backend:
    type: simulator
    provider: qiskit-aer
  problem:
    model: transverse-field-ising
    qubits: 12
  execution:
    mode: distributed
    replicas: 4
  outputs:
    - energy
    - circuit
    - measurement_counts
    - convergence_plot
```

量子プロジェクトらしい要素は、段階的にはこうです。

```text
v0.2.x
  quantum-python-base
  Qiskit / PennyLane / QuTiP / NetKet runtime

v0.3.x
  QuantumExperiment CRD
  VQE / QAOA / Ising / CHSH サンプル

v0.4.x
  Experiment → Quantum Job 生成
  結果に energy / counts / fidelity / expectation value を保存

v0.5.x
  GPU/HPC simulator
  distributed statevector / tensor network / NetKet

v0.6.x
  QPU backend abstraction
  IBM Quantum / Braket / IonQ 等への接続余地

v0.7.x
  AI Generated Quantum Experiment PR
```

特に良いのは、Kubernetes側では普通のJobでも、意味論としては

```text
QuantumExperiment
```

にすることです。

つまり、

```text
Kubernetes Job
```

ではなく、

```text
VQE実験
QAOA実験
Ising最適化
量子回路評価
測定分布比較
```

として扱える。

ここが「量子プロジェクトらしさ」になります。

最初のサンプルはこれが良さそうです。

```text
1. Bell state
2. CHSH
3. VQE H2
4. QAOA MaxCut
5. Transverse Field Ising
6. NetKet variational ground state
```

Research Fabric Lab の物語としては、

```text
GitOps for Research
```

から一歩進んで、

```text
GitOps for Quantum Experiments
```

ですね。これはかなり看板になります。
