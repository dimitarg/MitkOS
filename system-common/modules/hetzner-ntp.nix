{
  # Use Hetzner's own NTP servers instead of the default *.nixos.pool.ntp.org.
  #
  # The Hetzner Robot firewall is stateless: outbound UDP leaves fine, but a reply
  # only gets back in if an incoming rule names it. TCP is covered by the template's
  # ACK-flag rule, and Hetzner's own service addresses are exempt, but everything
  # else UDP is dropped at the switch. So the NixOS pool is unreachable from a
  # Hetzner box — timesyncd times out on every poll and the clock free-runs.
  #
  # Don't "fix" this with an incoming `udp sport 123` rule in Robot: each direction
  # has an implicit deny at the end, so editing the rule list is an easy way to lock
  # yourself out of the machine.
  #
  # Same pattern as nixpkgs' own amazon-image.nix / google-compute-config.nix, which
  # point at the provider's time service for the same reason.
  networking.timeServers = [
    "ntp1.hetzner.de"
    "ntp2.hetzner.de"
    "ntp3.hetzner.de"
  ];
}
