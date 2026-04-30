{ lib, config, pkgs, osConfig, inputs, ... }:

{
  # Cloudflare DNS
  networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  
  # OpenVPN defaults to using systemd-resolved to manage dns. Seems like the less painful route
  # This also enables DNS over TLS
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = "true";
        DNSOverTLS = "true";
        Domains =  [ "~." ];
        FallbackDNS = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
      };
    };
  };
}
