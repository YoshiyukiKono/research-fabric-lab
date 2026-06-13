# 最初の Experiment 実行

## 概要

この文書では、Research Fabric Lab における最初の Experiment 実行を記録する。

Day-1 Bootstrap では、`ising-netket-001` というサンプル実験を GitOps 経由で Kubernetes Job として実行した。

## 実行されたリソース

```text
experiments/
└─ ising-netket-001
```

この実験では、現時点では NetKet の本格実行ではなく、placeholder Job を実行している。

## 確認コマンド

```bash
kubectl get experiment -n research
kubectl get jobs -n research
kubectl logs -n research job/ising-netket-001
```

## 実行結果

```json
{"status":"placeholder","engine":"netket"}
```

## 意味

この結果は、まだ量子シミュレーションとして意味を持つものではない。

重要なのは、以下のパスが成立したことである。

```text
GitHub上の実験定義
↓
Argo CD同期
↓
Kubernetes Job作成
↓
Job実行
↓
ログ確認
```

## 次の改善

次の段階では、placeholder を軽量 Python 実験に置き換える。

例：

- Experiment YAML からパラメータを読む
- 小さな数値計算を行う
- JSON で結果を出力する
- PVC または object storage に結果を保存する
