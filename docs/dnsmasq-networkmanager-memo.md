# dnsmasq / NetworkManager 作業メモ

## 概要

このメモは、NixOS マシンで LAN 内の `dnsmasq` サーバー `192.168.0.24` を名前解決先として使うために行った設定と、その確認結果をまとめたものです。

## 目的

- LAN 内ホスト名を `dnsmasq` で引けるようにする
- DHCP で配布される上位 DNS ではなく、ローカル DNS を優先する
- 設定を Nix で宣言的に管理する

## 実施した変更

### 1. `/etc/hosts` 相当の静的ホスト定義

`modules/networking.nix` の `networking.hosts` に、既存の `dnsmasq` ルールを Nix 形式で移植した。

### 2. システム側の DNS 参照先追加

`modules/networking.nix` に以下を追加した。

```nix
networking.nameservers = [ "192.168.0.24" ];
networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
```

ただし、これだけでは実効 DNS の先頭が DHCP 配布 DNS のまま残るケースがあった。

### 3. NetworkManager 接続プロファイルの宣言化

最終的には `networking.networkmanager.ensureProfiles.profiles."wired-eno1"` を追加し、`eno1` の接続プロファイルに対して以下を設定した。

- `ipv4.method = "auto"`
- `ipv4.ignore-auto-dns = true`
- `ipv4.dns = "192.168.0.24;"`
- `ipv6.ignore-auto-dns = true`

これにより、DHCP で IP アドレスは受け取りつつ、DNS だけを `192.168.0.24` に固定する。

## 確認の過程

### 初回の状態

`nixos-rebuild switch` 後も、以下のように DHCP 配布 DNS が優先されていた。

- `nmcli device show eno1` で `IP4.DNS[1] = 218.219.82.240`
- `/etc/resolv.conf` の先頭が上位 DNS
- `resolvconf -l` でも `NetworkManager` 由来の DNS が先頭

### 決定打になった対応

以下で接続を張り直したところ、`NetworkManager` 側の新しい DNS 設定が有効になった。

```bash
sudo nmcli connection down '有線接続 1'
sudo nmcli connection up '有線接続 1'
```

### 最終確認結果

最終的に以下になった。

```bash
$ nmcli device show eno1 | grep -E 'IP4.DNS|IP6.DNS'
IP4.DNS[1]: 192.168.0.24

$ cat /etc/resolv.conf
options edns0
nameserver 192.168.0.24
```

`resolvconf -l` でも、`NetworkManager` / `static` の両方が `192.168.0.24` を出力する状態になった。

## 運用上の注意

- `eno1` の NIC 名が変わると `wired-eno1` の `interface-name` を更新する必要がある
- NetworkManager 接続 UUID が変わると `uuid` も更新する必要がある
- `nixos-rebuild switch` 後に設定が即時反映されない場合は、接続の再アクティベートを行う
- `networking.nameservers` と `NetworkManager` 側の DNS 固定を両方入れているため、少し冗長だが安定性は高い

## 関連ファイル

- `modules/networking.nix`
- `README.md`

## 関連コミット

- `4045c30` `feat(networking): add static host mappings via networking.hosts`
- `a3de0a6` `fix(networking): prefer dnsmasq host for DNS resolution`
- `6209452` `fix(networking): enforce dnsmasq resolver address`
- `a58ab41` `fix(networking): override DHCP DNS in NetworkManager profile`
- `7d2ba3b` `docs(networking): explain local dnsmasq resolver setup`
- `b488feb` `docs(readme): add dns and NetworkManager notes`
