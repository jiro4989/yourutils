import argparse

import clitools/[io, log]

import parseopt, logging
from strutils import parseInt, join
from strformat import `&`
from os import commandLineParams

type
  Options* = ref object
    columnCount*: int
    delimiter*: string

const
  appName = "flat"

var
  version: string
  useDebug: bool

include clitools/version

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
    option("-n", "--columncount", help="Column count", default = "0")
    option("-d", "--delimiter", help="Delimiter", default = " ")
    flag("-X", "--debug", help="Debug")
    arg("files", nargs = -1)
  
  var opts = p.parse(params)

  if opts.help:
    quit 0

  useDebug = opts.debug
  setDebugLogger useDebug
  debug appName, ": options = ", opts
  
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  var lines: seq[string]
  if opts.files.len < 1:
    debug appName, ": read stdin"
    lines = stdin.readLines
  else:
    debug appName, ": read args files"
    for arg in opts.files:
      var f = open(arg)
      lines.add f.readLines
      f.close
  
  let conf = new Options
  conf.columnCount = opts.columnCount.parseInt()
  conf.delimiter = opts.delimiter
  result = lines.joinLines(conf)

when isMainModule:
  for line in main(commandLineParams()):
    echo line