{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: let
  configHelpers = import ../lib/config-helpers.nix {inherit pkgs lib;};
in {
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${JUICE_FS_ROOT}/sonarr";
  };

  systemd.services.sonarr = {
    after = ["network.target" "juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    requires = ["juicefs-mount.service" "qbittorrent.service" "prowlarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = lib.mkAfter ''
      mkdir -p ${JUICE_FS_ROOT}/sonarr
      mkdir -p ${JUICE_FS_ROOT}/shows
      mkdir -p ${JUICE_FS_ROOT}/anime
      ${configHelpers.ensureConfigFromTemplate {
        template = "sonarr.config.xml.template";
        destination = "${JUICE_FS_ROOT}/sonarr/config.xml";
        substitutions = {
          PORT = "8989";
          URL_BASE = "/sonarr";
          INSTANCE_NAME = "Sonarr";
        };
        updates = {
          "<UrlBase>.*</UrlBase>" = "<UrlBase>/sonarr</UrlBase>";
        };
      }}
    '';
  };
}
