import argparse

import clitools/[io, log, option]
import clitools/private/common

import parseopt, logging
from strutils import parseInt, join
from strformat import `&`
from os import commandLineParams

type
  Options* = ref object of RootOptions
    delimiter*: string
    format*: string

const
  appName = "tb"

var
  version: string
  useDebug: bool

include clitools/private/version

proc formatMarkdown*(opts: Options): seq[string] =
  discard

proc formatHtml*(opts: Options): seq[string] =
  discard

proc formatAsciidoc*(opts: Options): seq[string] =
  discard

proc main*(params: seq[string]): seq[string] =
  var p = newParser(appName):
    flag("-v", "--version", help="Print version")
    flag("-X", "--debug", help="Debug")
    option("-d", "--delimiter", help="Delimiter", default = " ")
    option("-f", "--format", help="Output format. [markdown | html | asciidoc]",
           default = "markdown")
    arg("args", nargs = -1)
  
  let opt = p.parse(params)
  setOptions:
    let opts = Options(
      delimiter: opt.delimiter,
      format: opt.format,
      args: opt.args)

  # TODO

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  var lines: seq[string]
  if opts.args.len < 1:
    debug "read stdin"
    lines = stdin.readLines
  else:
    debug "read args files"
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