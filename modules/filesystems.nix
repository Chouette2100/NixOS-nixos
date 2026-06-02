# /etc/nixos/filesystems.nix
{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/mnt/m223" = {
      device = "/dev/disk/by-uuid/2af9c009-cd0e-4d9f-9319-e33e20ba2962";
      fsType = "btrfs";
    };
    "/mnt/nfsh" = {
      device = "/dev/disk/by-uuid/4121b09e-5d5d-40ce-8e94-1cba91340963";
      fsType = "btrfs";
    };
    "/home/chouette/go" = {
      device = "/mnt/nfsh/custom/default_samba/go";
      fsType = "btrfs";
      options = [ "bind" ];
    };
    "/kvm" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@kvm" ];
    };
    "/incus" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@incus" ];
    };
    "/home/chouette/storage/Steam" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@Steam" ];
    };
    # 今後増えるバインドマウントもここに追加
    # "/home/chouette/Documents" = {
    #   device = "/mnt/nfsh/...";
    #   options = [ "bind" ];
    # };
  };
}
