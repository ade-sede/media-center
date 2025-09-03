{...}: {
  standardProxyHeaders = ''
    proxy_buffering off;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';

  plexProxyHeaders = ''
    proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
    proxy_set_header X-Plex-Device $http_x_plex_device;
    proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
    proxy_set_header X-Plex-Platform $http_x_plex_platform;
    proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
    proxy_set_header X-Plex-Product $http_x_plex_product;
    proxy_set_header X-Plex-Token $http_x_plex_token;
    proxy_set_header X-Plex-Version $http_x_plex_version;
    proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
    proxy_set_header X-Plex-Provides $http_x_plex_provides;
    proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
    proxy_set_header X-Plex-Model $http_x_plex_model;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';

  mkPublicLocation = port: subpath: extraHeaders: {
    proxyPass = "http://127.0.0.1:${toString port}${subpath}";
    proxyWebsockets = true;
    extraConfig = extraHeaders;
  };

  mkProtectedLocation = path: port: subpath: serviceName: httpAuth: extraHeaders: {
    proxyPass = "http://127.0.0.1:${toString port}${subpath}";
    proxyWebsockets = true;
    basicAuth = "${serviceName} Access";
    basicAuthFile = "${httpAuth}";
    extraConfig =
      extraHeaders
      + (
        if path != "/"
        then "proxy_set_header X-Forwarded-Prefix ${path};\n"
        else ""
      );
  };
}
