# DeepSeek Harness (DSH) Web ランチャー。
#
# なぜ公式 Node.js を fetchurl しているのか:
#   * DSH は公式配布の Node.js バイナリを前提にしており、nixpkgs の nodejs_24 では
#     ネイティブアドオン (node-addon-require-builtin) が "Unsupported/no-getter"
#     で起動に失敗する。
#   * 公式 tarball の node は /lib64/ld-linux-x86-64.so.2 を要求するため、
#     FHS 環境 (steam-run) の中で実行する必要がある。
#
# バージョン更新:
#   dshVersion を書き換える (nodeVersion を変える場合は hash も更新する)。
{ lib, pkgs, ... }:

let
  dshVersion = "0.2.3-alpha.2";
  nodeVersion = "24.22.3";

  nodejs-official = pkgs.stdenvNoCC.mkDerivation {
    pname = "nodejs-official";
    version = nodeVersion;
    src = pkgs.fetchurl {
      url = "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.xz";
      hash = "sha256-TysXWm1TpcYXqA26JnYjigaIzvKMbaTro1x9hE5m/Ps=";
    };
    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;
    installPhase = ''
      mkdir -p "$out"
      cp -a . "$out/"
    '';
  };

  dsh-web = pkgs.writeShellApplication {
    name = "dsh-web";
    text = ''
      export PATH="${lib.makeBinPath [ nodejs-official ]}:$PATH"
      exec ${pkgs.steam-run}/bin/steam-run ${pkgs.bash}/bin/bash -c '
        exec npx --yes @deepseek-ai/dsh@${dshVersion} web "$@"
      ' bash "$@"
    '';
  };
in
{
  home.packages = [ dsh-web ];

  # 従来の ~/.local/bin/dsh-web.sh を、この宣言的なラッパーへのリンクに置き換える。
  home.file.".local/bin/dsh-web.sh" = {
    source = "${dsh-web}/bin/dsh-web";
    force = true;
  };
}
