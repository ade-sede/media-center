{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: {
  services.jellyseerr = {
    enable = true;
    port = 5055;
    openFirewall = true;
    package = pkgs.jellyseerr;
  };

  systemd.services.jellyseerr-setup = {
    before = ["jellyseerr.service"];
    requiredBy = ["jellyseerr.service"];
    after = ["juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    script = ''
      mkdir -p "${JUICE_FS_ROOT}/jellyseerr"
      chmod 755 "${JUICE_FS_ROOT}/jellyseerr"
      ln -sf "${JUICE_FS_ROOT}/jellyseerr" /var/lib/jellyseerr/data || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };
  };

  systemd.services.jellyseerr = {
    after = ["network.target" "juicefs-mount.service" "jellyseerr-setup.service"];
    requires = ["juicefs-mount.service" "jellyseerr-setup.service"];
    wants = ["qbittorrent.service" "prowlarr.service" "sonarr.service" "radarr.service" "bazarr.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];
    serviceConfig = {
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
      PrivateUsers = lib.mkForce false;
    };
  };
}
