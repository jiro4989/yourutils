import argparse

import clitools/[io, log, option]
import clitools/private/common

import parseopt, logging
from strutils import parseInt, join
from strformat import `&`
from os import commandLineParams

type
  Options* = ref object of RootOptions
    columnCount*: int
    delimiter*: string

const
  appName = "flat"

var
  version: string
  useDebug: bool

include clitools/private/version

proc joinLines*(lines: openArray[string], opts: Options): seq[string] =
  ## 行のデータをcolumnCountずつ１行にまとめる
  ## columnCountが初期値(-1)の場合は1行にまとめる
  var s: seq[string]
  for i, v in lines:
    debug appName, ": process line = ", v
    s.add v
    if 0 < opts.columnCount and (i+1) mod opts.columnCount == 0:
      debug appName, ": result = ", result.join, ", s = ", s.join
      result.add s.join(opts.delimiter)
      s = @[]
  result.add s.join(opts.delimiter)

proc main*(params: seq[string]): seq[string] =
  var p = newParser(appName):
    flag("-v", "--version", help="Print version")
    flag("-X", "--debug", help="Debug")
    option("-n", "--columncount", help="Column count", default = "0")
    option("-d", "--delimiter", help="Delimiter", default = " ")
    arg("args", nargs = -1)
  
  let opt = p.parse(params)
  setOptions:
    let opts = Options(
      columnCount: opt.columncount.parseInt,
      delimiter: opt.delimiter,
      args: opt.args)

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  var lines: seq[string]
  if opts.args.len < 1:
    debug appName, ": read stdin"
    lines = stdin.readLines
  else:
    debug appName, ": read args files"
    for arg in opts.args:
      var f = open(arg)
      lines.add f.readLines
      f.close
  
  result = lines.joinLines(opts)

when isMainModule:
  try:
    for line in main(commandLineParams()):
      echo line
  except:
    stderr.writeLine(getCurrentExceptionMsg())
    quit 1