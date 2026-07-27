{ openvpn }:

# AWS Client VPN endpoints using SAML federated auth (`auth-federate`) speak a
# dialect of the OpenVPN protocol that stock OpenVPN cannot handle: the SAML
# assertion is passed as the password, which is far larger than the wire format
# allows for. AWS never upstreamed this, so we carry their patch.
#
# The patch does two things:
#   - enlarges a pile of buffers (USER_PASS_LEN, OPTION_PARM_SIZE, ...)
#   - widens the string length prefixes in key_method_2_write from u16 to u32
#
# That second change is a *wire format* change, which is why this is a separate
# package rather than an override of `pkgs.openvpn`. This binary can only talk
# to AWS Client VPN endpoints; it is not a drop-in OpenVPN. Never feed it to
# openvpn3, NetworkManager or services.openvpn.
#
# Upstream patch: https://github.com/aws-vpn-client/aws-vpn-client
# It targets 2.6.12 but applies cleanly (offsets only) to nixpkgs' 2.6.x.
openvpn.overrideAttrs (old: {
  pname = "openvpn-aws";

  patches = (old.patches or [ ]) ++ [ ./openvpn-v2.6.12-aws.patch ];

  # The test suite exercises the stock wire format, which we have deliberately
  # broken above.
  doCheck = false;

  meta = old.meta // {
    description = "OpenVPN patched for AWS Client VPN SAML federated authentication";
  };
})
