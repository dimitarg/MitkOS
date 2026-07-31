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
  # The package list is Metals' own, taken from the jdk.compiler half of the set
  # that scalameta/metals#8639 moved out of JavaPruneCompiler's defaults. mtags
  # currently only reaches api/file/parser/tree/util; the rest are carried so a
  # future Metals touching one more package cannot silently reintroduce the
  # hang. All twelve are verified to exist in jdk.compiler on this JDK (a bogus
  # one would make the JVM warn on every start).
  javacExports = map (p: "--add-exports jdk.compiler/com.sun.tools.javac.${p}=ALL-UNNAMED") [
    "api"
    "code"
    "comp"
    "file"
    "jvm"
    "main"
    "model"
    "parser"
    "processing"
    "resources"
    "tree"
    "util"
  ];

  # extraJavaOpts is read back through finalAttrs in the package's installPhase,
  # so extending it here lands the flags in the real JVM argument position --
  # ahead of `-cp ... scala.meta.metals.Main` -- for both the metals and
  # metals-mcp wrappers. Appending via makeWrapper --add-flags would instead put
  # them after the main class, where Metals would read them as its own
  # arguments, and JDK_JAVA_OPTIONS would leak the flags into every build tool
  # Metals spawns. Drop this once nixpkgs' metals ships the flags itself.
  metals = pkgs.metals.overrideAttrs (old: {
    extraJavaOpts = "${old.extraJavaOpts} ${builtins.concatStringsSep " " javacExports}";
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
