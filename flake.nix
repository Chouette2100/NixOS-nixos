# /etc/nixos/flake.nix
# $ vi flake.nix     ...   inputs.nixpkgs.urlを変更する
# $ nix flake update
# $ sudo nixos-rebuild switch --flake .
{
  description = "My NixOS Configuration with age-encrypted secrets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # ドライバが580系だった頃のnixpkgsを別名で登録
    nixpkgs-nvidia-legacy.url = "github:nixos/nixpkgs/nixos-25.11"; 

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixpkgs-nvidia-legacy, ... }@inputs:
    let
      mkNixosConfig = machineType: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit machineType;
          # 580系ドライバを持つpkgsを個別に作成して渡す
          pkgs-nvidia = import nixpkgs-nvidia-legacy {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        
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
