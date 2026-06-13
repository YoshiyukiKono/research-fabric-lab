# GitHub Actions と GHCR による Runtime Image 配布

## 概要

Research Fabric Lab では、研究ワークロードを実行するための Runtime Image を GitHub Container Registry (GHCR) へ公開する。

Runtime Image は Kubernetes クラスタへ事前インストールせず、Job 実行時にコンテナイメージとして取得する。

構成は以下の通りである。

GitHub Repository
↓
GitHub Actions
↓
GHCR
↓
Kubernetes Job

---

## Runtime Image

初回作成した Runtime Image

* quantum-python-base

目的：

* Python 実行環境の共通化
* 研究ライブラリの集約
* Job 定義の簡素化

---

## GitHub Actions

Workflow

```text
.github/workflows/publish-runtime-images.yml
```

GitHub Actions により以下を自動実行する。

1. Docker Build
2. GHCR Login
3. Container Image Push

---

## 初回構築時の注意点

### Workflow が認識されない

症状：

Actions 画面に

```text
Get started with GitHub Actions
```

のみが表示される。

原因：

`.github/workflows/` 以下に Workflow が配置されていない。

対応：

GitHub Web UI の

Add File
↓
Create New File

から

```text
.github/workflows/publish-runtime-images.yml
```

を作成する。

---

## Build 成功確認

Actions タブで

```text
Publish Runtime Images
```

が成功していることを確認する。

確認項目：

* Build Success
* Push Success
* Package 作成

---

## GHCR Package

生成された Package

```text
ghcr.io/yoshiyukikono/research-fabric-lab/quantum-python-base
```

Pull 例：

```bash
docker pull \
ghcr.io/yoshiyukikono/research-fabric-lab/quantum-python-base:<tag>
```

---

## Kubernetes ノードでの Pull 確認

K3s ノード上で実施。

```bash
sudo k3s ctr image pull \
ghcr.io/yoshiyukikono/research-fabric-lab/quantum-python-base:<tag>
```

成功時：

```text
unpacking ... done
```

と表示される。

---

## Runtime Image 利用確認

Job

```text
ising-python-runtime-001
```

にて Runtime Image を利用。

実行結果：

```json
{
  "status": "completed",
  "experiment": "ising-netket-001"
}
```

Research Fabric Lab において、

GitHub Actions
↓
GHCR
↓
Kubernetes Runtime

の経路が成立したことを確認した。

---

## 今後の展開

現在

* quantum-python-base

将来

* netket-runtime
* qiskit-runtime
* qubo-runtime
* report-runtime

を追加予定。

Experiment は Runtime Image を指定することで、実行環境を選択可能とする。
