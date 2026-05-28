# nixos configuration of host

## DNS / NetworkManager メモ

この構成では、LAN 内の `dnsmasq` サーバー `192.168.0.24` を名前解決の参照先として使います。

詳細な作業経緯は `docs/dnsmasq-networkmanager-memo.md` にまとめています。

### 目的

- LAN 内ホスト名を `dnsmasq` でまとめて引けるようにする
- DHCP で配布される上位 DNS よりも、ローカル DNS を優先する

### 実装方針

- `modules/networking.nix` の `networking.hosts` で `/etc/hosts` 相当の静的対応を宣言する
- `networking.nameservers = [ "192.168.0.24" ];` でシステム側にも DNS を入れる
- `networking.networkmanager.ensureProfiles.profiles."wired-eno1"` で `eno1` のプロファイルを宣言し、`ipv4.ignore-auto-dns = true` にして DHCP 配布 DNS を無視する

### 反映時の注意

- `sudo nixos-rebuild switch --flake /home/chouette/NixOS-nixos#baremetal` 実行後、既存接続に設定がすぐ反映されない場合がある
- その場合は `nmcli connection down '有線接続 1'` → `nmcli connection up '有線接続 1'` で接続を張り直す
- NIC 名や NetworkManager 接続 UUID が変わった場合は、`modules/networking.nix` 内の `wired-eno1` 定義も更新する

### 確認コマンド

```bash
nmcli device show eno1 | grep -E 'IP4.DNS|IP6.DNS'
cat /etc/resolv.conf
resolvconf -l | sed -n '1,120p'
```
