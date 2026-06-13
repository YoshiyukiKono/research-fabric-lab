# AgentTask CRD

## 概要

`AgentTask` は、AI Agent に依頼する補助作業を表現するための CRD である。

Research Fabric Lab では、AI を Kubernetes を直接操作する主体とはしない。AI は、実験定義やレポート生成を補助する存在として扱う。

## 役割

`AgentTask` は以下を表現する。

- 実験結果の要約
- レポート生成
- 異常検知の補助
- 次の実験候補の提案
- Pull Request の生成

## 基本思想

```text
Experiment = 計算の仕様
AgentTask = 解釈・生成・補助の仕様
```

AI の出力は GitHub Pull Request として生成し、人間がレビューする。

```text
AI generates PR
↓
Human reviews
↓
GitOps applies
```
