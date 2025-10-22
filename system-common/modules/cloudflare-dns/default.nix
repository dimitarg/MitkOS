{ lib, config, pkgs, osConfig, inputs, ... }:

{
  # Cloudflare DNS
  networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
  
  # OpenVPN defaults to using systemd-resolved to manage dns. Seems like the less painful route
  # This also enables DNS over TLS
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    dnsovertls = "true";
  };
}
