{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./services/juicefs.nix
    ./services/plex.nix
    ./services/jellyfin.nix
    ./services/qbittorrent.nix
    ./services/sonarr.nix
    ./services/prowlarr.nix
    ./services/radarr.nix
    ./services/bazarr.nix
    ./services/jellyseerr.nix
    ./services/systemctl-dashboard.nix
    ./services/nginx.nix
  ];

  systemd.services.media-center = {
    description = "Media Center Master Service";
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    wants = ["plex.service" "jellyseerr.service" "jellyfin.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/echo 'Media Center services starting...'";
      ExecStop = "${pkgs.coreutils}/bin/echo 'Media Center services stopping...'";
    };
  };
}
