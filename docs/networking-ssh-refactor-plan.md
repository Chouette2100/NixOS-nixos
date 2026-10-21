# Networking / SSH リファクタリング計画

## 1. 背景と目的

これまで NixOS マシンでは LAN 内の dnsmasq サーバー（`192.168.0.24`）を名前解決先として固定し、SSH ポートも `9978` に変更して運用していた。
今回 Tailscale を導入したことで、以下の新しい接続経路が生まれた。

- **Tailscale MagicDNS**: `.ts.net` などの名前解決
- **Tailscale SSH**: Tailscale ネットワーク越しの SSH（ポート 22）

しかし、既存の dnsmasq 固定設定と SSH ポートのデフォルト化が Tailscale と競合し、次の問題が発生している。

```text
$ tailscale ssh kagoya10.tail2b675a.ts.net
No ED25519 host key is known for [kagoya10.tail2b675a.ts.net.]:9978 and you have requested strict checking.
Host key verification failed.

$ ssh kagoya10.tail2b675a.ts.net
ssh: Could not resolve hostname kagoya10.tail2b675a.ts.net: Name or service not known
```

本計画では、これらの問題を解決するために

1. DNS 設定を「DHCP 配布 DNS（または上位 DNS）を基本とし、Tailscale MagicDNS を重ね、dnsmasq をフォールバックとする」というオーソドックスな形に戻す
2. SSH 設定を「Tailscale SSH 用」と「通常 SSH（ポート 9978）用」に明確に分離する

ことを目的とする。

## 2. 現状の問題点

### 2.1 DNS: Tailscale MagicDNS が機能しない

`modules/networking.nix` で DNS を dnsmasq (`192.168.0.24`) に強制固定している。

```nix
networking.nameservers = [ "192.168.0.24" ];
networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
```

さらに NetworkManager の `wired-eno1` プロファイルでも `ignore-auto-dns = true` と `dns = "192.168.0.24;"` を設定しており、DHCP 配布 DNS を無視している。

この状態では、Tailscale が提供する `100.100.100.100`（MagicDNS リゾルバー）が `/etc/resolv.conf` に反映されないため、`.ts.net` の名前解決ができない。

### 2.2 SSH: `tailscale ssh` がホスト鍵検証で失敗する

`home.nix` の `~/.ssh/config` で `Host *` のデフォルトポートを `9978` に設定している。

```text
Host *
  Port 9978
  ...
```

`tailscale ssh` は内部的に OpenSSH を呼び出す際、汎用の `Host *` ブロックを読み込む可能性がある。これにより Tailscale SSH 本来の接続先に `9978` ポートが適用され、ホスト鍵の不一致や到達不能が発生していると考えられる。

エラーメッセージ中の `[kagoya10.tail2b675a.ts.net.]:9978` がこの仮説を裏付けている。

### 2.3 SSH: 通常 SSH と Tailscale SSH の境界が曖昧

- SSH サーバーは `9978` 番で待ち受け
- `~/.ssh/config` は `Host *` で `9978` をデフォルトにしつつ、`*.ts.net` だけ `22` を上書き
- `modules/service.nix` の SSH トンネルはグローバル IP / LAN IP 向けなので `9978` が必要

「Tailscale SSH はポート 22」「通常 SSH はポート 9978」という2つの接続経路が混在しており、設定が分かりにくく、誤ったポートが使われるリスクがある。

## 3. 目標と設計方針

### 3.1 DNS 設計

```text
┌─────────────────────────────────────────────────────────────┐
│  クライアント（NixOS）                                       │
│                                                             │
│  1. 通常の名前解決 → DHCP 配布 DNS / パブリック DNS         │
│  2. .ts.net など Tailscale ドメイン → MagicDNS (100.100.100.100) │
│  3. LAN 内ホスト名 → `networking.hosts` で静的に補完        │
└─────────────────────────────────────────────────────────────┘
```

- **基本**: NetworkManager + DHCP 配布 DNS を尊重する（オーソドックスな状態）
- **Tailscale 重ねがけ**: `tailscale up --accept-dns=true` で MagicDNS を有効化
- **LAN 内ホスト名**: `networking.hosts` で補完。dnsmasq サーバー (192.168.0.24) は今回の構成では使用しない

### 3.2 SSH 設計

```text
┌──────────────────────────────┬──────────────────────────────┐
│ 接続先                        │ ポート / 備考                 │
├──────────────────────────────┼──────────────────────────────┤
│ *.ts.net                     │ 22 (Tailscale SSH)           │
│ グローバル IP / LAN IP       │ 9978 (通常 SSH)              │
│ その他一般ホスト             │ 22 (OpenSSH デフォルト)      │
└──────────────────────────────┴──────────────────────────────┘
```

- `Host *` には `Port 9978` を設定しない
- Tailscale SSH 用に `Host *.ts.net` を明示的に定義
- 通常 SSH 接続先（既存のグローバル IP / LAN IP ホスト）は個別に `Port 9978` を指定
- SSH サーバーは引き続き `9978` で待ち受け、非常時アクセスを担保

## 4. 作業スコープ

今回の作業では、以下に絞って実施する。

- **DNS 設定の見直し**: dhcpmasq 強制固定を解除し、DHCP DNS を基本としつつ Tailscale MagicDNS を有効化する。LAN 内ホスト名は `networking.hosts` で補完する。
- **Tailscale SSH 用の SSH クライアント設定**: `tailscale ssh` および `ssh *.ts.net` が正しく動作するよう `~/.ssh/config` を整理する。

以下は今回のスコープ外とする。

- **通常 SSH（ポート 9978）接続先の定義**: `home.nix` における `nix01` などの通常 SSH ホスト設定は、今回はコメントアウトまたは削除する。Tailscale 運用が安定した後、必要に応じて再定義する。
- **SSH トンネル（`modules/service.nix`）**: 現状のまま維持する。Tailscale 経由で代替できるようになった時点で廃止を検討する。

### 4.1 `modules/networking.nix`

#### 変更前

```nix
networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
networking.nameservers = [ "192.168.0.24" ];

networking.networkmanager.ensureProfiles.profiles."wired-eno1" = {
  connection = {
    id = "有線接続 1";
    type = "802-3-ethernet";
    interface-name = "eno1";
    uuid = "99e03e99-129f-39c9-a1df-6656eade4e6d";
    autoconnect = true;
  };
  ipv4 = {
    method = "auto";
    ignore-auto-dns = true;
    dns = "192.168.0.24;";
  };
  ipv6 = {
    method = "auto";
    ignore-auto-dns = false;
  };
};
```

#### 変更後（案）

```nix
# DHCP 配布 DNS を基本とする。
# Tailscale MagicDNS は tailscaled が resolv.conf を管理することで有効になる。
# LAN 内ホスト名は `networking.hosts` で補完する。

networking.networkmanager.ensureProfiles.profiles."wired-eno1" = {
  connection = {
    id = "有線接続 1";
    type = "802-3-ethernet";
    interface-name = "eno1";
    uuid = "99e03e99-129f-39c9-a1df-6656eade4e6d";
    autoconnect = true;
  };
  ipv4 = {
    method = "auto";
    # DHCP 配布 DNS をそのまま使う
    ignore-auto-dns = false;
  };
  ipv6 = {
    method = "auto";
    ignore-auto-dns = false;
  };
};
```

#### 検討事項

- `networking.nameservers` は指定しない。DHCP 配布 DNS を尊重する。
- NetworkManager が `resolv.conf` を管理する場合、`ignore-auto-dns = false` で DHCP DNS をそのまま使う。
- 最終的な DNS サーバー順序は `cat /etc/resolv.conf` または `nmcli device show eno1 | grep DNS` で確認する。
- LAN 内ホスト名は `networking.hosts` で静的に補完する。dnsmasq サーバー (192.168.0.24) は今回の構成では使用しない。

### 4.2 `configuration.nix`

Tailscale サービスはすでに有効化されている。

```nix
services.tailscale.enable = true;
```

追加で以下を検討する。

```nix
# Tailscale からの通信を許可
networking.firewall.trustedInterfaces = [ "tailscale0" ];
networking.firewall.checkReversePath = false;
```

上記は既存で有効になっているため、そのまま維持する。

MagicDNS の有効化は手動で実行する。

```bash
sudo tailscale up --accept-dns=true
```

`--accept-dns=true` を有効にすると、Tailscale は `/etc/resolv.conf` に MagicDNS を含む設定を反映させる。NetworkManager と `resolv.conf` の管理権限が競合する場合は、別途検討が必要。

### 4.3 `home.nix`（SSH クライアント設定）

#### 変更前

```text
Host *.ts.net
  HostName %h
  User chouette
  Port 22
  ...

Host *
  Port 9978
  IdentityFile ~/.ssh/id_ed25519
  ...
```

#### 変更後（案）

今回は Tailscale SSH 用のみに絞り、`Host *` から `Port 9978` を除去する。通常 SSH（ポート 9978）接続先は、Tailscale 運用安定後に再定義するため、今回は削除またはコメントアウトする。

```text
# Tailscale SSH 用: ポート 22
Host *.ts.net
  HostName %h
  User chouette
  Port 22
  StrictHostKeyChecking accept-new
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 60
  ServerAliveCountMax 3

Host github.com
  HostName github.com
  Port 22
  User git

# 通常 SSH（ポート 9978）接続先は、今回の作業スコープ外。
# Tailscale 運用が安定した後、必要に応じて以下のように個別に追加する。
# Host nix01
#   HostName 133.18.43.195
#   User chouette
#   Port 9978

# デフォルト: Tailscale や上記ホストに該当しない場合は OpenSSH デフォルト（ポート 22）
Host *
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
  ServerAliveInterval 60
  ServerAliveCountMax 3
  ForwardAgent yes
```

#### ポイント

- `Host *` から `Port 9978` を除去
- Tailscale SSH 用に `Host *.ts.net` を明示的に定義
- 通常 SSH（ポート 9978）接続先の再定義は今回のスコープ外。Tailscale 運用が安定した後に別途対応する
- `tailscale ssh` コマンドを使う場合も、`~/.ssh/config` の `Host *.ts.net` 設定が読み込まれないよう `tailscale ssh` 自身が分離しているが、万が一 OpenSSH が呼ばれる場合も安全な構成にする

### 4.4 `modules/service.nix`

今回の作業スコープ外とする。現状の `-p 9978` を維持する。

将来的に Tailscale 経由で代替できるようになった時点で、SSH トンネルを廃止するか、接続先を Tailscale IP / `.ts.net` ドメインに移行してポートを `22` に変更することを検討する。

```bash
${pkgs.openssh}/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
  -L 9910:127.0.0.1:3306 \
  chouette@133.18.160.207
```

## 5. リスクと注意点

| リスク | 内容 | 対応 |
|--------|------|------|
| リモート接続不能 | 設定変更後、外部 SSH（ポート 9978）や Tailscale SSH に接続できなくなる可能性がある | ローカルコンソールで検証し、問題があればロールバック |
| DNS 競合 | NetworkManager と Tailscale が `resolv.conf` の管理権限を巡って競合する可能性がある | `resolvectl status` や `nmcli device show eno1` で DNS サーバー順序を確認 |
| LAN 内ホスト名解決の変化 | dnsmasq を使用しなくなったため、`LMTabKS` などの LAN ホスト名が解決できなくなる可能性がある | `networking.hosts` で静的に補完する。必要なホストがあれば追加する |
| SSH ポートの混乱 | 従来 `Host *` で 9978 がデフォルトだったため、普段使いの SSH コマンドでポート指定を忘れて接続失敗する可能性がある | 接続先ごとに `~/.ssh/config` を整備し、慣れるまで注意 |


## 6. 検証手順

### 6.1 設定反映後の確認

```bash
# NixOS 設定の反映
sudo nixos-rebuild switch --flake '.#baremetal'

# Home Manager 設定の反映（必要に応じて）
home-manager switch
```

### 6.2 DNS 確認

```bash
# resolv.conf の内容確認
cat /etc/resolv.conf

# DNS サーバー一覧確認
resolvectl status
nmcli device show eno1 | grep -E 'IP4.DNS|IP6.DNS'

# Tailscale MagicDNS 確認
resolvectl query kagoya10.tail2b675a.ts.net
nslookup kagoya10.tail2b675a.ts.net

# LAN 内ホスト名確認
nslookup LMTabKS
```

### 6.3 SSH 確認

```bash
# Tailscale SSH（tailscale コマンド経由）
tailscale ssh kagoya10.tail2b675a.ts.net

# 通常の OpenSSH 経由（MagicDNS + Tailscale 経由）
ssh kagoya10.tail2b675a.ts.net
```

通常 SSH（ポート 9978）接続先の確認は、今回の作業スコープ外とする。Tailscale 運用が安定した後、別途 `~/.ssh/config` に接続先を追加して検証する。

### 6.4 フォールバック確認

```bash
# Tailscale 停止時の挙動確認（LAN 内ホスト名が networking.hosts で解決できるか）
sudo systemctl stop tailscaled
getent hosts nixos
getent hosts LMTabKS
sudo systemctl start tailscaled
```

なお、dnsmasq サーバー (192.168.0.24) は今回の構成では使用しない。

## 7. 運用フロー

### 7.1 通常時

1. Tailscale が起動し、MagicDNS が有効
2. `.ts.net` ドメインは Tailscale MagicDNS で解決
3. 一般インターネットドメインは DHCP 配布 DNS で解決
4. LAN 内ホスト名は `networking.hosts` で解決

### 7.2 Tailscale 停止時や MagicDNS 無効時

1. DHCP 配布 DNS で名前解決を継続
2. Tailscale SSH は使用不可となるため、通常 SSH（ポート 9978）で接続する必要がある。今回の作業では通常 SSH 接続先は定義しないため、必要に応じて `~/.ssh/config` に手動で追加するか、当面は `ssh -p 9978 user@host` で接続する
3. LAN 内ホスト名は `networking.hosts` で解決

## 8. 関連ファイル

- `modules/networking.nix`
- `configuration.nix`
- `home.nix`
- `modules/service.nix`
- `docs/dnsmasq-networkmanager-memo.md`
- `docs/networking-ssh-refactor-plan.md`（本ファイル）

## 9. 今後の検討事項

- Tailscale 運用が安定した後、必要なホストについて通常 SSH（ポート 9978）接続先を `~/.ssh/config` に再定義する
- Tailscale 経由で `modules/service.nix` の SSH トンネルを代替できるか検討し、可能であれば廃止する
- Tailscale の `--accept-routes=true` など、ルーティング周りの追加設定が必要にならないか
- SSH サーバーのポート 9978 を Tailscale 経由だけに限定すべきか（ファイアウォールで絞り込む検討）
- `systemd-resolved` を明示的に有効化し、DNS 解決をより制御しやすくする検討

