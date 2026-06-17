# Harvester Single Node PoC Notes

## 概要

イベント向け PoC 環境の事前検証として、Harvester 単一ノード構成の初期設定および SLES Cloud Image の動作確認を実施した。

本作業では以下を確認した。

* Harvester 初期セットアップ
* Longhorn Replica 設定の変更
* Virtual Machine Network 構成
* SLES Cloud Image の起動
* Cloud-Init の適用
* DHCP による IP 取得
* Proxmox と Harvester における Cloud Image の挙動の違い

---

# Storage 設定

## 初期状態

Harvester インストール直後の StorageClass は以下の状態であった。

| Name                | Replicas | Default |
| ------------------- | -------- | ------- |
| harvester-longhorn  | 3        | Yes     |
| longhorn            | 3        | No      |
| vmstate-persistence | 3        | No      |

単一ノード環境では Replica 3 を維持できないため、そのままでは VM ディスク作成時に問題となる。

## 対応

Replica 数を 1 とした StorageClass を新規作成した。

| Name        | Replicas | Default |
| ----------- | -------- | ------- |
| replica-one | 1        | Yes     |

PoC やラボ用途ではこちらをデフォルトとして利用する。

---

# Network 設定

## 初期状態

Cluster Network としては組み込みの `mgmt` のみが存在した。

```text
Cluster Network
└── mgmt
```

この状態では VM 用ネットワークが存在しない。

## 過去構成

以前の自宅環境では以下の設定を利用していた。

```text
Type: L2VlanNetwork
Mode: Access
VLAN ID: 1
Cluster Network: mgmt
```

しかし VLAN を利用しない環境では VLAN ID の扱いが環境依存となる。

## 今回採用した構成

PoC の可搬性を優先し、以下を採用した。

```text
Type: UntaggedNetwork
Cluster Network: mgmt
```

この構成では VM が管理ネットワークと同一セグメントに参加する。

メリット

* VLAN 設定不要
* DHCP 利用可能
* イベント会場などの簡易ネットワークで利用しやすい

デメリット

* 管理ネットワークと VM ネットワークが分離されない
* 本番用途には不向き

PoC 用途としては十分実用的である。

---

# SLES Cloud Image

利用イメージ

```text
SLES15-SP7-Minimal-VM.x86_64-Cloud-QU4.qcow2
```

---

# Proxmox と Harvester の違い

同一イメージを利用したにも関わらず挙動が異なった。

## Proxmox

起動後に Firstboot が起動した。

```text
Language
↓
Keyboard
↓
User Creation
↓
First Login
```

そのため通常のインストーラのように利用できた。

## Harvester

起動直後にログインプロンプトが表示された。

```text
localhost login:
```

これは異常ではない。

Cloud Image は本来、

```text
Cloud Image
↓
Cloud-Init
↓
初期ユーザー作成
↓
起動
```

を前提としているためである。

Harvester（KubeVirt）は Cloud Image をより素直に扱うため、この挙動となる。

---

# Cloud-Init

以下を設定した。

```yaml
package_update: true
packages:
  - qemu-guest-agent

runcmd:
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service

password: password
chpasswd:
  expire: false
ssh_pwauth: true
```

当初は root/password でログインできると考えていたが、実際には以下でログインできた。

```text
user: sles
password: password
```

SLES Cloud Image では既定ユーザーとして `sles` が利用される。

---

# DHCP 動作確認

ログイン後に以下を確認した。

```bash
ip a
ip route
```

結果

```text
eth0: 10.110.0.226/24
default via 10.110.0.1
```

DHCP によるアドレス取得およびデフォルトゲートウェイ取得を確認できた。

---

# 今後の検討事項

イベント会場では隔離ネットワークおよび固定 IP 構成となる可能性が高い。

その場合は以下を事前に整理する必要がある。

* Harvester ホスト IP
* 管理 VM IP
* RKE2 ノード IP
* DNS 設定
* 外部公開方法（NodePort / Ingress）

一方で Kubernetes Pod や Service の内部アドレスは固定化不要である。

PoC 環境としては、

```text
Harvester
↓
SLES VM
↓
RKE2
↓
Sample Application
```

まで事前構築し、会場では IP のみ調整する構成が望ましい。

---

# 結論

単一ノード Harvester 環境では、

* StorageClass を Replica 1 に変更
* Untagged Network を利用
* SLES Cloud Image + Cloud-Init を利用

することで、短時間で安定した PoC 環境を構築できることを確認した。

また、Proxmox と Harvester では Cloud Image の扱いが異なるため、Cloud-Init の理解が重要であることを再認識した。
