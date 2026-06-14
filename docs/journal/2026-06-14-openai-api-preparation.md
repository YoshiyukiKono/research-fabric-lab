# Journal: OpenAI API 利用準備

日付: 2026-06-14

## 背景

Research Fabric Lab v0.3.0-preview では、Workload Cluster 上に Research Portal を構築した。

次の段階として、Research Portal から OpenAI API を呼び出し、

* Experiment Spec生成
* Runtime Job生成
* GitHub PR生成

などを支援する AI Assistant 機能を追加する。

そのために OpenAI API Key を取得する。

---

## OpenAI API Platform

OpenAI API は以下から利用できる。

OpenAI Platform

https://platform.openai.com/

ドキュメント

https://platform.openai.com/docs

料金

https://platform.openai.com/docs/pricing

---

## API Key 作成手順

OpenAI Platform にログイン後、

```text
Dashboard
 ↓
API Keys
 ↓
Create new secret key
```

を選択する。

作成されたキーは、

```text
sk-xxxxxxxxxxxxxxxx
```

の形式となる。

注意:

API Key は作成時にのみ表示される。

後から再表示できないため、安全な場所に保管する。

---

## Kubernetes Secret 管理

Research Fabric Lab では API Key を GitHub に保存しない。

以下は禁止とする。

```yaml
env:
  OPENAI_API_KEY: sk-xxxxxxxx
```

```yaml
configMap:
  OPENAI_API_KEY: sk-xxxxxxxx
```

理由:

* GitHub履歴に残る
* ArgoCD履歴に残る
* 誤公開リスクがある

代わりに Kubernetes Secret を利用する。

---

## Secret 作成

Workload Cluster 上で実行する。

```bash
kubectl --context agent-lab \
  -n research \
  create secret generic openai-api-key \
  --from-literal=OPENAI_API_KEY='sk-xxxxxxxx'
```

確認:

```bash
kubectl --context agent-lab \
  get secret -n research
```

期待結果:

```text
openai-api-key
```

---

## Deployment から利用

Deployment 側では Secret を環境変数として参照する。

例:

```yaml
env:
  - name: OPENAI_API_KEY
    valueFrom:
      secretKeyRef:
        name: openai-api-key
        key: OPENAI_API_KEY
```

---

## 今後の利用計画

Research Portal から以下を実装予定。

```text
Prompt
 ↓
OpenAI API
 ↓
Experiment Spec生成
 ↓
JSON/YAML表示
```

将来的には、

```text
Prompt
 ↓
OpenAI API
 ↓
Experiment CR生成
 ↓
GitHub Pull Request生成
```

まで発展させることを目標とする。

---

## メモ

当初は Research Portal の表示を優先した。

OpenAI API 連携は Stage 3 と位置付ける。

```text
Stage 1
Portal表示

Stage 2
Experiment Draft UI

Stage 3
OpenAI Integration

Stage 4
Experiment Operator
```
