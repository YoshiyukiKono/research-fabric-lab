# Research Fabric Lab Documentation

Research Fabric Lab は、量子・HPC・最適化・AI Agent の研究ワークロードを GitOps と Kubernetes で扱うための実験基盤です。

この `docs/` ディレクトリでは、プロジェクトの思想、アーキテクチャ、初期構築手順、運用メモ、ADR、ロードマップを管理します。

## 構成

```text
docs/
├─ architecture/   # 全体構想とターゲットアーキテクチャ
├─ bootstrap/      # 初期構築手順と作業記録
├─ concepts/       # Experiment / AgentTask などの概念整理
├─ operations/     # Argo CD や Kubernetes 運用メモ
├─ adr/            # Architecture Decision Record
└─ roadmap/        # 今後の開発フェーズ
```

## 最初に読む文書

- [Research Fabric Lab の構想](architecture/00-vision.md)
- [Harvester 上への初期構築](bootstrap/01-harvester-rancher-argocd.md)
- [GitOps モデル](architecture/02-gitops-model.md)
- [ADR-0001: Argo CD を採用する](adr/0001-use-argocd.md)
