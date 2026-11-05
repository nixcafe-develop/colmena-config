{
  # Image-only host: exposed as `images.minimal-no-zfs.iso-installer`
  # and excluded from `nixosConfigurations` by default.
  images = [ "iso-installer" ];
}
