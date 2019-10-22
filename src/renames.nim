import os, strutils, terminal
from strformat import `&`

const
  whiteSpaces = @[" ", "　", "\t"]
  version = """renames version 1.2.0
Copyright (c) 2019 jiro4989
Released under the MIT License.
https://github.com/jiro4989/clitools"""

proc renames(dryRun = false, printRename = false, whiteSpace = false,
             fromStrs: seq[string] = @[], toStr = "",
             lower = false, upper = false, deleteStrs: seq[string] = @[],
             filter = false,
             dirs: seq[string]): int =
  ## Rename files or directories.
  ## 一番下の階層から再帰的にリネームしてまわる。

  # whitespaceを使う指定があれば置換元の文字列をwhiteSpaceにする
  var fromStrs2 = fromStrs
  if whiteSpace:
    fromStrs2 = whiteSpaces

  # fromStrsとtoStrは必須なのでチェック
  if not lower and not upper and deleteStrs.len < 1 and (fromStrs2.len < 1 or toStr.len < 1):
    stderr.writeLine "[ ERR ] must need fromStrs and toStr"
    stderr.writeLine "[ ERR ] see help"
    return 1

  # 変更対象のファイル件数
  var changeFileCount: int
  template printMsg(kind: PathComponent, path, newPath: string) =
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

  var fileCount: int        # 走査した全てのファイル件数
  var changedFileCount: int # 実際に変更したファイル件数
  template runRename(kind: PathComponent, path, newPath: string) =
    inc(fileCount)
    if dryRun:
      printMsg(kind, path, newPath)
    else:
      if printRename:
        printMsg(kind, path, newPath)
      if path != newPath:
        inc(changedFileCount)
        moveFile(path, newPath)

  proc getReplaceName(path: string): string =
    let (dir, name, ext) = splitFile(path)
    let base = name & ext
    var newBase = base

    # 大文字小文字変換があればそれだけやる
    if lower:
      newBase = toLowerAscii(newBase)
    elif upper:
      newBase = toUpperAscii(newBase)
    elif 1 <= deleteStrs.len:
      # 削除文字があれば削除だけ
      for s in deleteStrs:
        newBase = newBase.replace(s, "")
    else:
      # どちらもなければ、置換文字を使う
      for subs in fromStrs2:
        newBase = newBase.replace(subs, toStr)
    result = dir / newBase

  proc rename(dir: string) =
    for kind, path in walkDir(dir):
      let newPath = getReplaceName(path)

      case kind
      of pcDir:
        rename(path)
        runRename(kind, path, newPath)
      of pcFile:
        runRename(kind, path, newPath)
      else:
        discard

  for dir in dirs:
    rename(dir)
    runRename(pcDir, dir, getReplaceName(dir))

  echo ""
  echo &"{fileCount} files, {changeFileCount} changes files, {changedFileCount} files changed"

when isMainModule:
  import cligen
  clCfg.version = version
  dispatch(renames,
           short = {"deleteStrs":'D', "filter":'F'},
           help = {
             "whiteSpace":"replace name from white spaces to `toStr`",
             "fromStrs":"replace name from `fromStrs` to `toStr`",
             "toStr":"replace name from `fromStrs` to `toStr`",
             "printRename":"print rename action when this command renames files",
             "dryRun":"NO rename, but print rename action. You can check rename",
             "filter":"filtering no change files",
             })
