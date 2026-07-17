{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    purr.url = "https://flakehub.com/f/nixcafe/purr/0.1.*.tar.gz";

    git-hooks = {
      url = "https://flakehub.com/f/cachix/git-hooks.nix/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "https://flakehub.com/f/nixos/nixos-hardware/0.1.*.tar.gz";

    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "https://flakehub.com/f/nix-community/nixos-generators/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cattery-modules = {
      url = "https://flakehub.com/f/nixcafe/cattery-modules/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-secrets = {
      url = "github:nixcafe/develop-my-secrets";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.purr.lib.mkFlake {
      inherit inputs;
      src = ./.;

      nixpkgsConfig = {
        allowUnfree = true;
      };

      extraModules = {
        nixos = [ inputs.cattery-modules.nixosModules.default ];
        darwin = [ inputs.cattery-modules.darwinModules.default ];
        home = [ inputs.cattery-modules.homeModules.default ];
      };

      outputsBuilder = { pkgs, ... }: {
        formatter = pkgs.nixfmt;
      };
    }
    // {
      colmenaHive = import ./colmena/colmenaHive { inherit inputs; };
    };
}
