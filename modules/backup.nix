# /etc/nixos/modules/backup.nix
# { config, pkgs, ... }:

# 設定を反映した後、手動で即座に実行テストをしたい場合は以下のコマンドを叩きます。
# sudo systemctl start vps-db-backup.service
# ログを確認するには：
# journalctl -u vps-db-backup.service

{ pkgs, ... }:

let
  dbBackupScript = pkgs.writeShellScript "mysql-dump-vps" ''
    export THISDIR="kagoya10"
    export DBNAME="showroom"
    export BACKUP_DIR="/home/chouette/MyProject/MySQL/$THISDIR"
    
    mkdir -p "$BACKUP_DIR"
    cd "$BACKUP_DIR"

    dumpfn=''${DBNAME}_$(date +%Y%m%d_%H%M).sql
    
    # --login-path を使用
    # ※ 事前に chouette ユーザーで mysql_config_editor set --login-path=kagoyar ... を実行しておく必要があります
    ${pkgs.mariadb}/bin/mysqldump \
      --login-path=kagoyar \
      --single-transaction \
      --flush-logs \
      --source-data=2 \
      --databases "$DBNAME" > "$dumpfn"

    # 古いファイルの削除
    ${pkgs.findutils}/bin/find . -name "$DBNAME_202?????_????.sql" -mtime +3 -delete
  '';
in
{
  systemd.services.vps-db-backup = {
    description = "Daily VPS MySQL Backup";
    
    # トンネルサービスが起動していることを条件にする
    after = [ "ssh-tunnel-kagoya.service" ];
    requires = [ "ssh-tunnel-kagoya.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "chouette";
      # ホームディレクトリを明示することで .mylogin.cnf を読み込めるようにする
      Environment = "HOME=/home/chouette";
    };
    script = "${dbBackupScript}";
  };

  # 以下のコマンドを叩くと、​​「次の実行予定時刻」​​がいつになるかを一覧で確認できます。
  # systemctl list-timers vps-db-backup.timer
  # 平日の20時の次の実行予定を確認
  # systemd-analyze calendar "Mon..Fri *-*-* 20:00:00"
  systemd.timers.vps-db-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # OnCalendar = "daily";
      OnCalendar = "03:00:00";
      # リスト形式で複数のスケジュールを指定
      # OnCalendar = [
      #   "Mon..Fri *-*-* 20:00:00"  # 月〜金 の 20:00
      #   "Sat,Sun *-*-* 18:00:00"    # 土・日 の 18:00
      # ];
      Persistent = true;
      Unit = "vps-db-backup.service";
    };
  };
}
