# /etc/nixos/modules/desktop.nix
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
# services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  programs.firefox.enable = true;
}
