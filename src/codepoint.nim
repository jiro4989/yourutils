import clitools/log
import parseopt, logging, unicode
from strformat import `&`
from os import commandLineParams
from strutils import toHex, strip

type
  Options* = ref object
    help*: bool
    version*: bool
    args*: seq[string]

const
  appName = "codepoint"
  version = "v1.0.0"
  doc = &"""
{appName} prints code point.

Usage:
    {appName} [options] <words...>

Options:
    -h, --help                Print this help
    -v, --version             Print version
    -X, --debug               Print debug log
    -c, --codepoint           Print code point
    -H, --hex                 Print hex code point
    -s, --shorthex            Print short hex code point
    -n, --noheader            Not print header
"""

var
  useDebug: bool

proc getCmdOpts*(params: seq[string]): Options =
  var optParser = initOptParser(params)
  new result

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      result.args.add key
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo doc
        result.help = true
        return
      of "version", "v":
        echo version
        result.version = true
        return
      of "debug", "X":
        useDebug = true
    of cmdEnd:
      assert(false)  # cannot happen

proc printCodepoint(line: string) =
  for ch in line.toRunes:
    let
      codePoint = ch.ord
      hex       = codePoint.toHex
      shortHex  = hex.strip(trailing = false, chars = {'0'})
    echo &"{ch} {codePoint} {hex} \\U{shortHex}"

when isMainModule:
  let opts = getCmdOpts(commandLineParams())
  if opts.help or opts.version: quit 0

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
