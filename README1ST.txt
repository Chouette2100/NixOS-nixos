# NixOSをインストールする
# sshdを起動する
# configuration.nixを2箇所修正すれば22で接続できる

# リモートから
# ~/Backup/nixos/NixOS-nixos-202........tar.z　をnixosに転送する

tar xvf NixOS-nixos-202.......tar.z

vi ~/.config/age/key.txt

cd ~/NixOS-nixos

# OSインストール直後
# cp -a /etc/nixos/hardware-configuration.nix .
# mkdir ~/.ssh

# 場合によっては
# rm ../.ssh/config

mv .git git

.build.sh



問題点

最初に.sshを作成しなければならない
~/.ssh/configを削除しなければならないケースがある
