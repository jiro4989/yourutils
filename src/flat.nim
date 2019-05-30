import clitools/[io, log]
import parseopt, logging
from strutils import parseInt, join
from strformat import `&`
from os import commandLineParams

type
  Options* = ref object
    help*: bool
    version*: bool
    columnCount*: int
    delimiter*: string
    args*: seq[string]

const
  appName = "flat"
  version = "v1.0.0"
  doc = &"""
{appName} flats lines to lines.

Usage:
    {appName} tmp.txt
    seq 5 | {appName}

Options:
    -h, --help                Print this help
    -v, --version             Print version
    -X, --debug               Print debug log
    -n, --columncount:int     Count
    -d, --delimiter:string    Delimiter
"""

var
  useDebug: bool

proc getCmdOpts*(params: seq[string]): Options =
  var optParser = initOptParser()
  new result
  result.columnCount = 0
  result.delimiter = " "

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
        of "column-count", "n":
          result.columnCount = val.parseInt
          doAssert 0 < result.columnCount, &"{appName}: {key} = {result.columnCount}: parameters is illegal"
        of "delimiter", "d":
          result.delimiter = val
      of cmdEnd:
        assert(false)  # cannot happen

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
  let opts = getCmdOpts(params)
  if opts.help or opts.version: return

  setDebugLogger useDebug
  debug appName, ": options = ", opts[]
  
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
  for line in main(commandLineParams()):
    echo line