{ lib, buildGoModule, src, openvpn-aws }:

# Drives the two-stage SAML handshake that AWS requires:
#
#   1. run openvpn with the magic password `ACS::35001`, which the endpoint
#      rejects with an AUTH_FAILED,CRV1 carrying a SAML redirect URL and a
#      session id
#   2. open that URL in a browser, catch the POSTed SAMLResponse on
#      127.0.0.1:35001, then re-run openvpn with `CRV1::<sid>::<response>`
#      as the password
#
# Stage 2 runs under sudo, since it needs to create the tun device and install
# routes. The browser is opened via xdg-open, so this is GUI hosts only.
#
# `src` is the `aws-vpn-client-src` flake input, pinned to an immutable rev; see
# the comment on that input in flake.nix for why it must not track a branch.
# We take the source only, and build it against our own nixpkgs with the 2.6.x
# patch, so we are not carrying the EOL OpenVPN 2.5.x its flake would pull in.
buildGoModule {
  pname = "aws-vpn-client";
  version = "0-unstable-2025-06-19";

  inherit src;

  # No third-party imports; stdlib only.
  vendorHash = null;

  # Bake in the patched openvpn so the wrapper works with no arguments beyond
  # --config. Still overridable via --openvpn.
  ldflags = [ "-X main.openVpnBinary=${openvpn-aws}/bin/openvpn" ];

  meta = {
    description = "SAML authentication wrapper for connecting to AWS Client VPN";
    homepage = "https://github.com/imgrant/aws-vpn-client";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "aws-vpn-client";
  };
}
