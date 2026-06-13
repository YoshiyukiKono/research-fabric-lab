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

# Day 2: First Result-Producing Experiment Job

experiments/ising-netket-001/jobs/job-python-result.yamlを追加



```bash
ubuntu@rancher-mgmt-02:~$ k get jobs -n research
NAME               STATUS     COMPLETIONS   DURATION   AGE
ising-netket-001   Complete   1/1           13s        21m
ubuntu@rancher-mgmt-02:~$ kubectl annotate application research-experiments -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
application.argoproj.io/research-experiments annotated
ubuntu@rancher-mgmt-02:~$ kubectl get jobs -n research
NAME                      STATUS     COMPLETIONS   DURATION   AGE
ising-netket-001          Complete   1/1           13s        33m
ising-python-result-001   Complete   1/1           8s         10s
ubuntu@rancher-mgmt-02:~$ kubectl logs -n research job/ising-python-result-001
<string>:23: DeprecationWarning: datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version. Use timezone-aware objects to represent datetimes in UTC: datetime.datetime.now(datetime.UTC).
{"status": "completed", "timestamp": "2026-06-13T19:24:55.836994Z", "experiment": {"name": "ising-netket-001", "engine": "python-placeholder", "model": "transverse-field-ising", "L": 16, "h_values": [0.2, 0.5, 1.0]}, "results": [{"h": 0.2, "estimated_energy": -16.316862443496913}, {"h": 0.5, "estimated_energy": -17.88854381999832}, {"h": 1.0, "estimated_energy": -22.627416997969522}]}
ubuntu@rancher-mgmt-02:~$
```
experiments/ising-netket-001/jobs/job-python-result.yamlを編集

```yaml
image: ghcr.io/yoshiyukikono/research-fabric-lab/quantum-python-base:480943889aca4677d70a5c6ad54e6c629e7562e1
```
```yaml
metadata:
  name: ising-python-runtime-001
```
```bash
ubuntu@rancher-mgmt-02:~$ kubectl annotate application research-experiments -n argocd \
  argocd.argoproj.io/refresh=hard --overwrite
application.argoproj.io/research-experiments annotated
ubuntu@rancher-mgmt-02:~$ k get jobs -n research
NAME                       STATUS     COMPLETIONS   DURATION   AGE
ising-netket-001           Complete   1/1           13s        65m
ising-python-result-001    Complete   1/1           8s         32m
ising-python-runtime-001   Complete   1/1           4s         11s
ubuntu@rancher-mgmt-02:~$ k logs -n research job/ising-python-runtime-001
<string>:23: DeprecationWarning: datetime.datetime.utcnow() is deprecated and scheduled for removal in a future version. Use timezone-aware objects to represent datetimes in UTC: datetime.datetime.now(datetime.UTC).
{"status": "completed", "timestamp": "2026-06-13T19:57:06.122306Z", "experiment": {"name": "ising-netket-001", "engine": "python-placeholder", "model": "transverse-field-ising", "L": 16, "h_values": [0.2, 0.5, 1.0]}, "results": [{"h": 0.2, "estimated_energy": -16.316862443496913}, {"h": 0.5, "estimated_energy": -17.88854381999832}, {"h": 1.0, "estimated_energy": -22.627416997969522}]}
ubuntu@rancher-mgmt-02:~$
```
