import strutils, net

type
  IPv4* = object
    address*: string
    cidr*: int
    bin*: string
    mask*: string

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

proc parseCidr*(ipCidr: string): IPv4 = 
  ## parseCIDRはIP/CIDR文字列をパースしてIPv4オブジェクトとして返す
  let ipc = ipCidr.split "/"
  let ip = ipc[0]
  var cidr = ipc[1].parseInt
  if cidr < 1:
    cidr = 1
  elif 32 < cidr:
    cidr = 32
  let bin = ip.toIPv4bin
  let mask = cidr.toMask
  result = IPv4(address: ip, cidr: cidr, bin: bin, mask: mask)

proc format(ipv4: IPv4, showIpAddress: bool, showCidr: bool,
            showIpBin: bool, showIpBinMask: bool,
            useColor: bool, delimiter: string): string =
  var col: seq[string]
  if showIpAddress: col.add(ipv4.address)
  if showCidr: col.add($ipv4.cidr)
  if showIpBin:
    if useColor:
      let bin = ipv4.bin
      let cidr = ipv4.cidr
      col.add("\e[31m" & bin[0..<cidr] & "\e[32m" & bin[cidr..^1] & "\e[m")
    else:
      col.add(ipv4.bin)
  if showIpBinMask: col.add(ipv4.mask)
  result = col.join(delimiter)

proc subnet(showIpAddress = true, showCidr = true,
            showIpBin = true, showIpBinMask = true,
            useColor=false, delimiter="\t", showHeader=true,
            args: seq[string]): int =
  # # オプションがすべてfalseなら全部trueにする
  # # wcコマンドと同じような設定のしかた
  # if not showIPAddress and not showCidr and not showIPBin and not showIPBinMask:
  #   showIPAddress = true
  #   showCIDR = true
  #   showIPBin = true
  #   showIPBinMask = true
  if showHeader:
    var header: seq[string]
    if showIpAddress: header.add("ip_address")
    if showCidr: header.add("cidr")
    if showIpBin: header.add("bin")
    if showIpBinMask: header.add("mask")
    echo header.join(delimiter)

  # 引数（ファイル）の指定がなければ標準入力を処理対象にする
  if args.len < 1:
    for line in stdin.lines:
      let ipv4 = line.parseCidr
      echo ipv4.format(showIpAddress=showIpAddress,
                       showCidr=showCidr,
                       showIpBin=showIpBin,
                       showIpBinMask=showIpBinMask,
                       useColor=useColor,
                       delimiter=delimiter)
    return

  # 引数があればそれを入力として扱う
  for arg in args:
    let ipv4 = arg.parseCidr
    echo ipv4.format(showIpAddress=showIpAddress,
                     showCidr=showCidr,
                     showIpBin=showIpBin,
                     showIpBinMask=showIpBinMask,
                     useColor=useColor,
                     delimiter=delimiter)

when isMainModule:
  import cligen
  dispatch(subnet)