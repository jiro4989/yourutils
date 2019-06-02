import unittest

import subnet

suite "parseBin":
  test "正常系":
    check("00000000000000000000000000000001" == "0.0.0.1".parseIPv4Bin)
    check("00000000000000000000000100000001" == "0.0.1.1".parseIPv4Bin)
    check("00000000000000010000000100000001" == "0.1.1.1".parseIPv4Bin)
    check("00000001000000010000000100000001" == "1.1.1.1".parseIPv4Bin)
    check("00000000000000000000000000000010" == "0.0.0.2".parseIPv4Bin)
    check("00000000000000000000000011111111" == "0.0.0.255".parseIPv4Bin)
    check("11111111111111111111111111111111" == "255.255.255.255".parseIPv4Bin)
  test "異常系 .0.0.1": expect(ValueError): discard ".0.0.1".parseIPv4Bin
  test "異常系 0..0.1": expect(ValueError): discard "0..0.1".parseIPv4Bin
  test "異常系 0.0..1": expect(ValueError): discard "0.0..1".parseIPv4Bin
  test "異常系 0.0.1.": expect(ValueError): discard "0.0.1.".parseIPv4Bin
  test "異常系 0.0.1.x": expect(ValueError): discard "0.0.1.x".parseIPv4Bin
  test "異常系 0.0.1": expect(ValueError): discard "0.0.1".parseIPv4Bin

suite "parseMask":
  test "00000000000000000000000000000000 < 1":
    check("00000000000000000000000000000000" == (-1).parseMask)
    check("00000000000000000000000000000000" == 0.parseMask)
  test "10000000000000000000000000000000 == 1":
    check("10000000000000000000000000000000" == 1.parseMask)
  test "11000000000000000000000000000000 == 2":
    check("11000000000000000000000000000000" == 2.parseMask)
  test "11111111111111111111111111111111 == 32":
    check("11111111111111111111111111111111" == 32.parseMask)
  test "11111111111111111111111111111111 > 32":
    check("11111111111111111111111111111111" == 33.parseMask)

suite "parseCIDR":
  test "正常系":
    check(IPv4(address: "1.1.1.1", CIDR: 1, bin: "00000001000000010000000100000001", mask:"10000000000000000000000000000000") == "1.1.1.1/1".parseCIDR)
    check(IPv4(address: "1.1.1.1", CIDR: 24, bin: "00000001000000010000000100000001", mask:"11111111111111111111111100000000") == "1.1.1.1/24".parseCIDR)
    check(IPv4(address: "1.1.1.1", CIDR: 32, bin: "00000001000000010000000100000001", mask:"11111111111111111111111111111111") == "1.1.1.1/32".parseCIDR)
  test "異常系 CIDRが1未満":
    check(IPv4(address: "1.1.1.1", CIDR: 1, bin: "00000001000000010000000100000001", mask:"10000000000000000000000000000000") == "1.1.1.1/0".parseCIDR)
    check(IPv4(address: "1.1.1.1", CIDR: 1, bin: "00000001000000010000000100000001", mask:"10000000000000000000000000000000") == "1.1.1.1/-1".parseCIDR)
  test "異常系 1.1.1.1/33":
    check(IPv4(address: "1.1.1.1", CIDR: 32, bin: "00000001000000010000000100000001", mask:"11111111111111111111111111111111") == "1.1.1.1/33".parseCIDR)
  test "異常系 .1.1.1/24":
    expect(ValueError):
      discard ".1.1.1/24".parseCIDR