# Global Zed tasks for Scala development, shared between the local editor (gui
# module) and the remote host (zed-server module). Written to
# ~/.config/zed/tasks.json; tasks are reachable from the command palette via
# `task: spawn`. A per-project .zed/tasks.json, if present, takes precedence.
#
# A task tagged "scala-test" also gets a run button in the editor gutter next
# to test classes -- this is independent of the Metals DAP, so it works as a
# quick "run this test file" regardless of the debugger setup. `$ZED_STEM` is
# the open file's name without extension (e.g. FooSpec -> testOnly *FooSpec*).
[
  {
    label = "Scala: test current file";
    command = "sbt 'testOnly *$ZED_STEM'";
    args = [ "testOnly *$ZED_STEM*" ];
    reveal = "no_focus";
    tags = [ "scala-test" ];
  }
]
