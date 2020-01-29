import os, osproc, strutils, logging
from sequtils import mapIt
import uuids
import clitools/util

const
  version = """mcp version 1.0.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/mutils"""

proc copyFileAndDir(srcs, dsts: seq[string]): seq[string] =
  if srcs.len != dsts.len:
    warn "srcs.len doesn't equal dsts.len"
    return

  for i, src in srcs:
    let dst = dsts[i]
    if existsFile(src):
      # copy file to dir/base
      if existsDir(dst):
        let (_, name, ext) = splitFile(src)
        let dst = dst / name & ext
        copyFile(src, dst)
        result.add(dst)
      else:
        # copy file to file
        let parentDir = parentDir(dst)
        if not existsDir(parentDir):
          createDir(parentDir)
        copyFile(src, dst)
        result.add(dst)
    elif existsDir(src):
      # copy dir to dir/basedir
      if existsDir(dst):
        let (_, name, ext) = splitFile(src)
        let dst = dst / name & ext
        copyDir(src, dst)
        result.add(dst)
      else:
        # copy dir to dir
        let parentDir = parentDir(dst)
        if not existsDir(parentDir):
          createDir(parentDir)
        copyDir(src, dst)
        result.add(dst)
    else:
      let msg = src & " doesn't exist"
      warn msg

proc mcp(srcs: seq[string]): int =
  addHandler(newConsoleLogger(lvlInfo, fmtStr = verboseFmtStr, useStderr = true))

  let srcs = getArgsOrStdinLines(srcs)
  let (srcBody, dstBody) = editTmpFile(srcs)
  if srcBody == dstBody:
    info "not edited"
    return

  let dsts = dstBody.strip.split("\n").mapIt(it.strip)
  for dsts in copyFileAndDir(srcs, dsts):
    echo dsts

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(mcp)
