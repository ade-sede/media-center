{
  config,
  pkgs,
  ADMIN_EMAIL,
  SECRET_HTTP_PASSWORD,
  ...
}: let
  nginxHelpers = import ../lib/nginx-helpers.nix {};
  inherit (nginxHelpers) standardProxyHeaders plexProxyHeaders mkPublicLocation mkProtectedLocation;

  httpAuth = pkgs.runCommand "http-htpasswd" {} ''
    echo "admin:$(${pkgs.openssl}/bin/openssl passwd -apr1 '${SECRET_HTTP_PASSWORD}')" > $out
  '';
in {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "media.ade-sede.com" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = mkPublicLocation 5055 "/" standardProxyHeaders; # Jellyseerr
        locations."/jellyfin/" = mkPublicLocation 8096 "/" standardProxyHeaders;

        locations."/torrent/" = mkProtectedLocation "/torrent/" 8080 "/" "qBittorrent" httpAuth standardProxyHeaders;
        locations."/sonarr/" = mkProtectedLocation "/sonarr/" 8989 "/sonarr/" "Sonarr" httpAuth standardProxyHeaders;
        locations."/prowlarr/" = mkProtectedLocation "/prowlarr/" 9696 "/prowlarr/" "Prowlarr" httpAuth standardProxyHeaders;
        locations."/radarr/" = mkProtectedLocation "/radarr/" 7878 "/radarr/" "Radarr" httpAuth standardProxyHeaders;
        locations."/bazarr/" = mkProtectedLocation "/bazarr/" 6767 "/bazarr/" "Bazarr" httpAuth standardProxyHeaders;
        locations."/health/" = mkProtectedLocation "/health/" 5000 "/" "System Health" httpAuth standardProxyHeaders;
      };

      "plex.ade-sede.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = mkPublicLocation 32400 "/" plexProxyHeaders;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = ADMIN_EMAIL;
  };
}
