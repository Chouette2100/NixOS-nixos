# /etc/nixos/modules/desktop.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isBaremetal = machineType == "baremetal";
in

{
  services.xserver.enable = true;

  services.xserver.videoDrivers = lib.optionals isBaremetal [ "nvidia" ];

  hardware = lib.mkIf isBaremetal {
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "jp";
    model = "jp106";
  };

  console.keyMap = "jp106";

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

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

}
