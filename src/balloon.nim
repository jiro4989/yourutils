import clitools/io
import eastasianwidth
import parseopt, logging, strutils
from strformat import `&`
from sequtils import mapIt

type
  Options* = ref object
    top*, right*, bottom*, left*: bool
    position*: int

const
  appName = "balloon"
  version = "v1.0.0"
  doc = &"""
{appName} flats lines to lines.

Usage:
    {appName} tmp.txt
    seq 5 | {appName}

Options:
    -h, --help       Print this help
    -v, --version    Print version
    -X, --debug      Print debug log
    -t, --top        Top
    -r, --right      Right
    -b, --bottom     Bottom
    -l, --left       Left
"""

var
  useDebug: bool

proc formatBalloon*(lines: openArray[string], opts: Options): seq[string] =
  ## "Hello" -> "|  Hello  |"
  let
    lineMaxWidth = lines.mapIt(it.stringWidth).max
    topLine    = "." & "-".repeat(lineMaxWidth + 4).join & "."
    bottomLine = "`" & "-".repeat(lineMaxWidth + 4).join & "'"
    blankLine  = "|  " & " ".repeat(lineMaxWidth).join & "  |"
  result.add topLine
  result.add blankLine
  for line in lines:
    let diff = lineMaxWidth - line.stringWidth
    var s = "|  "
    if 0 < diff:
      s.add " ".repeat((diff / 2).int).join
      s.add line
      s.add " ".repeat((diff / 2).int).join
      if diff mod 2 != 0:
        s.add " "
    else:
      s.add line
    s.add "  |"
    result.add s
  result.add blankLine
  result.add bottomLine

when isMainModule:
  var
    optParser = initOptParser()
    opts = new Options
    args: seq[string]

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
      case kind
      of cmdArgument:
        args.add val
      of cmdLongOption, cmdShortOption:
        case key
        of "help", "h":
          echo doc
          quit 0
        of "version", "v":
          echo version
          quit 0
        of "debug", "X": useDebug = true
        of "top", "t": opts.top = true
        of "right", "r": opts.right = true
        of "bottom", "b": opts.bottom = true
        of "left", "l": opts.left = true
      of cmdEnd:
        assert(false)  # cannot happen

  # デバッグログを標準出力にだすか否か
  if useDebug:
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger
  
  debug appName, ": options = ", opts[]
  
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  var lines: seq[string]
  if args.len < 1:
    debug appName, ": read stdin"
    lines = stdin.readLines
  else:
    debug appName, ": read args files"
    lines = args
  
  for line in lines.formatBalloon(opts):
    echo line