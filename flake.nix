# /etc/nixos/flake.nix
# $ vi flake.nix     ...   inputs.nixpkgs.urlを変更する
# $ nix flake update
# $ sudo nixos-rebuild switch --flake .
{
  description = "My NixOS Configuration with age-encrypted secrets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      mkNixosConfig = machineType: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit machineType; };
        
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          
          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.chouette = import ./home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        qemu = mkNixosConfig "qemu";
        baremetal = mkNixosConfig "baremetal";
      };
    };
}
