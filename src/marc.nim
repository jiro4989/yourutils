import os, osproc, strutils, logging
from sequtils import mapIt

import uuids
import clitools/util

const
  version = """marc version 1.0.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/mutils"""

proc archive(srcs, dsts: seq[string]): seq[string] =
  if srcs.len != dsts.len:
    warn "srcs.len doesn't equal dsts.len"
    return

  for i, src in srcs:
    let dst = dsts[i]
    if src == dst:
      continue

    if existsFile(src):
      # copy file to dir/base
      let (_, name, ext) = splitFile(dst)
      case ext
      of ".tar.gz":
        # FIXME:
        let cmd = "tar czf " & dst & " " & src
        discard execCmd(cmd)
      of ".gz":
        let cmd = "gzip " & src
        discard execCmd(cmd)
      else:
        warn ext & " is not supported"
        continue
      result.add(dst)
    else:
      let msg = src & " doesn't exist"
      warn msg

proc marc(srcs: seq[string]): int =
  addHandler(newConsoleLogger(lvlInfo, fmtStr = verboseFmtStr, useStderr = true))

  let srcs = getArgsOrStdinLines(srcs)
  let (srcBody, dstBody) = editTmpFile(srcs)
  if srcBody == dstBody:
    info "not edited"
    return

  let dsts = dstBody.strip.split("\n").mapIt(it.strip)
  for dsts in archive(srcs, dsts):
    echo dsts

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(marc)
