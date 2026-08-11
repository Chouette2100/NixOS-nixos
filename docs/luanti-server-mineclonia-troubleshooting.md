# Luanti + Mineclonia サーバー構築トラブル対応メモ

## 1. 目的

このドキュメントは、NixOS 上で Luanti サーバーを宣言的に構築した際に発生した問題の整理と、最終的に安定稼働した構成をまとめたものです。

対象:

- NixOS + flake 構成
- Luanti サーバーを Mineclonia で動かしたい
- サービス管理は systemd と NixOS 宣言で一元化したい


## 2. 最初に採った方針

方針は最初から一貫して次の 3 点でした。

1. 再現性重視: 手動配置ではなく Nix 宣言でゲーム本体を固定取得する
2. 権限整合性重視: systemd の実行ユーザー minetest が読める場所へ world と game を置く
3. 運用容易性重視: 既存 world は初回だけ自動移行し、以後はサービス用パスで運用する

この方針自体は正しく、途中の失敗は主にパス解釈とパッケージ展開階層のズレによるものでした。


## 3. 発生した問題と原因

### 3.1 services.luanti-server が存在しない

症状:

- The option services.luanti-server does not exist

原因:

- パッケージ名は luanti 系へ移行しているが、NixOS モジュール名は services.minetest-server のまま

対応:

- services.luanti-server ではなく services.minetest-server を使用
- settings ではなく config オプションを使用


### 3.2 xorg.xhost 廃止警告が消えない

症状:

- evaluation warning: xorg package set deprecated, xorg.xhost renamed to xhost

原因:

- Home Manager の複数行文字列内で、コメント行に見える ${pkgs.xorg.xhost} が補間評価されていた

対応:

- コメント行そのものを削除し、${pkgs.xhost} のみを残した


### 3.3 Game mineclonia not found

症状:

- ERROR: Game "mineclonia" not found

原因:

- Luanti 本体はインストール済みでも Mineclonia ゲーム本体は別配布
- 宣言的にゲームを配置しないと gameId だけでは解決されない

対応:

- Codeberg の Mineclonia リリースを fetchzip で固定取得
- systemd.tmpfiles.rules でゲームディレクトリを配置


### 3.4 world パス権限問題

症状:

- /home/chouette/.minetest/worlds/world4 を指定していた

原因:

- /home/chouette が 0700 のため、minetest サービスユーザーが辿れない

対応:

- world を /var/lib/minetest/worlds/world4 に移行
- 初回のみ旧パスからコピーする activation script を追加


### 3.5 ゲーム探索パスの誤認

症状:

- /var/lib/minetest/games に置いたが見つからない

原因:

- サービス実行時のユーザーパスが /var/lib/minetest/.minetest
- このため探索先は /var/lib/minetest/.minetest/games

対応:

- シンボリックリンク配置先を /var/lib/minetest/.minetest/games/mineclonia に修正


### 3.6 Mineclonia 展開階層の 1 段ズレ

症状:

- game.conf が mineclonia/mineclonia/game.conf に入り、ゲームとして認識されない

原因:

- installPhase の cp でルートを丸ごとコピーし、1 段深くネストした

対応:

- game.conf の有無でコピー元を分岐し、最終的に mineclonia/game.conf が直下に来るよう修正


### 3.7 スマホから到達不可

症状:

- Termux から ping 不通、サーバー接続不可

原因:

- 最終的には Android 側の Private DNS 設定が影響

補足:

- NixOS 側は UDP 30000 待受と ICMP 許可を確認済み


## 4. 最終構成の要点

主な変更ファイル:

- configuration.nix
- home.nix

設計上の要点:

1. services.minetest-server を使用
2. gameId は mineclonia
3. world は /var/lib/minetest/worlds/world4
4. Mineclonia は固定 URL と固定 hash で取得
5. /var/lib/minetest/.minetest/games/mineclonia へ宣言的にリンク
6. 旧 world は初回のみ自動コピー


## 5. 実装内容の概要

### 5.1 Mineclonia の宣言的取得

configuration.nix の let 節で以下を定義:

- minecloniaVersion
- minecloniaGame derivation
- fetchzip の固定 hash

目的:

- リポジトリ更新やミラー差異があっても、同じ入力から同じ出力を再現する


### 5.2 ゲーム配置の固定化

systemd.tmpfiles.rules で:

- /var/lib/minetest/.minetest
- /var/lib/minetest/.minetest/games
- /var/lib/minetest/worlds

を作成し、Mineclonia へのリンクを定義。

目的:

- Luanti が実際に探索するディレクトリへ、起動前に確実配置する


### 5.3 world の初回移行

system.activationScripts.minetestWorldBootstrap で:

- 新 world に world.mt が無い場合のみ
- 旧 world からコピー
- 所有者を minetest:minetest に修正

目的:

- 既存データを破壊せずに運用パスだけ正規化する


## 6. なぜこの構成が安全か

1. 宣言的管理: 手動配置に依存せず、再構築時に状態を再現できる
2. 権限整合: サービスユーザーが読めるパスのみを使用する
3. 破壊回避: world 移行は存在チェック付きで一度だけ実行する
4. トラブル切り分け容易: game 本体と world の責務を明確に分離できる


## 7. 検証で確認した事実

確認済み:

1. systemd サービスは active running
2. ログに Server for gameid=mineclonia listening on [::]:30000
3. ss -lunp で UDP 30000 待受あり
4. スマホクライアントで接続しゲーム画面表示


## 8. 今後の運用メモ

### 8.1 Mineclonia バージョン更新

更新時は次を順に実施:

1. minecloniaVersion を更新
2. fetchzip hash を更新
3. nixos-rebuild build で検証
4. switch して再起動確認


### 8.2 障害時の優先確認

優先順位:

1. systemctl status minetest-server
2. journalctl -u minetest-server -n 100 --no-pager
3. /var/lib/minetest/.minetest/games/mineclonia/game.conf の存在
4. world パスと所有者
5. ss -lunp | grep 30000
6. クライアント側ネットワーク設定 Private DNS, VPN, 接続先 IP


## 9. まとめ

今回の本質は、Luanti 本体の導入ではなく、以下の 2 点でした。

1. Mineclonia を Luanti の探索パスへ正しい階層で配置すること
2. world をサービスユーザーがアクセス可能な運用パスへ寄せること

この 2 点を宣言的に固定したことで、再起動や再ビルド後も同じ挙動を保てる構成になりました。

