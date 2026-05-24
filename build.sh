#!/bin/sh
# rm /home/chouette/.ssh/{config,id_ed25519*}
# ls -l /home/chouette/.ssh/
sudo nixos-rebuild switch --flake /home/chouette/NixOS-nixos#nixos
