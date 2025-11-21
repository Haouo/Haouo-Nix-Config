{
  description = "Haouo's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-wsl.url = "github:nix-community/nixos-wsl/release-25.05";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim for neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix for managing secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-wsl, home-manager, nixvim, sops-nix, ... }:
  let
    userName = "haouo"; # FIXME - replace it with the actual value
    hostName = "nixos"; # FIXME - replace it with the actual value
    wslEnable = false; # FIXME - replace it with the actual value
    hostSystem = "aarch64-linux"; # FIXME - replace it with the actual value
  in
  {
    # system-wide configuration
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = hostSystem;
        specialArgs = { inherit userName hostName wslEnable hostSystem };
        modules = [
          ./configuration.nix
          (if wslEnable then nixos-wsl.nixosModules.default else {})
        ];
      };
    };

    # homeConfigurations with home-manager
    homeConfigurations = {
      "${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${hostSystem};
        specialArgs = { inherit userName };
        modules = [
          nixvim.homeModules.nixvim
          sops-nix.homeManagerModules.sops
          ./home-manager/home.nix
        ];
      };
    };
  };
}
