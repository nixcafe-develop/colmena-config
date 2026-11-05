{ inputs, ... }:
{
  # if you need to use secrets, set to true
  enable = false;
  # Import `my-secrets` in flake.nix
  # Here, enable and set the secret repository.
  # If you don’t need to use secrets, you can remove them yourself.
  secretsPath = "${inputs.my-secrets}";
}
