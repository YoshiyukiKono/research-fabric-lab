# Phase 2: Operator

## 目的

`Experiment` CRD から Kubernetes Job を生成する Operator を実装する。

## 現在

Day-1 時点では、`Experiment` と Job は手動で併置されている。

```text
Experiment
Job
```

## 目標

```text
Experiment
↓
Operator
↓
Job
↓
Result
```

## 最小実装

- `Experiment` を watch する
- `spec.engine` を読む
- engine に応じて Job template を選ぶ
- Job を作成する
- Job の状態を `Experiment.status` に反映する
