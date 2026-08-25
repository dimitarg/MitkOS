# Language servers used by Zed, shared between the local editor (gui module)
# and the remote host (zed-server module) so the set stays in sync and is not
# duplicated.
#
# On NixOS the LSP binaries Zed would otherwise download into
# ~/.local/share/zed/languages won't run, so we provide them from nixpkgs on
# PATH instead -- on the client for local editing, and on the remote host where
# the servers actually run during SSH remote development.
#
# Add future Zed language servers here (and, if they need configuration, to
# ./zed-settings.nix).
pkgs:
let
  # Metals indexes Java sources with scala.meta.internal.mtags.JavacMtags, which
  # calls into jdk.compiler internals. JDK 9+ does not export those packages to
  # the unnamed module, and nixpkgs launches Metals as a bare
  # `java <extraJavaOpts> -cp ... scala.meta.metals.Main` with no --add-exports,
  # so every Java source Metals touches throws:
  #
  #   java.lang.IllegalAccessError: class scala.meta.internal.mtags.JavacMtags
  #   (in unnamed module) cannot access class com.sun.tools.javac.util.Context
  #   (in module jdk.compiler) because module jdk.compiler does not export
  #   com.sun.tools.javac.util to unnamed module
  #
  # Raised from Indexer.indexWorkspaceSources it escapes a parallel-collection
  # worker thread and kills the indexing task outright: Metals never logs
  # "indexed workspace" and the editor sits at "Indexing..." forever, with no
  # cross-project navigation. Raised from the dependency-source path it is
  # survivable, but silently drops those Java symbols. Only projects whose own
  # sources or dependency source jars contain .java files are affected, which is
  # why some Scala projects here index fine and others hang.
  #
  # Upstream: scalameta/metals#8735 (open, "Indexing never finishes (since
  # 1.6.8)") and the older scalameta/metals#8144. Metals 1.6.8 replaced the
  # QDox-based Java indexer with this javac-based one, which is why the hang
  # arrived with the nixpkgs 1.6.7 -> 1.6.8 bump (NixOS/nixpkgs#545024, merged
  # 2026-07-24). No released Metals carries a fix and nixpkgs has no issue open
  # for it, so we supply the flags ourselves.
  #
  # We do not have to guess the flags, or vendor a copy of them. Metals ships the
  # exact list it requires as META-INF/metals-required-vm-options.txt inside
  # metals_2.13-<version>.jar, added by scalameta/metals#8357 -- the same PR that
  # swapped QDox for the javac indexer.
  #
  # No code on the Metals classpath reads that resource; per the maintainer in
  # scalameta/metals#8735 it is the editor integration's job to apply it, and
  # metals-vscode duly does (src/readRequiredVmOptions.ts opens the first jar of
  # the classpath and parses the file). metals-zed does not: it resolves `metals`
  # off PATH and hands that opaque binary to a proxy, so it never sees a
  # classpath to read the resource from, nor a java command line to add flags to.
  # Hence the hang here but not in VS Code.
  #
  # Applying the flags in the launcher instead is a better fit for this setup
  # anyway: it covers metals-mcp and any other client, not just Zed.
  #
  # So read the list straight out of the jar at build time. Vendoring it here
  # would silently rot the next time Metals needs one more package -- exactly the
  # failure mode we are fixing -- whereas this tracks whatever the packaged
  # version declares. Currently twelve --add-exports plus four --add-opens.
  # extraJavaOpts is where the flags go: the package interpolates it into the
  # real JVM argument position -- ahead of `-cp ... scala.meta.metals.Main` --
  # for both the metals and metals-mcp wrappers. Appending via makeWrapper
  # --add-flags would instead put them after the main class, where Metals would
  # read them as its own arguments, and JDK_JAVA_OPTIONS would leak the flags
  # into every build tool Metals spawns. Drop this whole override once metals-zed
  # reads the resource the way metals-vscode does, or once nixpkgs applies it in
  # the package.
  metals =
    let
      inherit (pkgs.lib) assertMsg hasInfix;

      # Where the jar lives. NixOS/nixpkgs#552786 moved deps under passthru to
      # stop it leaking into the build environment; the bare `metals.deps` of the
      # previous override no longer resolves.
      depsJar = "${pkgs.metals.passthru.deps}/share/java/metals_2.13-*.jar";

      # That same PR turned extraJavaOpts from a derivation attribute into a
      # package argument, defaulted in the function head. callPackage does not
      # pass it (nothing named extraJavaOpts exists in pkgs), so it is absent
      # from the original argument set and neither `override` nor `overrideAttrs`
      # can read the previous value back -- extending it means restating the
      # upstream default. Restating it silently is how it goes stale, so check it
      # against the installPhase the package actually ships and fail evaluation
      # if upstream has retuned the JVM since.
      upstreamJavaOpts = "-XX:+UseG1GC -XX:+UseStringDeduplication -Xss4m -Xms100m";

      # The $(...) is expanded by bash, not Nix: this string is interpolated into
      # a double-quoted shell argument in the package's installPhase, so the
      # substitution runs there. Doing it inline rather than via a variable set in
      # an earlier phase keeps it independent of which hooks the package calls.
      requiredVmOpts = ''$(unzip -p ${depsJar} META-INF/metals-required-vm-options.txt | tr '\n' ' ')'';
    in
    assert assertMsg (hasInfix ''--add-flags "${upstreamJavaOpts} -cp'' pkgs.metals.installPhase) ''
      metals: the packaged extraJavaOpts default is no longer
        ${upstreamJavaOpts}
      Copy the new default out of the metals package into upstreamJavaOpts in
      zed-language-servers.nix, or drop this override if the package now applies
      the required VM options itself.
    '';
    (pkgs.metals.override {
      extraJavaOpts = "${upstreamJavaOpts} ${requiredVmOpts}";
    }).overrideAttrs
      (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.unzip ];

        # A renamed or dropped resource must fail the rebuild loudly rather than
        # quietly produce a wrapper with no flags -- `unzip -p` on a missing
        # member succeeds with empty output -- which is the exact regression this
        # override exists to prevent. preInstall fires since #552786 taught the
        # custom installPhase to call runHook; before that it was silently
        # skipped and the guard had to sit in preBuild.
        preInstall = (old.preInstall or "") + ''
          if ! unzip -p ${depsJar} \
                 META-INF/metals-required-vm-options.txt 2>/dev/null | grep -q .; then
            echo "metals: META-INF/metals-required-vm-options.txt is missing or empty." >&2
            echo "Check whether a launcher now applies these flags itself; if so, drop" >&2
            echo "this override in zed-language-servers.nix." >&2
            exit 1
          fi
        '';
      });
in
[
  # nix language server
  pkgs.nixd
  # scala language server
  metals
  # java language server (Eclipse JDT LS). Used by the Zed `java` extension for
  # reading Java dependency sources from Scala projects. Note: jdtls only
  # understands Maven/Gradle/standalone Java projects, so it does not know an
  # sbt project's classpath -- expect basic Java features (syntax, hover,
  # outline, JDK navigation) rather than full cross-dependency navigation.
  pkgs.jdt-language-server
]
