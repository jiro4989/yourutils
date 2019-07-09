import argparse

import clitools/[io, log, option]
import clitools/private/common

import alignment
import parseopt, logging
from strutils import parseInt, split, join
from strformat import `&`
from sequtils import mapIt, repeat
from os import commandLineParams

type
  Options* = ref object of RootOptions
    delimiter*: string
    outputDelimiter*: string
    fields*: seq[int]

const
  appName = "ucut"

var
  version: string
  useDebug: bool

include clitools/private/version

proc cut*(line: string, opts: Options): string =
  let fields = line.split(opts.delimiter)
  var outf: seq[string]
  for i in opts.fields:
    let n = i - 1
    if n < 0 or fields.len <= n: continue
    outf.add fields[n]
  result = outf.join(opts.outputDelimiter)

proc main*(params: seq[string]) =
  var p = newParser(appName):
    flag("-v", "--version", help="Print version")
    flag("-X", "--debug", help="Debug")
    option("-d", "--delimiter", help="Delimiter", default = " ")
    option("-D", "--output-delimiter", help="Output delimiter", default = " ")
    option("-f", "--fields", help="Output delimiter", default = "1")
    arg("args", nargs = -1)

  let opt = p.parse(params)
  setOptions:
    let opts = Options(
      delimiter: opt.delimiter,
      outputDelimiter: opt.outputDelimiter,
      fields: opt.fields.split(",").mapIt(it.parseInt),
      args: opt.args)

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if opts.args.len < 1:
    debug "read stdin"
    for line in stdin.lines:
      echo line.cut(opts)

  # 引数があればファイルの中身を読み取って処理する
  debug "read args files"
  for arg in opts.args:
    for line in arg.lines:
      echo line.cut(opts)

when isMainModule:
  try:
    main(commandLineParams())
  except:
    stderr.writeLine(getCurrentExceptionMsg())
    quit 1