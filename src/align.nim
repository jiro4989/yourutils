import clitools/[io, log]
import alignment
import parseopt, logging
from strutils import parseInt
from strformat import `&`
from os import commandLineParams

type
  Options* = ref object
    help*: bool
    version*: bool
    subcmd*: string
    length*: int
    pad*: string
    writeFile*: bool
    args*: seq[string]

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

proc getCmdOpts*(params: seq[string]): Options =
  var optParser = initOptParser()
  new result
  result.pad = " "

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      if result.subcmd == "":
        case key
        of "left", "center", "right":
          result.subcmd = key
      else:
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
      of "length", "n":
        result.length = val.parseInt
        doAssert 0 < result.length, &"{appName}: {key} = {result.length}: parameters is illegal"
      of "pad", "p":
        result.pad = val
      of "writeFile", "w":
        result.writeFile = true
    of cmdEnd:
      assert(false)  # cannot happen


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
  let opts = getCmdOpts(commandLineParams())

  setDebugLogger useDebug
  
  debug appName, ": options = ", opts[]
  
  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if opts.args.len < 1:
    debug appName, ": read stdin"
    let lines = stdin.readLines
    execSubcmd stdout, lines, opts
    quit 0

  # 引数があればファイルの中身を読み取って処理する
  debug appName, ": read args files"
  for arg in opts.args:
    var
      f = open(arg, fmReadWrite)
      outf = if opts.writeFile: f
             else: stdout
    let lines = f.readLines
    execSubcmd outf, lines, opts
    f.close