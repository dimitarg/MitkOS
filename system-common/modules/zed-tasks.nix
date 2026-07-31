# Global Zed tasks for Scala development, shared between the local editor (gui
# module) and the remote host (zed-server module). Written to
# ~/.config/zed/tasks.json; tasks are reachable from the command palette via
# `task: spawn`. A per-project .zed/tasks.json, if present, takes precedence.
#
# A task tagged "scala-test" also gets a run button in the editor gutter next
# to test classes -- this is independent of the Metals DAP, so it works as a
# quick "run this test file" regardless of the debugger setup. `$ZED_STEM` is
# the open file's name without extension (e.g. FooSpec -> testOnly *FooSpec*).
#
# `sbt --client` is used (not plain `sbt`) so the task attaches to the running
# sbt server -- the same one Metals' BSP keeps warm -- instead of cold-starting
# a fresh sbt JVM each run. This is the only way to get warm execution under SSH
# remoting, since Metals' own DAP test runner does not work on remote hosts
# (zed#33835: extension debug adapters aren't registered remotely).
[
  {
    label = "Scala: test current file";
    command = "sbt --client 'testOnly *$ZED_STEM'";
    reveal = "no_focus";
    tags = [ "scala-test" ];
  }
  {
    # Zed's LSP Logs pane stays empty for Metals on a remote project: Metals
    # writes nothing to stderr (it redirects its own System.err into
    # .metals/metals.log) and ships its log over LSP as window/logMessage
    # instead, which Zed's remote forwarding does not surface. Servers that do
    # write to stderr, such as nixd and jdtls, show up there normally. Opening
    # the same project locally shows the Metals log, which is what pins this to
    # the remote path. So read Metals' own file, on the host where it runs.
    #
    # -F, not -f: Metals recreates metals.log on restart and after a .metals
    # wipe, and -F re-opens by name instead of holding the deleted inode.
    label = "Metals: tail log";
    command = ''tail -F -n 200 "$ZED_WORKTREE_ROOT/.metals/metals.log"'';
  }
]
