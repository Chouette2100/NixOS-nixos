# /etc/nixos/modules/containers.nix
{ config, pkgs, ... }:

{
  virtualisation.incus.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
