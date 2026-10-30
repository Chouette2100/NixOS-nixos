{ config, lib, pkgs, ... }:

let
  messageToDiscord = pkgs.buildGoModule rec {
    pname = "message-to-discord";
    version = "0.1.0";
    src = /home/chouette/go/src/messageToDiscord;
    vendorHash = null;
    postInstall = ''
      mv $out/bin/messageToDiscord $out/bin/message-to-discord
    '';
  };

  sendmailCompat = pkgs.writeShellScriptBin "sendmail" ''
    exec ${messageToDiscord}/bin/message-to-discord "$@"
  '';
in
{
  environment.systemPackages = [
    messageToDiscord
    sendmailCompat
  ];

  environment.variables = {
    DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1563536699936612362/Civ0Avi53lhcxkW7gD1HO4Rhr5w986CeIijYrRfKZBI0XTGHkMcmFXi07j7MpmpiP_E8";
    DISCORD_WEBHOOK_RETRIES = "3";
    DISCORD_WEBHOOK_RETRY_DELAY = "2";
    DISCORD_FAILED_LOG_PATH = "/tmp/discord_failed.json";
  };

  systemd.services.message-to-discord = {
    description = "Discord relay for cron/sendmail-style alerts";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      ExecStart = "${messageToDiscord}/bin/message-to-discord";
      Environment = [
        "DISCORD_WEBHOOK_URL=${config.environment.variables.DISCORD_WEBHOOK_URL}"
        "DISCORD_WEBHOOK_RETRIES=${config.environment.variables.DISCORD_WEBHOOK_RETRIES}"
        "DISCORD_WEBHOOK_RETRY_DELAY=${config.environment.variables.DISCORD_WEBHOOK_RETRY_DELAY}"
        "DISCORD_FAILED_LOG_PATH=${config.environment.variables.DISCORD_FAILED_LOG_PATH}"
      ];
    };
  };
}
