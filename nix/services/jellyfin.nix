{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    dataDir = "${JUICE_FS_ROOT}/jellyfin";
    cacheDir = "${JUICE_FS_ROOT}/jellyfin-cache";
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  systemd.services.jellyfin = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    environment = {
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    };

    serviceConfig = {
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
      PrivateUsers = lib.mkForce false;
    };
  };
}
