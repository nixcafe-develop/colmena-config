{
  inputs = {
    # nixos-unstable (use flakehub to avoid github api limit)
    # https://github.com/NixOS/nixpkgs/tree/nixos-unstable
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    # https://github.com/nixos/nixos-hardware
    nixos-hardware.url = "https://flakehub.com/f/nixos/nixos-hardware/0.1.*.tar.gz";

    darwin = {
      # https://github.com/nix-darwin/nix-darwin
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # https://github.com/nix-community/home-manager
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      # https://github.com/cachix/git-hooks.nix
      url = "https://flakehub.com/f/cachix/git-hooks.nix/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      # https://github.com/nix-community/nixos-generators
      url = "https://flakehub.com/f/nix-community/nixos-generators/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      # https://github.com/snowfallorg/lib
      url = "https://flakehub.com/f/snowfallorg/lib/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cattery-modules = {
      # https://github.com/nixcafe/cattery-modules
      url = "https://flakehub.com/f/nixcafe/cattery-modules/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "darwin";
      inputs.home-manager.follows = "home-manager";
    };

    # Replace this with your host's secret, which can be generated using this template
    # https://github.com/nixcafe/develop-my-secrets
    # or local secrets
    # path: `./secrets` or `git+file:///path/to/secrets`
    my-secrets = {
      url = "github:nixcafe/develop-my-secrets";
      # 1. No pollution to the environment
      # 2. Only the key is stored
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      # TODO: write your own module loader with container support.
      lib = inputs.snowfall-lib.mkLib {
        # snowfall doc: https://snowfall.org/guides/lib/quickstart/
        inherit inputs;
        # root dir
        src = ./.;

        snowfall = {
          namespace = "example";
          meta = {
            name = "example-flake";
            title = "example' Nix Flakes";
          };
        };
      };

      nixos-modules = with inputs; [
        cattery-modules.nixosModules.default
      ];
      darwin-modules = with inputs; [
        cattery-modules.darwinModules.default
      ];
      homes-modules = with inputs; [
        cattery-modules.homeModules.default
      ];
    in
    lib.mkFlake {

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      systems = {
        modules = {
          nixos = nixos-modules;
          darwin = darwin-modules;
        };
      };

      homes.modules = homes-modules;

      outputs-builder = channels: { formatter = channels.nixpkgs.nixfmt-rfc-style; };
    };
}
