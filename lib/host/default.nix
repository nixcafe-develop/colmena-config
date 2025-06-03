{
  # default vars
  host = {
    # timezone and locale
    timezone = "America/New_York";
    defaultLocale = "en_US.UTF-8";
    # Your name
    name = "nixos";
    # Your real name (currently used as git name)
    realName = "NixOS";
    # Your email
    email = {
      address = "nixos@example.com";
      # smtp.host = "smtp.example.com";
      # imap.host = "imap.example.com";
    };
    gpg = {
      # If you want git to use gpg, you can fill in the key id here
      signKey = "";
      encryptKey = "";
    };
    # Fill in the key that all your hosts trust.
    # Note that they have large permissions and need to be saved offline.
    authorizedKeys.keys = [ ];
    # starship config, see: https://starship.rs/config/
    starship.settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };
}
