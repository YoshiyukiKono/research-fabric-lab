# Research Fabric Lab on Harvester

## 目的
Harvester上にK3sクラスタを構築し、Agent Fabric LabとResearch Fabric Labをデプロイする。

## 実施概要
- Harvester上にUbuntu Jump Host作成
- workload-k3sへkubectl接続
- agent-fabric-labをデプロイ
- Ollama/Agents/Orchestrator動作確認
- research-fabric-labをデプロイ
- Argo CD App of Apps構築
- Experiment/AgentTask CRD登録
- MinIOデプロイ
- Streamlit Portalデプロイ
- PortalからJob生成・実行
- CoreDNS(NodeHosts)へ以下を追加
  - rancher.demo.local
  - k3s-server
  - minio.lab.local
  - console.minio.lab.local
  - portal.agent.lab.local

## 主なトラブル
- ArgoCD CRD annotation size → server-side applyで解決
- Secret名・キー名不一致
- Portal Jobからminio.lab.localが名前解決できない
- CoreDNS NodeHosts更新で解決

## 到達点
- Rancher
- workload-k3s
- ArgoCD
- Agent Fabric Lab
- Ollama
- Research Portal
- MinIO
- Experiment Job実行
