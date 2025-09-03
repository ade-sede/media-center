{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: let
  configHelpers = import ../lib/config-helpers.nix {inherit pkgs lib;};
in {
  environment.systemPackages = [
    pkgs.qbittorrent-nox
  ];

  systemd.services.qbittorrent = {
    description = "qBittorrent-nox BitTorrent client";
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = ''
      mkdir -p /root/.config/qBittorrent
      mkdir -p ${JUICE_FS_ROOT}/downloads
      ${configHelpers.createConfigFromTemplate {
        template = "qbittorrent.conf.template";
        destination = "/root/.config/qBittorrent/qBittorrent.conf";
        substitutions = {
          WEBUI_PORT = "8080";
          USERNAME = "ade-sede";
          DEFAULT_DOWNLOAD_DIR = "${JUICE_FS_ROOT}/downloads";
        };
        createDirs = false;
      }}
    '';

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --confirm-legal-notice --webui-port=8080 --save-path=${JUICE_FS_ROOT}/downloads";
      Restart = "on-failure";
      RestartSec = "5s";
      WorkingDirectory = "/root";
      NoNewPrivileges = true;
    };
  };

  networking.firewall.allowedTCPPorts = [8080];
}
