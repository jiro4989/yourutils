import clitools/[log, option]
import strutils, strformat, terminal, logging, net, parseopt
from os import commandLineParams

type
  Options* = ref object of RootOptions
    printIPAddress*, printCIDR*, printIPAddressBin*, printIPAddressBinMask*, printColoredIPAddress*, printHeader*: bool
    delimiter*: string
  IPv4* = object
    address*: string
    CIDR*: int
    bin*: string
    parseMask*: string
    mask*: string

const
  appName = "subnet"
  version = "v1.0.0"
  doc = &"""
{appName} is subnet calc.

Usage:
    {appName} [options] <ip/cidr>...
    {appName} [options]

Options:
    -a, --ipaddress          show IP address
    -r, --cidr               show CIDR
    -b, --bin                show IP binaries
    -m, --mask               show IP binaries Mask
    -c, --color              show colored IP binaries
    -d, --delimiter=<d>      output delimiter [default: \t]
    -H, --header             show header column
    -X, --debug              set on loggin level 'debug'

help options:
  -h --help         show this screen
  -v --version      show version
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
      of "ipaddress", "a": result.printIPAddress = true
      of "cidr", "r": result.printCIDR = true
      of "bin", "b": result.printIPAddressBin = true
      of "mask", "m": result.printIPAddressBinMask = true
      of "color", "c": result.printColoredIPAddress = true
      of "header", "H": result.printHeader = true
      of "delimiter", "d": result.delimiter = val
    of cmdEnd:
      assert(false)  # cannot happen

proc parseIPNumber*(ip: string): seq[int] =
  ## 0-255
  ## 2,3,4
  ## -255
  ## 20-
  ## 1-6,19,33-
  for s in ip.split(","):
    if s.contains("-"):
      let splited = s.split("-")
      var startNum = 0
      var endNum = 255
      if splited[0] != "": startNum = splited[0].parseInt()
      if splited[1] != "": endNum = splited[1].parseInt()
      for i in startNum..endNum:
        result.add(i)
    else:
      result.add(s.parseInt())

proc toIPv4bin*(ip: string): string =
  ## toIPv4bin はIPアドレス文字列を2進数に変換して返す
  ## 変換に失敗したら例外を投げる。
  discard ip.parseIpAddress
  for ip in ip.split("."):
    let uip = ip.parseInt.toBin(8)
    result.add $uip
  
proc toMask*(i: int): string =
  ## toMask は2進数IPアドレスのマスクを返す
  var n = i
  if n < 0:
    n = 0
  elif 32 < n:
    n = 32
  let one = '1'.repeat(n)
  let zero = '0'.repeat(32 - n)
  result = $one & $zero

proc parseCIDR*(ipCIDR: string): IPv4 = 
  ## parseCIDRはIP/CIDR文字列をパースしてIPv4オブジェクトとして返す
  let
    ipc = ipCIDR.split "/"
    ip = ipc[0]
  var
    cidr = ipc[1].parseInt
  if cidr < 1:
    cidr = 1
  elif 32 < cidr:
    cidr = 32
  let
    bin = ip.toIPv4bin
    mask = cidr.toMask
  result = IPv4(address: ip, CIDR: cidr, bin: bin, mask: mask)

when isMainModule:
  let opts = getCmdOpts(commandLineParams())
  if opts.help or opts.version: quit 0

  setDebugLogger useDebug
  debug "options = ", opts[]
  
  # オプションがすべてfalseなら全部trueにする
  # wcコマンドと同じような設定のしかた
  if not opts.printIPAddress and not opts.printCIDR and not opts.printIPAddressBin and not opts.printIPAddressBinMask:
    opts.printIPAddress = true
    opts.printCIDR = true
    opts.printIPAddressBin = true
    opts.printIPAddressBinMask = true

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if opts.args.len < 1:
    debug "read stdin"
    for line in stdin.lines:
      #printCodepoint line
      discard
    quit 0

  # 引数があればファイルの中身を読み取って処理する
  debug "read args files"
  for arg in opts.args:
    for line in arg.lines:
      #printCodepoint line
      discard

when false:


  let args = docopt(doc, version="v1.0.0")

  proc echoHeader(ipAddressFlag: bool = false,
                  cidrFlag: bool = false,
                  binFlag: bool = false,
                  maskFlag: bool = false,
                  delimiter: string = "\t"
                  ) =
    ## echoHeader はヘッダを出力する
    var s: string
    if ipAddressFlag:
      s.add("IPAddr" & delimiter)
    if cidrFlag:
      s.add("CIDR" & delimiter)
    if binFlag:
      s.add("Bin" & delimiter)
    if maskFlag:
      s.add("Mask" & delimiter)
    echo s

  proc echoValue(ipv4: IPv4,
                    ipAddressFlag: bool = false,
                    cidrFlag: bool = false,
                    binFlag: bool = false,
                    maskFlag: bool = false,
                    colorFlag: bool = false,
                    delimiter: string = "\t"
                    ) =
    ## echoValue はオプションに応じてIPv4の出力内容を変更して標準出力する
    if ipAddressFlag:
      stdout.write(ipv4.address, delimiter)
    if cidrFlag:
      stdout.write(ipv4.CIDR, delimiter)
    if binFlag:
      if colorFlag:
        let
          cidr = ipv4.CIDR
          b = ipv4.bin
          netdiv = b[0 ..< cidr]
          hostdiv = b[cidr .. b.len - 1]
        stdout.styledWrite(fgRed, netdiv)
        stdout.styledWrite(fgGreen, hostdiv)
        stdout.write(delimiter)
      else:
        stdout.write(ipv4.bin, delimiter)
    if maskFlag:
      stdout.write(ipv4.mask)
    stdout.write("\n")

  proc initLogger(debugFlag: bool) =
    ## initLoggerはロガーを初期化する
    ## オプション引数に指定があれば全ログレベルを出力するフラグをたてる
    var lvl: logging.Level
    if debugFlag:
      lvl = lvlAll
    else:
      lvl = lvlInfo
    var L = newConsoleLogger(lvl, fmtStr = "$datetime [$levelname]$appname:")
    addHandler(L)

  if isMainModule:
    let ipcidrs = @(args["<ip/cidr>"])
    var
      ipAddressFlag = ($args["--ipaddress"]).parseBool
      cidrFlag = ($args["--cidr"]).parseBool
      binFlag = ($args["--bin"]).parseBool
      maskFlag = ($args["--mask"]).parseBool
      colorFlag = ($args["--color"]).parseBool
      outDelimiter = ($args["--delimiter"]).replace("\\t", "\t")
      debugFlag = ($args["--debug"]).parseBool
      headerFlag = ($args["--header"]).parseBool

    initLogger debugFlag

    debug "args:", args
    
    # オプションがすべてfalseなら全部trueにする
    # wcコマンドと同じような設定のしかた
    if not ipAddressFlag and not cidrFlag and not binFlag and not maskFlag:
      ipAddressFlag = true
      cidrFlag = true
      binFlag = true
      maskFlag = true
    
    if headerFlag:
      echoHeader(ipAddressFlag = ipAddressFlag,
                cidrFlag = cidrFlag,
                binFlag = binFlag,
                maskFlag = maskFlag,
                delimiter = outDelimiter)

    # 引数指定がなければ標準入力を処理
    if ipcidrs.len < 1:
      debug "process stdin"
      var line: string
      while stdin.readLine line:
        try:
          let ipv4 = line.parseCIDR
          ipv4.echoValue(ipAddressFlag = ipAddressFlag,
                            cidrFlag = cidrFlag,
                            binFlag = binFlag,
                            maskFlag = maskFlag,
                            colorFlag = colorFlag,
                            delimiter = outDelimiter)
        except ValueError:
          warn "invalid value:", line, " and skiped calc."
      quit 0

    # 引数指定がアレば引数を処理
    debug "process args:", $ipcidrs
    for ipcidr in ipcidrs:
      try:
        let ipv4 = ipcidr.parseCIDR
        ipv4.echoValue(ipAddressFlag = ipAddressFlag,
                          cidrFlag = cidrFlag,
                          binFlag = binFlag,
                          maskFlag = maskFlag,
                          colorFlag = colorFlag,
                          delimiter = outDelimiter)
      except ValueError:
        warn "invalid value:", ipcidr, " and skiped calc."


