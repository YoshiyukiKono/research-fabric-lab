# Phase 3: AI-generated PR

## 目的

自然言語の研究意図から、AI が GitHub Pull Request を生成する。

## 基本フロー

```text
Human Intent
↓
AI Draft Generator
↓
GitHub Branch / Commit
↓
Pull Request
↓
Human Review
↓
GitOps Apply
```

## 原則

AI は Kubernetes を直接操作しない。

AI の出力は GitHub Pull Request として扱い、人間のレビューを通してから Argo CD が適用する。
