import argparse

import clitools/[log, option]

import parseopt, logging, unicode
from strformat import `&`
from os import commandLineParams
from strutils import toHex, strip

type
  Options* = ref object of RootOptions

const
  appName = "codepoint"

var
  version: string
  useDebug: bool

include clitools/version

proc printCodepoint(line: string) =
  for ch in line.toRunes:
    let
      codePoint = ch.ord
      hex       = codePoint.toHex
      shortHex  = hex.strip(trailing = false, chars = {'0'})
    echo &"{ch} {codePoint} {hex} \\U{shortHex}"

proc main*(params: seq[string]) =
  var p = newParser(appName):
    flag("-v", "--version", help="Print version")
    flag("-X", "--debug", help="Debug")
    arg("args", nargs = -1)

  let opt = p.parse(params)

  if opt.help:
    quit 0
  
  if opt.version:
    echo version
    quit 0

  let opts = Options(
    args: opt.args)

  useDebug = opt.debug
  setDebugLogger useDebug
  debug appName, ": options = ", opts[]
  
  echo "char code_point code_point(hex) code_point(short_hex)"

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if opts.args.len < 1:
    debug appName, ": read stdin"
    for line in stdin.lines:
      printCodepoint line
    quit 0

  # 引数があればファイルの中身を読み取って処理する
  debug appName, ": read args files"
  for arg in opts.args:
    for line in arg.lines:
      printCodepoint line

when isMainModule:
  try:
    main(commandLineParams())
  except:
    stderr.writeLine(getCurrentExceptionMsg())
    quit 1