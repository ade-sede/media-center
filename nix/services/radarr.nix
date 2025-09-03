{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: let
  configHelpers = import ../lib/config-helpers.nix {inherit pkgs lib;};
in {
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${JUICE_FS_ROOT}/radarr";
  };

  systemd.services.radarr = {
    after = ["network.target" "juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    requires = ["juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = lib.mkAfter ''
      mkdir -p ${JUICE_FS_ROOT}/radarr
      mkdir -p ${JUICE_FS_ROOT}/movies
      ${configHelpers.ensureConfigFromTemplate {
        template = "radarr.config.xml.template";
        destination = "${JUICE_FS_ROOT}/radarr/config.xml";
        substitutions = {
          PORT = "7878";
          URL_BASE = "/radarr";
          INSTANCE_NAME = "Radarr";
        };
        updates = {
          "<UrlBase>.*</UrlBase>" = "<UrlBase>/radarr</UrlBase>";
        };
      }}
    '';
  };
}
