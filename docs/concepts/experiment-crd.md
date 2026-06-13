# Experiment CRD

## 概要

`Experiment` は、Research Fabric Lab における研究ワークロードの中心概念である。

Kubernetes Job を直接書く代わりに、研究上の意図やパラメータを `Experiment` として表現する。

## 目的

`Experiment` の目的は、研究対象と実行方式を分離することである。

```text
研究の意図 = Experiment
実行方法 = Job / Workflow / Operator
```

## 例

```yaml
apiVersion: research.fabric/v1alpha1
kind: Experiment
metadata:
  name: ising-netket-001
  namespace: research
spec:
  domain: quantum
  engine: netket
  task: ground-state-estimation
  model:
    name: transverse-field-ising
```

## 現在の状態

Day-1 Bootstrap 時点では、CRD は存在するが Operator はまだ存在しない。

そのため、`Experiment` と Kubernetes Job は手動で併置されている。

## 将来像

将来的には Operator が `Experiment` を監視し、必要な Job / Workflow を生成する。

```text
Experiment
↓
Operator
↓
Job / Workflow
↓
Result
```
