import os, strutils, terminal
from strformat import `&`

const
  whiteSpaces = @[" ", "　", "\t"]
  version = """renames version 2.0.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""

var
  changeFileCount: int  # 変更対象のファイル件数
  fileCount: int        # 走査した全てのファイル件数
  changedFileCount: int # 実際に変更したファイル件数

proc printResult() =
  echo ""
  echo &"{fileCount} files, {changeFileCount} changes files, {changedFileCount} files changed"

template printMsg(kind: PathComponent, path, newPath: string, filter: bool) =
  let kindCol =
    if kind == pcFile: fgYellow
    else: fgBlue
  let kindStr =
    if kind == pcFile: "[ File ]"
    else: "[ Dir  ]"

  if path != newPath:
    inc(changeFileCount)
    styledEcho fgBlack, kindCol, kindStr, resetStyle, " ", path, " -> ", fgGreen, newPath, resetStyle
  else:
    if not filter:
      styledEcho fgBlack, kindCol, kindStr, resetStyle, " ", "NO CHANGE ", path

proc runMoveFile(kind: PathComponent, path, newPath: string,
                 dryRun, filter, printRename: bool) =
  inc(fileCount)
  if dryRun:
    printMsg(kind, path, newPath, filter)
    return

  if printRename:
    printMsg(kind, path, newPath, filter)
  if path != newPath:
    inc(changedFileCount)
    moveFile(path, newPath)

proc rename(dir: string, newPathProc: proc (path: string): string,
            dryRun, filter, printRename: bool) =
  for kind, path in walkDir(dir):
    let newPath = newPathProc(path)

    case kind
    of pcDir:
      rename(path, newPathProc,
             dryRun = dryRun, filter = filter, printRename = printRename)
      runMoveFile(kind, path, newPath,
                  dryRun = dryRun, filter = filter, printRename = printRename)
    of pcFile:
      runMoveFile(kind, path, newPath,
                  dryRun = dryRun, filter = filter, printRename = printRename)
    else:
      discard

proc renameDirs(dirs: seq[string], f: proc (path: string): string,
                    dryRun, printRename, filter: bool) =
  for dir in dirs:
    rename(dir, f, dryRun = dryRun, filter = filter, printRename = printRename)
    runMoveFile(pcDir, dir, f(dir), dryRun = dryRun, filter = filter, printRename = printRename)

proc cmdDelete(dryRun = false, printRename = false, filter = false,
            fromStrs: seq[string] = whiteSpaces,
            dirs: seq[string]): int =
  proc getRemovedName(path: string): string =
    let (dir, name, ext) = splitFile(path)
    let base = name & ext
    var newBase = base

    for s in fromStrs:
      newBase = newBase.replace(s, "")
    result = dir / newBase

  renameDirs(dirs, getRemovedName, dryRun = dryRun, filter = filter, printRename = printRename)
  printResult()

proc cmdReplace(dryRun = false, printRename = false, filter = false,
            fromStrs: seq[string] = whiteSpaces, toStr = "",
            dirs: seq[string]): int =
  proc getReplaceName(path: string): string =
    let (dir, name, ext) = splitFile(path)
    let base = name & ext
    var newBase = base

    for s in fromStrs:
      newBase = newBase.replace(s, toStr)
    result = dir / newBase

  renameDirs(dirs, getReplaceName, dryRun = dryRun, filter = filter, printRename = printRename)
  printResult()

proc cmdLower(dryRun = false, printRename = false, filter = false,
           dirs: seq[string]): int =
  proc getLowerName(path: string): string =
    let (dir, name, ext) = splitFile(path)
    let base = name & ext
    result = dir / toLowerAscii(base)

  renameDirs(dirs, getLowerName, dryRun = dryRun, filter = filter, printRename = printRename)
  printResult()

proc cmdUpper(dryRun = false, printRename = false, filter = false,
           dirs: seq[string]): int =
  proc getUpperName(path: string): string =
    let (dir, name, ext) = splitFile(path)
    let base = name & ext
    result = dir / toUpperAscii(base)

  renameDirs(dirs, getUpperName, dryRun = dryRun, filter = filter, printRename = printRename)
  printResult()

when isMainModule and not defined(isTesting):
  import cligen
  clCfg.version = version

  const
    helpPrintRename = "print rename action when this command renames files"
    helpDryRun = "NO rename, but print rename action. You can check rename"
    helpFilter = "filtering no change files"
  dispatchMulti([cmdDelete, cmdName = "delete",
                 short = {"filter":'F'},
                 help = {
                   "fromStrs":"delete characters",
                   "printRename":helpPrintRename,
                   "dryRun":helpDryRun,
                   "filter":helpFilter,
                   }],
                [cmdReplace, cmdName = "replace",
                 short = {"filter":'F'},
                 help = {
                   "fromStrs":"replace name from white spaces to `toStr`",
                   "toStr":"replace name from `fromStrs` to `toStr`",
                   "printRename":helpPrintRename,
                   "dryRun":helpDryRun,
                   "filter":helpFilter,
                   }],
                [cmdLower, cmdName = "lower",
                 short = {"filter":'F'},
                 help = {
                   "printRename":helpPrintRename,
                   "dryRun":helpDryRun,
                   "filter":helpFilter,
                   }],
                [cmdUpper, cmdName = "upper",
                 short = {"filter":'F'},
                 help = {
                   "printRename":helpPrintRename,
                   "dryRun":helpDryRun,
                   "filter":helpFilter,
                   }],
                )
