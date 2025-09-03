{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: let
  configHelpers = import ../lib/config-helpers.nix {inherit pkgs lib;};
in {
  services.bazarr = {
    enable = true;
    openFirewall = true;
    user = "root";
    group = "root";
    dataDir = "${JUICE_FS_ROOT}/bazarr";
  };

  systemd.services.bazarr = {
    after = ["network.target" "juicefs-mount.service" "sonarr.service" "radarr.service"];
    requires = ["juicefs-mount.service" "sonarr.service" "radarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    preStart = lib.mkAfter ''
      mkdir -p ${JUICE_FS_ROOT}/bazarr
      ${configHelpers.ensureConfigFromTemplate {
        template = "bazarr.config.ini.template";
        destination = "${JUICE_FS_ROOT}/bazarr/config/config.ini";
        substitutions = {
          PORT = "6767";
          URL_BASE = "/bazarr";
        };
        updates = {
          "base_url = .*" = "base_url = /bazarr";
        };
        createDirs = true;
      }}
    '';
  };
}
