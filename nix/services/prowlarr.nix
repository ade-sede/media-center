{
  config,
  pkgs,
  lib,
  JUICE_FS_ROOT,
  ...
}: {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 9696;
        urlbase = "/prowlarr";
        bindaddress = "*";
      };
      update = {
        mechanism = "external";
        automatically = false;
      };
      log = {
        analyticsEnabled = false;
      };
    };
  };

  systemd.services.prowlarr = {
    after = ["network.target" "juicefs-mount.service"];
    requires = ["juicefs-mount.service"];
    bindsTo = ["juicefs-mount.service"];
    partOf = ["media-center.service"];

    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "root";
      Group = "root";
      StateDirectory = lib.mkForce "prowlarr";
      ExecStart = lib.mkForce "${lib.getExe config.services.prowlarr.package} -nobrowser -data=${JUICE_FS_ROOT}/prowlarr";
    };

    preStart = lib.mkAfter ''
      mkdir -p ${JUICE_FS_ROOT}/prowlarr
    '';
  };
}
