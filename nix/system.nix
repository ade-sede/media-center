{
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "24.11";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["fuse"];

  time.timeZone = "UTC";

  services.journald.extraConfig = ''
    SystemMaxUse=150M
    SystemKeepFree=1G
    SystemMaxFileSize=15M
    SystemMaxFiles=10
    MaxRetentionSec=2week
  '';

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    sqlite
    juicefs
    fuse
    qbittorrent-nox
    jellyseerr
  ];
}
