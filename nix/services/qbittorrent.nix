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

            PROXY_LIST_FILE="/root/nixos/assets/proxy-list.txt"

            if [[ ! -f "$PROXY_LIST_FILE" ]]; then
              echo "ERROR: Proxy list file not found at $PROXY_LIST_FILE" >&2
              exit 1
            fi

            if [[ ! -s "$PROXY_LIST_FILE" ]]; then
              echo "ERROR: Proxy list file is empty at $PROXY_LIST_FILE" >&2
              exit 1
            fi

            PROXY_COUNT=$(${pkgs.coreutils}/bin/wc -l < "$PROXY_LIST_FILE")
            if [[ $PROXY_COUNT -eq 0 ]]; then
              echo "ERROR: No proxies found in $PROXY_LIST_FILE" >&2
              exit 1
            fi

            RANDOM_LINE=$((RANDOM % PROXY_COUNT + 1))
            SELECTED_PROXY=$(${pkgs.gnused}/bin/sed -n "''${RANDOM_LINE}p" "$PROXY_LIST_FILE")

            if [[ ! "$SELECTED_PROXY" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
              echo "ERROR: Invalid proxy format '$SELECTED_PROXY' in $PROXY_LIST_FILE (expected IP:PORT)" >&2
              exit 1
            fi

            SELECTED_PROXY_HOST="''${SELECTED_PROXY%:*}"
            SELECTED_PROXY_PORT="''${SELECTED_PROXY#*:}"

            echo "Selected proxy: $SELECTED_PROXY"

            # Create qBittorrent config with runtime proxy values
            cat > /root/.config/qBittorrent/qBittorrent.conf << EOF
      [BitTorrent]
      Session\\QueueingSystemEnabled=true

      [LegalNotice]
      Accepted=true

      [Meta]
      MigrationVersion=8

      [Network]
      Cookies=@Invalid()
      Proxy\\Type=2
      Proxy\\IP=$SELECTED_PROXY_HOST
      Proxy\\Port=$SELECTED_PROXY_PORT
      Proxy\\Username=
      Proxy\\Password=
      Proxy\\OnlyForTorrents=true

      [Preferences]
      WebUI\\Enabled=true
      WebUI\\LocalHostAuth=false
      WebUI\\Port=8080
      WebUI\\Username=admin

      Downloads\\SavePath=${JUICE_FS_ROOT}/downloads
      General\\UseRandomPort=true
      EOF
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
