import clitools/io
import parseopt, logging, unicode
from strutils import parseInt, join, repeat
from strformat import `&`
from sequtils import mapIt
from os import commandLineParams

type
  Options* = ref object
    format*: string
    delimiter*: string
    useStdin*: bool

const
  appName = "repeat"
  version = "v1.0.0"
  doc = &"""
{appName} repeats a word

Usage:
    {appName} [options] (count...) [word]

Examples:
    {appName} 5 A
    {appName} 3 5 A
    echo word | {appName} 2 3 -i

Options:
    -h, --help                Print this help
    -v, --version             Print version
    -X, --debug               Print debug log
    -f, --format:string       Format
    -d, --delimiter:string    Delimiter
    -i, --stdin               Use stdin
"""

var
  useDebug: bool

proc repeatString*(word: string, repeatCounts: openArray[int], opts: Options): seq[string] =
  if repeatCounts.len < 1: return
  for cnt in repeatCounts:
    if cnt < 1: continue
    var s: seq[string]
    for i in 1..cnt:
      s.add word
      s.add opts.delimiter
    s = s[0..^2]
    result.add s.join

proc main*(params: seq[string]): seq[string] =
  var
    optParser = initOptParser(params)
    opts = new Options
    args: seq[string]
  opts.format = "%s"

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      args.add key
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo doc
        return
      of "version", "v":
        echo version
        return
      of "debug", "X": useDebug = true
      of "format", "f": opts.format = val
      of "delimiter", "d": opts.delimiter = val
      of "stdin", "i": opts.useStdin = true
    of cmdEnd:
      assert(false)  # cannot happen

  # デバッグログを標準出力にだすか否か
  if useDebug:
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger
  
  debug appName, ": options = ", opts[]

  doAssert 0 < args.len, &"{appName}: must count of arguments is over 0"

  var
    repeatCounts: seq[int]
    word: string
  if opts.useStdin:
    repeatCounts.add args.mapIt(it.parseInt)
    word = stdin.readLines.join
  else:
    repeatCounts = args[0..^2].mapIt(it.parseInt)
    word = args[args.len-1]

  result = word.repeatString(repeatCounts, opts)

when isMainModule:
  for line in main(commandLineParams()):
    echo line
