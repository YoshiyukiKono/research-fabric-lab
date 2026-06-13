## Job Evolution

### job-bootstrap-placeholder.yaml

Research Fabric Lab の最初の GitOps 疎通確認用 Job。

目的:

- Argo CD 同期確認
- Namespace 作成確認
- CRD 作成確認
- Job 実行確認

出力:

{"status":"placeholder","engine":"netket"}

---

### job-python-result.yaml

最初の実験結果生成 Job。

目的:

- 実験パラメータ入力
- Python による計算実行
- JSON 結果生成

次段階:

job-netket-simulation.yaml
