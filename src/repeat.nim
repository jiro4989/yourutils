import clitools/io
import parseopt, logging
from strutils import parseInt, join, repeat
from strformat import `&`
from sequtils import mapIt

type
  Options* = ref object
    format*: string
    delimiter*: string

const
  appName = "repeat"
  version = "v1.0.0"
  doc = &"""
{appName} repeats a word

Usage:
    {appName} count word
    echo word | {appName} count

Options:
    -h, --help             Print this help
    -v, --version          Print version
    -X, --debug            Print debug log
    -f, --format:string    Format
"""

var
  useDebug: bool

proc repeatString*(word: string, repeatCounts: openArray[int], opts: Options): seq[string] =
  for cnt in repeatCounts:
    result.add word.repeat(cnt).mapIt(it).join(opts.delimiter)

when isMainModule:
  var
    optParser = initOptParser()
    opts = new Options
    args: seq[string]
  opts.format = "%s"

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
      of "debug", "X":
        useDebug = true
      of "format", "f":
        opts.format = val
    of cmdEnd:
      assert(false)  # cannot happen

  # デバッグログを標準出力にだすか否か
  if useDebug:
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger
  
  debug appName, ": options = ", opts[]

  doAssert 0 < args.len, &"{appName}: must count of arguments is over 0"

  var repeatCounts: seq[int]
  if args.len <= 1:
    repeatCounts.add args[0].parseInt
  else:
    repeatCounts = args[0..^2].mapIt(it.parseInt)

  var word = args[args.len-1]
