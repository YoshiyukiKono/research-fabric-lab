# ADR-0003: Experiment を CRD として表現する

Date: 2026-06-13

## Status

Accepted

## Context

Research Fabric Lab では、研究実験を Kubernetes Job として実行する。しかし、Job は実行方式であり、研究の意図そのものではない。

量子シミュレーション、QUBO、Tensor Network、Hamiltonian Learning などを扱うためには、研究ワークロードをより高い抽象度で表現する必要がある。

## Decision

研究ワークロードは `Experiment` CRD として表現する。

AI Agent による補助作業は `AgentTask` CRD として表現する。

## Consequences

- 研究の意図と実行方式を分離できる。
- 将来的に Operator が `Experiment` から Job / Workflow を生成できる。
- CRD と Operator の設計・保守が必要になる。
- Day-1 時点では CRD のみを導入し、Operator は後続フェーズで実装する。
