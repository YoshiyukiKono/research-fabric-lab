# OpenAI Integration Guide

## 目的

Research Goal から Experiment Spec を生成する。

```text
Research Goal
↓
OpenAI API
↓
Experiment Spec
```

## Secret作成

```bash
kubectl --context agent-lab   -n research   create secret generic openai-api-key   --from-literal=OPENAI_API_KEY='sk-xxxx'
```

確認:

```bash
kubectl --context agent-lab get secret -n research
```

## Deployment設定

```yaml
env:
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: openai-api-key
      key: OPENAI_API_KEY
```

## 動作確認

Portal画面:

```text
OpenAI API key: configured
```

## よくあるエラー

### 401 Unauthorized

API Key誤り

### 429 insufficient_quota

Billing未設定または利用上限

## 実際の事例

Billing設定前:

```text
429 insufficient_quota
```

Billing有効化後:

```text
Experiment Spec生成成功
```
