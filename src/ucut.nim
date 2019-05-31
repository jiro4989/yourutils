import clitools/[io, log]
import alignment
import parseopt, logging
from strutils import parseInt, split, join
from strformat import `&`
from sequtils import mapIt, repeat
from os import commandLineParams

type
  Options* = ref object
    help*: bool
    version*: bool
    delimiter*: string
    outputDelimiter*: string
    fields*: seq[int]
    args*: seq[string]

const
  appName = "ucut"
  version = "v1.0.0"
  doc = &"""
{appName} aligns texts.

Usage:
    {appName} [options] <files...>

Options:
    -h, --help                       Print this help
    -v, --version                    Print version
    -X, --debug                      Print debug log
    -d, --delimiter:string           Delimiter [default: " "]
    -D, --output-delimiter:string    Output delimiter [default: " "]
                                     Format is '1,2,3' or '2-' or '-2'
    -f, --field:filed                Print field
"""

var
  useDebug: bool

proc getCmdOpts*(params: seq[string]): Options =
  var optParser = initOptParser(params)
  new result
  result.delimiter = " "
  result.outputDelimiter = " "

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
      of "delimiter", "d":
        result.delimiter = val
      of "output-delimiter", "D":
        result.outputDelimiter = val
      of "field", "f":
        let fields = val.split(",").mapIt(it.parseInt)
        result.fields = fields
    of cmdEnd:
      assert(false)  # cannot happen


proc cut*(lines: openArray[string], opts: Options): seq[string] =
  for line in lines:
    let fields = line.split(opts.delimiter)
    var outf: seq[string]
    for i in opts.fields:
      let n = i - 1
      if n < 0 or fields.len <= n: continue
      outf.add fields[n]
    result.add outf.join(opts.outputDelimiter)

proc main*(params: seq[string]): seq[string] =
  let opts = getCmdOpts(params)

  setDebugLogger useDebug
  
  debug appName, ": options = ", opts[]
  
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if opts.args.len < 1:
    debug appName, ": read stdin"
    let lines = stdin.readLines
    result = lines.cut(opts)
    return

  # 引数があればファイルの中身を読み取って処理する
  debug appName, ": read args files"
  for arg in opts.args:
    var f = open(arg)
    let lines = f.readLines
    result.add lines.cut(opts)
    f.close