chouette@nixos:~/NixOS-nixos$ nh os info
NixOS 26.05.20260531.b51242d
Generation No Build Date           NixOS Version          Kernel  Closure Size
192 (current) 2026-10-04 18:17:55  26.05.20260531.b51242d 6.18.33 22.8 GB     
191           2026-10-04 12:06:19  26.05.20260531.b51242d 6.18.33 22.8 GB     
190           2026-10-04 08:07:09  26.05.20260531.b51242d 6.18.33 22.8 GB     
189           2026-08-31 15:26:29  26.05.20260531.b51242d 6.18.33 22.8 GB     
188           2026-08-31 11:13:57  26.05.20260531.b51242d 6.18.33 22.8 GB     
187           2026-08-29 00:15:32  26.05.20260531.b51242d 6.18.33 22.8 GB     
186           2026-08-29 00:08:41  26.05.20260531.b51242d 6.18.33 22.8 GB     
185           2026-08-28 23:46:05  26.05.20260531.b51242d 6.18.33 22.8 GB     
chouette@nixos:~/NixOS-nixos$ nix flake update
warning: updating lock file "/home/chouette/NixOS-nixos/flake.lock":
• Updated input 'home-manager':
    'github:nix-community/home-manager/4baa8ac595f6122d2899093f575347af9c4e66d7?narHash=sha256-PPWavrpeQFqE3bEShp9xcWeh2xyVbUucjBbG64MLRl0%3D' (2026-06-01)
  → 'github:nix-community/home-manager/db7d5e2332710f5abb088f6b5de927d7f9511b35?narHash=sha256-f%2BkOxEmOUnQazVAmGg0i8hzwgd1kX/geY%2Bk/Dpheye8%3D' (2026-10-03)
• Updated input 'nixpkgs':
    'github:NixOS/nixpkgs/b51242d7d43689db2f3be91bd05d5b24fbb469c4?narHash=sha256-K5sT4jTpGs15ADhviMKNBH38REpPf5Q6mM1%2BN6cArVE%3D' (2026-05-31)
  → 'github:NixOS/nixpkgs/825e2028c29b702a4a5f085f08095d12099784f2?narHash=sha256-/FGDr01siZ8txrVzkOz6CYjiz0XR27JuVJP%2BaWchi4s%3D' (2026-10-03)
• Updated input 'nixvim':
    'github:nix-community/nixvim/f2029d9a26266eb67f46b0c79bd0a3713839a57a?narHash=sha256-9hXtN4my7eBqHRVQ/t6FQZ4YqZ1KG6SsKSG4Hdtr%2Bi0%3D' (2026-06-12)
  → github:nix-community/nixvim/1cdfef1a6eb583d65b606b04fc97687491479d62?narHash=sha256-EeMn6SmrBe4gnxaMyb3NZYMXG8FPF9PY0OCcbPDFFNI%3D' (2026-10-02)
• Updated input 'nixvim/flake-parts':
    'github:hercules-ci/flake-parts/f7c1a2d347e4c52d5fb8d10cb4d94b5884e546fb?narHash=sha256-m1Yf0wZ8j1OHjTc2UwHwyQRSnNeSgLJOd7q5Y45hzi4%3D' (2026-05-13)
  → 'github:hercules-ci/flake-parts/31729ca8cbdb4fa927b34e5f4353e6a83f39e993?narHash=sha256-glZLQlzIn1fXH6PazR2iUmTo7kzzyYSshrWhLS9TqCU%3D' (2026-09-03)
chouette@nixos:~/NixOS-nixos$ vi docs/flake_update_2026-10-05.md
chouette@nixos:~/NixOS-nixos$ cat build.sh 
#!/bin/sh
# rm /home/chouette/.ssh/{config,id_ed25519*}
# ls -l /home/chouette/.ssh/

# 起動方法: ./build.sh [qemu|600g4]
if [ -z "$1" ]; then
    echo "Usage: $0 [qemu|600g4]"
    exit 1
fi
if [ "$1" = "qemu" ]; then
    echo "Building for QEMU..."
    sudo nixos-rebuild switch --flake '.#qemu'
elif [ "$1" = "600g4" ]; then
    echo "Building for 600g4..."
    sudo nixos-rebuild switch --flake '.#baremetal'
else
    echo "Usage: $0 [qemu|600g4]"
    exit 1
fi
chouette@nixos:~/NixOS-nixos$ ./build.sh 600g4
Building for 600g4...
[sudo] chouette のパスワード:
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
building the system configuration...
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
error:
       … while calling the 'head' builtin
         at «github:NixOS/nixpkgs/825e2028c29b702a4a5f085f08095d12099784f2?narHash=sha256-/FGDr01siZ8txrVzkOz6CYjiz0XR27JuVJP%2BaWchi4s%3D»/lib/attrsets.nix:1717:13:
         1716|           if length values == 1 || pred here (elemAt values 1) (head values) then
         1717|             head values
             |             ^
         1718|           else

       … while evaluating the attribute 'value'
         at «github:NixOS/nixpkgs/825e2028c29b702a4a5f085f08095d12099784f2?narHash=sha256-/FGDr01siZ8txrVzkOz6CYjiz0XR27JuVJP%2BaWchi4s%3D»/lib/modules.nix:1167:7:
         1166|     // {
         1167|       value = addErrorContext "while evaluating the option `${showOption loc}':" value;
             |       ^
         1168|       inherit (res.defsFinal') highestPrio;

       … while evaluating the option `system.build.toplevel':

       … while evaluating definitions from `/nix/store/cj82fg23423frhfimn4srx0wii5164wy-source/nixos/modules/system/activation/top-level.nix':

       … while evaluating the option `assertions':

       … while evaluating definitions from `/nix/store/41xfn9jzjgn6avsdpwiv0zrnwbiz5mmb-source/nixos/common.nix':

       … while evaluating the option `home-manager.users.chouette.assertions':

       … while evaluating definitions from `/nix/store/38a47a7614fbzg32473qjd7gzwnfsi7j-source/wrappers/_shared.nix':

       … while evaluating the option `home-manager.users.chouette.programs.nixvim':

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: The option `home-manager.users.chouette.programs.nixvim.plugins.dap.extensionConfig' does not exist. Definition values:
       - In `/nix/store/vkibbv17d0rjml70srp4d0cvgy5w5a5c-source/modules/neovim/plugins.nix':
           ''
             -- プロジェクトの .vscode/launch.json を読み込む設定
             require('dap.ext.vscode').load_launchjs(nil, {
               -- 言語名と、dapのアダプタ名を紐付けます
               go = {'go'},
           ...

       Did you mean `home-manager.users.chouette.programs.nixvim.plugins.dap.extensionConfigLua', `home-manager.users.chouette.programs.nixvim.plugins.dap.extensions' or `home-manager.users.chouette.programs.nixvim.plugins.dap.luaConfig'?
Command 'nix --extra-experimental-features 'nix-command flakes' build --print-out-paths '.#nixosConfigurations."baremetal".config.system.build.toplevel' --no-link' returned non-zero exit status 1.
chouette@nixos:~/NixOS-nixos$ cat build.sh 
#!/bin/sh
# rm /home/chouette/.ssh/{config,id_ed25519*}
# ls -l /home/chouette/.ssh/

# 起動方法: ./build.sh [qemu|600g4]
if [ -z "$1" ]; then
    echo "Usage: $0 [qemu|600g4]"
    exit 1
fi
if [ "$1" = "qemu" ]; then
    echo "Building for QEMU..."
    sudo nixos-rebuild switch --flake '.#qemu'
elif [ "$1" = "600g4" ]; then
    echo "Building for 600g4..."
    sudo nixos-rebuild switch --flake '.#baremetal'
else
    echo "Usage: $0 [qemu|600g4]"
    exit 1
fi
chouette@nixos:~/NixOS-nixos$ 
chouette@nixos:~/NixOS-nixos$ 
chouette@nixos:~/NixOS-nixos$ 
chouette@nixos:~/NixOS-nixos$ grep extensionConfig *.nix */*.nix
chouette@nixos:~/NixOS-nixos$ grep -i extensionConfig *.nix */*.nix
chouette@nixos:~/NixOS-nixos$ grep -i dap *.nix */*.nix
chouette@nixos:~/NixOS-nixos$ grep -i config *.nix */*.nix
configuration.nix:# /etc/nixos/configuration.nix
configuration.nix:# { config, lib, pkgs, machineType ? "baremetal", ... }:
configuration.nix:    dontConfigure = true;
configuration.nix:  nixpkgs.config.allowUnfree = true;
configuration.nix:  security.polkit.extraConfig = ''
configuration.nix:    configDir = "/home/chouette/.config/syncthing";
configuration.nix:    config = {
flake.nix:  description = "My NixOS Configuration with age-encrypted secrets";
flake.nix:      mkNixosConfig = machineType: nixpkgs.lib.nixosSystem {
flake.nix:          ./hardware-configuration.nix
flake.nix:          ./configuration.nix
flake.nix:      nixosConfigurations = {
flake.nix:        qemu = mkNixosConfig "qemu";
flake.nix:        baremetal = mkNixosConfig "baremetal";
hardware-configuration.nix:# Do not modify this file!  It was generated by ‘nixos-generate-config’
hardware-configuration.nix:# to /etc/nixos/configuration.nix instead.
hardware-configuration.nix:# { config, lib, pkgs, modulesPath, machineType ? "qemu", ... }:
hardware-configuration.nix:{ config, lib, modulesPath, machineType ? "qemu", ... }:
hardware-configuration.nix:      lib.mkDefault config.hardware.enableRedistributableFirmware
home.nix:# { config, pkgs, lib, inputs, ... }:
home.nix:{ config, pkgs, lib, ... }:
home.nix:    ".ssh/config" = {
home.nix:  xdg.configFile."autostart/xhost-local.desktop".text = ''
home.nix:      if [ -f "${config.home.homeDirectory}/.config/age/key.txt" ]; then
home.nix:          -i "${config.home.homeDirectory}/.config/age/key.txt" \
home.nix:          -o "${config.home.homeDirectory}/.ssh/id_ed25519" \
home.nix:          "${config.home.homeDirectory}/NixOS-nixos/secrets/id_ed25519.age"
home.nix:        chmod 600 "${config.home.homeDirectory}/.ssh/id_ed25519"
home.nix:        echo "Warning: age key not found at ~/.config/age/key.txt"
home.nix:        echo "  age -d -i ~/.config/age/key.txt -o ~/.ssh/id_ed25519 ~/NixOS-nixos/secrets/id_ed25519.age"
home.nix:      mkdir -p "${config.home.homeDirectory}/kb"
home.nix:    "f /home/chouette/.ssh/config 0600 - - - -"
home.nix:    enableDefaultConfig = false;
home.nix:  xdg.configFile."kscreenlockerrc".text = ''
home.nix:  xdg.configFile."fcitx5/config".force = true;
home.nix:  xdg.configFile."fcitx5/config".text = ''
home.nix:  xdg.configFile."kxkbrc".text = ''
home.nix:  xdg.configFile."autostart/setxkbmap-jp.desktop".text = ''
home.nix:  xdg.configFile."autostart/terminator.desktop".text = ''
home.nix:        --config=/home/chouette/.config/rclone/rclone.conf \
modules/backup.nix:# { config, pkgs, ... }:
modules/backup.nix:    # ※ 事前に chouette ユーザーで mysql_config_editor set --login-path=kagoyar ... を実行しておく必要があります
modules/backup.nix:    serviceConfig = {
modules/backup.nix:    timerConfig = {
modules/containers.nix:# { config, pkgs, ... }:
modules/containers.nix:    #       config = {
modules/containers.nix:    #   #     config = {
modules/containers.nix:    fontconfig = {
modules/desktop.nix:# console.useXkbConfig = true;
modules/filesystems.nix:# { config, lib, pkgs, ... }:
modules/networking.nix:# { config, lib, pkgs, machineType ? "baremetal", ... }:
modules/printer.nix:# { config, pkgs, ... }:
modules/qemukvm.nix:# { config, pkgs, ... }:
modules/service.nix:# { config, pkgs, ... }:
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/system.nix:# { config, pkgs, ... }:
modules/system.nix:      # sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
modules/system.nix:  nixpkgs.config.allowUnfree = true;
chouette@nixos:~/NixOS-nixos$ grep Config *.nix */*.nix
configuration.nix:    dontConfigure = true;
configuration.nix:  security.polkit.extraConfig = ''
flake.nix:  description = "My NixOS Configuration with age-encrypted secrets";
flake.nix:      mkNixosConfig = machineType: nixpkgs.lib.nixosSystem {
flake.nix:      nixosConfigurations = {
flake.nix:        qemu = mkNixosConfig "qemu";
flake.nix:        baremetal = mkNixosConfig "baremetal";
home.nix:    enableDefaultConfig = false;
modules/backup.nix:    serviceConfig = {
modules/backup.nix:    timerConfig = {
modules/desktop.nix:# console.useXkbConfig = true;
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
chouette@nixos:~/NixOS-nixos$ grep Config *.nix */*.nix */*/*.nix
configuration.nix:    dontConfigure = true;
configuration.nix:  security.polkit.extraConfig = ''
flake.nix:  description = "My NixOS Configuration with age-encrypted secrets";
flake.nix:      mkNixosConfig = machineType: nixpkgs.lib.nixosSystem {
flake.nix:      nixosConfigurations = {
flake.nix:        qemu = mkNixosConfig "qemu";
flake.nix:        baremetal = mkNixosConfig "baremetal";
home.nix:    enableDefaultConfig = false;
modules/backup.nix:    serviceConfig = {
modules/backup.nix:    timerConfig = {
modules/desktop.nix:# console.useXkbConfig = true;
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/service.nix:  serviceConfig = {
modules/neovim/plugins.nix:      extensionConfig = ''
chouette@nixos:~/NixOS-nixos$ ./build.sh 600g4
Building for 600g4...
[sudo] chouette のパスワード:
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
building the system configuration...
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
error:
       … while calling the 'head' builtin
         at «github:NixOS/nixpkgs/825e2028c29b702a4a5f085f08095d12099784f2?narHash=sha256-/FGDr01siZ8txrVzkOz6CYjiz0XR27JuVJP%2BaWchi4s%3D»/lib/attrsets.nix:1717:13:
         1716|           if length values == 1 || pred here (elemAt values 1) (head values) then
         1717|             head values
             |             ^
         1718|           else

       … while evaluating the attribute 'value'
         at «github:NixOS/nixpkgs/825e2028c29b702a4a5f085f08095d12099784f2?narHash=sha256-/FGDr01siZ8txrVzkOz6CYjiz0XR27JuVJP%2BaWchi4s%3D»/lib/modules.nix:1167:7:
         1166|     // {
         1167|       value = addErrorContext "while evaluating the option `${showOption loc}':" value;
             |       ^
         1168|       inherit (res.defsFinal') highestPrio;

       … while evaluating the option `system.build.toplevel':

       … while evaluating definitions from `/nix/store/cj82fg23423frhfimn4srx0wii5164wy-source/nixos/modules/system/activation/top-level.nix':

       … while evaluating the option `assertions':

       … while evaluating definitions from `/nix/store/41xfn9jzjgn6avsdpwiv0zrnwbiz5mmb-source/nixos/common.nix':

       … while evaluating the option `home-manager.users.chouette.assertions':

       … while evaluating definitions from `/nix/store/38a47a7614fbzg32473qjd7gzwnfsi7j-source/wrappers/_shared.nix':

       … while evaluating the option `home-manager.users.chouette.programs.nixvim':

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: The option `home-manager.users.chouette.programs.nixvim.plugins.plugins' does not exist. Definition values:
       - In `/nix/store/h83yv2hcxn3dbyq3k4agwpspng9z18zi-source/modules/neovim/plugins.nix':
           {
             copilot-chat = {
               enable = true;
             };
           }
Command 'nix --extra-experimental-features 'nix-command flakes' build --print-out-paths '.#nixosConfigurations."baremetal".config.system.build.toplevel' --no-link' returned non-zero exit status 1.
chouette@nixos:~/NixOS-nixos$ grep copilot-chat *.nix */*.nix */*/*.nix
modules/neovim/plugins.nix:    plugins.copilot-chat = {
chouette@nixos:~/NixOS-nixos$ ./build.sh 600g4
Building for 600g4...
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
building the system configuration...
warning: Git tree '/home/chouette/NixOS-nixos' is dirty
Checking switch inhibitors... done
updating systemd-boot from 260.1 to 260.4
Copied "/nix/store/b4b1x5fhxpc78qlclj3kdbl9dd49g917-systemd-260.4/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/systemd/systemd-bootx64.efi".
Copied "/nix/store/b4b1x5fhxpc78qlclj3kdbl9dd49g917-systemd-260.4/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/EFI/BOOT/BOOTX64.EFI".
stopping the following units: accounts-daemon.service, colord.service, cups.service, cups.socket, ensure-printers.service, fwupd.service, geoclue.service, kmod-static-nodes.service, logrotate-checkconf.service, minetest-server.service, ModemManager.service, mysql.service, network-local-commands.service, NetworkManager-wait-online.service, NetworkManager.service, nfs-idmapd.service, nfs-mountd.service, nfs-server.service, nfsdcld.service, nscd.service, power-profiles-daemon.service, resolvconf.service, rpc-statd-notify.service, rpc-statd.service, rpcbind.service, rpcbind.socket, rtkit-daemon.service, spice-vdagentd.service, ssh-tunnel-kagoya.service, ssh-tunnel-LB10.service, ssh-tunnel-nix01.service, ssh-tunnel-ubuntu05.service, syncthing.service, systemd-machined.service, systemd-modules-load.service, systemd-oomd.service, systemd-oomd.socket, systemd-sysctl.service, systemd-timesyncd.service, systemd-tmpfiles-resetup.service, systemd-vconsole-setup.service, udisks2.service, upower.service
NOT restarting the following changed units: bluetooth.service, display-manager.service, incus-startup.service, libvirt-guests.service, libvirtd.service, lxcfs.service, post-boot.service, systemd-fsck@dev-disk-by\x2duuid-0c01aa2a\x2ddd01\x2d4e67\x2db063\x2d15600ab81c4d.service, systemd-fsck@dev-disk-by\x2duuid-8280\x2d0A6A.service, systemd-fsck@dev-disk-by\x2duuid-c0212957\x2dddf7\x2d4d29\x2da0a6\x2de3be986a6b80.service, systemd-journal-flush.service, systemd-logind.service, systemd-random-seed.service, systemd-remount-fs.service, systemd-update-utmp.service, systemd-user-sessions.service, user-runtime-dir@1001.service, user@1001.service, virtlogd.service
activating the configuration...
setting up /etc...
restarting systemd...
reloading user units for chouette...
stopping the following user units: at-spi-dbus-bus.service, dconf.service, gcr-ssh-agent.service, gcr-ssh-agent.socket, geoclue-agent.service, gvfs-afc-volume-monitor.service, gvfs-daemon.service, gvfs-goa-volume-monitor.service, gvfs-gphoto2-volume-monitor.service, gvfs-metadata.service, gvfs-mtp-volume-monitor.service, gvfs-udisks2-volume-monitor.service, obex.service, pipewire-pulse.service, pipewire-pulse.socket, pipewire.service, pipewire.socket, speech-dispatcher.service, speech-dispatcher.socket, wireplumber.service, xdg-desktop-portal-gtk.service, xdg-desktop-portal.service, xdg-document-portal.service, xdg-permission-store.service
reloading the following user units: dbus-broker.service
starting the following user units: at-spi-dbus-bus.service, dconf.service, gcr-ssh-agent.socket, geoclue-agent.service, gvfs-afc-volume-monitor.service, gvfs-daemon.service, gvfs-goa-volume-monitor.service, gvfs-gphoto2-volume-monitor.service, gvfs-metadata.service, gvfs-mtp-volume-monitor.service, gvfs-udisks2-volume-monitor.service, obex.service, pipewire-pulse.socket, pipewire.socket, speech-dispatcher.socket, wireplumber.service, xdg-desktop-portal-gtk.service, xdg-desktop-portal.service, xdg-document-portal.service, xdg-permission-store.service
restarting the following user units: nixos-activation.service
restarting sysinit-reactivation.target
reloading the following units: dbus-broker.service, nftables.service, reload-systemd-vconsole-setup.service
restarting the following units: home-manager-chouette.service, incus.service, nix-daemon.service, polkit.service, sshd.service, systemd-journald.service, systemd-udevd.service, tailscaled.service, wpa_supplicant.service
starting the following units: accounts-daemon.service, colord.service, cups.socket, ensure-printers.service, fwupd.service, geoclue.service, kmod-static-nodes.service, logrotate-checkconf.service, minetest-server.service, ModemManager.service, mysql.service, network-local-commands.service, NetworkManager-wait-online.service, NetworkManager.service, nfs-idmapd.service, nfs-mountd.service, nfs-server.service, nfsdcld.service, nscd.service, power-profiles-daemon.service, resolvconf.service, rpc-statd-notify.service, rpc-statd.service, rpcbind.socket, rtkit-daemon.service, spice-vdagentd.service, ssh-tunnel-kagoya.service, ssh-tunnel-LB10.service, ssh-tunnel-nix01.service, ssh-tunnel-ubuntu05.service, syncthing.service, systemd-machined.service, systemd-modules-load.service, systemd-oomd.socket, systemd-sysctl.service, systemd-timesyncd.service, systemd-tmpfiles-resetup.service, systemd-vconsole-setup.service, udisks2.service, upower.service
the following new units were started: systemd-hostnamed.service, time-set.target
warning: the following units failed: ssh-tunnel-ubuntu05.service
● ssh-tunnel-ubuntu05.service - SSH Tunnel to ubuntu05 (Local & Reverse)
     Loaded: loaded (/etc/systemd/system/ssh-tunnel-ubuntu05.service; enabled; preset: ignored)
     Active: activating (auto-restart) (Result: exit-code) since Mon 2026-10-05 13:58:22 JST; 4s ago
 Invocation: f1c8c7ba417b4c4190c27e6b35598d58
    Process: 357758 ExecStart=/nix/store/5lxyvxz845rzklwn556f6cizv2sg0rrg-openssh-10.5p1/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N -L 9911:127.0.0.1:3306 chouette@192.168.0.28 (code=exited, status=255/EXCEPTION)
   Main PID: 357758 (code=exited, status=255/EXCEPTION)
         IP: 0B in, 60B out
         IO: 0B read, 0B written
   Mem peak: 2M
        CPU: 10ms
Command 'systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER -E NIXOS_NO_CHECK --collect --no-ask-password --pipe --quiet --service-type=exec --unit=nixos-rebuild-switch-to-configuration /nix/store/l72sncs272xyavnr6lr5ksyz9h8lx2bb-nixos-system-nixos-26.05.20261003.825e202/bin/switch-to-configuration switch' returned non-zero exit status 4.
chouette@nixos:~/NixOS-nixos$ nh os info
NixOS 26.05.20261003.825e202
Generation No Build Date           NixOS Version          Kernel  Closure Size
193 (current) 2026-10-05 13:57:28  26.05.20261003.825e202 6.18.55 23.2 GB     
192           2026-10-04 18:17:55  26.05.20260531.b51242d 6.18.33 22.8 GB     
191           2026-10-04 12:06:19  26.05.20260531.b51242d 6.18.33 22.8 GB     
190           2026-10-04 08:07:09  26.05.20260531.b51242d 6.18.33 22.8 GB     
189           2026-08-31 15:26:29  26.05.20260531.b51242d 6.18.33 22.8 GB     
188           2026-08-31 11:13:57  26.05.20260531.b51242d 6.18.33 22.8 GB     
187           2026-08-29 00:15:32  26.05.20260531.b51242d 6.18.33 22.8 GB     
186           2026-08-29 00:08:41  26.05.20260531.b51242d 6.18.33 22.8 GB     
185           2026-08-28 23:46:05  26.05.20260531.b51242d 6.18.33 22.8 GB     
chouette@nixos:~/NixOS-nixos$ 
