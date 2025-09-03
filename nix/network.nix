{
  config,
  pkgs,
  ...
}: {
  networking.hostName = "media-center";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    settings.PasswordAuthentication = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];
  };
}
