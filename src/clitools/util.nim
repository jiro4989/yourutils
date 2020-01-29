import os, osproc
from strutils import join

import uuids

proc getArgsOrStdinLines*(args: seq[string]): seq[string] =
  result = args
  if result.len < 1:
    for line in stdin.lines:
      result.add(line)

proc editTmpFile*(srcs: seq[string]): (string, string) =
  let tmpfile = getTempDir() / $genUUID() & ".txt"
  defer: removeFile(tmpfile)
  let srcBody = srcs.join("\n")
  writeFile(tmpfile, srcBody)

  let editor = getEnv("EDITOR", "vi")
  discard execCmd(editor & " " & tmpfile)
  result = (srcBody, readFile(tmpfile))
