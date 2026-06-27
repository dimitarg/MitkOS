# Global Zed debug configurations for Scala/Metals, shared between the local
# editor (gui module) and the remote host (zed-server module). Written to
# ~/.config/zed/debug.json, whose entries Zed merges into every workspace's
# "New Debug Session" dialog (reached via `debugger: start` / F4). A per-project
# .zed/debug.json, if present, takes precedence.
#
# Metals never auto-populates Scala test targets into the debug modal, so we
# declare reusable ones here. `request = "launch"` is used for both running and
# debugging -- set a breakpoint first to debug. `path = "$ZED_FILE"` makes the
# config act on whatever test file is currently open.
[
  {
    label = "Scala: test current file";
    adapter = "Metals";
    request = "launch";
    path = "$ZED_FILE";
    runType = "testFile";
  }
  {
    label = "Scala: test all in module";
    adapter = "Metals";
    request = "launch";
    path = "$ZED_FILE";
    runType = "testTarget";
  }
]
