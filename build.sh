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
