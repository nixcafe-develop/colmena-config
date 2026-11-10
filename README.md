# NixOS configuration with Colmena

This template is based on [nix-config](https://github.com/nixcafe-develop/nix-config) and adds Colmena deployment. It keeps the purr setup for NixOS, nix-darwin, and home-manager, and adds a `colmenaHive` output that turns each NixOS configuration into a Colmena node. Deployment targets are set in `colmena/colmenaHive/deployments.nix`.

It is part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection and can be copied with `nix flake init` or used as a GitHub template.

## Quick start

### Create from the flake template

```bash
nix flake init -t "github:nixcafe/develop-templates#colmena-config" --refresh
```

If you use the templates often, register the collection once:

```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#colmena-config
```

On systems that import cattery-modules, the `beans` registry entry is already configured.

### Create a GitHub repository from the template

```bash
gh repo create my-colmena-config --template nixcafe-develop/colmena-config --clone
```

### Enter the development shell

```bash
direnv allow   # or: nix develop
nix flake show # list the discovered systems and homes
```

## What's included

| Output or component | Purpose |
|---------------------|---------|
| `nixosConfigurations` | NixOS hosts from `systems/x86_64-linux`. |
| `darwinConfigurations` | macOS hosts from `systems/aarch64-darwin`. |
| `homeConfigurations` | Standalone home-manager configurations from `homes/`. |
| `colmenaHive` | Colmena hive built from `nixosConfigurations`. |
| `images` | Images for hosts that list formats in `meta.nix`, such as `images.graphical.iso-installer`. |
| `devShells.default` | Shell with colmena, nixfmt, deadnix, statix, and the git hooks. |
| `formatter` | `nixfmt`, also available through `nix fmt`. |
| `checks.git-hooks` | Pre-commit checks for nixfmt, deadnix, and statix. |
| `modules/` | Local modules for the user account, secrets, and Homebrew. |
| `cattery-modules` | Input that provides the `cattery` option namespace. |
| Home linking | A home named `<user>@<host>` is added to the system with the same host name. |

## Configuration

### Host identity

Edit `lib/host/default.nix`. The values are used by the user modules and can be overridden per host.

```nix
{
  name = "myhost";
  realName = "Jane Doe";
  email.address = "jane@example.com";
  timeZone = "America/New_York";
  authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
}
```

### Add a system

Create `systems/<arch-format>/<name>/default.nix`. For NixOS, use a directory such as `systems/x86_64-linux/myhost`. The directory name becomes the key in `nixosConfigurations` and the node name in `colmenaHive`.

```nix
{
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "myhost";
  system.stateVersion = "25.11";
}
```

purr sets `networking.hostName` to the directory name by default. Add an optional `meta.nix` next to `default.nix` for host metadata.

### Add a home

Create `homes/<arch-format>/<user>@<host>/default.nix`. purr links the home to the system with the same host name and sets `home.username` and `home.homeDirectory`. The same file is also exposed as a standalone entry in `homeConfigurations`.

```nix
{
  home.stateVersion = "25.11";
  cattery.room.desktop.dev.enable = true;
}
```

### Add an image recipe

Image hosts are normal NixOS hosts with a `meta.nix` that lists formats. The repository has three image hosts under `systems/x86_64-linux`: `graphical`, `minimal`, and `minimal-no-zfs`.

```nix
# systems/x86_64-linux/graphical/meta.nix
{
  images = [ "iso-installer" ];
}
```

Build one with:

```bash
nix build .#images.graphical.iso-installer
```

Image-only hosts are not added to `nixosConfigurations` by default. Set `deployable = true` in `meta.nix` to include the host as a system as well. Only deployable hosts become Colmena nodes.

### Deploy with Colmena

Set deployment targets in `colmena/colmenaHive/deployments.nix`:

```nix
{
  myhost = {
    deployment = {
      targetHost = "192.168.1.42";
      targetPort = 22;
      targetUser = "root";
    };
  };
}
```

The shipped file sets a target for `hostname-server`. Hosts without an entry still appear in the hive with an empty `deployment` attribute set, so Colmena uses its defaults for those hosts. Add an entry for every host you deploy.

The hive description is set in `colmena/colmenaHive/default.nix` (`meta.description = "my personal machines"`). Change it to describe your machines.

Common commands:

```bash
colmena apply                          # deploy all hosts in the hive
colmena apply --on hostname-server     # deploy one host
colmena build                          # build and evaluate without applying
colmena push                           # copy closures without activating
```

Colmena builds each system closure locally, copies it to the target over SSH, and activates the new generation.

### Git hooks

Hooks are defined in `checks/git-hooks/default.nix` and run `nixfmt`, `deadnix`, and `statix`. The `statix.toml` file ignores `repeated_keys` and `.direnv`.

| Hook | Effect |
|------|--------|
| `nixfmt` | Formats staged `.nix` files. |
| `deadnix` | Removes dead code from staged `.nix` files. |
| `statix` | Lints staged `.nix` files. |

```bash
pre-commit run --all-files   # run the hooks manually
git commit                   # hooks run on the staged files
```

Entering the development shell installs the hooks in `.git/hooks`.

## Project structure

```
.
├── flake.nix                  # inputs, purr mkFlake call, and colmenaHive
├── .envrc                     # direnv: use flake
├── .gitignore
├── statix.toml
├── colmena/
│   └── colmenaHive/
│       ├── default.nix        # maps nixosConfigurations to Colmena nodes
│       └── deployments.nix    # deployment targets
├── checks/
│   └── git-hooks/
│       └── default.nix        # pre-commit hooks
├── shells/
│   └── default/
│       └── default.nix        # development shell with colmena
├── systems/
│   ├── aarch64-darwin/
│   │   └── hostname-mbp/
│   └── x86_64-linux/
│       ├── graphical/         # meta.nix declares an ISO image
│       ├── hostname-nixos/
│       ├── hostname-server/
│       ├── hostname-wsl/
│       ├── minimal/           # meta.nix declares an ISO image
│       └── minimal-no-zfs/    # meta.nix declares an ISO image
├── homes/
│   ├── aarch64-darwin/
│   │   └── nixos@hostname-mbp/
│   └── x86_64-linux/
│       ├── nixos@graphical/
│       ├── nixos@hostname-nixos/
│       ├── nixos@minimal/
│       ├── nixos@minimal-no-zfs/
│       ├── root@hostname-server/
│       └── root@hostname-wsl/
├── modules/
│   ├── nixos/
│   │   ├── secrets/
│   │   └── user/
│   ├── darwin/
│   │   ├── brew/
│   │   ├── secrets/
│   │   └── user/
│   └── home/
│       ├── home/
│       ├── secrets/
│       └── user/
└── lib/
    ├── host/
    │   ├── config/starship.toml
    │   └── default.nix        # host identity defaults
    ├── module/
    │   └── default.nix        # module helpers
    └── secrets/
        └── default.nix        # secrets settings
```

## Flake inputs

| Input | Source | Role |
|-------|--------|------|
| `nixpkgs` | `flakehub.com/f/NixOS/nixpkgs` | Package set |
| `purr` | `flakehub.com/f/nixcafe/purr` | Provides `mkFlake` |
| `git-hooks` | `flakehub.com/f/cachix/git-hooks.nix` | Pre-commit hook runner |
| `nixos-hardware` | `flakehub.com/f/nixos/nixos-hardware` | Hardware modules |
| `darwin` | `flakehub.com/f/nix-darwin/nix-darwin` | nix-darwin input |
| `home-manager` | `flakehub.com/f/nix-community/home-manager` | User environments |
| `cattery-modules` | `flakehub.com/f/nixcafe/cattery-modules` | cattery modules |
| `colmena` | `github:zhaofengli/colmena` | Colmena CLI and hive library |
| `my-secrets` | `github:nixcafe-develop/nix-secrets` | Secrets repository, `flake = false` |

## How it differs from nix-config

Both templates use purr, cattery-modules, and support NixOS, nix-darwin, home-manager, and image recipes. `colmena-config` adds the `colmena` input, the `colmenaHive` output, and `colmena/colmenaHive/deployments.nix` for remote targets.

## Useful commands

```bash
nix develop
nix flake show
nix flake check
nix fmt
nix build .#images.graphical.iso-installer
colmena apply --on hostname-server
```
