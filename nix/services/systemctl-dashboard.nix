{
  config,
  lib,
  pkgs,
  ...
}: let
  systemctl-dashboard-src = pkgs.fetchFromGitHub {
    owner = "ade-sede";
    repo = "systemctl-dashboard";
    rev = "main";
    sha256 = "sha256-8olmwmbgBzRnKgVpUfQ+PzM+OEeTg6B0QnzT/wZ9tDc=";
  };
in {
  systemd.services.systemctl-dashboard = {
    description = "Systemctl Dashboard";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "root";
      Group = "root";
      ExecStart = "${pkgs.python3}/bin/python3 ${systemctl-dashboard-src}/dashboard.py --port 5000 --host 127.0.0.1 --config-dir /var/lib/systemctl-dashboard --base-url /health/";
      Restart = "always";
      RestartSec = "10";
      StateDirectory = "systemctl-dashboard";
      StateDirectoryMode = "0755";
      WorkingDirectory = "${systemctl-dashboard-src}";
    };

    environment = {
      PATH = lib.mkForce "${pkgs.systemd}/bin:${pkgs.sudo}/bin:${pkgs.coreutils}/bin";
    };
  };
}
