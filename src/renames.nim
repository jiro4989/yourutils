import os, strutils, terminal

const
  whiteSpaces = @[" ", "　", "\t"]

proc renames(dryRun = false, printRename = false, whiteSpace = false,
             fromStrs: seq[string] = @[], toStr: string,
             dirs: seq[string]): int =
  ## Rename files or directories.
  # 一番下の階層から再帰的にリネームしてまわる。

  # whitespaceを使う指定があれば置換元の文字列をwhiteSpaceにする
  var fromStrs2 = fromStrs
  if whiteSpace:
    fromStrs2 = whiteSpaces

  if fromStrs2.len < 1 or toStr.len < 1:
    stderr.writeLine "[ ERR ] see help"
    return 1

  template printMsg(kind: PathComponent, path, newPath: string) =
    let kindCol =
      if kind == pcFile: bgYellow
      else: bgBlue
    let kindStr =
      if kind == pcFile: "[ File ]"
      else: "[ Dir  ]"

    if path != newPath:
      styledEcho fgBlack, kindCol, kindStr, resetStyle, " ", path, " -> ", fgGreen, newPath, resetStyle
    else:
      styledEcho fgBlack, kindCol, kindStr, resetStyle, " ", "NO CHANGE ", path

  template runRename(kind: PathComponent, path, newPath: string) =
    if dryRun:
      printMsg(kind, path, newPath)
    else:
      if printRename:
        printMsg(kind, path, newPath)
      moveFile(path, newPath)

  proc rename(dir: string) =
    for kind, path in walkDir(dir):
      let (dir, name, ext) = splitFile(path)
      let base = name & ext
      var newBase = base
      for subs in fromStrs2:
        newBase = newBase.replace(subs, toStr)
      let newPath = dir / newBase

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

when isMainModule:
  import cligen
  import clitools/appinfo
  clCfg.version = version
  dispatch(renames,
           help = {
             "whiteSpace":"replace name from white spaces to `toStr`",
             "fromStrs":"replace name from `fromStrs` to `toStr`",
             "toStr":"replace name from `fromStrs` to `toStr`",
             "printRename":"print rename action when this command renames files",
             "dryRun":"NO rename, but print rename action. You can check rename",
             })
