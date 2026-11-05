# Nix Flake · Colmena Deployment

> purr · git-hooks · nixos · colmena · nix-flake

Nix flake template for NixOS configuration with Colmena deployment — extends [nix-config](https://github.com/nixcafe-develop/nix-config) with remote deployment, a `colmenaHive` output, and purr image recipes (ISO/VM/cloud) declared in each host's `meta.nix`.

Part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection (`nix flake init`-ready).

## Quick Start

### `nix flake init`

```bash
nix flake init -t "github:nixcafe/develop-templates#colmena-config" --refresh
```

Register an alias:
```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#colmena-config
```

> **Tip**: With [cattery-modules](https://github.com/nixcafe/cattery-modules), `beans` is pre-registered.

### Create from Template

```bash
gh repo create my-colmena-config --template nixcafe-develop/colmena-config --clone
```

### Enter the Dev Shell

```bash
direnv allow       # or: nix develop
```

## What's Inside

| Component | Purpose |
|-----------|---------|
| `nixosConfigurations` | NixOS system builds (`systems/`) |
| `darwinConfigurations` | macOS system builds (`systems/aarch64-darwin/`) |
| `homeConfigurations` | Standalone home-manager builds (`homes/`) |
| `colmenaHive` | Colmena deployment hive — remote apply to fleets |
| `colmena` | Colmena CLI for stateless remote deployment |
| `images` | ISO / VM / cloud images declared in host `meta.nix` |
| `formatter` | `nixfmt` for canonical formatting |
| `checks.git-hooks` | Pre-commit: nixfmt, deadnix, statix |
| `cattery-modules` | Pre-built NixOS / darwin / home-manager modules |
| Home auto-linking | `user@host` homes from `homes/` auto-injected into matching systems |

## Customizing

### 1. Set Your Host Identity

Edit `lib/host/default.nix`:

```nix
{
  name = "myhost";
  realName = "Jane Doe";
  email.address = "jane@example.com";
  timeZone = "America/New_York";
  authorizedKeys.keys = [ "ssh-ed25519 AAAAC3..." ];
}
```

### 2. Add a System

Create a directory under `systems/<arch>/<hostname>/` with a `default.nix`. The framework auto-discovers it. Example `systems/x86_64-linux/myhost/default.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
  ];
  networking.hostName = "myhost";
  system.stateVersion = "24.11";
}
```

Home-manager configurations in `homes/<arch>/<user>@<host>/` are auto-linked to matching systems.

Image recipes are normal `x86_64-linux` hosts with a `meta.nix`:

```nix
# systems/x86_64-linux/installer/meta.nix
{
  images = [ "iso-installer" ];
}
```

Build them with `nix build .#images.installer.iso-installer`. Image-only hosts are excluded from `nixosConfigurations` unless `deployable = true` is set in `meta.nix`.

### 3. Deploy with Colmena

Define deployment targets in `colmena/colmenaHive/deployments.nix`:

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

Common commands:

```bash
colmena apply              # deploy all hosts
colmena apply --on myhost  # deploy single host
colmena build              # build & evaluate without applying
colmena push               # push system closures without activating
```

Colmena builds each system's closure locally, copies it to the target via SSH, and activates the new generation — fast, parallel, and stateless.

### 4. Pre-commit Hooks

Git hooks (defined in `checks/git-hooks/default.nix`) run automatically on `git commit`:

| Hook | Effect |
|------|--------|
| `nixfmt` | Re-formats staged `.nix` files |
| `deadnix` | Strips dead code from staged `.nix` files |
| `statix` | Lints staged `.nix` files (ignores `repeated_keys`, `.direnv`) |

Manually run all hooks:

```bash
pre-commit run --all-files
```

## Project Structure

```
.
├── flake.nix                     # Flake entrypoint — purr + colmenaHive
├── statix.toml                   # Statix lint rules
├── .envrc                        # direnv: `use flake`
├── .gitignore
│
├── colmena/
│   └── colmenaHive/
│       ├── default.nix           # Hive builder — maps nixosConfigurations → colmena nodes
│       └── deployments.nix       # Target hosts, SSH addresses, ports
│
├── systems/                      # NixOS & darwin system definitions
│   ├── aarch64-darwin/
│   └── x86_64-linux/
│       ├── hostname-nixos/
│       ├── hostname-server/
│       ├── hostname-wsl/
│       └── <image-host>/meta.nix # Optional image recipes
│
├── homes/                        # Standalone home-manager configs (user@host)
│   ├── aarch64-darwin/
│   └── x86_64-linux/
│       ├── nixos@hostname-nixos/
│       ├── root@hostname-server/
│       └── root@hostname-wsl/
│
├── modules/                      # Custom NixOS / darwin / home-manager modules
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
│
├── lib/                          # Shared utilities
│   ├── host/
│   │   ├── config/               # starship.toml, etc.
│   │   └── default.nix           # Per-user identity defaults
│   ├── module/
│   │   └── default.nix           # System detection & module helpers
│   └── secrets/
│
├── shells/
│   └── default/
│       └── default.nix           # Dev shell: colmena, nixfmt, deadnix, statix
│
└── checks/
    └── git-hooks/
        └── default.nix           # Pre-commit hooks: nixfmt, deadnix, statix
```

## Flake Inputs

| Input | Role |
|-------|------|
| [purr](https://flakehub.com/f/nixcafe/purr) | Flake framework — standardises NixOS/darwin/home-manager wiring |
| [colmena](https://colmena.cli.rs) | Stateless NixOS remote deployment tool |
| [cattery-modules](https://flakehub.com/f/nixcafe/cattery-modules) | Reusable opinionated module collection |
| [home-manager](https://github.com/nix-community/home-manager) | User environment management |
| [nix-darwin](https://github.com/LnL7/nix-darwin) | macOS declarative configuration |
| [nixos-hardware](https://github.com/NixOS/nixos-hardware) | Hardware-specific NixOS modules |
| [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix) | Pre-commit hook automation |

## How It Differs from nix-config

| Feature | nix-config | colmena-config |
|---------|:----------:|:--------------:|
| `purr` flake framework | ✓ | ✓ |
| NixOS system builds | ✓ | ✓ |
| nix-darwin support | ✓ | ✓ |
| home-manager | ✓ | ✓ |
| cattery-modules | ✓ | ✓ |
| **Colmena remote deployment** | ✗ | ✓ |
| **`colmenaHive` output** | ✗ | ✓ |
| **Image recipes (`images`)** | ✓ | ✓ |
