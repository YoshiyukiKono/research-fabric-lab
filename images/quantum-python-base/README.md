# quantum-python-base

Research Fabric Lab の最初の Runtime Image です。

このイメージは、NetKet や Qiskit などの重い量子ライブラリを入れる前段階として、軽量な Python 計算ジョブを安定して実行するためのベースイメージです。

## 含めるもの

- Python 3.12
- numpy
- scipy
- matplotlib
- networkx
- pydantic

## 含めないもの

このイメージには、まだ以下は含めません。

- NetKet
- Qiskit
- QuTiP
- TeNPy
- JAX / CUDA

これらは、後続の専用 Runtime Image として分けます。

## 想定イメージ名

```text
ghcr.io/yoshiyukikono/research-fabric-lab/quantum-python-base:latest
```

## 位置づけ

現時点では Operator よりも先に Runtime Image を定義します。

理由は、Operator が生成する Kubernetes Job の実行環境を先に安定させるためです。
