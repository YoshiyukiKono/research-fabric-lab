# Research Fabric Lab の構想

## 概要

Research Fabric Lab は、量子計算、HPC、数理最適化、AI Agent を Kubernetes 上の再現可能な研究ワークロードとして扱うための実験基盤である。

目的は、単に Kubernetes 上でアプリケーションを動かすことではない。研究の意図、実験定義、実行、結果、レポート生成までを GitOps の流れに載せることで、研究作業そのものを再現可能なソフトウェア資産として扱う。

## 中核コンセプト

```text
Human Intent
↓
AI generates PR
↓
Human reviews
↓
GitOps applies
↓
Kubernetes executes
↓
Results and reports
```

AI は直接 Kubernetes を操作しない。AI は GitHub Pull Request を生成し、人間がレビューし、GitOps Controller がクラスタへ反映する。

## 対象領域

- Quantum Simulation
- QUBO / Ising Optimization
- Tensor Network
- Hamiltonian Learning
- HPC Workflow
- AI-generated Research Report

## 基本思想

研究実験は、以下のように扱う。

```text
実験 = パラメータ化された再現可能な計算ワークロード
```

そのため、Kubernetes Job を直接書くのではなく、将来的には `Experiment` CRD を中心に研究ワークロードを表現する。
