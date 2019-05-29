import clitools/io
import parseopt, logging
from strutils import parseInt, join
from strformat import `&`

type
  Options* = ref object
    columnCount*: int
    delimiter*: string
    args*: seq[string]

const
  appName = "flat"

var
  useDebug: bool

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

when isMainModule:
  var
    optParser = initOptParser()
    opts = new Options
  opts.columnCount = 0
  opts.delimiter = " "

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
      case kind
      of cmdArgument:
        opts.args.add val
      of cmdLongOption, cmdShortOption:
        case key
        of "column-count", "n":
          opts.columnCount = val.parseInt
          doAssert 0 < opts.columnCount, &"{appName}: {key} = {opts.columnCount}: parameters is illegal"
        of "delimiter", "d": opts.delimiter = val
        of "debug", "X": useDebug = true
      of cmdEnd:
        assert(false)  # cannot happen

  # デバッグログを標準出力にだすか否か
  if useDebug:
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger
  
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
  
  var s = lines.joinLines(opts)
  for line in s:
    echo line