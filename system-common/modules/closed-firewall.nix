{
  # firewall enabled with no allowed ingress is the default, let's make it explicit here.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    allowPing = false;
  };
}