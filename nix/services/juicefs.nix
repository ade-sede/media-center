{
  config,
  pkgs,
  JUICE_FS_ROOT,
  SECRET_BUCKET_URL,
  SECRET_ACCESS_KEY,
  SECRET_SECRET_KEY,
  ...
}: let
  juicefs-setup-script = pkgs.writeShellScript "juicefs-setup" ''
    ${pkgs.coreutils}/bin/mkdir -p /etc/juice
    ${pkgs.coreutils}/bin/mkdir -p ${JUICE_FS_ROOT}
  '';
  juicefs-mount-script = pkgs.writeShellScript "juicefs-mount" ''
    ${pkgs.juicefs}/bin/juicefs mount sqlite3:///etc/juice/metadata.db ${JUICE_FS_ROOT} \
      --background \
      --cache-size 10240 \
      --free-space-ratio 0.2
  '';
in {
  systemd.services.juicefs-setup = {
    description = "Setup dependencies for a JuiceFS filesystem";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      RemainAfterExit = true;
      ExecStartPre = [
        "${juicefs-setup-script}"
        "${pkgs.coreutils}/bin/touch /etc/juice/metadata.db"
      ];
    };
    script = ''
      if ! ${pkgs.juicefs}/bin/juicefs status "sqlite3:///etc/juice/metadata.db" 2>/dev/null; then
        ${pkgs.juicefs}/bin/juicefs format \
          --storage scw \
          --bucket "${SECRET_BUCKET_URL}" \
          --access-key "${SECRET_ACCESS_KEY}" \
          --secret-key "${SECRET_SECRET_KEY}" \
          "sqlite3:///etc/juice/metadata.db" \
          media-center
      fi
    '';
  };

  systemd.services.juicefs-mount = {
    description = "Mount JuiceFS filesystem";
    after = ["juicefs-setup.service"];
    requires = ["juicefs-setup.service"];
    serviceConfig = {
      Type = "forking";
      User = "root";
      Group = "root";
      Environment = "PATH=/run/wrappers/bin:${pkgs.coreutils}/bin:${pkgs.util-linux}/bin";
      ExecStart = "${juicefs-mount-script}";
      ExecStop = "${pkgs.juicefs}/bin/juicefs umount ${JUICE_FS_ROOT}";
      Restart = "always";
      RestartSec = "5";
    };
  };
}
