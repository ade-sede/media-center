{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: let
  plexPackage = pkgs.plex.override {
    plexRaw = pkgs.plexRaw;
  };
in {
  environment.systemPackages = [
    plexPackage
  ];

  systemd.services.plex = {
    enable = true;
    description = "Plex Media Server";
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${plexPackage}/bin/plexmediaserver";
      KillSignal = "SIGQUIT";
      PIDFile = "${JUICE_FS_ROOT}/plex/Plex Media Server/plexmediaserver.pid";
      Restart = "on-failure";
    };

    environment = {
      PLEX_DATADIR = "${JUICE_FS_ROOT}/plex";
      LD_LIBRARY_PATH = "/run/opengl-driver/lib";
      PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS = "6";
      PLEX_MEDIA_SERVER_TMPDIR = "/tmp";
      PLEX_MEDIA_SERVER_USE_SYSLOG = "true";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      ADVERTISE_IP = "https://plex.ade-sede.com:443/";
    };
  };

  networking.firewall.allowedTCPPorts = [32400];
}
