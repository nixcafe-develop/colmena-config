{ lib, ... }:
{
  image.baseName = lib.mkForce "nixos-minimal-new-kernel";

  # `iso-installer` adds wireless support that
  # is incompatible with networkmanager.
  networking.wireless.enable = lib.mkForce false;

  cattery = {
    user = {
      name = "nixos"; # use nixos as default user
      initialHashedPassword = "";
    };
    system.boot.kernel.useLatestZfsCompatible = true;
    room.general.enable = true;
  };

  system.stateVersion = "25.11";
}
