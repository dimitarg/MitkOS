# Zed settings shared between the local editor (gui module) and the remote
# server on cloudy (zed-server module).
#
# Zed does NOT propagate a client's local settings to a remote SSH host: "Both
# the local Zed and the server Zed read the project settings, but they are not
# aware of the other's main settings file." Language servers run on the host,
# so their configuration (which LSP to use, heap size, etc.) must be readable
# server-side. To avoid drift we keep that LSP-relevant config here and import
# it on both sides -- the same pattern as ../vscode-settings.nix.
#
# Only put settings here that the *remote* Zed needs (languages / lsp). Purely
# client-side UI settings (theme, keymap, fonts) belong in the gui module.
{
  languages = {
    Nix = {
      language_servers = [ "nixd" "!nil" ];
    };
  };

  # Enable the Metals HTTP server (localhost:5031) so client commands
  # such as the Metals Doctor work in Zed. The `-Dmetals.http=on` JVM
  # property is injected automatically by the Zed Metals extension; we
  # only need to tell Metals to route client commands through it.
  #
  # NOTE: setting `binary.arguments` below makes Zed use these args
  # directly instead of the extension's defaults, which disables Metals
  # DAP/debug support in Zed. We accept that trade-off in order to give
  # the Metals language server a large enough heap for very large Scala
  # projects (mirrors `metals.serverProperties` in vscode-settings.nix).
  # This is the Metals *LSP* server heap; the sbt build server's heap is
  # configured separately via the project's `.jvmopts` / `SBT_OPTS`.
  lsp = {
    metals = {
      binary = {
        arguments = [
          "-Xms2G"
          "-Xmx8G"
        ];
      };
      initialization_options = {
        isHttpEnabled = true;
      };
      # Metals user-configuration (mirrors vscode-settings.nix).
      settings = {
        # Prefer the build tool's own BSP server (sbt) over Bloop, so the
        # editor shares the same compilation state as the sbt CLI.
        defaultBspToBuildTool = true;
        # Start Metals' MCP server so Claude Code can connect to it.
        startMcpServer = true;
        mcpClient = "claude";
      };
    };
  };
}
