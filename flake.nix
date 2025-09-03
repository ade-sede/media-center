{
  description = "A media center setup for home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    JUICE_FS_ROOT = "/mnt/juice";
    ADMIN_EMAIL = "adrien.de.sede@gmail.com";

    # SECRETS - Fill these in but NEVER commit them
    SECRET_BUCKET_URL = "REPLACE_ME";
    SECRET_ACCESS_KEY = "REPLACE_ME";
    SECRET_SECRET_KEY = "REPLACE_ME";
    SECRET_HTTP_PASSWORD = "REPLACE_ME";
  in {
    nixosConfigurations.media-center = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit JUICE_FS_ROOT ADMIN_EMAIL SECRET_BUCKET_URL SECRET_ACCESS_KEY SECRET_SECRET_KEY SECRET_HTTP_PASSWORD;
      };
      modules = [
        ./hardware-configuration.nix
        ./nix/system.nix
        ./nix/network.nix
        ./nix/users.nix
        ./nix/media-center.nix
      ];
    };
  };
}
