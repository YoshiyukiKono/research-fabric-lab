# Phase 1: Bootstrap

## 目的

Research Fabric Lab の最小 GitOps 基盤を構築する。

## 完了条件

- Harvester 上の K3s クラスタに Argo CD が導入されている
- GitHub リポジトリが Argo CD に接続されている
- App of Apps が動作している
- `research` / `research-system` namespace が作成されている
- `Experiment` / `AgentTask` CRD が作成されている
- サンプル Job が GitOps 経由で実行されている

## 状態

2026-06-13 時点で完了。
