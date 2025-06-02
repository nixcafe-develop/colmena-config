{
  # If you have hardware.nix, please copy and import it.
  # You can use `nixos-generate-config` to generate
  # path: /etc/nixos/hardware-configuration.nix
  # imports = [ ./hardware.nix ];

  cattery = {
    user.name = "root"; # use root as default user
    room.server.enable = true;

    # Convenient to use vscode to connect server development on the host
    # services.vscode-server.enable = true;

    system.boot.kernel.useIpForward = true;
  };

  # close firewall
  # networking.firewall.enable = false;

  system.stateVersion = "25.11";
}
