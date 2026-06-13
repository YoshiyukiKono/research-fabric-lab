# ADR-0001: Argo CD を採用する

Date: 2026-06-13

## Status

Accepted

## Context

Research Fabric Lab では、研究ワークロードを GitHub 上の宣言的定義として管理し、Kubernetes クラスタへ同期する必要がある。

Rancher / Fleet も利用可能だが、本プロジェクトではアプリケーション単位の同期状態、差分、手動同期、App of Apps の見通しを重視した。

## Decision

Research Fabric Lab のアプリケーションGitOpsには Argo CD を利用する。

## Consequences

- GitHub から Kubernetes への同期状態を Argo CD UI で確認できる。
- App of Apps パターンを利用できる。
- Rancher / Fleet とは役割分担する。
- Argo CD 自体の運用知識が必要になる。
