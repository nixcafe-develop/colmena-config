# NixOS Configuration with Colmena Deployment

This repository contains a NixOS configuration that supports deployment using [Colmena](https://colmena.cli.rs/), a NixOS deployment tool.

## Project Structure

```
.
├── colmena/              # Colmena deployment configuration
│   └── colmenaHive/     # Colmena hive configuration
├── systems/             # System-specific configurations
│   └── x86_64-linux/    # x86_64 Linux system configurations
├── modules/             # NixOS modules
├── homes/              # Home-manager configurations
├── lib/                # Utility functions and common configurations
├── shells/             # Development shell configurations
└── checks/             # System checks and validations
```

## Configuration

### Host Configuration

The main host configuration is located at `./lib/host/default.nix`:

```nix
{
  # default vars
  host = {
    # Your name
    name = "example";
    # Your nickname (currently used as git name)
    nickname = "example";
    # Your email
    email = "demo@example.com";
    # If you want git to use gpg, you can fill in the key id here
    signKey = "";
    # Fill in the key that all your hosts trust. 
    # Note that they have large permissions and need to be saved offline.
    authorizedKeys.keys = [ ];
    # starship config, see: https://starship.rs/config/
    starship.settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };
}
```

## Colmena Deployment

This project uses Colmena for deploying NixOS configurations to remote machines. The Colmena configuration is located in `colmena/colmenaHive/`.

### Prerequisites

- Target systems must have NixOS already installed
- SSH access to target machines
- Proper network connectivity between deployment machine and targets

### Deployment Configuration

To configure deployments, modify `colmena/colmenaHive/deployments.nix`. Here's an example:

```nix
{
  "hostname" = {
    deployment = {
      targetHost = "192.168.1.100";  # Target machine IP
      targetUser = "root";           # SSH user
      targetPort = 22;
    };
  };
}
```

### Using Colmena

The project includes Colmena in its development shell. You can use it in two ways:

1. Using Nix shell:
```bash
nix develop
colmena <command>
```

2. Using direnv (recommended):
```bash
direnv allow
colmena <command>
```

### Common Colmena Commands

- Deploy to all hosts:
```bash
colmena apply
```

- Deploy to specific host:
```bash
colmena apply --on hostname
```

- Check configuration without deploying:
```bash
colmena build
```

### System Configuration

To modify system configurations:

1. Navigate to `systems/x86_64-linux/`
2. Create or modify host-specific configurations
3. The configurations will be automatically picked up by Colmena

## Development

The project uses direnv for development environment management. Simply run:

```bash
direnv allow
```

This will set up the development environment with all necessary tools, including Colmena.
