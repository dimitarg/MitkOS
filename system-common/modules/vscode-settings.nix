{
  "files.watcherExclude" = {
    "**/.bloop" = true;
    "**/.metals" = true;
    "**/.ammonite" = true;
    "**/.direnv" = true;
  };
  "editor.tabSize" = 2;
  "editor.fontFamily" = "'JetBrainsMono Nerd Font'";
  "editor.fontLigatures" = true;
  "editor.renderWhitespace" = "all";

  "metals.suggestLatestUpgrade" = "off";
  "metals.startMcpServer" = true;
  "metals.mcpClient" = "claude";
  "metals.serverProperties" = [
    "-Xms2G"
    "-Xmx8G"
  ];
  "metals.defaultBspToBuildTool" = true;

  "update.mode" = "none";
  "workbench.enableExperiments" = false;

  "cSpell.userWords" = [
    "usecase"
    "usecases"
    "RDBMS"
    "Mailgun"
    "PosgtreSQL"
  ];
  "cSpell.language" = "en-GB";

  "github.copilot.enable" = {
    "*" = false;
    "plaintext" = false;
    "markdown" = false;
    "scminput" = false;
  };

  # https://github.com/nix-community/nixos-vscode-server/issues/82
  # TODO deduplicate, or find a better way
  # TODO this breaks reproducibility and consistency
  remote.SSH.defaultExtensions = [
    "bbenoist.nix"
    "scalameta.metals"
    "scala-lang.scala"
    "haskell.haskell"
    "rust-lang.rust-analyzer"
    "mkhl.direnv"
  ];
}
