# Workload Cluster Bootstrap

## Cluster

agent-lab-02

```bash
kubectl --context agent-lab get nodes -o wide
```

## Rancher経由Kubeconfig

取得した kubeconfig は

```text
https://rancher.lab.local/k8s/clusters/<cluster-id>
```

を参照する。

## hosts設定

名前解決できない場合:

```bash
sudo vi /etc/hosts
```

```text
192.168.11.18 rancher.lab.local
```

## 確認

```bash
kubectl --context agent-lab get nodes
```

期待:

```text
agent-lab-02 Ready
```
