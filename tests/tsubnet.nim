import unittest

import subnet
import strutils

doAssert "-1".split("-") == @["", "1"]

suite "parseIpNumber":
  var rep: seq[int]
  for i in 0..255:
    rep.add i
  test "0-255":
    check "0-255".parseIpNumber == rep
  test "2,3,4":
    check "2,3,4".parseIpNumber == @[2, 3, 4]
  test "-255":
    check "-255".parseIpNumber == rep
  test "20-":
    var rep: seq[int]
    for i in 20..255:
      rep.add i
    check "20-".parseIpNumber == rep
  test "1-3,19,253-":
    check "1-3,19,253-".parseIpNumber == @[1, 2, 3, 19, 253, 254, 255]

suite "toIPv4bin":
  test "正常系":
    check("00000000000000000000000000000001" == "0.0.0.1".toIPv4bin)
    check("00000000000000000000000100000001" == "0.0.1.1".toIPv4bin)
    check("00000000000000010000000100000001" == "0.1.1.1".toIPv4bin)
    check("00000001000000010000000100000001" == "1.1.1.1".toIPv4bin)
    check("00000000000000000000000000000010" == "0.0.0.2".toIPv4bin)
    check("00000000000000000000000011111111" == "0.0.0.255".toIPv4bin)
    check("11111111111111111111111111111111" == "255.255.255.255".toIPv4bin)
  test "異常系 .0.0.1": expect(ValueError): discard ".0.0.1".toIPv4bin
  test "異常系 0..0.1": expect(ValueError): discard "0..0.1".toIPv4bin
  test "異常系 0.0..1": expect(ValueError): discard "0.0..1".toIPv4bin
  test "異常系 0.0.1.": expect(ValueError): discard "0.0.1.".toIPv4bin
  test "異常系 0.0.1.x": expect(ValueError): discard "0.0.1.x".toIPv4bin
  test "異常系 0.0.1": expect(ValueError): discard "0.0.1".toIPv4bin

suite "toMask":
  test "00000000000000000000000000000000 < 1":
    check("00000000000000000000000000000000" == (-1).toMask)
    check("00000000000000000000000000000000" == 0.toMask)
  test "10000000000000000000000000000000 == 1":
    check("10000000000000000000000000000000" == 1.toMask)
  test "11000000000000000000000000000000 == 2":
    check("11000000000000000000000000000000" == 2.toMask)
  test "11111111111111111111111111111111 == 32":
    check("11111111111111111111111111111111" == 32.toMask)
  test "11111111111111111111111111111111 > 32":
    check("11111111111111111111111111111111" == 33.toMask)

suite "parseCidr":
  test "正常系":
    check(IPv4(address: "1.1.1.1", cidr: 1,
        bin: "00000001000000010000000100000001",
        mask: "10000000000000000000000000000000") == "1.1.1.1/1".parseCidr)
    check(IPv4(address: "1.1.1.1", cidr: 24,
        bin: "00000001000000010000000100000001",
        mask: "11111111111111111111111100000000") == "1.1.1.1/24".parseCidr)
    check(IPv4(address: "1.1.1.1", cidr: 32,
        bin: "00000001000000010000000100000001",
        mask: "11111111111111111111111111111111") == "1.1.1.1/32".parseCidr)
  test "異常系 Cidrが1未満":
    check(IPv4(address: "1.1.1.1", cidr: 1,
        bin: "00000001000000010000000100000001",
        mask: "10000000000000000000000000000000") == "1.1.1.1/0".parseCidr)
    check(IPv4(address: "1.1.1.1", cidr: 1,
        bin: "00000001000000010000000100000001",
        mask: "10000000000000000000000000000000") == "1.1.1.1/-1".parseCidr)
  test "異常系 1.1.1.1/33":
    check(IPv4(address: "1.1.1.1", cidr: 32,
        bin: "00000001000000010000000100000001",
        mask: "11111111111111111111111111111111") == "1.1.1.1/33".parseCidr)
  test "異常系 .1.1.1/24":
    expect(ValueError):
      discard ".1.1.1/24".parseCidr
