#!/bin/sh
#ふたつのディレクトおよびそはいかにあるでぃれくとりにあるファイルを比較するスクリプト
DIR1="/home/chouette/NixOS-nixos/"
DIR2="/run/media/chouette/ボリューム/NixOS/nixos_202605251105/"
#diffコマンドを使用して、両方のディレクトリの内容を比較する
diff -r "$DIR1" "$DIR2"