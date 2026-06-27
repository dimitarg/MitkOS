{ ... }:
# System-side counterpart of ./home.nix for Zed SSH remote development.
#
# Some Zed extensions ship a prebuilt native helper that runs on the remote
# host -- e.g. the `java` extension's `java-lsp-proxy` -- as a generic,
# dynamically-linked Linux binary. NixOS can't run those out of the box
# (https://nix.dev/permalink/stub-ld). nix-ld provides a stub dynamic loader so
# the binaries Zed downloads into ~/.local/share/zed work without patching.
#
# If a specific downloaded binary still fails to find a library, add it to
# `programs.nix-ld.libraries`.
{
  programs.nix-ld.enable = true;
}
