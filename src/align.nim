import clitools/io
import alignment
import parseopt, logging
from strutils import parseInt
from strformat import `&`

type
  Options* = ref object
    subcmd*: string
    length*: int
    pad*: string
    writeFile*: bool

const
  appName = "align"
  version = "v1.0.0"
  doc = &"""
{appName} aligns texts.

Usage:
    {appName} (-h | --help | -v | --version)
    {appName} left   [options] [files...]
    {appName} center [options] [files...]
    {appName} right  [options] [files...]

Options:
    -h, --help                Print this help
    -v, --version             Print version
    -X, --debug               Print debug log
    -n, --length:int          Padding length
    -p, --pad:string          Padding string
    -w, --writefile           Overwrite file
"""

var
  useDebug: bool

proc execSubcmd(f: File, lines: openArray[string], opts: Options) =
  case opts.subcmd
  of "left":
    f.writeLine lines.alignLeft(pad = opts.pad)
  of "center":
    f.writeLine lines.alignCenter(pad = opts.pad)
  of "right":
    f.writeLine lines.alignRight(pad = opts.pad)
  else: discard # 到達しない

when isMainModule:
  var
    optParser = initOptParser()
    opts = new Options
    args: seq[string]
  opts.pad = " "

  # まず先頭の引数を1つだけ調べる
  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      opts.subcmd = val
      case opts.subcmd
      of "left", "center", "right": discard
      else: assert false, "Illegal subcommand: cmd = " & opts.subcmd
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo doc
        quit 0
      of "version", "v":
        echo version
        quit 0
      else:
        assert false, "Illegal option: key = " & key
    of cmdEnd:
      assert(false)  # cannot happen
    break

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
      of "length", "n":
        opts.length = val.parseInt
        doAssert 0 < opts.length, &"{appName}: {key} = {opts.length}: parameters is illegal"
      of "pad", "p":
        opts.pad = val
      of "writeFile", "w":
        opts.writeFile = true
    of cmdEnd:
      assert(false)  # cannot happen

  # デバッグログを標準出力にだすか否か
  if useDebug:
    var logger = newConsoleLogger(lvlAll, verboseFmtStr)
    addHandler logger
  
  debug appName, ": options = ", opts[]
  
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if args.len < 1:
    debug appName, ": read stdin"
    let lines = stdin.readLines
    execSubcmd stdout, lines, opts
    quit 0

  # 引数があればファイルの中身を読み取って処理する
  debug appName, ": read args files"
  for arg in args:
    var
      f = open(arg, fmReadWrite)
      outf = if opts.writeFile: f
             else: stdout
    let lines = f.readLines
    execSubcmd outf, lines, opts
    f.close