# AWS Client VPN (SAML)

Connects to AWS Client VPN endpoints that use SAML federated authentication.

```
aws-vpn-connect ~/work.ovpn
```

Use the `.ovpn` exactly as downloaded from the AWS console. A browser opens for
the IdP login; stage two runs `sudo openvpn`, so expect a password prompt.

## Why not the AWS-supplied client

AWS ships a `.deb` for Ubuntu 22.04/24.04/26.04 only. Running it here would mean
hosting a .NET GTK app under an FHS env, and it fights NixOS on every axis:

- `postinst` runs `setcap cap_net_bind_service+p` on the GUI binary — impossible
  in the Nix store, needs `security.wrappers`. It exists purely to trigger
  kernel LD_PRELOAD stripping, not for function (SAML uses ports 8096-8115).
- `postinst` generates `fipsmodule.cnf` *into the install directory*, which is
  read-only for us.
- `ACVC.GTK.Service` runs as root and checks that its D-Bus caller's
  `/proc/<pid>/exe` lives under `/opt/awsvpnclient`, so the real path must exist.
- It hardcodes `/usr/bin/dbus-daemon` and its own dbus config path.
- It rewrites `/etc/resolv.conf` directly and stashes `/etc/resolv.conf.ovpnsave`,
  which collides with systemd-resolved and the `cloudflare-dns` module.
- It reports telemetry via bundled CloudWatch/Pinpoint/Cognito SDKs.
- No auto-update on Linux, so it would need manual version bumps anyway.

Note that patching its binaries is not an option regardless: the service holds a
hardcoded SHA-256 allowlist over `acvc-openvpn`, `openssl`, `configure-dns`,
`fips.so`, `ld-musl-x86_64.so.1` and `openssl.cnf`, and refuses to start on a
mismatch (`Ovpn resources checksum validation failed`).

## Why a separate OpenVPN package

Stock OpenVPN cannot talk to a SAML endpoint: the SAML assertion is passed as
the password and vastly exceeds the wire format's limits. AWS's patch enlarges
the buffers *and* widens the `key_method_2_write` string length prefixes from
u16 to u32.

That last part is a wire format change, so `openvpn-aws` can only talk to AWS
Client VPN endpoints. It is deliberately **not** an override of `pkgs.openvpn`.
Never point `openvpn3`, NetworkManager or `services.openvpn` at it.

For the same reason it is installed under the name `openvpn-aws` rather than as
the package's own `openvpn`, which would shadow stock OpenVPN on `PATH`. It is
exposed only for debugging a connection by hand; `aws-vpn-connect` does not use
the `PATH` entry.

## DNS

`aws-vpn-connect` appends `up`/`down` hooks calling `update-systemd-resolved`,
otherwise the endpoint's pushed nameservers are negotiated and then discarded.

On hosts that also import `cloudflare-dns` (currently `nixos`), be aware that it
sets `DNSOverTLS = true`, `DNSSEC = true` and `Domains = [ "~." ]` globally. A
corporate resolver reached over the tunnel will generally speak plain DNS and
serve unsigned internal zones, so it will fail those global checks. If internal
names do not resolve once connected, that is the cause — relax `DNSOverTLS` to
`opportunistic`, or scope the strict settings per-link rather than globally.

## Updating

The patch is vendored (`openvpn-v2.6.12-aws.patch`) because upstream has already
been archived and moved once. It targets OpenVPN 2.6.12 but applies to nixpkgs'
2.6.x with line offsets only; if a future bump breaks it, re-fetch from
<https://github.com/aws-vpn-client/aws-vpn-client>.

The wrapper is pinned by commit in `aws-vpn-client.nix`. Upstream's own flake
pins nixpkgs 22.05 to get OpenVPN 2.5.6 — we deliberately ignore that and build
against our nixpkgs so we are not carrying an EOL OpenVPN.
