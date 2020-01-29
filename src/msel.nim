import os, osproc, strutils, logging
import uuids
import clitools/util

const
  version = """msel version 1.0.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/mutils"""

proc strdiff(srcs, dsts: seq[string]): seq[string] =
  if srcs.len != dsts.len:
    warn "srcs.len doesn't equal dsts.len"
    return

  for i, src in srcs:
    let dst = dsts[i]
    if src != dst:
      result.add(src)

proc msel(srcs: seq[string]): int =
  addHandler(newConsoleLogger(lvlInfo, fmtStr = verboseFmtStr, useStderr = true))

  let srcs = getArgsOrStdinLines(srcs)
  let (srcBody, dstBody) = editTmpFile(srcs)
  if srcBody == dstBody:
    info "not edited"
    return

  let dsts = dstBody.strip.split("\n")
  for dsts in strdiff(srcs, dsts):
    echo dsts

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(msel)
