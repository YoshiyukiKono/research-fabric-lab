# What is Research Fabric Lab?

## Research Fabric Labとは何か

Research Fabric Lab は、AI と Kubernetes を利用して研究活動を実行可能なシステムとして扱うための実験プロジェクトです。

本プロジェクトの目的は、単にAIを利用して文章やコードを生成することではありません。

目指しているのは、

```text
Research Goal
↓
Experiment Specification
↓
Execution
↓
Artifact
```

という研究活動そのものを、一つの実行可能なパイプラインとして扱うことです。

---

## なぜ作るのか

研究や技術開発は、多くの場合、以下のような流れで進みます。

```text
アイディアを思いつく
↓
実験計画を書く
↓
コードを書く
↓
実行する
↓
結果を保存する
↓
考察する
```

しかし実際には、

* 実験条件の管理
* 実行環境の準備
* 結果の保存
* 再現性の確保

といった作業に多くの時間が費やされます。

特に近年では、

* 機械学習
* HPC
* 量子計算
* シミュレーション

などの分野で、研究環境そのものが複雑化しています。

Research Fabric Lab は、この複雑さを Kubernetes のワークロードとして扱うことで、研究活動の再現性と自動化を高めることを目指しています。

---

## 「Fabric」という名前について

Fabric とは「織物」や「基盤」を意味します。

Research Fabric Lab における Fabric は、

* AI
* Kubernetes
* Storage
* Compute
* Experiment

を織り合わせる基盤を意味しています。

研究者が直接インフラを意識しなくても、

```text
研究目的
↓
実験
↓
結果
```

へ到達できる環境を目指しています。

---

## AIは何を担当するのか

Research Fabric Lab において、AIは研究者の代わりになる存在ではありません。

AIは、

```text
Research Goal
↓
Experiment Specification
```

の変換を支援する役割を持ちます。

例えば、

```text
1次元量子Ising模型の基底状態を調べたい
```

という研究目的から、

```json
{
  "experiment": "...",
  "runtime": "...",
  "artifact": "..."
}
```

のような実験仕様を生成することができます。

しかし、

何を研究するか、
どの結果に意味があるか、
どの仮説を検証するか、

といった判断は研究者自身が行います。

Research Fabric Lab は研究者を置き換えることではなく、研究者の実行能力を拡張することを目的としています。

---

## Kubernetesを利用する理由

本プロジェクトでは Kubernetes を研究実行基盤として利用しています。

理由は単純です。

研究実験も本質的にはワークロードだからです。

例えば、

```text
量子シミュレーション
機械学習学習ジョブ
最適化計算
データ解析
```

はいずれも、

```text
入力
↓
計算
↓
出力
```

として表現できます。

Kubernetes は、このような処理を再現可能な形で管理するための優れた仕組みを持っています。

Research Fabric Lab は Kubernetes をクラウドアプリケーション基盤ではなく、研究実行基盤として利用しています。

---

## Artifactを重視する理由

研究において重要なのは実行そのものではなく、その結果です。

Research Fabric Lab では、

```text
Experiment
↓
Artifact
```

を重視しています。

実験結果は MinIO に保存されます。

例えば、

```text
research-artifacts/
└── ising-1d-demo/
    └── runs/
        └── 20260614-073546-9e6037/
            └── result.json
```

のように保存されます。

この構造により、

* 実験履歴
* 再現性
* 結果比較

が可能になります。

---

## 現在の実装

現時点では、

```text
Research Portal
↓
OpenAI
↓
Experiment Specification
↓
Kubernetes Job
↓
Execution
↓
Artifact Upload
↓
MinIO
```

という最小構成を実装しています。

研究者は Portal から実験仕様を生成し、実行し、その結果を保存できます。

---

## 今後について

Research Fabric Lab は特定の研究分野のためのシステムではありません。

量子計算、
機械学習、
最適化、
シミュレーション、

さらには将来的な GPU クラスタや HPC 環境も含め、

様々な研究ワークロードを扱うことを想定しています。

重要なのは、

研究内容ではなく、

```text
Research Goal
↓
Experiment
↓
Artifact
```

という研究活動の構造そのものを扱うことです。

Research Fabric Lab は、そのための実験的な基盤です。
