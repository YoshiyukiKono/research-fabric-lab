# Harvester Initial Access Troubleshooting

## 概要

Harvester 初回セットアップ時に、Web UI が正常に表示されず、初期パスワード設定画面へ到達するまでに複数の切り分けを実施した。

結果として問題は Harvester 本体ではなく、ブラウザキャッシュおよびセッション情報に起因していた。

本ドキュメントでは、その過程を記録する。

---

# 事象

Harvester インストール後、

```text
https://10.110.0.22
```

へアクセスした。

しかし、

```text
保護されていない通信
```

の警告表示後、

```text
真っ白な画面
```

となり、Harvester のセットアップ画面が表示されなかった。

---

# 初期切り分け

まず HTTP 応答を確認した。

```powershell
curl -v http://10.110.0.22/
```

結果

```text
HTTP/1.1 200 OK
Content-Length: 0
```

Harvester そのものは応答していることが確認できた。

---

# SSH 接続確認

次に SSH 接続を試行した。

```powershell
ssh rancher@10.110.0.22
```

ログインプロンプトが表示された。

```text
(rancher@10.110.0.22) Password:
```

この時点で、

* ネットワーク到達性
* SSH サービス

は正常と判断した。

---

# Harvester 状態の推測

当初は、

```text
Harvester インストール未完了
```

または

```text
管理サービス異常
```

を疑った。

しかし利用者から

> Harvester をインストールし、初期パスワード設定前の状態で停止している

との情報を得た。

そのため、

```text
初回セットアップ画面が表示されるはず
```

という仮説を立てた。

---

# URL 直接指定

以下へ直接アクセスした。

```text
https://10.110.0.22/dashboard/auth/setup
```

すると、

```text
Welcome to Harvester!
```

画面が表示された。

しかし、

```text
Continue
```

ボタンが押下できなかった。

---

# ブラウザ開発者ツール確認

Chrome Developer Tools を確認。

以下のエラーが表示されていた。

```text
Failed to fetch Rancher version metadata
404
```

および

```text
/v3/users
401
```

```text
/v3/principals
401
```

など。

当初は Rancher API 異常を疑った。

---

# 原因

Chrome の通常ブラウザでアクセスしていたため、

以前の Rancher / Harvester セッション情報やキャッシュが影響していた可能性が高かった。

---

# 解決

Chrome シークレットモードでアクセス。

すると、

```text
Welcome to Harvester!
```

画面が正常表示され、

パスワード設定が可能となった。

設定完了後、

```text
admin
```

アカウントでログインできることを確認した。

---

# SLES Cloud Image のログイン問題

Harvester 動作確認のため、

```text
SLES15-SP7-Minimal-VM.x86_64-Cloud-QU4.qcow2
```

を利用して VM を作成した。

Cloud-Init に以下を設定した。

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

---

# 誤った仮説

当初、

```text
root
password
```

でログインできると考えた。

しかしログインできなかった。

---

# 原因

SLES Cloud Image は Ubuntu Cloud Image と挙動が異なる。

今回のイメージでは、

```text
sles
```

ユーザーが既定ユーザーとして利用されていた。

---

# 解決

以下でログイン成功。

```text
user: sles
password: password
```

---

# 学び

## 1. Harvester UI が表示されない場合

まず以下を疑う。

```text
ブラウザキャッシュ
Cookie
既存セッション
```

シークレットモードでの再確認が有効。

---

## 2. curl が 200 を返すなら

Harvester 本体は動作している可能性が高い。

```text
curl
SSH
```

による切り分けが有効。

---

## 3. Cloud Image は Installer ISO ではない

Cloud Image は

```text
Cloud-Init 前提
```

である。

```text
Language
Keyboard
User Creation
```

などのセットアップ画面は表示されない場合がある。

---

## 4. Proxmox と Harvester の挙動は異なる

同じ Cloud Image でも、

```text
Proxmox
```

では Firstboot が表示される場合がある。

一方、

```text
Harvester (KubeVirt)
```

では Cloud Image をより素直に扱うため、

直接ログインプロンプトが表示されることがある。

---

# 結論

今回遭遇した問題は、

* Harvester の障害
* ネットワーク障害
* Cloud Image の破損

ではなかった。

実際には、

* ブラウザキャッシュ
* Cloud Image のユーザー仕様

に起因するものであった。

問題切り分けにおいて、

```text
curl
SSH
シークレットモード
```

が非常に有効であることを確認した。
