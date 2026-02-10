{
  # Prevent dhcpcd from interfering with Docker networking.
  # When dhcpcd detects Docker's virtual ethernet interfaces (veth*), it can
  # try to manage them and may delete the host's default route, making the
  # server unreachable from the network.
  networking.dhcpcd.denyInterfaces = [ "docker*" "veth*" ];
}
