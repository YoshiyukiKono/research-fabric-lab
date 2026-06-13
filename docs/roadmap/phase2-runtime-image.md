# Phase 2: Runtime Image 定義

## 目的

Operator 実装に進む前に、研究ワークロードの実行環境である Runtime Image を定義する。

## 背景

現在は `python:3.12-slim` を直接使って Job を実行している。

これは検証としては十分だが、Research Fabric Lab としては、実験ごとの実行環境を GitHub 上で明示的に定義し、GHCR から pull できる形にする必要がある。

## 目標

```text
GitHub
↓
GitHub Actions
↓
GHCR
↓
Kubernetes Job
↓
Result JSON
```

## 作成するもの

```text
images/quantum-python-base/
├─ Dockerfile
├─ requirements.txt
└─ README.md

.github/workflows/publish-runtime-images.yml
```

## 最初の Runtime Image

```text
quantum-python-base
```

含めるもの：

- Python 3.12
- numpy
- scipy
- matplotlib
- networkx
- pydantic

含めないもの：

- NetKet
- Qiskit
- QuTiP
- TeNPy
- JAX / CUDA

## Job差し替え手順

1. GitHub に Runtime Image 定義を commit
2. GitHub Actions で GHCR に publish
3. `templates/jobs/job-quantum-python-runtime.yaml` を参考に、実験Jobの image を差し替える
4. Argo CD で `research-experiments` を同期
5. Jobログで JSON 結果を確認

## agent-lab-02 との関係

初期の実験Jobは `rancher-mgmt-02` 上の K3s で実行した。

次段階では `agent-lab-02` を Workload Cluster として利用することを想定する。

ただし、Runtime Image はクラスタに依存しない。先に image を定義しておくことで、後から実行先クラスタを切り替えられる。

## 次の段階

Phase 2B では `netket-runtime` を追加し、実際の量子スピン系シミュレーションへ進む。
