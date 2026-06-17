# Harvester Event IP Change Runbook

## 目的

イベント会場へ Harvester PoC 環境を持ち込む際に、会場ネットワークに合わせて IP アドレスを変更し、Windows クライアントから Harvester / Rancher / RKE2 アプリへアクセスできる状態にする。

本手順は、最小構成として以下を前提とする。

* Harvester 単一ノード
* 追加NICなし
* 小型ルータまたは隔離LANを利用
* 固定IP構成
* Windowsクライアントの `hosts` ファイルで名前解決
* DNSサーバは用意しない

---

## 想定構成

### IP設計例

| 用途                 | ホスト名                | IP             |
| ------------------ | ------------------- | -------------- |
| ルータ / Gateway      | router              | 192.168.100.1  |
| Harvester Host     | harvester.lab.local | 192.168.100.10 |
| Rancher管理VM        | rancher.lab.local   | 192.168.100.11 |
| RKE2 / Workload VM | app.lab.local       | 192.168.100.12 |

Pod IP や Service Cluster IP は Kubernetes 内部アドレスのため、固定化しない。

---

## 事前準備

会場入り前に以下を確認しておく。

* Harvester UI にログインできる
* StorageClass `replica-one` が default になっている
* VM Network として `custom` / `UntaggedNetwork` が作成済み
* SLES VM が起動できる
* VM にログインできる
* Windowsクライアントから Harvester UI にアクセスできる

---

# 1. 会場ネットワーク確認

会場または持ち込みルータで、以下を確認する。

```text
Network: 192.168.100.0/24
Gateway: 192.168.100.1
DNS: 192.168.100.1 or 8.8.8.8
```

インターネット接続がない場合、DNSは必須ではない。

---

# 2. Harvester Host のIP変更

Harvesterノードに SSH でログインする。

```bash
ssh rancher@<current-harvester-ip>
```

例：

```bash
ssh rancher@10.110.0.22
```

root に昇格する。

```bash
sudo -i
```

NetworkManager の connection を確認する。

```bash
nmcli connection show
```

対象 connection 名を確認する。

例：

```text
Wired connection 1
```

固定IPへ変更する。

```bash
nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.168.100.10/24 \
  ipv4.gateway 192.168.100.1 \
  ipv4.dns 192.168.100.1
```

connection を再起動する。

```bash
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

IP確認。

```bash
ip a
ip route
```

Windowsクライアントから以下へアクセスする。

```text
https://192.168.100.10
```

---

# 3. VM のIP変更

Harvester UI から対象VMの Console を開く。

対象VMにログインする。

```text
user: sles
password: password
```

root に昇格する。

```bash
sudo -i
```

NetworkManager の connection を確認する。

```bash
nmcli connection show
```

固定IPへ変更する。

例：Rancher管理VM

```bash
nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.168.100.11/24 \
  ipv4.gateway 192.168.100.1 \
  ipv4.dns 192.168.100.1
```

例：RKE2 / Workload VM

```bash
nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.168.100.12/24 \
  ipv4.gateway 192.168.100.1 \
  ipv4.dns 192.168.100.1
```

connection を再起動する。

```bash
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

確認。

```bash
ip a
ip route
ping -c 4 192.168.100.1
ping -c 4 192.168.100.10
```

---

# 4. Windows クライアントの hosts 設定

Windowsでメモ帳を管理者として起動する。

以下のファイルを開く。

```text
C:\Windows\System32\drivers\etc\hosts
```

以下を追加する。

```text
192.168.100.10 harvester.lab.local
192.168.100.11 rancher.lab.local
192.168.100.12 app.lab.local
```

保存後、PowerShellで確認する。

```powershell
ping harvester.lab.local
ping rancher.lab.local
ping app.lab.local
```

ブラウザで確認する。

```text
https://harvester.lab.local
https://rancher.lab.local
http://app.lab.local
```

---

# 5. RKE2構成時の注意

RKE2ノードのIPを変更した場合、RKE2が参照するノードIPも確認する。

```bash
ip a
kubectl get nodes -o wide
```

`INTERNAL-IP` が期待したIPになっていることを確認する。

必要に応じて `/etc/rancher/rke2/config.yaml` に以下を設定する。

```yaml
node-ip: 192.168.100.12
```

変更後、RKE2を再起動する。

```bash
systemctl restart rke2-server
```

確認。

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

---

# 6. アプリ公開方法

最小構成では NodePort を利用する。

例：

```text
http://192.168.100.12:30080
```

Ingressを利用する場合は、`app.lab.local` を Ingress の host に指定し、Windows hosts で名前解決する。

---

# 7. 動作確認チェックリスト

## Harvester

```text
https://harvester.lab.local
```

* ログインできる
* Host が Ready
* VM が Running

## VM

```bash
ip a
ip route
ping -c 4 192.168.100.1
ping -c 4 192.168.100.10
```

## RKE2

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

## Windows Client

```powershell
ping harvester.lab.local
ping rancher.lab.local
ping app.lab.local
```

---

# 8. ロールバック

現在の検証環境へ戻す場合は、DHCPへ戻す。

HarvesterまたはVM上で実行する。

```bash
nmcli connection modify "Wired connection 1" \
  ipv4.method auto \
  ipv4.addresses "" \
  ipv4.gateway "" \
  ipv4.dns ""
```

connection を再起動する。

```bash
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

確認。

```bash
ip a
ip route
```

---

# 補足

Harvester Host のIPを変更すると、ブラウザでアクセスするURLも変わる。

また、Rancher や RKE2 の証明書、登録URL、Ingress Host を固定IPやホスト名に依存させている場合、IP変更後に追加対応が必要になる可能性がある。

イベント用PoCでは、なるべく以下の方針が望ましい。

* IPは固定化する
* 名前解決はWindows hostsで行う
* アプリ公開はNodePortまたは単純なIngressにする
* 当日変更する箇所を最小化する
