{
  services.systemctl-dashboard = {
    enable = true;
    port = 5000;
    host = "127.0.0.1";
    baseUrl = "/health/";
    user = "root";
    group = "root";
  };
}
