import unittest
import repeat
import strutils

doAssert "a".repeat(3) == "aaa"
doAssert "あ".repeat(3) == "あああ"

suite "repeatString":
  test "Delimiter is empty":
    check "A".repeatString([3], Options(delimiter: "")) == @["AAA"]
    check "あ".repeatString([3], Options(delimiter: "")) == @["あああ"]
  test "Delimiter is commma":
    check "A".repeatString([3], Options(delimiter: ",")) == @["A,A,A"]
    check "あ".repeatString([3], Options(delimiter: ",")) == @["あ,あ,あ"]
  test "Repeat counts is 2":
    check "B".repeatString([2, 3], Options(delimiter: ",")) == @["B,B", "B,B,B"]
  test "Repeat counts is empty":
    var empty: seq[string]
    check "あ".repeatString([], Options(delimiter: "")) == empty
  test "Repeat counts is 0":
    var empty: seq[string]
    check "あ".repeatString([0], Options(delimiter: "")) == empty
    check "あ".repeatString([0, 3], Options(delimiter: ",")) == @["あ,あ,あ"]

suite "main":
  var empty: seq[string]
  test "help":
    check main(@["-h"]) == empty
    check main(@["--help"]) == empty
    check main(@["--help", "1"]) == empty
  test "version":
    check main(@["-v"]) == empty
    check main(@["--version"]) == empty
    check main(@["--version", "1"]) == empty
  test "No options":
    check main(@["1", "A"]) == @["A"]
    check main(@["2", "A"]) == @["AA"]
  test "delimiter options":
    check main(@["2", "A", "-d:,"]) == @["A,A"]
    check main(@["2", "A", "-d:あ"]) == @["AあA"]
    check main(@["-d:あ", "2", "A"]) == @["AあA"]
    check main(@["--delimiter:あ", "3", "A"]) == @["AあAあA"]
    check main(@["--delimiter:あ", "3", "い"]) == @["いあいあい"]
  test "Two seq num":
    check main(@["2", "5", "A"]) == @["AA", "AAAAA"]
    check main(@["2", "5", "A", "-d:,"]) == @["A,A", "A,A,A,A,A"]
    check main(@["2", "5", "A", "-d:あ"]) == @["AあA", "AあAあAあAあA"]
    check main(@["2", "5", "--delimiter:あ", "A"]) == @["AあA", "AあAあAあAあA"]
    check main(@["--delimiter:あ", "2", "5", "漢字"]) == @["漢字あ漢字", "漢字あ漢字あ漢字あ漢字あ漢字"]
    check main(@["-X", "--delimiter:あ", "2", "5", "漢字"]) == @["漢字あ漢字", "漢字あ漢字あ漢字あ漢字あ漢字"]
    check main(@["--debug", "--delimiter:あ", "2", "5", "漢字"]) == @["漢字あ漢字", "漢字あ漢字あ漢字あ漢字あ漢字"]
  test "Seq num is 0":
    check main(@["0", "5", "A"]) == @["AAAAA"]
    check main(@["0", "-d:,", "5", "A"]) == @["A,A,A,A,A"]
    check main(@["0", "-d:,", "5", "漢字"]) == @["漢字,漢字,漢字,漢字,漢字"]
    check main(@["1", "-d:,", "5", "漢字"]) == @["漢字", "漢字,漢字,漢字,漢字,漢字"]
    check main(@["0", "-d:かんじ", "5", "漢字"]) == @["漢字かんじ漢字かんじ漢字かんじ漢字かんじ漢字"]
    check main(@["5", "1", "A"]) == @["AAAAA", "A"]