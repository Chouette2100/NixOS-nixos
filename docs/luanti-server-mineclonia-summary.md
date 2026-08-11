# Luanti + Mineclonia 対応サマリー

## 結論

今回の問題は、Luanti 本体の起動可否ではなく、Mineclonia の配置場所と配置階層、そして world の運用パスにありました。

最終的には次の構成で安定しました。

1. NixOS サービスは services.minetest-server を使用
2. Mineclonia は固定バージョンと固定 hash で宣言的に取得
3. ゲーム配置先は /var/lib/minetest/.minetest/games/mineclonia
4. world は /var/lib/minetest/worlds/world4
5. 旧 world は初回のみ自動移行

## 方針

1. 再現性: 手動配置をやめて Nix 宣言に統一
2. 権限整合: サービスユーザー minetest が確実に読めるパスを使う
3. 保守性: 既存データを壊さず段階的に移行する

## 主な原因と対処

1. services.luanti-server が存在しない
- 原因: モジュール名は services.minetest-server のまま
- 対処: サービス定義を services.minetest-server に変更

2. Game "mineclonia" not found
- 原因: Luanti 本体のみでゲーム本体が未配置
- 対処: Mineclonia を fetchzip で取得し、探索パスに配置

3. 配置後も見つからない
- 原因: 配置先が Luanti の実探索先と不一致
- 対処: /var/lib/minetest/.minetest/games へ配置

4. さらに見つからない
- 原因: パッケージ化時に mineclonia/mineclonia の 1 段ネストが発生
- 対処: installPhase を修正し、game.conf をゲーム直下に配置

5. world アクセス問題の潜在リスク
- 原因: /home/chouette は 0700 で minetest が辿れない
- 対処: world を /var/lib/minetest/worlds 配下で運用

6. スマホ接続不可
- 原因: 最終的には Android 側 Private DNS 設定の影響
- 補足: NixOS 側は UDP 30000 待受と ICMP 許可を確認済み

## 現在の到達点

1. サービスは active running
2. ログに gameid=mineclonia で listen している記録あり
3. UDP 30000 待受あり
4. スマホクライアントで接続とゲーム画面表示を確認

## 今後の運用チェック

問題が出たら次の順で確認します。

1. systemctl status minetest-server
2. journalctl -u minetest-server -n 100 --no-pager
3. /var/lib/minetest/.minetest/games/mineclonia/game.conf の有無
4. world のパスと所有者
5. ss -lunp | grep 30000
6. クライアント側の VPN と Private DNS と接続ネットワーク

## 更新時の最小手順

1. Mineclonia の version を更新
2. hash を更新
3. nixos-rebuild build で評価
4. nixos-rebuild switch で反映
5. status と journal で起動確認

## 変更箇所リンク

今回の対応で主に変更した箇所:

1. Mineclonia の固定取得とパッケージ化: [configuration.nix](../configuration.nix#L19)
2. minetest-server サービス定義: [configuration.nix](../configuration.nix#L201)
3. ゲーム配置先の tmpfiles ルール: [configuration.nix](../configuration.nix#L217)
4. world 初回移行の activation script: [configuration.nix](../configuration.nix#L225)
5. UDP 30000 の開放: [configuration.nix](../configuration.nix#L234)
6. xhost 廃止警告対応: [home.nix](../home.nix#L53)

参照用ドキュメント:

1. 詳細版: [docs/luanti-server-mineclonia-troubleshooting.md](luanti-server-mineclonia-troubleshooting.md)
2. 要約版: [docs/luanti-server-mineclonia-summary.md](luanti-server-mineclonia-summary.md)
