# Security Review: `aws-vpn` module

Reviewed 2026-07-27 on branch `playground/aws-vpn` (commit `978cc30`). The module
code is LLM-generated, so the review treated every external pin and the vendored
C patch as untrusted and verified them against independent sources.

**Bottom line: no high-confidence, exploitable vulnerability found.**

## Scope and method

- **Vendored patch authenticity** — `openvpn-v2.6.12-aws.patch` is
  **byte-identical** to upstream `aws-vpn-client/aws-vpn-client@master`
  (fetched independently from GitHub and diffed; the copy in the local nix
  store also matches the repo copy). No tampering, no additions.
- **Go wrapper supply chain** — `imgrant/aws-vpn-client` at the pinned rev
  `1e677b41` was downloaded independently and read in full (`main.go`,
  331 lines). Stdlib-only (`go.mod` has zero dependencies, so
  `vendorHash = null` is truthful). No network calls beyond the VPN flow, no
  telemetry, no shell interpolation: `xdg-open` and `sudo openvpn` are invoked
  via `exec.Command` argv arrays, and the attacker-influenceable SAML response
  is URL-escaped before being written to the `--auth-user-pass` file, so
  newline/config injection into the root-run OpenVPN is not possible.
- **C patch memory-safety audit** — unpacked the exact `openvpn-2.6.21` source
  from the nix store and swept every use of the resized macros
  (`BUF_SIZE_MAX`, `TLS_CHANNEL_BUF_SIZE`, `ERR_BUF_SIZE`, `USER_PASS_LEN`,
  `OPTION_PARM_SIZE`, `OPTION_LINE_SIZE`, management buffers), specifically
  hunting precedence bugs from the unparenthesized `#define X 1 << N` style.
  Verified the `memcpy` added to `key_method_2_write` writes into the 4-byte
  zero placeholder the function itself wrote at offset 0 (`buf_init(buf, 0)`
  means no headroom offset).
- **Shell wrappers** — `aws-vpn-connect` and `aws-vpn-update-resolved` are
  `writeShellApplication` (bash, `set -euo pipefail`, shellcheck-gated); all
  expansions are quoted; the temp profile comes from `mktemp` (0600).

## Vulnerabilities

None met the confidence bar (≥0.8 exploitability). Nothing in this module gives
a remote peer, the VPN endpoint, or another local user a code-execution or
privilege-escalation path that survives scrutiny: stage-2 root access is plain
interactive `sudo` (no sudoers rule is added), `script-security 2` only enables
the nix-store hooks appended to the user's own profile, and the wire-format
patch does not introduce out-of-bounds writes.

## Verified-benign latent defects (inherited verbatim from the upstream AWS patch)

Real C bugs the patch introduces, each of which lands safely. Listed because
they look alarming until traced:

1. `options.c:4612-4613` — `alloc_buf_gc(OPTION_PARM_SIZE + 16, …)` expands to
   `1 << (17 + 16)` = `1 << 33`, which is UB; GCC 15 folds it to **0**
   (compile-tested, warns `-Wshift-count-overflow`). Result: two zero-capacity
   buffers in `options_warning_safe_ml`. Not exploitable — `buf_printf`
   bounds-checks (`cap > 0` guard, verified in `buffer.c`), so the only effect
   is a silently degraded OCC options-mismatch diagnostic.
2. `error.c:273` — `m1[ERR_BUF_SIZE - 1]` expands to `m1[1 << 17]`, the
   midpoint of the 256 KB buffer rather than its last byte. In-bounds write;
   the null-termination it was meant to guarantee only matters on Windows.
3. `misc.c:528` — `USER_PASS_LEN - 1` expands to `1 << 16`, halving the
   auth-token base64 decode capacity. Under-, not over-sized: safe.

If the patch is ever touched, parenthesizing the three defines fixes all of
this.

## Below-threshold observations (design caveats, not flagged as vulns)

- **Loopback SAML listener (`127.0.0.1:35001`)** — inherent to the upstream
  design (AWS's own client does the same on 35001/8096-8115). On a multi-user
  machine, another local user could bind 35001 first and capture the
  browser-POSTed signed `SAMLResponse`, or POST garbage to trigger reconnect
  cycles. Actually converting a captured assertion into VPN access depends on
  AWS-side session binding that was not verified, and the target hosts are
  single-user, so this stays below the reporting bar.
- **Server-pushed DNS options are processed as root** by
  `update-systemd-resolved` via the appended `up`/`down` hooks — standard,
  widely deployed component; the pushing endpoint is CA-authenticated by the
  profile. No new trust boundary beyond what any OpenVPN+resolved setup
  accepts.
- `initialContactFindSAMLURL` will panic on a malformed `AUTH_FAILED` line
  (`parts[1]`/`parts[6]` unchecked) — crash only, DoS-class, excluded by
  review rules.
