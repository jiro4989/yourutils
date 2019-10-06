import os, strutils, terminal

const
  whiteSpaces = @[" ", "　", "\t"]

proc renames(dryRun = false, printRename = false, whiteSpace = false,
             fromStrs: seq[string] = @[], toStr: string,
             dirs: seq[string]): int =
  ## 指定のファイルorディレクトリ配下のファイル名の任意の文字を置換してリネームする。
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
    styledEcho fgBlack, kindCol, kindStr, resetStyle, " ", path, " -> ", fgGreen, newPath, resetStyle

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
  dispatch(renames)
