{ lib, config, pkgs, osConfig, inputs, ... }:

# Connect to AWS Client VPN endpoints that use SAML federated authentication
# (`auth-federate` in the downloaded .ovpn).
#
# The AWS-supplied client is an Ubuntu-only .NET app that installs into /opt,
# runs a root systemd service behind a private D-Bus, setcaps its GUI binary and
# rewrites /etc/resolv.conf out from under systemd-resolved. Rather than host
# that under an FHS env, we drive a patched OpenVPN directly. See ./README.md.
#
# Usage:
#   aws-vpn-connect ~/path/to/downloaded.ovpn
#
# Use the profile exactly as downloaded from the AWS console. The wrapper strips
# the directives that conflict with it (auth-federate, auth-retry, resolv-retry,
# remote) into a temporary copy, and aws-vpn-connect appends the DNS hooks.

let
  openvpn-aws = pkgs.callPackage ./openvpn-aws.nix { };
  aws-vpn-client = pkgs.callPackage ./aws-vpn-client.nix { inherit openvpn-aws; };

  # OpenVPN invokes up/down scripts with a minimal environment, and
  # update-systemd-resolved needs busctl and ip on PATH. Wrap it so it does not
  # depend on whatever sudo's secure_path happens to be.
  updateResolved = pkgs.writeShellApplication {
    name = "aws-vpn-update-resolved";
    runtimeInputs = [ pkgs.systemd pkgs.iproute2 ];
    text = ''
      exec ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved "$@"
    '';
  };

  # The Go wrapper builds the openvpn command line itself and offers no way to
  # pass extra directives, so we inject the DNS hooks into a copy of the profile
  # before handing it over. Without these, the endpoint's pushed nameservers are
  # negotiated and then silently discarded, and internal names do not resolve.
  aws-vpn-connect = pkgs.writeShellApplication {
    name = "aws-vpn-connect";
    runtimeInputs = [ aws-vpn-client pkgs.coreutils ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "usage: aws-vpn-connect <profile.ovpn>" >&2
        exit 2
      fi

      conf=$(mktemp -t aws-vpn-XXXXXXXX.ovpn)
      trap 'rm -f "$conf"' EXIT

      cat "$1" > "$conf"
      {
        printf '%s\n' ""
        printf '%s\n' "# appended by aws-vpn-connect"
        printf '%s\n' "script-security 2"
        printf '%s\n' "up ${updateResolved}/bin/aws-vpn-update-resolved"
        printf '%s\n' "down ${updateResolved}/bin/aws-vpn-update-resolved"
        printf '%s\n' "down-pre"
        printf '%s\n' "up-restart"
      } >> "$conf"

      exec aws-vpn-client -config "$conf"
    '';
  };
in
{
  config = lib.mkIf osConfig.gui.enable {

    environment.systemPackages = [
      aws-vpn-connect
      aws-vpn-client

      # Exposed under a distinct name for debugging a connection by hand. The
      # package's own binary is called `openvpn`, and installing it directly
      # would shadow stock OpenVPN on PATH with a build that cannot talk to
      # anything except AWS Client VPN. The wrapper does not rely on this; it
      # reaches the binary through a baked-in store path.
      (pkgs.runCommand "openvpn-aws-debug" { } ''
        mkdir -p $out/bin
        ln -s ${openvpn-aws}/bin/openvpn $out/bin/openvpn-aws
      '')
    ];
  };
}
