# /etc/nixos/filesystems.nix
# { config, lib, pkgs, ... }:
{ machineType ? "baremetal", ... }:

let
  isQemu = machineType == "qemu";
  # isBaremetal = machineType == "baremetal";
in

{
  fileSystems = {
    "/home" = {
      device = 
        if isQemu then
          "/dev/disk/by-uuid/6b6700e6-e806-4cf9-bdb3-4896318ae444"
        else
          "/dev/disk/by-uuid/d325e226-2824-4d85-a4f9-5e6af3697699";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd:3" "noatime" ];
    };
    "/mnt/m223" = {
      device = "/dev/disk/by-uuid/2af9c009-cd0e-4d9f-9319-e33e20ba2962";
      fsType = "btrfs";
    };
    "/mnt/sda3" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
    };
    "/mnt/980Pro2" = {
      device = "/dev/disk/by-uuid/c0212957-ddf7-4d29-a0a6-e3be986a6b80";
      fsType = "ext4";
    };
    "/mnt/980Pro3" = {
      device = "/dev/disk/by-uuid/0c01aa2a-dd01-4e67-b063-15600ab81c4d";
      fsType = "ext4";
    };
    "/mnt/nfsh" = {
      device = "/dev/disk/by-uuid/4121b09e-5d5d-40ce-8e94-1cba91340963";
      fsType = "btrfs";
    };
    "/mnt/lxddefault" = {
      device = "/dev/disk/by-uuid/4121b09e-5d5d-40ce-8e94-1cba91340963";
      fsType = "btrfs";
      options = [
        "subvolid=5"      # パーティションのルートをマウントする場合
        "compress=zstd"   # Btrfsの圧縮を有効にする場合（推奨）
        "noatime" 
      ];
    };
    "/home/chouette/go" = {
      device = "/mnt/nfsh/custom/default_samba/go";
      fsType = "btrfs";
      options = [ "bind" ];
    };
    "/home/chouette/Downloads" = {
      device = "/mnt/nfsh/custom/default_samba/Downloads";
      fsType = "btrfs";
      options = [ "bind" ];
    };
    "/home/chouette/Documents" = {
      device = "/mnt/nfsh/custom/default_samba/Documents";
      fsType = "btrfs";
      options = [ "bind" ];
    };
    "/home/chouette/Pictures" = {
      device = "/mnt/nfsh/custom/default_samba/Pictures";
      fsType = "btrfs";
      options = [ "bind" ];
    };
    "/mnt/kvm" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@kvm" ];
    };
#   "/var/lib/incus/storage-pools/default" = {
#     device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
#     fsType = "btrfs";
#     options = [ "subvol=@incus" ];
#   };
    "/home/chouette/storage/Steam" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@Steam" ];
    };
    "/home/chouette/.local/share/containers" = {
      device = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
      fsType = "btrfs";
      options = [ "subvol=@dbcont" ];
    };
    # 今後増えるバインドマウントもここに追加
    # "/home/chouette/Documents" = {
    #   device = "/mnt/nfsh/...";
    #   options = [ "bind" ];
    # };
  };
}
