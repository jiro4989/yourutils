import strutils, strformat, terminal, logging, net

type
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
    subcal [options] <ip/cidr>...
    subcal [options]

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

proc parseIPv4Bin*(ip: string): string =
  ## parseIPv4Bin はIPアドレス文字列を2進数に変換して返す
  # パースに失敗したら例外を投げるのでそれを利用して書式チェック
  discard ip.parseIpAddress
  for ip in ip.split("."):
    let uip = ip.parseInt.toBin(8)
    result.add $uip
  
proc parseMask*(i: int): string =
  ## parseMask は2進数IPアドレスのマスクを返す
  var n = i
  if n < 0:
    n = 0
  elif 32 < n:
    n = 32
  let one = '1'.repeat(n)
  let zero = '0'.repeat(32 - n)
  result = $one & $zero

proc parseCIDR*(ipCIDR: string): IPv4 = 
  ## parseCIDRはIP/CIDR文字列をパースしてIPv4として返す
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
    bin = ip.parseIPv4Bin
    mask = cidr.parseMask
  result = IPv4(address: ip, CIDR: cidr, bin: bin, mask: mask)


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


